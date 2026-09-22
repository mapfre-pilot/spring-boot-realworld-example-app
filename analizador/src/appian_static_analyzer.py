#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Analizador estático de paquetes de Appian · Gate de despliegue a PRO
====================================================================

Analiza uno o varios paquetes de exportación de Appian (.zip o directorio
extraído), detecta buenas y malas prácticas de diseño, evalúa el checklist
corporativo previo al paso a PRO y genera un informe estructurado (JSON y
opcionalmente CSV) pensado para consumirse desde una aplicación de Appian
(a!fromJson sobre el documento) y pintarse en el informe que se envía a los
desarrolladores.

Uso básico:
    python3 appian_static_analyzer.py paquete.zip
    python3 appian_static_analyzer.py app1.zip app2.zip app3.zip --output-dir informes/
    python3 appian_static_analyzer.py paquete.zip --csv
    python3 appian_static_analyzer.py paquete.zip --prefix ACME --fail-on HIGH --gate

Entradas opcionales:
    --health-check hc.xlsx|hc.csv|hc.json
                                    Informe de Health Check de Appian: cruza
                                    los riesgos High/Medium con los objetos
                                    del paquete. Si no se pasa, el gate G02
                                    queda en revisión manual.
    --perf-results perf.json|csv    Resultados de pruebas de rendimiento
                                    (name/status) para el gate G06.
    --justifications just.json      Justificaciones a OT por check, por
                                    objeto ("CHECK:Objeto"), por gate ("G03")
                                    o genéricas por check ("PM-008"). Los
                                    valores pueden ser texto o un objeto
                                    {text, approver, date}. No se valida
                                    firma: se audita texto/approver/fecha.
    --config config.json            Umbrales, ventana batch, severidades,
                                    forbiddenAlertGroups, qualityGate,
                                    minCoverage, allowGenericJustifications...

Salidas adicionales:
    --verdict-json verdict.json     Resumen mínimo del veredicto y gates.
    --markdown resumen.md           Resumen para $GITHUB_STEP_SUMMARY o
                                    comentario de PR.

Códigos de salida con --gate: APTO=0, APTO_CON_CONDICIONES=3, NO_APTO=1,
ERROR=2 (zip ilegible, Health Check ilegible cuando se pasó, o cobertura
por debajo de minCoverage). Sin --gate: 0 salvo ERROR=2.

Estructura del JSON de salida:
    report                    metadatos de la ejecución
    summary                   score 0-100, totales por severidad/categoría/tipo
    deploymentGate            veredicto APTO / APTO_CON_CONDICIONES / NO_APTO /
                              ERROR y el detalle de cada control del checklist
    monitoringRecommendations recomendaciones de monitorización por tipo de
                              objeto desplegado
    healthCheck               estado y riesgos del HC cruzados con el paquete
    analysis                  errores, warnings, parseErrors y cobertura
    justifications            justificaciones aplicadas/ignoradas/pendientes
    objects                   inventario de objetos analizados
    findings                  hallazgos (checkId, severidad, objeto, línea,
                              snippet, mensaje, recomendación, justificación)
    checksCatalog             catálogo de las comprobaciones aplicadas

Solo usa la librería estándar de Python (3.8+). No modifica el paquete.

Referencias: Appian Design Guidance, Health Check Report y guías de buenas
prácticas oficiales (docs.appian.com).
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from collections import Counter
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from typing import Dict, List, Optional, Tuple

VERSION = "3.0.0"

# ---------------------------------------------------------------------------
# Catálogo de comprobaciones
# ---------------------------------------------------------------------------

SEVERITY_ORDER = {"HIGH": 0, "MEDIUM": 1, "LOW": 2, "INFO": 3}
SEVERITY_LABEL = {"HIGH": "Alta", "MEDIUM": "Media", "LOW": "Baja", "INFO": "Informativa"}
SEVERITY_WEIGHT = {"HIGH": 8.0, "MEDIUM": 3.0, "LOW": 1.0, "INFO": 0.0}

CATEGORY_LABEL = {
    "PERFORMANCE": "Rendimiento",
    "MAINTAINABILITY": "Mantenibilidad",
    "NAMING": "Nomenclatura",
    "DOCUMENTATION": "Documentación",
    "SECURITY": "Seguridad",
    "DEPRECATION": "Obsolescencia",
    "PROCESS": "Modelos de proceso",
    "DATA": "Tipos de datos",
    "GOVERNANCE": "Gobierno / Gate PRO",
    "HEALTHCHECK": "Health Check",
    "GUIDANCE": "Design Guidance de Appian",
}

CHECKS: Dict[str, Dict[str, str]] = {
    # --- Obsolescencia -----------------------------------------------------
    "DEP-001": dict(
        title="Uso de load() / with() (obsoletos)",
        category="DEPRECATION", severity="HIGH",
        description="Las funciones load() y with() están obsoletas y su comportamiento de reevaluación es difícil de razonar.",
        recommendation="Sustituir por a!localVariables(), que unifica ambas y permite refrescos controlados con a!refreshVariable().",
        reference="https://docs.appian.com/suite/help/latest/fnc_evaluation_a_localvariables.html",
    ),
    "DEP-002": dict(
        title="Función no soportada o interna",
        category="DEPRECATION", severity="MEDIUM",
        description="Se usa una función no documentada/no soportada por Appian, que puede dejar de funcionar en cualquier versión.",
        recommendation="Refactorizar usando únicamente funciones documentadas de Appian.",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    # --- Rendimiento --------------------------------------------------------
    "PRF-001": dict(
        title="Consulta sin paginación acotada (batchSize -1)",
        category="PERFORMANCE", severity="HIGH",
        description="a!queryEntity / a!queryRecordType con batchSize -1 recupera todas las filas y puede agotar memoria con volúmenes grandes.",
        recommendation="Usar a!pagingInfo con un batchSize acotado y filtrar/paginar en la fuente de datos.",
        reference="https://docs.appian.com/suite/help/latest/Query_Recipes.html",
    ),
    "PRF-002": dict(
        title="Consulta dentro de una función de iteración",
        category="PERFORMANCE", severity="HIGH",
        description="Ejecutar consultas dentro de a!forEach/apply/reduce genera N consultas (patrón N+1).",
        recommendation="Sacar la consulta fuera del bucle: consultar una sola vez con un filtro 'in' y cruzar los datos en memoria.",
        reference="https://docs.appian.com/suite/help/latest/expressions-best-practices.html",
    ),
    "PRF-003": dict(
        title="fetchTotalCount activado",
        category="PERFORMANCE", severity="LOW",
        description="fetchTotalCount: true fuerza un count(*) adicional en cada ejecución de la consulta.",
        recommendation="Activarlo solo cuando el total sea imprescindible (p. ej. paginación con total exacto).",
        reference="https://docs.appian.com/suite/help/latest/Query_Entity_Function.html",
    ),
    "PRF-004": dict(
        title="Escritura dentro de a!forEach",
        category="PERFORMANCE", severity="MEDIUM",
        description="Ejecutar a!writeRecords/a!writeToDataStoreEntity/a!startProcess dentro del cuerpo de a!forEach lanza N escrituras.",
        recommendation="Acumular los valores en el bucle y escribir una sola vez fuera de él.",
        reference="https://docs.appian.com/suite/help/latest/expressions-best-practices.html",
    ),
    "PRF-005": dict(
        title="Expresión demasiado grande",
        category="MAINTAINABILITY", severity="MEDIUM",
        description="Expresiones muy largas son difíciles de revisar, probar y reutilizar.",
        recommendation="Descomponer en reglas de expresión reutilizables con una única responsabilidad.",
        reference="https://docs.appian.com/suite/help/latest/expressions-best-practices.html",
    ),
    # --- Mantenibilidad ------------------------------------------------------
    "MNT-001": dict(
        title="if() anidados (3 o más niveles)",
        category="MAINTAINABILITY", severity="LOW",
        description="Cadenas de if() anidados dificultan la lectura y el mantenimiento.",
        recommendation="Usar a!match() (o un if() con listas de condiciones/valores) para expresar la lógica condicional.",
        reference="https://docs.appian.com/suite/help/latest/fnc_evaluation_a_match.html",
    ),
    "MNT-002": dict(
        title="Identificador hardcodeado (UUID / ID numérico)",
        category="MAINTAINABILITY", severity="MEDIUM",
        description="UUIDs o IDs numéricos escritos en la expresión se rompen al desplegar entre entornos.",
        recommendation="Crear una constante para el objeto y referenciarla con cons!.",
        reference="https://docs.appian.com/suite/help/latest/Constants.html",
    ),
    "MNT-003": dict(
        title="URL hardcodeada",
        category="MAINTAINABILITY", severity="MEDIUM",
        description="Las URLs escritas en la expresión suelen ser específicas de entorno y quedan fuera del control de despliegue.",
        recommendation="Mover la URL a una constante específica de entorno o a un Connected System si es una integración.",
        reference="https://docs.appian.com/suite/help/latest/Managing_Import_Customization_Files.html",
    ),
    "MNT-004": dict(
        title="if(condición, true, false) redundante",
        category="MAINTAINABILITY", severity="LOW",
        description="Devolver true/false desde un if() es redundante: la propia condición ya es booleana.",
        recommendation="Devolver directamente la condición (o su negación con not()).",
        reference="https://docs.appian.com/suite/help/latest/expressions-best-practices.html",
    ),
    "MNT-005": dict(
        title="Demasiadas entradas de regla (rule inputs)",
        category="MAINTAINABILITY", severity="LOW",
        description="Un número alto de rule inputs sugiere que la regla tiene demasiadas responsabilidades.",
        recommendation="Agrupar parámetros relacionados en un CDT/mapa o dividir la regla.",
        reference="https://docs.appian.com/suite/help/latest/expressions-best-practices.html",
    ),
    "MNT-006": dict(
        title="Entrada de regla sin usar",
        category="MAINTAINABILITY", severity="LOW",
        description="La entrada (ri!) no se referencia en la definición del objeto (guía oficial: 'Unused rule input').",
        recommendation="Eliminar la entrada si está confirmado que no se usa.",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    "MNT-007": dict(
        title="Variable local sin usar",
        category="MAINTAINABILITY", severity="LOW",
        description="Variable local declarada pero nunca referenciada (guía oficial: 'Unused local variable'); puede ejecutar consultas innecesarias.",
        recommendation="Eliminar la variable local; si carga datos, la consulta se ejecuta aunque no se use.",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    "MNT-008": dict(
        title="Recursión directa",
        category="MAINTAINABILITY", severity="MEDIUM",
        description="La regla se invoca a sí misma. La recursión en SAIL es frágil (límites de profundidad) y difícil de depurar.",
        recommendation="Sustituir por funciones de iteración (a!forEach, reduce) siempre que sea posible.",
        reference="https://docs.appian.com/suite/help/latest/Looping_Functions.html",
    ),
    "MNT-009": dict(
        title="Comentario TODO/FIXME pendiente",
        category="MAINTAINABILITY", severity="INFO",
        description="Hay trabajo pendiente marcado en comentarios que va a desplegarse a producción.",
        recommendation="Resolver el TODO/FIXME o registrar la deuda técnica en el backlog y retirar el comentario.",
        reference="",
    ),
    # --- Nomenclatura y documentación ---------------------------------------
    "NAM-001": dict(
        title="Objeto sin el prefijo de la aplicación",
        category="NAMING", severity="LOW",
        description="El objeto no sigue el prefijo dominante de la aplicación.",
        recommendation="Renombrar el objeto con el prefijo acordado (p. ej. ACME_nombreObjeto).",
        reference="https://docs.appian.com/suite/help/latest/standards-configure.html",
    ),
    "NAM-002": dict(
        title="Nomenclatura de constante incorrecta",
        category="NAMING", severity="LOW",
        description="Las constantes deben nombrarse en mayúsculas con guiones bajos (PREFIJO_NOMBRE_CONSTANTE).",
        recommendation="Renombrar la constante siguiendo el patrón PREFIJO_MAYUSCULAS_CON_GUIONES.",
        reference="https://docs.appian.com/suite/help/latest/standards-configure.html",
    ),
    "NAM-003": dict(
        title="Nomenclatura de entrada de regla incorrecta",
        category="NAMING", severity="INFO",
        description="Las entradas de regla deberían ir en camelCase empezando en minúscula.",
        recommendation="Renombrar la entrada a camelCase (p. ej. customerId).",
        reference="https://docs.appian.com/suite/help/latest/standards-configure.html",
    ),
    "DOC-001": dict(
        title="Objeto sin descripción",
        category="DOCUMENTATION", severity="LOW",
        description="El objeto no tiene descripción; los siguientes desarrolladores no sabrán su propósito sin abrirlo.",
        recommendation="Añadir una descripción breve con el propósito del objeto.",
        reference="https://docs.appian.com/suite/help/latest/standards-configure.html",
    ),
    # --- Seguridad ------------------------------------------------------------
    "SEC-001": dict(
        title="Usuarios asignados directamente en la seguridad del objeto",
        category="SECURITY", severity="MEDIUM",
        description="La seguridad del objeto asigna roles a usuarios individuales en lugar de a grupos.",
        recommendation="Asignar la seguridad siempre mediante grupos.",
        reference="https://docs.appian.com/suite/help/latest/object-security.html",
    ),
    "SEC-002": dict(
        title="Nombre de usuario hardcodeado",
        category="SECURITY", severity="MEDIUM",
        description="Comparar loggedInUser() con un literal o construir user(\"...\") acopla la lógica a personas concretas.",
        recommendation="Usar pertenencia a grupos (a!isUserMemberOfGroup) con grupos referenciados por constante.",
        reference="https://docs.appian.com/suite/help/latest/object-security.html",
    ),
    "SEC-003": dict(
        title="Posible credencial en el código",
        category="SECURITY", severity="HIGH",
        description="Se ha detectado un literal que parece una contraseña, token o clave de API dentro de una expresión.",
        recommendation="Mover las credenciales a un Connected System o a los valores seguros de la Admin Console.",
        reference="https://docs.appian.com/suite/help/latest/Connected_System_Object.html",
    ),
    "SEC-004": dict(
        title="Constante con contraseña/credencial (gate G09)",
        category="SECURITY", severity="HIGH",
        description="Norma corporativa: no se permiten constantes con contraseñas, tokens o claves. Bloquea el paso a PRO.",
        recommendation="Sustituir la constante por un Connected System (o secured value de la Admin Console) y eliminarla del paquete.",
        reference="https://docs.appian.com/suite/help/latest/Connected_System_Object.html",
    ),
    # --- Modelos de proceso ----------------------------------------------------
    "PM-001": dict(
        title="Modelo de proceso con demasiados nodos",
        category="PROCESS", severity="MEDIUM",
        description="Guía oficial: más de 50 nodos por modelo dificulta el mantenimiento y afecta al rendimiento del motor.",
        recommendation="Dividir en subprocesos con responsabilidades claras o combinar nodos redundantes.",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    "PM-002": dict(
        title="Demasiadas variables de proceso",
        category="PROCESS", severity="MEDIUM",
        description="Health Check: 100+ variables de proceso es riesgo medio y 300+ riesgo alto; cada instancia las arrastra en memoria.",
        recommendation="Convertir variables a parámetros de nodo (activity class parameters) o dividir el proceso.",
        reference="https://docs.appian.com/suite/help/latest/understanding-the-health-check-report.html",
    ),
    "PM-003": dict(
        title="Variable de proceso sin usar",
        category="PROCESS", severity="LOW",
        description="La variable no se referencia en el modelo (puede usarse en informes: confirmar antes de borrar).",
        recommendation="Eliminar la variable si se confirma que ningún nodo ni informe la usa.",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    "PM-004": dict(
        title="Cadena de actividades (chaining) muy larga",
        category="PROCESS", severity="MEDIUM",
        description="Appian limita el chaining a 50 nodos y las cadenas largas bloquean al usuario mientras se ejecutan.",
        recommendation="Reducir el chaining al mínimo necesario entre formularios.",
        reference="https://docs.appian.com/suite/help/latest/Process_Model_Best_Practices.html",
    ),
    "PM-005": dict(
        title="Nodo que requiere revisión (SQL directo / servicio sensible)",
        category="PROCESS", severity="INFO",
        description="El modelo usa nodos 'Query Database' o 'Execute Stored Procedure' que ejecutan SQL directamente.",
        recommendation="Revisar que el SQL esté parametrizado y valorar sustituirlo por entidades/record types.",
        reference="https://docs.appian.com/suite/help/latest/Smart_Services.html",
    ),
    "PM-006": dict(
        title="MNI (múltiples instancias de nodo) detectado",
        category="PROCESS", severity="INFO",
        description="El uso de MNI, especialmente con chaining, es un patrón desaconsejado por la guía oficial de diseño.",
        recommendation="Valorar rediseñar como operación en bloque o subprocesos asíncronos.",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    "PM-007": dict(
        title="Proceso sin grupo de alertas propio (gate G03)",
        category="GOVERNANCE", severity="MEDIUM",
        description="Norma corporativa: todo proceso debe enviar sus alertas a un grupo de soporte propio, nunca a los administradores por defecto.",
        recommendation="Configurar en el modelo un grupo de alertas específico de la aplicación (referenciado por constante) distinto de administradores.",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    "PM-008": dict(
        title="Borrado de instancias no configurado o superior a 3 días (gate G04)",
        category="GOVERNANCE", severity="HIGH",
        description="Norma corporativa: las instancias de proceso deben borrarse (delete) en menos de 3 días tras completarse.",
        recommendation="En Data Management del modelo, configurar 'Delete processes N days after completion' con N <= 3 (o justificar a OT la retención).",
        reference="https://docs.appian.com/suite/help/latest/understanding-the-health-check-report.html",
    ),
    "PM-009": dict(
        title="Tarea de usuario sin excepción de tiempo <= 1 día (gate G07)",
        category="GOVERNANCE", severity="MEDIUM",
        description="Norma corporativa: toda tarea de usuario debe tener una excepción/escalado temporal configurado y menor o igual a 1 día.",
        recommendation="Añadir un timer de excepción o escalado a la tarea con duración <= 1 día (o justificar a OT).",
        reference="https://docs.appian.com/suite/help/latest/process-node-and-smart-service-properties.html",
    ),
    "PM-010": dict(
        title="Proceso batch programado fuera de la ventana prohibida",
        category="GOVERNANCE", severity="INFO",
        description="Proceso batch detectado con horario fuera de la ventana 06:30-22:00; se anota la hora para revisar que coincide con la de menor carga.",
        recommendation="Confirmar el horario de menor carga en Site Gestión de Procesos > Batch model process management.",
        reference="",
    ),
    "PM-011": dict(
        title="Proceso batch programado en horario prohibido (gate G10)",
        category="GOVERNANCE", severity="HIGH",
        description="Norma corporativa: los procesos batch no pueden programarse entre las 06:30 y las 22:00. También marca en revisión los horarios no verificables (expresiones, zona horaria dinámica).",
        recommendation="Reprogramar fuera de la ventana 06:30-22:00 y revisar el horario de menor carga en Site Gestión de Procesos > Batch model process management.",
        reference="",
    ),
    "PM-012": dict(
        title="Grupo de alertas de administración de aplicación",
        category="GOVERNANCE", severity="INFO",
        description="El grupo de alertas del proceso es un grupo de administradores propio de la aplicación (no bloquea).",
        recommendation="Confirmar que el grupo no es el de administradores de plataforma.",
        reference="",
    ),
    "PM-013": dict(
        title="Timer recurrente intra-proceso",
        category="PROCESS", severity="INFO",
        description="Timer recurrente en un nodo distinto del Start (bucle de polling); no se evalúa como proceso batch.",
        recommendation="Verificar que el intervalo de polling es razonable y no satura el motor.",
        reference="",
    ),
    # --- Record types -----------------------------------------------------------
    "REC-001": dict(
        title="Record sincronizado con full sync diario (gate G08)",
        category="GOVERNANCE", severity="MEDIUM",
        description="Norma corporativa: un record de base de datos bien diseñado no debería necesitar una sincronización completa diaria.",
        recommendation="Revisar el diseño del sync (sync incremental en escrituras, source filters) y eliminar el full sync programado diario, o justificar a OT.",
        reference="https://docs.appian.com/suite/help/latest/records-sync.html",
    ),
    "REC-002": dict(
        title="Record sincronizado sobre fuente RDBMS",
        category="DATA", severity="INFO",
        description="El record está sincronizado (RecordsReplica) sobre una fuente de base de datos: recordar los límites de filas sincronizadas.",
        recommendation="Vigilar el número de filas sincronizadas y el crecimiento de la fuente (límites del record sync).",
        reference="https://docs.appian.com/suite/help/latest/records-sync.html",
    ),
    # --- Tipos de datos ----------------------------------------------------------
    "DAT-001": dict(
        title="Tipo de datos con demasiados campos",
        category="DATA", severity="LOW",
        description="Guía oficial: un CDT con más de 100 campos es difícil de mantener.",
        recommendation="Mover campos a tipos relacionados (relaciones planas con campos ID).",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    "ENV-001": dict(
        title="Constante con valor específico de entorno",
        category="MAINTAINABILITY", severity="INFO",
        description="La constante contiene una URL u otro valor que probablemente cambie entre entornos.",
        recommendation="Marcarla como específica de entorno y gestionarla con el fichero de personalización de importación (.properties).",
        reference="https://docs.appian.com/suite/help/latest/Managing_Import_Customization_Files.html",
    ),
    # --- Gobierno / paquete --------------------------------------------------------
    "DEPN-001": dict(
        title="Objeto sin dependencias dentro de la aplicación (gate G05)",
        category="GOVERNANCE", severity="LOW",
        description="Ningún otro objeto del export referencia a este objeto. Norma corporativa: los objetos sin dependencias deben borrarse antes del paso a PRO.",
        recommendation="Confirmar con la vista de dependencias de Appian (puede estar referenciado desde otra aplicación); si no tiene usos, borrarlo o justificar a OT su permanencia.",
        reference="https://docs.appian.com/suite/help/latest/viewing-object-dependents-and-precedents.html",
    ),
    "DEPN-002": dict(
        title="Dependencias externas no verificables con un paquete parcial",
        category="GOVERNANCE", severity="LOW",
        description="Al ser un paquete/parche (no una aplicación completa), no se pueden verificar las dependencias externas de este objeto.",
        recommendation="Confirmar en Appian que el objeto sigue siendo necesario antes de desplegarlo.",
        reference="https://docs.appian.com/suite/help/latest/viewing-object-dependents-and-precedents.html",
    ),
    "HC-001": dict(
        title="Riesgo ALTO de Health Check sobre un objeto del paquete (gate G02)",
        category="HEALTHCHECK", severity="HIGH",
        description="El informe de Health Check de Appian reporta un riesgo alto sobre un objeto incluido en este despliegue.",
        recommendation="Resolver el riesgo señalado por el Health Check antes del paso a PRO o justificar a OT.",
        reference="https://docs.appian.com/suite/help/latest/understanding-the-health-check-report.html",
    ),
    "HC-002": dict(
        title="Riesgo de Health Check sobre la aplicación desplegada",
        category="HEALTHCHECK", severity="INFO",
        description="El informe de Health Check reporta un riesgo sobre la aplicación que se despliega (no sobre un objeto concreto).",
        recommendation="Revisar el riesgo señalado a nivel de aplicación y planificar su corrección.",
        reference="https://docs.appian.com/suite/help/latest/understanding-the-health-check-report.html",
    ),
    "HC-003": dict(
        title="Riesgo de plataforma reportado por Health Check",
        category="HEALTHCHECK", severity="INFO",
        description="El informe de Health Check reporta riesgos que no citan ningún objeto del paquete ni la aplicación (riesgos de plataforma).",
        recommendation="Trasladar los riesgos de plataforma al equipo correspondiente.",
        reference="https://docs.appian.com/suite/help/latest/understanding-the-health-check-report.html",
    ),
    "PRT-001": dict(
        title="Prueba de rendimiento no satisfactoria (gate G06)",
        category="GOVERNANCE", severity="HIGH",
        description="Los resultados de pruebas de rendimiento aportados contienen pruebas fallidas.",
        recommendation="Repetir las pruebas tras corregir el rendimiento o justificar a OT la desviación.",
        reference="",
    ),
    "ADG-001": dict(
        title="Design guidance de Appian activa en el objeto",
        category="GUIDANCE", severity="MEDIUM",
        description="El propio Appian marca una recomendación/aviso de diseño sin resolver sobre este objeto (META-INF/design-guidance.json del paquete).",
        recommendation="Abrir el objeto en Appian Designer, revisar la guidance indicada y corregirla antes del paso a PRO.",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    "ADG-002": dict(
        title="Design guidance descartada (dismissed) por el desarrollador",
        category="GUIDANCE", severity="INFO",
        description="El desarrollador descartó una recomendación de diseño de Appian sobre este objeto. Norma corporativa: los desacuerdos se justifican a OT.",
        recommendation="Documentar a OT el motivo del descarte de la guidance o restaurarla y corregirla.",
        reference="https://docs.appian.com/suite/help/25.2/appian-recommendations.html",
    ),
    "PKG-001": dict(
        title="Fichero del paquete no analizable",
        category="MAINTAINABILITY", severity="INFO",
        description="No se pudo interpretar un fichero XML del paquete; se excluye del análisis.",
        recommendation="Revisar manualmente el fichero indicado.",
        reference="",
    ),
    "PKG-002": dict(
        title="El inventario analizado no cuadra con el manifiesto del paquete",
        category="MAINTAINABILITY", severity="LOW",
        description="El número de objetos analizados no coincide con los declarados en el manifiesto del export.",
        recommendation="Comprobar que el export está completo y reportar el desajuste para ajustar el analizador si es un tipo de objeto no soportado.",
        reference="",
    ),
    "PKG-003": dict(
        title="Objeto no analizable",
        category="MAINTAINABILITY", severity="MEDIUM",
        description="El XML del objeto no se pudo interpretar; los controles sobre ese objeto quedan en revisión manual.",
        recommendation="Revisar manualmente el objeto indicado y regenerar el export si está corrupto.",
        reference="",
    ),
    "PRF-006": dict(
        title="a!forEach anidados (3 o más niveles)",
        category="PERFORMANCE", severity="MEDIUM",
        description="Bucles anidados a 3+ niveles suelen indicar complejidad O(n³) y expresiones difíciles de mantener.",
        recommendation="Aplanar los datos, precalcular índices/mapas o delegar el cruce a la consulta.",
        reference="https://docs.appian.com/suite/help/latest/expressions-best-practices.html",
    ),
    "ENV-002": dict(
        title="Valor de entorno sin fichero de personalización",
        category="MAINTAINABILITY", severity="MEDIUM",
        description="Constante marcada como específica de entorno o Connected System con valor cifrado (EncryptedText) cuyo valor no está definido en ningún fichero .properties del paquete.",
        recommendation="Añadir la clave con un valor no vacío en el fichero de personalización de importación (.properties).",
        reference="https://docs.appian.com/suite/help/latest/Managing_Import_Customization_Files.html",
    ),
    "SEC-005": dict(
        title="Posible acceso público/anónimo",
        category="SECURITY", severity="HIGH",
        description="Web API, Site o Portal cuyo XML indica acceso público o anónimo (sin autenticación).",
        recommendation="Confirmar que el acceso anónimo es intencionado y revisar la exposición de datos.",
        reference="https://docs.appian.com/suite/help/latest/object-security.html",
    ),
    "SEC-006": dict(
        title="Constante con nombre de credencial pero valor tipo identificador",
        category="SECURITY", severity="MEDIUM",
        description="El nombre sugiere credencial (SECRET/TOKEN/PASSWORD...) pero el valor es un slug o identificador (kebab-case, snake_case) sin pinta de secreto. No bloquea el gate G09.",
        recommendation="Confirmar que el valor es realmente un identificador y no una credencial; si lo es, mover a un Connected System.",
        reference="https://docs.appian.com/suite/help/latest/Connected_System_Object.html",
    ),
    "NAM-004": dict(
        title="Objeto con un prefijo distinto al de la aplicación",
        category="NAMING", severity="LOW",
        description="El objeto usa un prefijo propio que no coincide con el prefijo dominante de la aplicación.",
        recommendation="Unificar el prefijo con el de la aplicación o documentar el motivo del prefijo distinto.",
        reference="https://docs.appian.com/suite/help/latest/standards-configure.html",
    ),
}

QUERY_FUNCS = {
    "a!queryentity", "a!queryrecordtype", "a!queryprocessanalytics",
    "a!executestoredprocedureforquery", "queryrecord",
}
WRITE_FUNCS = {
    "a!writerecords", "a!writetodatastoreentity", "a!startprocess",
    "a!writetomultipledatastoreentities",
}
LOOP_FUNCS = {"a!foreach", "apply", "reduce", "a!applycomponents"}
UNSUPPORTED_FUNCS = {
    "getcontentobjectdetailsbyid", "getprocessmodeldetailsbyuuid",
    "queryrecord", "queryrule", "webservicequery", "webservicewrite",
}

CREDENTIAL_NAME_RE = re.compile(
    r"(PASSWORD|PASSWD|PWD|SECRET|TOKEN|API[_-]?KEY|CREDENTIAL|CONTRASE|CLAVE|PRIVATE[_-]?KEY)", re.I)

DEFAULT_THRESHOLDS = dict(
    max_expression_lines=2000,
    max_expression_chars=150000,
    max_rule_inputs=25,
    max_pm_nodes=30,
    max_pm_variables=50,
    max_pm_variables_high=300,
    max_cdt_fields=25,
    max_chained_flows=30,
    max_if_depth=3,
    max_foreach_depth=3,
    max_instance_cleanup_days=3,
    max_user_task_escalation_days=1,
)

DEFAULT_BATCH_WINDOW = ("06:30", "22:00")  # ventana PROHIBIDA para batch

DEFAULT_FORBIDDEN_ALERT_GROUPS = dict(
    uuids=["SYSTEM_GROUP_ADMINISTRATORS"],
    names=["Administrators", "Administradores", "Process Administrators"],
)

DEFAULT_MIN_COVERAGE = 0.9
DEFAULT_HC_MAX_AGE_DAYS = 10

MAX_ZIP_BYTES = 200 * 1024 * 1024
MAX_ENTRY_BYTES = 50 * 1024 * 1024
MAX_ENTRIES = 20000

# ---------------------------------------------------------------------------
# Gates corporativos (checklist previo al paso a PRO)
# ---------------------------------------------------------------------------

GATE_STATUS_LABEL = {
    "PASS": "Cumple",
    "FAIL": "No cumple",
    "REVIEW": "Revisión manual",
    "JUSTIFIED": "Justificado a OT",
    "NA": "No aplica",
}

GATES: List[Dict] = [
    dict(id="G01", checks=[], title="Recomendaciones de monitorización revisadas",
         detail="Revisar y aplicar las recomendaciones de monitorización de los objetos que se despliegan (sección monitoringRecommendations)."),
    dict(id="G02", checks=["HC-001", "PKG-003"], title="Sin riesgos ALTOS de Health Check en los objetos del paquete",
         detail="Cruce del informe de Health Check con los objetos del despliegue."),
    dict(id="G03", checks=["PM-007", "PKG-003"], title="Procesos con grupo de alertas propio (no administradores)",
         detail="Todo modelo de proceso debe tener configurado un grupo de alertas distinto de los administradores."),
    dict(id="G04", checks=["PM-008", "PKG-003"], title="Borrado de instancias de proceso <= 3 días",
         detail="Data Management de cada modelo con borrado (delete) de instancias inferior a 3 días."),
    dict(id="G05", checks=["DEPN-001", "DEPN-002", "PKG-003"], title="Sin objetos sin dependencias",
         detail="Los objetos que no referencia nadie deben borrarse del paquete o justificarse a OT."),
    dict(id="G06", checks=["PRT-001"], title="Pruebas de rendimiento satisfactorias",
         detail="Resultados de pruebas de rendimiento aportados con --perf-results."),
    dict(id="G07", checks=["PM-009", "PKG-003"], title="Tareas de usuario con excepción de tiempo <= 1 día",
         detail="Toda tarea de usuario debe tener timer de excepción/escalado menor o igual a 1 día."),
    dict(id="G08", checks=["REC-001", "PKG-003"], title="Records sincronizados sin full sync diario",
         detail="Un record de base de datos no debería necesitar sincronización completa diaria."),
    dict(id="G09", checks=["SEC-004", "SEC-003", "PKG-003"], title="Sin constantes ni expresiones con contraseñas",
         detail="Las credenciales deben ir en Connected Systems u otro mecanismo seguro, nunca en constantes o expresiones."),
    dict(id="G10", checks=["PM-011", "PKG-003"], title="Procesos batch fuera de la ventana 06:30-22:00",
         detail="Ningún proceso programado dentro de 06:30-22:00; elegir el horario de menor carga en Site Gestión de Procesos > Batch model process management."),
]

MONITORING_CATALOG: Dict[str, List[str]] = {
    "processModel": [
        "Vigilar instancias y errores en Monitor > Process Activity durante los primeros días tras el despliegue.",
        "Confirmar que las alertas de proceso llegan al grupo de soporte de la aplicación (no a administradores).",
        "Revisar procesos de larga duración y el impacto en memoria del motor de procesos (Health Check > Process Sizing).",
        "Comprobar que el archivado/borrado de instancias se ejecuta según lo configurado.",
    ],
    "outboundIntegration": [
        "Monitorizar latencia y tasa de error en Monitor > Integrations tras el despliegue.",
        "Verificar timeouts configurados y comportamiento ante caídas del sistema destino (reintentos, colas).",
    ],
    "connectedSystem": [
        "Verificar credenciales por entorno tras la importación (fichero .properties) y caducidad de tokens/certificados.",
    ],
    "recordType": [
        "Revisar Monitor > Record Sync Status: estado, duración y filas de las sincronizaciones.",
        "Vigilar el límite de filas sincronizadas y el crecimiento de la fuente.",
    ],
    "webApi": [
        "Monitorizar consumo, latencia y códigos de error de la Web API (logs y herramienta APM corporativa).",
        "Confirmar la autenticación (API key / OAuth) y el throttling esperado.",
    ],
    "interface": [
        "Revisar el rendimiento de las interfaces con la vista Performance (consultas lentas, componentes pesados).",
    ],
    "site": [
        "Comprobar permisos de páginas del site tras el despliegue y monitorizar adopción/uso.",
    ],
    "dataStore": [
        "Vigilar el crecimiento de las tablas del data store e índices en los campos usados como filtro.",
    ],
}

# ---------------------------------------------------------------------------
# Modelo de datos
# ---------------------------------------------------------------------------

@dataclass
class AppianObject:
    name: str
    objectType: str
    objectTypeLabel: str
    uuid: str = ""
    description: str = ""
    file: str = ""
    definition: str = ""
    ruleInputs: List[str] = field(default_factory=list)
    constantValue: str = ""
    xml: Optional[ET.Element] = None
    rawXml: str = ""
    haulRoot: Optional[ET.Element] = None
    fileText: str = ""
    envSpecific: Optional[bool] = None


@dataclass
class Finding:
    checkId: str
    objectName: str
    objectType: str
    objectTypeLabel: str
    objectUuid: str
    file: str
    severity: str
    severityLabel: str
    category: str
    categoryLabel: str
    title: str
    message: str
    recommendation: str
    line: Optional[int] = None
    snippet: str = ""
    reference: str = ""
    findingId: str = ""
    justification: str = ""
    gateStatus: str = "FAIL"  # FAIL | REVIEW | INFO (efecto del hallazgo en su gate)


OBJECT_TYPE_LABELS = {
    "interface": "Interfaz",
    "expressionRule": "Regla de expresión",
    "constant": "Constante",
    "decision": "Decisión",
    "outboundIntegration": "Integración",
    "connectedSystem": "Sistema conectado",
    "processModel": "Modelo de proceso",
    "recordType": "Record Type",
    "dataType": "Tipo de datos (CDT)",
    "dataStore": "Data Store",
    "document": "Documento",
    "folder": "Carpeta",
    "group": "Grupo",
    "site": "Site",
    "webApi": "Web API",
    "application": "Aplicación",
    "portal": "Portal",
    "translationSet": "Conjunto de traducciones",
    "package": "Paquete",
    "unknown": "Objeto",
}

# ---------------------------------------------------------------------------
# Utilidades XML / SAIL
# ---------------------------------------------------------------------------

def local_tag(tag: str) -> str:
    return re.sub(r"^\{.*\}", "", tag).strip().lower()


def strip_namespaces(root: ET.Element) -> ET.Element:
    """Elimina namespaces de etiquetas y atributos (in place).

    Los export de Appian usan un namespace por defecto; sin esto, ET.tostring
    reserializa con prefijos ns0: y los análisis por regex dejan de casar.
    """
    for el in root.iter():
        el.tag = re.sub(r"^\{.*\}", "", el.tag)
        if any(k.startswith("{") for k in el.attrib):
            el.attrib = {re.sub(r"^\{.*\}", "", k): v for k, v in el.attrib.items()}
    return root


def first_text(elem: ET.Element, *names: str) -> str:
    wanted = {n.lower() for n in names}
    for child in elem.iter():
        if local_tag(child.tag) in wanted and child.text and child.text.strip():
            return child.text.strip()
    return ""


def direct_child_text(elem: ET.Element, *names: str) -> str:
    wanted = {n.lower() for n in names}
    for child in list(elem):
        if local_tag(child.tag) in wanted and child.text and child.text.strip():
            return child.text.strip()
    return ""


STRING_RE = r'"(?:[^"]|"")*"'
COMMENT_RE = r"/\*.*?\*/"


def comment_spans(expr: str) -> List[Tuple[int, int]]:
    return [m.span() for m in re.finditer(COMMENT_RE, expr, re.S)]


def in_spans(pos: int, spans: List[Tuple[int, int]]) -> bool:
    return any(a <= pos < b for a, b in spans)


def line_of(expr: str, pos: int) -> int:
    return expr.count("\n", 0, pos) + 1


def snippet_at(expr: str, pos: int, width: int = 90) -> str:
    start = expr.rfind("\n", 0, pos) + 1
    end = expr.find("\n", pos)
    if end == -1:
        end = len(expr)
    line = expr[start:end].strip()
    return (line[: width - 3] + "...") if len(line) > width else line


TOKEN_RE = re.compile(
    STRING_RE + r"|'[^'\n]*'|" + COMMENT_RE + r"|([a-zA-Z_][\w.]*(?:!\s*[\w.]+)?)\s*\(|\(|\)",
    re.S,
)


def iter_call_events(expr: str):
    """Recorre la expresión SAIL ignorando strings y comentarios.

    Genera (nombre_funcion, posicion, pila_de_funciones_abiertas) en cada
    apertura de llamada a función.
    """
    stack: List[Optional[str]] = []
    for m in TOKEN_RE.finditer(expr):
        tok = m.group(0)
        name = m.group(1)
        if tok.startswith('"') or tok.startswith("'") or tok.startswith("/*"):
            continue
        if name is not None:
            fname = re.sub(r"\s+", "", name).lower()
            yield fname, m.start(), list(stack)
            stack.append(fname)
        elif tok == "(":
            stack.append(None)
        elif tok == ")":
            if stack:
                stack.pop()


def foreach_expression_spans(expr: str) -> List[Tuple[int, int, int, int]]:
    """Spans de las llamadas a a!forEach y de su argumento expression:.

    Devuelve tuplas (call_start, call_end, expr_start, expr_end) parseadas
    con conteo de paréntesis ignorando strings y comentarios. Las consultas
    del argumento items: se evalúan una sola vez: solo el cuerpo
    (expression:) puede generar el patrón N+1.
    """
    spans = []
    for m in re.finditer(r"a!foreach\s*\(", expr, re.I):
        open_pos = m.end() - 1
        depth = 0
        i = open_pos
        end = len(expr)
        args = []
        arg_start = open_pos + 1
        while i < end:
            ch = expr[i]
            if ch == '"':
                j = i + 1
                while j < end:
                    if expr[j] == '"':
                        if expr[j:j + 2] == '""':
                            j += 2
                            continue
                        break
                    j += 1
                i = j + 1
                continue
            if expr.startswith("/*", i):
                j = expr.find("*/", i + 2)
                i = (j + 2) if j != -1 else end
                continue
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0:
                    args.append((arg_start, i))
                    break
            elif ch == "," and depth == 1:
                args.append((arg_start, i))
                arg_start = i + 1
            i += 1
        expr_span = None
        for a, b in args:
            head = expr[a:b].lstrip()
            if re.match(r"expression\s*:", head, re.I):
                expr_span = (a + (len(expr[a:b]) - len(head))
                             + head.index(":") + 1, b)
                break
        if expr_span:
            spans.append((m.start(), i + 1, expr_span[0], expr_span[1]))
        else:
            spans.append((m.start(), i + 1, -1, -1))
    return spans


def normalize_name(name: str) -> str:
    return re.sub(r"[\s_\-]+", "", name or "").lower()


def parse_hhmm(text: str) -> Optional[Tuple[int, int]]:
    m = re.match(r"^(\d{1,2}):(\d{2})$", text.strip())
    if not m:
        return None
    h, mi = int(m.group(1)), int(m.group(2))
    if 0 <= h < 24 and 0 <= mi < 60:
        return (h, mi)
    return None


# ---------------------------------------------------------------------------
# Lectura del paquete
# ---------------------------------------------------------------------------

class PackageError(Exception):
    """Error de seguridad/lectura del paquete: provoca veredicto ERROR."""


class PackageReader:
    """Lee un .zip de exportación de Appian o un directorio extraído.

    Límites de seguridad de entrada: maxZipBytes (200 MB), maxEntryBytes
    (50 MB), maxEntries (20000) y rechazo de rutas con '..' o absolutas.
    """

    def __init__(self, path: str, errors: Optional[List[str]] = None):
        self.path = path
        self.files: Dict[str, str] = {}
        self.errors = errors if errors is not None else []

    def _safe_relpath(self, rel: str) -> bool:
        parts = rel.replace("\\", "/").split("/")
        return not (rel.startswith(("/", "\\")) or ":" in rel.split("/")[0]
                    or ".." in parts)

    def load(self) -> None:
        if os.path.isdir(self.path):
            for root, _dirs, names in os.walk(self.path):
                for n in names:
                    full = os.path.join(root, n)
                    rel = os.path.relpath(full, self.path)
                    if not self._safe_relpath(rel):
                        continue
                    self._add(rel, full=full)
        elif zipfile.is_zipfile(self.path):
            if os.path.getsize(self.path) > MAX_ZIP_BYTES:
                raise PackageError(
                    f"El zip supera el límite de {MAX_ZIP_BYTES // (1024 * 1024)} MB.")
            with zipfile.ZipFile(self.path) as zf:
                infos = [i for i in zf.infolist() if not i.is_dir()]
                if len(infos) > MAX_ENTRIES:
                    raise PackageError(
                        f"El zip tiene {len(infos)} entradas (límite: {MAX_ENTRIES}).")
                for info in infos:
                    if not self._safe_relpath(info.filename):
                        raise PackageError(
                            f"Entrada del zip con ruta no segura: '{info.filename}'.")
                    if info.file_size > MAX_ENTRY_BYTES:
                        raise PackageError(
                            f"La entrada '{info.filename}' supera el límite de "
                            f"{MAX_ENTRY_BYTES // (1024 * 1024)} MB.")
                    self._add(info.filename, data=zf.read(info))
        else:
            raise PackageError(f"'{self.path}' no es un .zip válido ni un directorio.")

    def _add(self, rel: str, full: str = "", data: Optional[bytes] = None) -> None:
        lower = rel.lower()
        if not (lower.endswith(".xml") or lower.endswith(".xsd")
                or lower.endswith(".properties") or lower.endswith(".txt")
                or lower.endswith(".log") or lower.endswith(".json")):
            return
        if data is None:
            with open(full, "rb") as fh:
                data = fh.read()
        try:
            self.files[rel.replace("\\", "/")] = data.decode("utf-8")
        except UnicodeDecodeError:
            self.files[rel.replace("\\", "/")] = data.decode("latin-1", errors="replace")


TAG_TO_TYPE = {
    "rule": "expressionRule",
    "interface": "interface",
    "constant": "constant",
    "decision": "decision",
    "outboundintegration": "outboundIntegration",
    "connectedsystem": "connectedSystem",
    "document": "document",
    "folder": "folder",
    "rulesfolder": "folder",
    "communityknowledgecenter": "folder",
    "knowledgecenter": "folder",
    "group": "group",
    "site": "site",
    "webapi": "webApi",
    "application": "application",
    "recordtype": "recordType",
    "datastore": "dataStore",
    "datatype": "dataType",
    "portal": "portal",
    "translationset": "translationSet",
    "processmodelport": "processModel",
    "process_model_port": "processModel",
    "pm": "processModel",
}

UI_COMPONENT_HINT = re.compile(
    r"a!(formlayout|columnslayout|sectionlayout|headercontentlayout|gridfield|"
    r"textfield|dropdownfield|buttonarraylayout|cardlayout|wizardlayout|"
    r"billboardlayout|sidebysidelayout|richtextdisplayfield)", re.I)


def detect_object_type(tag: str, elem: ET.Element, file_path: str) -> str:
    t = TAG_TO_TYPE.get(tag)
    if t == "expressionRule":
        pref = first_text(elem, "preferredEditor")
        definition = first_text(elem, "definition")
        if (pref and "interface" in pref.lower()) or UI_COMPONENT_HINT.search(definition or ""):
            return "interface"
        return "expressionRule"
    if t:
        return t
    folder = file_path.split("/", 1)[0].lower() if "/" in file_path else ""
    if "processmodelfolder" in folder or folder in ("contentfolder", "rulefolder"):
        return "folder"
    if "processmodel" in folder:
        return "processModel"
    if "recordtype" in folder:
        return "recordType"
    return "unknown"


# Elementos auxiliares de los ficheros haul que NO son objetos
AUX_TAGS = {
    "versionuuid", "rolemap", "history", "typedvalue", "file", "members",
    "admins", "ruleset", "folderuuid", "ispublished", "migrationversion",
    "versions", "version", "exportmetadata", "haultype",
}


def parse_package(files: Dict[str, str], add_finding,
                  parse_errors: Optional[List[dict]] = None,
                  file_stats: Optional[dict] = None) -> List[AppianObject]:
    """Extrae los objetos del paquete: un fichero haul = un objeto Appian."""
    objects: List[AppianObject] = []
    for path, text in sorted(files.items()):
        lower = path.lower()
        base = os.path.basename(lower)
        if (not lower.endswith((".xml", ".xsd"))
                or base == "patches.xml" or lower.startswith("meta-inf/")):
            continue
        if lower.endswith(".xsd"):
            objects.extend(parse_xsd(path, text))
            if file_stats is not None:
                file_stats["ok"] += 1
            continue
        try:
            root = strip_namespaces(ET.fromstring(text))
        except ET.ParseError as exc:
            if parse_errors is not None:
                parse_errors.append(dict(file=path, error=str(exc)))
            if file_stats is not None:
                file_stats["failed"] += 1
            add_finding("PKG-003", AppianObject(
                name=os.path.basename(path), objectType="unknown",
                objectTypeLabel="Fichero", file=path),
                f"Objeto no analizable: no se pudo parsear el XML ({exc}). "
                "Sus controles quedan en revisión manual.",
                gate="REVIEW")
            continue
        if file_stats is not None:
            file_stats["ok"] += 1

        root_tag = local_tag(root.tag)
        if root_tag.endswith("haul"):
            candidates = [c for c in root if local_tag(c.tag) in TAG_TO_TYPE]
            if not candidates:
                candidates = [c for c in root
                              if local_tag(c.tag) not in AUX_TAGS and extract_name(c)]
            for child in candidates:
                otype = detect_object_type(local_tag(child.tag), child, path)
                obj = build_object(child, otype, path, haul_root=root, file_text=text)
                if obj:
                    objects.append(obj)
        else:
            otype = detect_object_type(root_tag, root, path)
            if otype != "unknown":
                obj = build_object(root, otype, path, haul_root=root, file_text=text)
                if obj:
                    objects.append(obj)
    return objects


def extract_name(elem: ET.Element) -> str:
    """Nombre de un objeto: atributo, hijo directo o mapa de locales.

    En los string-map se prefiere el valor del locale 'es', luego 'en',
    luego el primero no vacío.
    """
    for k, v in elem.attrib.items():
        if local_tag(k) == "name" and v.strip():
            return v.strip()
    for child in list(elem):
        if local_tag(child.tag) != "name":
            continue
        if child.text and child.text.strip():
            return child.text.strip()
        pairs = []
        for pair in child.iter():
            if local_tag(pair.tag) != "pair":
                continue
            lang = ""
            val = ""
            for sub in list(pair):
                if local_tag(sub.tag) == "locale":
                    lang = (sub.get("lang") or "").lower()
                elif local_tag(sub.tag) == "value" and sub.text:
                    val = sub.text.strip()
            pairs.append((lang, val))
        for want in ("es", "en"):
            hit = next((v for l, v in pairs if l == want and v), "")
            if hit:
                return hit
        any_val = next((v for _, v in pairs if v), "")
        if any_val:
            return any_val
    return ""


def extract_uuid(elem: ET.Element) -> str:
    for k, v in elem.attrib.items():
        if local_tag(k) == "uuid" and v.strip():
            return v.strip()
    return direct_child_text(elem, "uuid")


def extract_description(elem: ET.Element) -> str:
    for child in list(elem):
        if local_tag(child.tag) == "description":
            if child.text and child.text.strip():
                return child.text.strip()
            v = first_text(child, "value")
            if v:
                return v
    return ""


def build_object(elem: ET.Element, otype: str, path: str,
                 haul_root: Optional[ET.Element] = None,
                 file_text: str = "") -> Optional[AppianObject]:
    meta = elem
    if otype == "processModel":
        # process_model_port -> pm -> meta (uuid, name y description del modelo)
        for tagname in ("meta", "pm"):
            cand = next((c for c in elem.iter() if local_tag(c.tag) == tagname), None)
            if cand is not None and (extract_name(cand) or extract_uuid(cand)):
                meta = cand
                break
    name = extract_name(meta) or extract_name(elem) \
        or os.path.splitext(os.path.basename(path))[0]
    obj = AppianObject(
        name=name,
        objectType=otype,
        objectTypeLabel=OBJECT_TYPE_LABELS.get(otype, "Objeto"),
        uuid=extract_uuid(meta) or extract_uuid(elem),
        description=extract_description(meta) or extract_description(elem),
        file=path,
        xml=elem,
        rawXml=ET.tostring(elem, encoding="unicode"),
        haulRoot=haul_root,
        fileText=file_text or ET.tostring(elem, encoding="unicode"),
    )
    if otype in ("expressionRule", "interface", "decision", "outboundIntegration", "webApi"):
        obj.definition = first_text(elem, "definition", "expression")
        obj.ruleInputs = extract_rule_inputs(elem)
    elif otype == "constant":
        obj.constantValue = extract_constant_value(elem)
        env = direct_child_text(elem, "isEnvironmentSpecific")
        if env:
            obj.envSpecific = env.strip().lower() == "true"
    return obj


EXPORT_LOG_SECTIONS = {
    "success": re.compile(
        r"^(?:Éxito|Exito|Success) \((\d+)\):", re.I),
    "problems": re.compile(
        r"^(?:Problemas|Problems) \((\d+)\):", re.I),
    "warnings": re.compile(
        r"^(?:Advertencias|Warnings) \((\d+)\):", re.I),
    "precedents": re.compile(
        r"^(?:Precedentes referenciados que no fueron exportados|"
        r"Referenced precedents that were not exported) \((\d+)\):", re.I),
}
EXPORT_LOG_ITEM_RE = re.compile(r'^(\S+)\s+\S+\s+(\S+)\s*(?:"([^"]*)")?\s*$')


def parse_export_log(files: Dict[str, str]) -> dict:
    """Del META-INF/export.log: secciones de éxito, problemas, advertencias
    y precedentes referenciados no exportados (español o inglés)."""
    out = dict(success=[], problems=[], warnings=[], precedents=[],
               successCount=0)
    for path, text in files.items():
        if not path.lower().endswith("export.log"):
            continue
        section = None
        for line in text.splitlines():
            if not line.strip():
                if section:
                    section = None
                continue
            msec = None
            for key, rx in EXPORT_LOG_SECTIONS.items():
                msec = rx.match(line)
                if msec:
                    section = key
                    if key == "success":
                        out["successCount"] = int(msec.group(1))
                    break
            if msec:
                continue
            if not section:
                continue
            m = EXPORT_LOG_ITEM_RE.match(line.strip())
            if not m or re.match(r"^\d{4}-\d{2}-\d{2}", line):
                section = None
                continue
            item = dict(type=m.group(1), uuid=m.group(2), name=m.group(3) or "")
            if section == "success":
                out["success"].append(item)
            elif section == "problems":
                out["problems"].append(item)
            elif section == "warnings":
                out["warnings"].append(item)
            else:
                out["precedents"].append(item)
        break
    out["names"] = {i["uuid"]: i["name"] for i in out["success"] if i["name"]}
    return out


def parse_appian_version(files: Dict[str, str]) -> str:
    """Versión de Appian del export (MANIFEST.MF o cabecera del export.log)."""
    for path, text in files.items():
        lower = path.lower()
        if lower.endswith("manifest.mf"):
            m = re.search(r"^Appian-Version:\s*(\S+)", text, re.M)
            if m:
                return m.group(1)
        if lower.endswith("export.log"):
            m = re.search(r"[Vv]ersi[oó]n[:\s]+(\d+[\d.]+)", text)
            if m:
                return m.group(1)
    return ""


MANIFEST_TYPE_LABELS = {
    "content": "Contenido (reglas, interfaces, constantes, documentos...)",
    "group": "Grupos",
    "grouptype": "Tipos de grupo",
    "processmodel": "Modelos de proceso",
    "recordtype": "Record Types",
    "webapi": "Web APIs",
    "datatype": "Tipos de datos (CDT)",
    "datastore": "Data Stores",
    "site": "Sites",
    "connectedsystem": "Sistemas conectados",
    "application": "Aplicaciones",
}


def parse_manifest(files: Dict[str, str], objects: List[AppianObject],
                   export_log: Optional[dict] = None) -> Optional[dict]:
    """Inventario oficial del despliegue.

    Preferencia: META-INF/export.log (sección 'Éxito (N):'), después
    patches.xml; como último recurso, la aplicación exportada.
    """
    log = export_log if export_log is not None else parse_export_log(files)
    kind = ("application" if any(
                p.lower().startswith("application/") and p.lower().endswith(".xml")
                for p in files) else "package")
    app_obj = next((o for o in objects if o.objectType == "application"), None)
    if log["success"]:
        by_type: Dict[str, int] = Counter(i["type"] for i in log["success"])
        uuids = {i["uuid"]: i["type"] for i in log["success"]}
        return dict(
            source="META-INF/export.log", kind=kind,
            packageName=app_obj.name if app_obj else "",
            applicationUuid=app_obj.uuid if app_obj else "",
            byType=dict(by_type), uuids=uuids,
            expectedObjects=log["successCount"] or len(uuids),
            externalPrecedents=log["precedents"],
            logProblems=log["problems"], logWarnings=log["warnings"])

    for path, text in files.items():
        if os.path.basename(path).lower() != "patches.xml":
            continue
        try:
            root = strip_namespaces(ET.fromstring(text))
        except ET.ParseError:
            continue
        by_type = {}
        uuids = {}
        pkg_name = ""
        for pi in root.iter():
            if local_tag(pi.tag) == "packageinfo":
                pkg_name = direct_child_text(pi, "name")
                break
        for item in root.iter():
            if local_tag(item.tag) != "item":
                continue
            t = direct_child_text(item, "type") or "unknown"
            ids = [u.text.strip() for u in item.iter()
                   if local_tag(u.tag) == "uuid" and u.text and u.text.strip()]
            by_type[t] = by_type.get(t, 0) + len(ids)
            for u in ids:
                uuids[u] = t
        return dict(source="patches.xml", kind=kind, packageName=pkg_name,
                    applicationUuid=first_text(root, "applicationUuid"),
                    byType=by_type, uuids=uuids, expectedObjects=len(uuids),
                    externalPrecedents=log["precedents"],
                    logProblems=log["problems"], logWarnings=log["warnings"])

    if app_obj is not None and app_obj.xml is not None:
        uuid_re = re.compile(r"^(_[a-z]-)?[0-9a-fA-F-]{20,}$")
        uuids = {el.text.strip() for el in app_obj.xml.iter()
                 if local_tag(el.tag) == "uuid" and el.text
                 and uuid_re.match(el.text.strip())}
        uuids.discard(app_obj.uuid)
        return dict(source=f"aplicación '{app_obj.name}'", kind="application",
                    packageName=app_obj.name, applicationUuid=app_obj.uuid,
                    byType={}, uuids={u: "unknown" for u in sorted(uuids)},
                    expectedObjects=len(uuids),
                    externalPrecedents=log["precedents"],
                    logProblems=log["problems"], logWarnings=log["warnings"])
    return None


def parse_design_guidance(files: Dict[str, str]) -> List[dict]:
    """Del META-INF/design-guidance.json: guidance de Appian por objeto."""
    for path, text in files.items():
        if path.lower().endswith("design-guidance.json"):
            try:
                data = json.loads(text)
                return data if isinstance(data, list) else []
            except json.JSONDecodeError:
                return []
    return []


def extract_rule_inputs(elem: ET.Element) -> List[str]:
    names: List[str] = []
    for child in elem.iter():
        if local_tag(child.tag) in ("ruleinput", "namedtypedvalue", "input"):
            n = direct_child_text(child, "name")
            if n and n not in names:
                names.append(n)
    return names


def extract_constant_value(elem: ET.Element) -> str:
    for child in elem.iter():
        tag = local_tag(child.tag)
        if tag == "value" and child.text and child.text.strip():
            return child.text.strip()
        if tag == "typedvalue":
            inner = direct_child_text(child, "value")
            if inner:
                return inner
    return ""


def parse_xsd(path: str, text: str) -> List[AppianObject]:
    try:
        root = strip_namespaces(ET.fromstring(text))
    except ET.ParseError:
        return []
    objs = []
    for ct in root.iter():
        if local_tag(ct.tag) == "complextype":
            name = ct.get("name") or os.path.splitext(os.path.basename(path))[0]
            objs.append(AppianObject(
                name=name, objectType="dataType",
                objectTypeLabel=OBJECT_TYPE_LABELS["dataType"],
                file=path, xml=ct, rawXml=ET.tostring(ct, encoding="unicode")))
    return objs


# ---------------------------------------------------------------------------
# Lectores de ficheros auxiliares (Health Check, rendimiento, justificaciones)
# ---------------------------------------------------------------------------

def read_xlsx(path: str) -> List[List[str]]:
    """Lector mínimo de .xlsx (solo strings/números) sin dependencias."""
    rows: List[List[str]] = []
    with zipfile.ZipFile(path) as zf:
        shared: List[str] = []
        if "xl/sharedStrings.xml" in zf.namelist():
            sroot = ET.fromstring(zf.read("xl/sharedStrings.xml"))
            for si in sroot:
                shared.append("".join(t.text or "" for t in si.iter()
                                      if local_tag(t.tag) == "t"))
        sheets = sorted((n for n in zf.namelist()
                         if re.match(r"xl/worksheets/sheet\d+\.xml$", n)),
                        key=lambda n: int(re.search(r"(\d+)", n).group(1)))
        for sheet in sheets:
            root = ET.fromstring(zf.read(sheet))
            for row_el in root.iter():
                if local_tag(row_el.tag) != "row":
                    continue
                row: List[str] = []
                for c in row_el:
                    if local_tag(c.tag) != "c":
                        continue
                    ref = c.get("r") or ""
                    col_letters = re.sub(r"\d+", "", ref)
                    idx = 0
                    for ch in col_letters:
                        idx = idx * 26 + (ord(ch.upper()) - 64)
                    idx = max(idx - 1, len(row))
                    while len(row) < idx:
                        row.append("")
                    ctype = c.get("t") or ""
                    val = ""
                    for v in c.iter():
                        if local_tag(v.tag) in ("v", "t") and v.text:
                            val = v.text
                            break
                    if ctype == "s" and val.isdigit() and int(val) < len(shared):
                        val = shared[int(val)]
                    row.append(val)
                if any(cell.strip() for cell in row):
                    rows.append(row)
    return rows


def read_csv_rows(path: str) -> List[List[str]]:
    with open(path, "r", encoding="utf-8-sig", newline="") as fh:
        sample = fh.read(4096)
        fh.seek(0)
        try:
            dialect = csv.Sniffer().sniff(sample, delimiters=",;\t")
        except csv.Error:
            dialect = csv.excel
        return [row for row in csv.reader(fh, dialect)]


RISK_VALUES = {
    "high": "HIGH", "alto": "HIGH", "alta": "HIGH",
    "medium": "MEDIUM", "medio": "MEDIUM", "media": "MEDIUM",
    "low": "LOW", "bajo": "LOW", "baja": "LOW",
}


HC_TEXT_HEADERS = ("finding", "details", "detalle", "description", "descrip",
                   "object", "objeto", "name", "nombre")


def load_health_check(path: str) -> List[Dict[str, str]]:
    """Extrae hallazgos de un Health Check de Appian (.xlsx, .csv o .json).

    Formato real del informe oficial (hoja Details): columnas
    ID | Category | Description | Finding | Risk | Value | Details |
    Application Name | More Information. Es tolerante a variaciones: detecta
    la cabecera por la columna de riesgo y usa como texto de búsqueda todas
    las columnas descriptivas (los objetos van por uuid/nombre en el texto).
    En .json se acepta una lista de objetos con campos
    object|uuid|risk|description.
    """
    lower = path.lower()
    if lower.endswith(".json"):
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
        items = data if isinstance(data, list) else data.get("risks", [])
        findings = []
        for item in items:
            risk = RISK_VALUES.get(str(item.get("risk", "")).strip().lower(), "")
            if not risk:
                continue
            text = " | ".join(str(item.get(k, "")) for k in
                             ("object", "uuid", "description", "id")
                             if item.get(k))
            findings.append(dict(risk=risk, findingId=str(item.get("id", "")),
                                 category=str(item.get("category", "")),
                                 description=str(item.get("description", "")),
                                 detail=text[:200], appName=str(item.get("application", "")),
                                 text=text))
        return findings
    rows = read_xlsx(path) if lower.endswith("x") else read_csv_rows(path)
    findings: List[Dict[str, str]] = []
    cols: Optional[dict] = None

    for row in rows:
        cells = [str(c).strip() for c in row]
        lowers = [c.lower() for c in cells]

        if cols is not None and len(cells) > cols["risk"] \
                and cells[cols["risk"]].lower() in RISK_VALUES:
            def col(key):
                i = cols.get(key)
                return cells[i] if i is not None and len(cells) > i else ""
            text = " | ".join(cells[i] for i in cols["textCols"]
                              if len(cells) > i and cells[i])
            if text:
                findings.append(dict(
                    risk=RISK_VALUES[cells[cols["risk"]].lower()],
                    findingId=col("id"), category=col("category"),
                    description=col("description"),
                    detail=col("detail") or text[:200],
                    appName=col("app"), text=text))
            continue

        # Detección de cabecera
        risk_i = next((i for i, c in enumerate(lowers)
                       if c in ("risk", "riesgo", "risk level", "nivel de riesgo")), None)
        if risk_i is None:
            risk_i = next((i for i, c in enumerate(lowers)
                           if ("risk" in c or "riesgo" in c) and len(c) <= 20), None)
        if risk_i is None:
            continue
        text_cols = [i for i, c in enumerate(lowers)
                     if i != risk_i and any(k in c for k in HC_TEXT_HEADERS)]
        if not text_cols:
            continue
        cols = dict(
            risk=risk_i, textCols=text_cols,
            id=next((i for i, c in enumerate(lowers) if c == "id"), None),
            category=next((i for i, c in enumerate(lowers) if "categ" in c), None),
            description=next((i for i, c in enumerate(lowers) if "descrip" in c), None),
            detail=next((i for i, c in enumerate(lowers)
                         if "detail" in c or "detalle" in c), None),
            app=next((i for i, c in enumerate(lowers)
                      if "application" in c or "aplicaci" in c), None),
        )
    return findings


HC_DATE_RE = re.compile(
    r"(\d{4}-\d{2}-\d{2})|(\d{4})(\d{2})(\d{2})|(\d{2})-(\d{2})-(\d{4})")
HC_DATE_HEADERS = ("fecha", "date", "generated", "report date")


def detect_hc_date(path: str, rows: List[List[str]]) -> Optional[str]:
    """Fecha del informe HC: celda con cabecera Fecha/Date/Generated o el
    propio nombre de fichero (YYYY-MM-DD, YYYYMMDD o DD-MM-YYYY)."""
    for row in rows[:15]:
        cells = [str(c).strip() for c in row]
        for i, c in enumerate(cells):
            if any(k in c.lower() for k in HC_DATE_HEADERS):
                for cand in cells[i + 1:] + [c]:
                    m = HC_DATE_RE.search(cand)
                    if m:
                        return _norm_hc_date(m)
    m = HC_DATE_RE.search(os.path.basename(path))
    return _norm_hc_date(m) if m else None


def _norm_hc_date(m: "re.Match") -> str:
    if m.group(1):
        return m.group(1)
    if m.group(2):
        return f"{m.group(2)}-{m.group(3)}-{m.group(4)}"
    return f"{m.group(6)}-{m.group(5)}-{m.group(4)}"


def read_hc_rows(path: str) -> List[List[str]]:
    lower = path.lower()
    if lower.endswith(".xlsx"):
        return read_xlsx(path)
    if lower.endswith(".json"):
        return []
    return read_csv_rows(path)


PERF_PASS_VALUES = {"pass", "passed", "ok", "success", "apto", "apta",
                    "satisfactorio", "satisfactoria", "superada", "superado",
                    "yes", "si", "sí", "true", "1"}


def load_perf_results(path: str) -> List[Dict[str, str]]:
    """Lee resultados de pruebas de rendimiento (JSON lista/objeto o CSV)."""
    results: List[Dict[str, str]] = []
    if path.lower().endswith(".json"):
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
        items = data.get("tests", data) if isinstance(data, dict) else data
        for item in items:
            results.append(dict(name=str(item.get("name", "?")),
                                status=str(item.get("status", item.get("result", "")))))
    else:
        rows = read_csv_rows(path)
        if not rows:
            return results
        header = [h.strip().lower() for h in rows[0]]
        name_i = next((i for i, h in enumerate(header) if "name" in h or "nombre" in h or "prueba" in h), 0)
        stat_i = next((i for i, h in enumerate(header) if "status" in h or "result" in h or "estado" in h), 1)
        for row in rows[1:]:
            if len(row) > max(name_i, stat_i) and any(c.strip() for c in row):
                results.append(dict(name=row[name_i].strip(), status=row[stat_i].strip()))
    return results


def load_justifications(path: str) -> Dict[str, dict]:
    """Justificaciones a OT: valor string u objeto {text, approver, date}.

    Claves: 'CHECK:Objeto' > 'Gxx' (gate) > 'CHECK' (genérica; solo si la
    config allowGenericJustifications está activa). No se valida firma.
    """
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)
    if not isinstance(data, dict):
        raise SystemExit("ERROR: el fichero de justificaciones debe ser un JSON objeto clave->texto.")
    out: Dict[str, dict] = {}
    for k, v in data.items():
        if isinstance(v, dict):
            out[str(k)] = dict(text=str(v.get("text", "")),
                               approver=str(v.get("approver", "")),
                               date=str(v.get("date", "")))
        else:
            out[str(k)] = dict(text=str(v), approver="", date="")
    return out


# ---------------------------------------------------------------------------
# Analizador
# ---------------------------------------------------------------------------

class Analyzer:
    def __init__(self, prefix: Optional[str], thresholds: Dict[str, int],
                 excluded_checks: Optional[set] = None,
                 severity_overrides: Optional[Dict[str, str]] = None,
                 batch_window: Tuple[str, str] = DEFAULT_BATCH_WINDOW,
                 config: Optional[dict] = None):
        self.prefix = prefix
        self.th = thresholds
        self.excluded = excluded_checks or set()
        self.severity_overrides = severity_overrides or {}
        self.batch_window = (parse_hhmm(batch_window[0]) or (6, 30),
                             parse_hhmm(batch_window[1]) or (22, 0))
        self.batch_window_text = f"{batch_window[0]}-{batch_window[1]}"
        self.findings: List[Finding] = []
        self.dominant_prefix: Optional[str] = None
        self.manifest: Optional[dict] = None
        self.app_name: str = ""
        self.hc_path: str = ""
        self.hc_totals: Dict[str, int] = {}
        # Estadísticas para los gates
        self.stats = Counter()
        self.analysis = dict(parseErrors=[], errors=[], warnings=[])
        cfg = config or {}
        fag = cfg.get("forbiddenAlertGroups", {})
        self.forbidden_alert_uuids = {str(u) for u in fag.get(
            "uuids", DEFAULT_FORBIDDEN_ALERT_GROUPS["uuids"])}
        self.forbidden_alert_names = {str(n).lower() for n in fag.get(
            "names", DEFAULT_FORBIDDEN_ALERT_GROUPS["names"])}
        self.allow_generic_justifications = bool(
            cfg.get("allowGenericJustifications", False))
        qg = cfg.get("qualityGate", {}) or {}
        self.quality_gate = dict(enabled=bool(qg.get("enabled", False)),
                                 maxHigh=int(qg.get("maxHigh", 0)))
        self.min_coverage = float(cfg.get("minCoverage", DEFAULT_MIN_COVERAGE))
        self.hc_max_age_days = int(cfg.get("hcMaxAgeDays", DEFAULT_HC_MAX_AGE_DAYS))
        self.group_names: Dict[str, str] = {}
        self.properties_files: Dict[str, str] = {}
        self.hc_info: Dict = {}
        self.appian_version: str = ""

    # -- manifiesto del paquete (patches.xml / aplicación) ---------------------
    def check_manifest(self, objects: List[AppianObject], pkg_obj: AppianObject) -> None:
        if not self.manifest:
            return
        expected = self.manifest.get("expectedObjects", 0)
        parsed_uuids = {o.uuid for o in objects if o.uuid}
        analyzed = len([o for o in objects if o.objectType != "application"]) \
            if self.manifest.get("kind") == "package" else len(objects)
        missing = [u for u in self.manifest.get("uuids", {}) if u not in parsed_uuids]
        self.manifest["missingUuids"] = missing
        self.manifest["analyzedObjects"] = analyzed
        if missing or (expected and analyzed != expected):
            self.add("PKG-002", pkg_obj,
                     f"El manifiesto ({self.manifest['source']}) declara {expected} objetos "
                     f"pero se han analizado {analyzed}"
                     + (f"; sin analizar: {', '.join(missing[:5])}" if missing else "") + ".")

    # -- registro de hallazgos ------------------------------------------------
    def add(self, check_id: str, obj: AppianObject, message: str,
            line: Optional[int] = None, snippet: str = "",
            severity: Optional[str] = None, gate: str = "FAIL") -> None:
        if check_id in self.excluded:
            return
        meta = CHECKS[check_id]
        sev = self.severity_overrides.get(check_id) or severity or meta["severity"]
        if gate == "INFO":
            sev = "INFO"
        self.findings.append(Finding(
            checkId=check_id,
            objectName=obj.name,
            objectType=obj.objectType,
            objectTypeLabel=obj.objectTypeLabel,
            objectUuid=obj.uuid,
            file=obj.file,
            severity=sev,
            severityLabel=SEVERITY_LABEL[sev],
            category=meta["category"],
            categoryLabel=CATEGORY_LABEL[meta["category"]],
            title=meta["title"],
            message=message,
            recommendation=meta["recommendation"],
            line=line,
            snippet=snippet,
            reference=meta.get("reference", ""),
            gateStatus=gate,
        ))

    # -- punto de entrada -----------------------------------------------------
    def analyze(self, objects: List[AppianObject],
                hc_findings: Optional[List[Dict[str, str]]] = None,
                perf_results: Optional[List[Dict[str, str]]] = None,
                design_guidance: Optional[List[dict]] = None,
                package_name: str = "") -> None:
        self.dominant_prefix = self.prefix or infer_dominant_prefix(objects)
        self.group_names = {o.uuid: o.name for o in objects
                            if o.objectType == "group" and o.uuid}
        for obj in objects:
            self.check_description(obj)
            self.check_naming(obj, self.dominant_prefix)
            self.check_security_rolemap(obj)
            if obj.definition:
                self.analyze_expression(obj, obj.definition)
                self.check_rule_level(obj)
            if obj.objectType == "constant":
                self.check_constant(obj)
            elif obj.objectType == "processModel":
                self.stats["processModels"] += 1
                self.check_process_model(obj)
                self.check_process_governance(obj)
            elif obj.objectType == "recordType":
                self.check_record_type(obj)
            elif obj.objectType == "dataType":
                self.check_data_type(obj)
            elif obj.objectType == "connectedSystem":
                self.check_connected_system(obj)
            elif obj.objectType in ("webApi", "site", "portal"):
                self.check_public_access(obj)

        self.check_dependencies(objects)
        pkg_obj = AppianObject(name=package_name or "paquete", objectType="package",
                               objectTypeLabel=OBJECT_TYPE_LABELS["package"])
        if design_guidance:
            self.check_design_guidance(objects, design_guidance, pkg_obj)
        self.check_manifest(objects, pkg_obj)
        if hc_findings is not None:
            self.stats["hcProvided"] = 1
            app_obj = next((o for o in objects if o.objectType == "application"), None)
            self.check_health_check(objects, hc_findings, pkg_obj,
                                    app_name=self.app_name or (app_obj.name if app_obj else ""))
        if perf_results is not None:
            self.stats["perfProvided"] = 1
            for res in perf_results:
                if res["status"].strip().lower() not in PERF_PASS_VALUES:
                    self.stats["perfFailures"] += 1
                    self.add("PRT-001", pkg_obj,
                             f"La prueba de rendimiento '{res['name']}' no es satisfactoria "
                             f"(resultado: '{res['status']}').")

    # -- checks transversales ---------------------------------------------
    def check_description(self, obj: AppianObject) -> None:
        needs_desc = obj.objectType in (
            "expressionRule", "interface", "constant", "decision",
            "outboundIntegration", "processModel", "recordType", "webApi",
            "application", "site",
        )
        if needs_desc and not obj.description.strip():
            self.add("DOC-001", obj,
                     f"El objeto '{obj.name}' ({obj.objectTypeLabel}) no tiene descripción.")

    def check_naming(self, obj: AppianObject, dominant: Optional[str]) -> None:
        if obj.objectType not in ("expressionRule", "interface", "constant",
                                  "decision", "outboundIntegration",
                                  "processModel", "recordType"):
            return
        if not dominant:
            return
        m = re.match(r"^([A-Za-z]{2,6})[_ ]", obj.name)
        obj_prefix = m.group(1).upper() if m else None
        if obj_prefix == dominant:
            return
        if obj_prefix is None:
            self.add("NAM-001", obj,
                     f"'{obj.name}' no usa el prefijo dominante de la aplicación "
                     f"('{dominant}_').")
        else:
            self.add("NAM-004", obj,
                     f"'{obj.name}' usa el prefijo '{obj_prefix}_', distinto del "
                     f"prefijo dominante de la aplicación ('{dominant}_').")

    def check_security_rolemap(self, obj: AppianObject) -> None:
        # El roleMap va como hermano del objeto dentro del fichero haul
        scope = obj.haulRoot if obj.haulRoot is not None else obj.xml
        if scope is None:
            return
        users: List[str] = []
        for el in scope.iter():
            if "rolemap" not in local_tag(el.tag):
                continue
            for sub in el.iter():
                if local_tag(sub.tag) in ("user", "username") and sub.text and sub.text.strip():
                    users.append(sub.text.strip())
        if users:
            shown = ", ".join(sorted(set(users))[:5])
            self.add("SEC-001", obj,
                     f"La seguridad de '{obj.name}' asigna roles directamente a usuarios: {shown}.")

    # -- checks de expresiones SAIL ----------------------------------------
    def analyze_expression(self, obj: AppianObject, expr: str) -> None:
        spans = comment_spans(expr)

        n_lines = expr.count("\n") + 1
        if n_lines > self.th["max_expression_lines"] or len(expr) > self.th["max_expression_chars"]:
            self.add("PRF-005", obj,
                     f"La expresión de '{obj.name}' tiene {n_lines} líneas y "
                     f"{len(expr)} caracteres (umbral: {self.th['max_expression_lines']} "
                     f"líneas / {self.th['max_expression_chars']} caracteres).")

        max_foreach, max_if = 0, 0
        first_foreach_pos = first_if_pos = None
        reported_loop_query = set()
        reported_foreach_write = set()
        deprecated_hits: Dict[str, Tuple[int, int]] = {}
        unsupported_hits: Dict[str, Tuple[int, int]] = {}
        foreach_spans = foreach_expression_spans(expr)

        def enclosing_foreach(p: int) -> Optional[Tuple[int, int, int, int]]:
            inside = [s for s in foreach_spans if s[0] <= p < s[1]]
            return min(inside, key=lambda s: s[1] - s[0]) if inside else None

        for fname, pos, stack in iter_call_events(expr):
            base = fname.split("!")[-1] if fname.startswith("fn!") else fname
            if base in ("load", "with") and base not in deprecated_hits:
                deprecated_hits[base] = (line_of(expr, pos), pos)
            if base in UNSUPPORTED_FUNCS and base not in unsupported_hits:
                unsupported_hits[base] = (line_of(expr, pos), pos)

            loops_open = sum(1 for s in stack if s in LOOP_FUNCS)
            if fname in LOOP_FUNCS:
                depth = loops_open + 1
                if depth > max_foreach:
                    max_foreach, first_foreach_pos = depth, pos
            if fname == "if":
                depth = sum(1 for s in stack if s == "if") + 1
                if depth > max_if:
                    max_if, first_if_pos = depth, pos
            if fname in QUERY_FUNCS and loops_open > 0 and fname not in reported_loop_query:
                fe = enclosing_foreach(pos)
                in_foreach_body = fe is not None and fe[2] >= 0 \
                    and fe[2] <= pos < fe[3]
                if fe is None or in_foreach_body:
                    reported_loop_query.add(fname)
                    self.add("PRF-002", obj,
                             f"'{fname}' se ejecuta dentro del cuerpo de una función "
                             f"de iteración en '{obj.name}' (patrón N+1).",
                             line=line_of(expr, pos), snippet=snippet_at(expr, pos))
            if fname in WRITE_FUNCS:
                fe = enclosing_foreach(pos)
                if fe is not None and fe[2] >= 0 and fe[2] <= pos < fe[3] \
                        and fname not in reported_foreach_write:
                    reported_foreach_write.add(fname)
                    self.add("PRF-004", obj,
                             f"'{fname}' se ejecuta dentro del cuerpo de a!forEach en "
                             f"'{obj.name}' (N escrituras).",
                             line=line_of(expr, pos), snippet=snippet_at(expr, pos))

        for fn, (ln, pos) in deprecated_hits.items():
            self.add("DEP-001", obj,
                     f"'{obj.name}' usa la función obsoleta {fn}().",
                     line=ln, snippet=snippet_at(expr, pos))
        for fn, (ln, pos) in unsupported_hits.items():
            self.add("DEP-002", obj,
                     f"'{obj.name}' usa la función no soportada/interna {fn}().",
                     line=ln, snippet=snippet_at(expr, pos))
        if max_foreach >= self.th["max_foreach_depth"]:
            self.add("PRF-006", obj,
                     f"'{obj.name}' anida funciones de iteración hasta {max_foreach} niveles.",
                     line=line_of(expr, first_foreach_pos),
                     snippet=snippet_at(expr, first_foreach_pos))
        if max_if >= self.th["max_if_depth"]:
            self.add("MNT-001", obj,
                     f"'{obj.name}' anida if() hasta {max_if} niveles; valorar a!match().",
                     line=line_of(expr, first_if_pos),
                     snippet=snippet_at(expr, first_if_pos))

        def finditer(pattern: str, flags=re.I):
            for m in re.finditer(pattern, expr, flags):
                if not in_spans(m.start(), spans):
                    yield m

        for m in finditer(r"batchsize\s*:\s*-\s*1"):
            self.add("PRF-001", obj,
                     f"Consulta en '{obj.name}' con batchSize: -1 (recupera todas las filas).",
                     line=line_of(expr, m.start()), snippet=snippet_at(expr, m.start()))

        for m in finditer(r"fetchtotalcount\s*:\s*true"):
            self.add("PRF-003", obj,
                     f"Consulta en '{obj.name}' con fetchTotalCount: true.",
                     line=line_of(expr, m.start()), snippet=snippet_at(expr, m.start()))

        seen_uuid = False
        for m in finditer(r'"(?:_[a-z])?[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"'):
            if not seen_uuid:
                seen_uuid = True
                self.add("MNT-002", obj,
                         f"'{obj.name}' contiene un UUID hardcodeado: {m.group(0)}.",
                         line=line_of(expr, m.start()), snippet=snippet_at(expr, m.start()))

        for m in finditer(r"\b(togroup|group|document|folder|processmodel|touser|getdocumenturl)\s*\(\s*(\d{2,})"):
            self.add("MNT-002", obj,
                     f"'{obj.name}' referencia un objeto por ID numérico: "
                     f"{m.group(1)}({m.group(2)}...). Los IDs cambian entre entornos.",
                     line=line_of(expr, m.start()), snippet=snippet_at(expr, m.start()))

        for m in finditer(r'"https?://[^"\s]+'):
            url = m.group(0).strip('"')
            self.add("MNT-003", obj,
                     f"URL hardcodeada en '{obj.name}': {url[:80]}",
                     line=line_of(expr, m.start()), snippet=snippet_at(expr, m.start()))

        for m in finditer(r"\bif\s*\([^,()]+,\s*true(\(\))?\s*,\s*false(\(\))?\s*\)"):
            self.add("MNT-004", obj,
                     f"if(condición, true, false) redundante en '{obj.name}'.",
                     line=line_of(expr, m.start()), snippet=snippet_at(expr, m.start()))

        for m in finditer(r"loggedinuser\s*\(\s*\)\s*=\s*\"[^\"]+\"|\buser\s*\(\s*\"[^\"]+\""):
            self.add("SEC-002", obj,
                     f"Usuario hardcodeado en '{obj.name}'.",
                     line=line_of(expr, m.start()), snippet=snippet_at(expr, m.start()))

        for m in finditer(r'\b(password|passwd|pwd|secret|apikey|api_key|clientsecret|client_secret|authtoken|auth_token|contrasena|contraseña|clave)\s*[:=]\s*"[^"]{4,}"'):
            self.add("SEC-003", obj,
                     f"Posible credencial hardcodeada en '{obj.name}' (clave '{m.group(1)}').",
                     line=line_of(expr, m.start()), snippet=snippet_at(expr, m.start()))

        for a, b in spans:
            comment = expr[a:b]
            cm = re.search(r"\b(TODO|FIXME|HACK|PENDIENTE)\b", comment, re.I)
            if cm:
                self.add("MNT-009", obj,
                         f"Comentario pendiente en '{obj.name}': "
                         f"\"{comment[cm.start():cm.start() + 70].strip()}\"",
                         line=line_of(expr, a + cm.start()))

        decls = [(m.group(1), m.start()) for m in re.finditer(r"local!(\w+)\s*:", expr)
                 if not in_spans(m.start(), spans)]
        for var, pos in decls:
            uses = len(re.findall(rf"local!{re.escape(var)}\b", expr))
            if uses <= 1:
                self.add("MNT-007", obj,
                         f"La variable local!{var} de '{obj.name}' se declara pero no se usa.",
                         line=line_of(expr, pos))

        if obj.name:
            rm = re.search(rf"rule!\s*{re.escape(obj.name)}\s*\(", expr, re.I)
            if rm and not in_spans(rm.start(), spans):
                self.add("MNT-008", obj,
                         f"'{obj.name}' se invoca a sí misma (recursión directa).",
                         line=line_of(expr, rm.start()), snippet=snippet_at(expr, rm.start()))

    # -- checks a nivel de regla/interfaz ------------------------------------
    def check_rule_level(self, obj: AppianObject) -> None:
        if len(obj.ruleInputs) > self.th["max_rule_inputs"]:
            self.add("MNT-005", obj,
                     f"'{obj.name}' tiene {len(obj.ruleInputs)} entradas de regla "
                     f"(umbral: {self.th['max_rule_inputs']}).")
        for ri in obj.ruleInputs:
            if not re.match(r"^[a-z][a-zA-Z0-9]*$", ri):
                self.add("NAM-003", obj,
                         f"La entrada '{ri}' de '{obj.name}' no sigue camelCase.")
            if obj.definition and not re.search(rf"ri!\s*{re.escape(ri)}\b", obj.definition, re.I):
                self.add("MNT-006", obj,
                         f"La entrada ri!{ri} de '{obj.name}' no se usa en la definición.")

    # -- checks de constantes -------------------------------------------------
    def check_constant(self, obj: AppianObject) -> None:
        base = re.sub(r"^[A-Za-z]{2,6}[_ ]", "", obj.name)
        if not re.match(r"^[A-Z0-9_]+$", base):
            self.add("NAM-002", obj,
                     f"La constante '{obj.name}' no está en MAYUSCULAS_CON_GUIONES.")
        val = obj.constantValue or ""
        const_type = ""
        if obj.xml is not None:
            for el in obj.xml.iter():
                if local_tag(el.tag) == "typedvalue":
                    const_type = first_text(el, "name")
                    break
        is_text = const_type.lower() in ("string", "text", "texto", "")
        looks_ref = bool(val.startswith(("#\"", "cons!", "rule!", "pv!", "ac!",
                                         "ri!", "tp!", "urn:"))
                         or re.match(r"^https?://", val, re.I)
                         or re.match(r"^(_?[a-z]-)?[0-9a-fA-F]{8}-[0-9a-fA-F-]{15,}$", val))
        if CREDENTIAL_NAME_RE.search(obj.name) and is_text and val and not looks_ref:
            slug_like = bool(
                re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)+", val)
                or (re.fullmatch(r"[a-z0-9_]+", val)
                    and (len(val) < 16 or "_" in val)))
            if slug_like:
                self.add("SEC-006", obj,
                         f"La constante '{obj.name}' tiene nombre de credencial pero "
                         f"su valor ('{val[:60]}') parece un identificador, no un "
                         f"secreto: verificar que no es una credencial real.",
                         gate="REVIEW")
            else:
                self.add("SEC-004", obj,
                         f"La constante '{obj.name}' parece contener una credencial "
                         f"(norma corporativa: usar Connected System u otro método seguro).")
        env_value = bool(re.match(r"^https?://", val, re.I)
                         or re.search(r"\b(dev|test|uat|preprod|localhost)\b", val, re.I))
        if env_value and obj.envSpecific is not True:
            self.add("ENV-001", obj,
                     f"La constante '{obj.name}' contiene un valor que parece específico "
                     f"de entorno ('{val[:80]}') y no está marcada como "
                     f"'Environment Specific'.")
        if obj.envSpecific is True and not self._properties_define(obj):
            self.add("ENV-002", obj,
                     f"La constante '{obj.name}' es específica de entorno pero ningún "
                     f"fichero .properties del paquete define su valor.")

    def _properties_define(self, obj: AppianObject) -> bool:
        """True si algún .properties del paquete define un valor no vacío y no
        comentado para este objeto (por uuid o por nombre)."""
        if not self.properties_files:
            return False
        keys = [k for k in (obj.uuid, obj.name) if k]
        for text in self.properties_files.values():
            for line in text.splitlines():
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                k, _, v = line.partition("=")
                if any(key in k for key in keys) and v.strip():
                    return True
        return False

    def check_connected_system(self, obj: AppianObject) -> None:
        if obj.xml is None:
            return
        has_encrypted = any("encryptedtext" in (v or "").lower()
                            for el in obj.xml.iter()
                            for v in el.attrib.values()) or \
            any("encryptedtext" in local_tag(el.tag) for el in obj.xml.iter())
        if has_encrypted and not self._properties_define(obj):
            self.add("ENV-002", obj,
                     f"El sistema conectado '{obj.name}' tiene un valor cifrado "
                     f"(EncryptedText) sin definir en el fichero .properties del paquete.")

    def check_public_access(self, obj: AppianObject) -> None:
        if obj.xml is None:
            return
        for el in obj.xml.iter():
            tag = local_tag(el.tag)
            if not any(k in tag for k in ("public", "anonymous", "authentication")):
                continue
            text = (el.text or "").strip().lower()
            attrs = " ".join(str(v).lower() for v in el.attrib.values())
            if text in ("true", "anonymous", "none", "public") \
                    or any(k in attrs for k in ("anonymous", "none", "public")):
                self.add("SEC-005", obj,
                         f"'{obj.name}' ({obj.objectTypeLabel}) indica acceso "
                         f"público/anónimo en su configuración ({tag}).")
                return

    # -- design guidance del propio Appian (META-INF/design-guidance.json) ----
    def check_design_guidance(self, objects: List[AppianObject],
                              guidance: List[dict], pkg_obj: AppianObject) -> None:
        by_uuid = {o.uuid: o for o in objects if o.uuid}
        for entry in guidance:
            key = str(entry.get("designGuidanceKey", ""))
            short = key.rsplit(".", 1)[-1] or key
            # camelCase -> palabras legibles
            pretty = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", short)
            count = entry.get("instanceCount", 1)
            target = by_uuid.get(str(entry.get("objectUuid", ""))) or pkg_obj
            if entry.get("dismissed"):
                self.add("ADG-002", target,
                         f"Guidance de Appian descartada en '{target.name}': "
                         f"'{pretty}' ({count} instancia(s)). Justificar el descarte a OT.")
            else:
                self.add("ADG-001", target,
                         f"Guidance de Appian sin resolver en '{target.name}': "
                         f"'{pretty}' ({count} instancia(s)).")

    # -- checks de modelos de proceso (diseño) --------------------------------
    def check_process_model(self, obj: AppianObject) -> None:
        if obj.xml is None:
            return
        raw = obj.rawXml
        nodes = [el for el in obj.xml.iter() if local_tag(el.tag) == "node"]
        n_nodes = len(nodes)
        if n_nodes > self.th["max_pm_nodes"]:
            sev = "HIGH" if n_nodes > 2 * self.th["max_pm_nodes"] else "MEDIUM"
            self.add("PM-001", obj,
                     f"El modelo '{obj.name}' tiene {n_nodes} nodos "
                     f"(recomendado: <= {self.th['max_pm_nodes']}).", severity=sev)

        pvs = []
        for el in obj.xml.iter():
            if local_tag(el.tag) == "pv":
                n = direct_child_text(el, "name") or first_text(el, "name")
                if n:
                    pvs.append(n)
        if len(pvs) > self.th["max_pm_variables"]:
            sev = "HIGH" if len(pvs) >= self.th["max_pm_variables_high"] else "MEDIUM"
            self.add("PM-002", obj,
                     f"El modelo '{obj.name}' tiene {len(pvs)} variables de proceso "
                     f"(riesgo medio > {self.th['max_pm_variables']}, "
                     f"alto >= {self.th['max_pm_variables_high']}).", severity=sev)
        for pv in pvs:
            if len(re.findall(rf"pv!\s*{re.escape(pv)}\b", raw)) == 0:
                self.add("PM-003", obj,
                         f"La variable de proceso '{pv}' de '{obj.name}' no se referencia "
                         f"en el modelo.")

        chained = len(re.findall(r'chained\s*=\s*"true"|<chained>\s*true\s*</chained>', raw, re.I))
        if chained > self.th["max_chained_flows"]:
            self.add("PM-004", obj,
                     f"El modelo '{obj.name}' tiene {chained} flujos encadenados (chaining); "
                     f"el límite duro de Appian es 50 nodos.")

        node_names = " | ".join(
            (direct_child_text(n, "friendlyname", "name") or "") for n in nodes
        ).lower()
        for needle, label in (("query database", "Query Database"),
                              ("execute stored procedure", "Execute Stored Procedure")):
            if needle in node_names or needle.replace(" ", "") in raw.lower():
                self.add("PM-005", obj,
                         f"El modelo '{obj.name}' usa el nodo '{label}' (SQL directo).")
                break

        if re.search(r"<spawning\b|multipleinstance|<mni\b", raw, re.I):
            self.add("PM-006", obj,
                     f"El modelo '{obj.name}' usa múltiples instancias de nodo (MNI).")

        exprs = [el.text for el in obj.xml.iter()
                 if el.text and el.text.strip().startswith("=") and len(el.text) > 3]
        if exprs:
            self.analyze_expression(obj, "\n".join(exprs))

    # -- checks de gobierno de procesos (gates corporativos) -------------------
    def check_process_governance(self, obj: AppianObject) -> None:
        if obj.xml is None:
            return
        meta = next((el for el in obj.xml.iter() if local_tag(el.tag) == "meta"),
                    obj.xml)
        self._check_alert_group(obj, meta)
        self._check_cleanup(obj, meta)
        self._check_user_tasks(obj)
        self._check_batch_schedule(obj, meta)

    # -- G03: grupo de alertas propio -----------------------------------------
    def _check_alert_group(self, obj: AppianObject, meta: ET.Element) -> None:
        settings = next((el for el in meta.iter()
                         if local_tag(el.tag) == "pm-notification-settings"), None)
        people: List[Tuple[str, str]] = []  # (tipo, id)
        recipients_expr = ""
        custom = ""
        if settings is not None:
            custom = direct_child_text(settings, "custom-settings").lower()
            for el in settings.iter():
                tag = local_tag(el.tag)
                if tag == "people":
                    ptype = direct_child_text(el, "type")
                    pid = direct_child_text(el, "stringid")
                    if pid:
                        people.append((ptype, pid))
                elif tag == "recipients-exp" and el.text and el.text.strip():
                    recipients_expr = el.text.strip()

        if settings is None or custom == "false" or (not people and not recipients_expr):
            self.add("PM-007", obj,
                     f"El modelo '{obj.name}' no tiene destinatarios de alertas propios: "
                     f"se usa la configuración por defecto (administradores).")
            return

        groups = [pid for t, pid in people if t == "4096"]
        users = [pid for t, pid in people if t and t != "4096"]
        if not groups:
            if users:
                self.add("PM-007", obj,
                         f"Las alertas del modelo '{obj.name}' van solo a usuarios "
                         f"individuales: las alertas deben ir a un grupo de soporte.")
            elif recipients_expr:
                self.add("PM-007", obj,
                         f"El modelo '{obj.name}' calcula los destinatarios de alertas "
                         f"con una expresión ('{recipients_expr[:80]}'): verificar que "
                         f"resuelve a un grupo de soporte, no a administradores.",
                         gate="REVIEW")
            return

        unresolved = [g for g in groups if g not in self.group_names]
        resolved = [(g, self.group_names[g]) for g in groups if g in self.group_names]
        forbidden = [f"{g} ('{n}')" for g, n in resolved
                     if g in self.forbidden_alert_uuids
                     or n.lower() in self.forbidden_alert_names] + \
                    [g for g in unresolved if g in self.forbidden_alert_uuids]
        if forbidden:
            self.add("PM-007", obj,
                     f"Las alertas del modelo '{obj.name}' van a un grupo prohibido "
                     f"(administradores de plataforma): {', '.join(forbidden)}.")
            return
        if unresolved:
            extra = ""
            if resolved:
                extra = (f" Grupos resueltos: "
                         f"{', '.join(n for _, n in resolved)}.")
            self.add("PM-007", obj,
                     f"El grupo de alertas '{unresolved[0]}' del modelo '{obj.name}' "
                     f"no está en el paquete ni en la configuración: no se puede "
                     f"verificar offline que no sea de administradores.{extra}",
                     gate="REVIEW")
            return
        admin_like = [n for _, n in resolved
                      if re.search(r"administrator|administrador", n, re.I)]
        if admin_like:
            self.add("PM-012", obj,
                     f"El grupo de alertas '{admin_like[0]}' del modelo '{obj.name}' "
                     f"es un grupo de administradores de aplicación; confirmar que no "
                     f"es el de plataforma.", gate="INFO")
        if recipients_expr:
            self.add("PM-007", obj,
                     f"El modelo '{obj.name}' además calcula destinatarios con la "
                     f"expresión '{recipients_expr[:80]}': verificar que resuelve "
                     f"a un grupo de soporte.", gate="REVIEW")

    # -- G04: borrado de instancias --------------------------------------------
    def _check_cleanup(self, obj: AppianObject, meta: ET.Element) -> None:
        """G04. cleanup-action: 0=no limpiar, 1=archivar, 2=borrar,
        3=defecto del sistema. auto-delete-delay/auto-archive-delay en días."""
        limit = self.th["max_instance_cleanup_days"]
        action = archive_delay = delete_delay = None
        for el in meta.iter():
            tag = local_tag(el.tag)
            text = (el.text or "").strip()
            if tag == "cleanup-action" and re.match(r"^-?\d+$", text):
                action = int(text)
            elif tag == "auto-archive-delay" and text.isdigit():
                archive_delay = int(text)
            elif tag == "auto-delete-delay" and text.isdigit():
                delete_delay = int(text)
        if action is None:
            self.add("PM-008", obj,
                     f"El modelo '{obj.name}' no declara política de borrado de "
                     f"instancias: verificar que borra <= {limit} días tras completarse.",
                     gate="REVIEW")
            return
        if action == 2:
            if delete_delay is None:
                self.add("PM-008", obj,
                         f"El modelo '{obj.name}' borra instancias pero no se pudo leer "
                         f"el plazo (auto-delete-delay).", gate="REVIEW")
            elif delete_delay <= limit:
                pass
            else:
                self.add("PM-008", obj,
                         f"El modelo '{obj.name}' borra las instancias a los "
                         f"{delete_delay} días (norma: <= {limit} días).")
        elif action == 0:
            self.add("PM-008", obj,
                     f"El modelo '{obj.name}' no archiva ni borra las instancias "
                     f"(norma: borrado <= {limit} días tras completarse).")
        elif action == 1:
            self.add("PM-008", obj,
                     f"El modelo '{obj.name}' archiva las instancias a los "
                     f"{archive_delay if archive_delay is not None else '?'} días en lugar "
                     f"de borrarlas (norma: borrado <= {limit} días).")
        elif action == 3:
            self.add("PM-008", obj,
                     f"El modelo '{obj.name}' usa la configuración de limpieza por "
                     f"defecto del sistema en lugar de borrado propio "
                     f"(norma: borrado <= {limit} días).")
        else:
            self.add("PM-008", obj,
                     f"El modelo '{obj.name}' tiene un código de limpieza no "
                     f"reconocido ({action}): verificar la política de borrado.",
                     gate="REVIEW")

    # -- G07: tareas de usuario con excepción temporal -------------------------
    DEADLINE_TYPE_DAYS = {0: 1 / 1440, 1: 1 / 24, 2: 1.0, 3: 7.0}

    def _check_user_tasks(self, obj: AppianObject) -> None:
        """G07. Tarea de usuario = <node> con ac/local-id 'internal.17' o con
        <assignments><assignee>. El Start (core.0) con formulario no cuenta."""
        limit = self.th["max_user_task_escalation_days"]
        for node in (el for el in obj.xml.iter() if local_tag(el.tag) == "node"):
            ac = next((c for c in list(node) if local_tag(c.tag) == "ac"), None)
            local_id = direct_child_text(ac, "local-id") if ac is not None else ""
            has_assignee = any(local_tag(e.tag) == "assignee"
                               for el in node.iter() if local_tag(el.tag) == "assignments"
                               for e in list(el))
            if local_id != "internal.17" and not has_assignee:
                continue
            self.stats["userTasks"] += 1
            node_name = self._node_name(node)
            deadline = next((el for el in node.iter()
                             if local_tag(el.tag) == "deadline"), None)
            escalations = next((el for el in node.iter()
                                if local_tag(el.tag) == "escalations"), None)
            if deadline is not None and \
                    direct_child_text(deadline, "enabled").lower() == "true":
                dtype = direct_child_text(deadline, "type")
                dunits = direct_child_text(deadline, "units")
                if dtype.isdigit() and dunits.isdigit() \
                        and int(dtype) in self.DEADLINE_TYPE_DAYS:
                    days = int(dunits) * self.DEADLINE_TYPE_DAYS[int(dtype)]
                    if days > limit:
                        self.add("PM-009", obj,
                                 f"La excepción temporal (deadline) de la tarea "
                                 f"'{node_name}' del modelo '{obj.name}' es de "
                                 f"~{days:g} día(s) (norma: <= {limit} día(s)).")
                    continue
                else:
                    self.add("PM-009", obj,
                             f"La tarea '{node_name}' del modelo '{obj.name}' tiene un "
                             f"deadline con unidades no interpretables "
                             f"(type={dtype or '?'}, units={dunits or '?'}): verificar "
                             f"que la excepción es <= {limit} día(s).", gate="REVIEW")
                    continue
            if escalations is not None and len(list(escalations)) > 0:
                days = self._escalation_days(escalations)
                if days is not None:
                    if days > limit:
                        self.add("PM-009", obj,
                                 f"El escalado de la tarea '{node_name}' del modelo "
                                 f"'{obj.name}' es de ~{days:g} día(s) "
                                 f"(norma: <= {limit} día(s)).")
                    continue
                snippet = re.sub(r"\s+", " ",
                                 ET.tostring(escalations, encoding="unicode"))[:300]
                self.add("PM-009", obj,
                         f"La tarea '{node_name}' del modelo '{obj.name}' tiene "
                         f"escalaciones que no se pudieron interpretar: verificar "
                         f"manualmente que son <= {limit} día(s). "
                         f"Fragmento: {snippet}", gate="REVIEW")
                continue
            self.add("PM-009", obj,
                     f"La tarea de usuario '{node_name}' del modelo '{obj.name}' no tiene "
                     f"excepción/escalado temporal (norma: <= {limit} día(s)).")

    @staticmethod
    def _escalation_days(escalations: ET.Element) -> Optional[float]:
        """Duración máxima (en días) declarada dentro de <escalations>."""
        factors = {"minutes": 1 / 1440, "minute": 1 / 1440,
                   "hours": 1 / 24, "hour": 1 / 24,
                   "days": 1.0, "day": 1.0, "weeks": 7.0, "week": 7.0}
        best: Optional[float] = None
        for el in escalations.iter():
            tag = local_tag(el.tag)
            if tag in factors and el.text and re.match(r"^\d+(\.\d+)?$", el.text.strip()):
                days = float(el.text.strip()) * factors[tag]
                if best is None or days > best:
                    best = days
            for attr, v in el.attrib.items():
                at = local_tag(attr)
                if at in factors and re.match(r"^\d+(\.\d+)?$", v or ""):
                    days = float(v) * factors[at]
                    if best is None or days > best:
                        best = days
            if tag in ("interval", "delay") and el.text \
                    and re.match(r"^\d+(\.\d+)?$", el.text.strip()):
                days = float(el.text.strip())
                if best is None or days > best:
                    best = days
        sub = ET.tostring(escalations, encoding="unicode")
        for m in re.finditer(r"intervalds\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)", sub):
            days = int(m.group(1)) / 24 + int(m.group(2)) / 1440 + int(m.group(3)) / 86400
            if best is None or days > best:
                best = days
        return best

    @staticmethod
    def _node_name(node: ET.Element) -> str:
        # El <ac> hijo directo es la actividad del nodo; los ac anidados
        # (p. ej. dentro de <assignments>) son configuración auxiliar.
        for el in list(node):
            if local_tag(el.tag) == "ac":
                n = direct_child_text(el, "name")
                if n:
                    return n
        for el in node.iter():
            if local_tag(el.tag) == "ac":
                n = direct_child_text(el, "name")
                if n:
                    return n
        return direct_child_text(node, "friendlyname", "name") or "(sin nombre)"

    # -- G10: procesos batch programados ----------------------------------------
    def _check_batch_schedule(self, obj: AppianObject, meta: ET.Element) -> None:
        """G10. Batch = timer-trigger recurrente en pre-triggers del nodo Start
        (local-id core.0). La hora 'HH:MM:SSZ' es UTC: se convierte a la zona
        del PM (timeZoneId del recurrence o meta/timeZoneId vía =pm!timezone).
        """
        pm_tz = direct_child_text(meta, "timezoneid")
        scheduled = False
        for node in (el for el in obj.xml.iter() if local_tag(el.tag) == "node"):
            ac = next((c for c in list(node) if local_tag(c.tag) == "ac"), None)
            local_id = direct_child_text(ac, "local-id") if ac is not None else ""
            node_name = self._node_name(node)
            pre = next((el for el in node.iter()
                        if local_tag(el.tag) == "pre-triggers"), None)
            if pre is None:
                continue
            for trigger in (el for el in pre.iter()
                            if local_tag(el.tag) == "timer-trigger"):
                schedule = next((el for el in trigger.iter()
                                 if local_tag(el.tag) == "schedule"), None)
                recurrence = next((el for el in trigger.iter()
                                   if local_tag(el.tag) == "recurrence"), None)
                is_rec = ((schedule.get("isRecurring")
                           or schedule.get("isrecurring") or "").lower()
                          if schedule is not None else "")
                recurring_timer = is_rec == "true" or recurrence is not None
                if not recurring_timer:
                    continue
                if local_id != "core.0":
                    self.add("PM-013", obj,
                             f"El nodo '{node_name}' del modelo '{obj.name}' tiene un "
                             f"timer recurrente intra-proceso (polling); no se evalúa "
                             f"como proceso batch.", gate="INFO")
                    continue
                scheduled = True
                self._check_batch_trigger(obj, node_name, trigger,
                                          recurrence, pm_tz)
        if scheduled:
            self.stats["scheduledProcesses"] += 1

    def _check_batch_trigger(self, obj: AppianObject, node_name: str,
                             trigger: ET.Element, recurrence: Optional[ET.Element],
                             pm_tz: str) -> None:
        (h1, m1), (h2, m2) = self.batch_window
        window = self.batch_window_text
        if recurrence is None:
            self.add("PM-011", obj,
                     f"El timer del Start del modelo '{obj.name}' es recurrente pero no "
                     f"declara <recurrence>: verificar el horario manualmente "
                     f"(ventana prohibida {window}).", gate="REVIEW")
            return
        ri = next((el for el in recurrence.iter()
                   if local_tag(el.tag) == "recurring-interval"), None)
        time_txt = direct_child_text(ri, "time") if ri is not None else ""
        time_expr = direct_child_text(ri, "timeexpr") if ri is not None else ""
        tz_txt = direct_child_text(recurrence, "timezoneid")
        tz_expr = direct_child_text(recurrence, "timezoneidexpr")

        tz_name = ""
        if tz_txt:
            tz_name = tz_txt
        elif tz_expr:
            if tz_expr.strip().lower() == "=pm!timezone":
                tz_name = pm_tz
            else:
                self.add("PM-011", obj,
                         f"El batch '{obj.name}' usa una zona horaria dinámica "
                         f"('{tz_expr[:80]}'): verificar el horario manualmente "
                         f"(ventana prohibida {window}).", gate="REVIEW")
                return

        local_times: List[Tuple[int, int]] = []
        winter_summer = False
        utc_txt = ""
        if time_txt:
            m = re.match(r"^(\d{1,2}):(\d{2}):(\d{2})Z$", time_txt.strip())
            if not m:
                self.add("PM-011", obj,
                         f"El batch '{obj.name}' tiene una hora no interpretable "
                         f"('{time_txt}'): verificar el horario manualmente.",
                         gate="REVIEW")
                return
            utc_txt = f"{int(m.group(1)):02d}:{m.group(2)} UTC"
            if tz_name:
                conv = self._convert_tz(int(m.group(1)), int(m.group(2)), tz_name)
                if conv is None:
                    self.add("PM-011", obj,
                             f"No se pudo convertir la hora del batch '{obj.name}' "
                             f"({utc_txt}) a la zona '{tz_name}': verificar el "
                             f"horario manualmente (ventana prohibida {window}).",
                             gate="REVIEW")
                    return
                local_times = conv
                winter_summer = len(set(conv)) > 1
            else:
                local_times = [(int(m.group(1)), int(m.group(2)))]
        elif time_expr:
            lit = re.match(r'^=\s*"\s*(\d{1,2}):(\d{2})(?:\s*(AM|PM))?\s*"\s*$',
                           time_expr.strip(), re.I)
            if lit:
                h = int(lit.group(1))
                if lit.group(3) and lit.group(3).upper() == "PM" and h < 12:
                    h += 12
                if lit.group(3) and lit.group(3).upper() == "AM" and h == 12:
                    h = 0
                local_times = [(h, int(lit.group(2)))]
            else:
                self.add("PM-011", obj,
                         f"El batch '{obj.name}' calcula su hora con la expresión "
                         f"'{time_expr[:80]}': verificar el horario manualmente "
                         f"(ventana prohibida {window}).", gate="REVIEW")
                return
        else:
            self.add("PM-011", obj,
                     f"El batch '{obj.name}' no declara hora de ejecución: verificar "
                     f"el horario manualmente (ventana prohibida {window}).",
                     gate="REVIEW")
            return

        # conv devuelve [invierno, verano] cuando hay tz con DST.
        hw, hs = local_times[0], local_times[-1]

        def _fmt(t: Tuple[int, int]) -> str:
            return (f"{t[0]:02d}:{t[1]:02d} {tz_name}" if tz_name
                    else f"{t[0]:02d}:{t[1]:02d} (hora del servidor)")

        desc = (f"{_fmt(hs)} en verano / {_fmt(hw)} en invierno"
                if winter_summer else _fmt(hw))
        in_win = [(h1, m1) <= t < (h2, m2) for t in (hw, hs)]
        suffix = f" ({utc_txt})" if utc_txt else ""
        if all(in_win):
            self.add("PM-011", obj,
                     f"El proceso batch '{obj.name}' está programado a las {desc}"
                     + suffix
                     + f", dentro de la ventana prohibida {window}.")
        elif any(in_win):
            self.add("PM-011", obj,
                     f"El proceso batch '{obj.name}' está programado a las {desc}"
                     + suffix
                     + f": cae dentro de la ventana prohibida {window} solo en "
                     "una época del año (cambio de hora): verificar manualmente.",
                     gate="REVIEW")
        else:
            self.add("PM-010", obj,
                     f"Proceso batch '{obj.name}' programado a las {desc}"
                     + suffix
                     + ": fuera de la ventana prohibida. Revisar que coincide con "
                     "el horario de menor carga en Site Gestión de Procesos > "
                     "Batch model process management.", gate="INFO")

    @staticmethod
    def _convert_tz(hour: int, minute: int,
                    tz_name: str) -> Optional[List[Tuple[int, int]]]:
        """Convierte una hora UTC a la zona indicada en dos fechas (15 de enero
        y 15 de julio) para cubrir el cambio de hora (DST). Devuelve
        [hora_invierno, hora_verano] o None si la zona no existe."""
        try:
            from zoneinfo import ZoneInfo
        except ImportError:
            return None
        try:
            tz = ZoneInfo(tz_name)
        except Exception:
            return None
        out = []
        for month in (1, 7):
            dt = datetime(2024, month, 15, hour, minute, tzinfo=timezone.utc)
            local = dt.astimezone(tz)
            out.append((local.hour, local.minute))
        return out

    # -- checks de record types -------------------------------------------------
    def check_record_type(self, obj: AppianObject) -> None:
        """G08. Sincronizado = <source xsi:type='...:RecordsReplica'/>.
        refreshSchedule.value es un JSON {hour, minute, amPM, timeZone,
        dayOfWeek}: sin dayOfWeek => full sync diaria."""
        if obj.xml is None:
            return
        is_synced = False
        for el in obj.xml.iter():
            if local_tag(el.tag) != "source":
                continue
            for v in el.attrib.values():
                if "recordsreplica" in str(v).lower():
                    is_synced = True
        if not is_synced:
            return
        self.stats["syncedRecords"] += 1

        source_type = first_text(obj.xml, "sourcetype")
        if source_type.upper().startswith("RDBMS"):
            self.add("REC-002", obj,
                     f"El record '{obj.name}' está sincronizado sobre una fuente "
                     f"RDBMS ({source_type}): vigilar los límites de filas "
                     f"sincronizadas.", gate="INFO")

        sched = next((el for el in obj.xml.iter()
                      if local_tag(el.tag) == "refreshschedule"), None)
        if sched is None:
            return
        activated = direct_child_text(sched, "activated").lower() == "true"
        if not activated:
            return
        sched_json = {}
        val = direct_child_text(sched, "value")
        try:
            sched_json = json.loads(val) if val else {}
        except json.JSONDecodeError:
            self.add("REC-001", obj,
                     f"El record '{obj.name}' tiene una programación de sync activa "
                     f"que no se pudo interpretar: verificar que no es diaria.",
                     gate="REVIEW")
            return
        hour = sched_json.get("hour", "?")
        minute = sched_json.get("minute", "00")
        ampm = sched_json.get("amPM", "")
        dow = str(sched_json.get("dayOfWeek", "") or "").strip()
        tz = sched_json.get("timeZone", "")
        if dow:
            self.add("REC-001", obj,
                     f"El record '{obj.name}' tiene un full sync semanal "
                     f"programado ({hour}:{minute} {ampm} {tz}, día {dow}): "
                     f"cumple la norma (no diario).", gate="INFO")
        else:
            self.add("REC-001", obj,
                     f"El record '{obj.name}' tiene programada una sincronización "
                     f"completa DIARIA a las {hour}:{minute} {ampm} {tz}; con un buen "
                     f"diseño de sync (incremental / smart services) no debería ser "
                     f"necesaria.")

    # -- checks de tipos de datos -------------------------------------------------
    def check_data_type(self, obj: AppianObject) -> None:
        if obj.xml is None:
            return
        fields = [el for el in obj.xml.iter() if local_tag(el.tag) == "element"]
        if len(fields) > self.th["max_cdt_fields"]:
            self.add("DAT-001", obj,
                     f"El tipo '{obj.name}' tiene {len(fields)} campos "
                     f"(recomendado: <= {self.th['max_cdt_fields']}).")

    # -- dependencias dentro del paquete -------------------------------------------
    DEPENDENCY_TYPES = {"expressionRule", "interface", "constant", "decision",
                        "outboundIntegration", "processModel", "recordType"}
    # Objetos "raíz" en un export de aplicación: puntos de entrada que no
    # necesitan referencias entrantes internas.
    ROOT_TYPES = {"site", "webApi", "recordType", "group", "folder",
                  "dataType", "dataStore", "application", "portal",
                  "document", "connectedSystem", "translationSet",
                  "package", "unknown"}

    def _is_root_object(self, obj: AppianObject) -> bool:
        if obj.objectType in self.ROOT_TYPES:
            return True
        if obj.objectType == "constant" and obj.envSpecific is True:
            return True
        if obj.objectType == "processModel" and obj.xml is not None:
            # Punto de entrada si el Start tiene formulario o timer
            for node in (el for el in obj.xml.iter() if local_tag(el.tag) == "node"):
                ac = next((c for c in list(node) if local_tag(c.tag) == "ac"), None)
                if ac is None or direct_child_text(ac, "local-id") != "core.0":
                    continue
                sub = ET.tostring(node, encoding="unicode").lower()
                if "<timer-trigger" in sub or "<form-config" in sub \
                        or "<form-map" in sub:
                    return True
            return False
        return False

    def check_dependencies(self, objects: List[AppianObject]) -> None:
        kind = self.manifest.get("kind", "package") if self.manifest else "package"
        seen_files = set()
        parts = []
        for o in objects:
            if o.file not in seen_files and o.fileText:
                seen_files.add(o.file)
                parts.append(o.fileText)
        full_text = "\n".join(parts).lower()
        for obj in objects:
            if obj.objectType not in self.DEPENDENCY_TYPES or not obj.fileText:
                continue
            own = obj.fileText.lower()
            inbound = 0
            tokens = []
            if obj.uuid and len(obj.uuid) >= 8:
                tokens.append(obj.uuid.lower())
            if obj.objectType in ("expressionRule", "interface", "decision", "outboundIntegration"):
                tokens.append(f"rule!{obj.name.lower()}")
            if obj.objectType == "constant":
                tokens.append(f"cons!{obj.name.lower()}")
            for token in tokens:
                inbound += max(0, full_text.count(token) - own.count(token))
            if inbound > 0:
                continue
            self.stats["orphanObjects"] += 1
            if kind != "application":
                self.add("DEPN-002", obj,
                         f"Ningún objeto del paquete referencia a '{obj.name}' "
                         f"({obj.objectTypeLabel}); al ser un paquete parcial no se "
                         f"pueden verificar dependencias externas.", gate="REVIEW")
            elif self._is_root_object(obj):
                continue
            else:
                self.add("DEPN-001", obj,
                         f"Ningún otro objeto de la aplicación referencia a "
                         f"'{obj.name}' ({obj.objectTypeLabel}). Puede referenciarlo "
                         f"otra aplicación: confirmar dependencias en Appian y "
                         f"borrarlo del paquete o justificar a OT.")

    # -- cruce con Health Check ------------------------------------------------------
    def check_health_check(self, objects: List[AppianObject],
                           hc_findings: List[Dict[str, str]],
                           pkg_obj: AppianObject, app_name: str = "") -> None:
        """Cruza los riesgos del Health Check con los objetos del paquete:
        por UUID (confianza HIGH), por nombre normalizado (MEDIUM), por
        nombre de aplicación (applicationRisks) o de plataforma."""
        object_risks: List[Dict[str, str]] = []
        app_risks: List[Dict[str, str]] = []
        platform_risks: List[Dict[str, str]] = []
        stats = dict(byUuid=0, byName=0, unmatched=0)
        candidates = []
        for o in objects:
            uid = o.uuid.lower() if o.uuid and len(o.uuid) >= 12 else ""
            nn = normalize_name(o.name)
            candidates.append((o, uid, nn if len(nn) >= 6 else ""))
        norm_app = normalize_name(app_name)
        seen = set()
        for hc in hc_findings:
            text_lower = hc["text"].lower()
            text_norm = normalize_name(hc["text"])
            parts = [p for p in (hc.get("findingId"), hc.get("description")) if p]
            detail = hc.get("detail", "")[:180]
            target = next((o for o, uid, _ in candidates if uid and uid in text_lower),
                          None)
            method, confidence = "byUuid", "HIGH"
            if target is None:
                target = next((o for o, _, nn in candidates if nn and nn in text_norm),
                              None)
                method, confidence = "byName", "MEDIUM"
            if target is not None:
                if method == "byUuid":
                    stats["byUuid"] += 1
                else:
                    stats["byName"] += 1
                check = "HC-001" if hc["risk"] == "HIGH" else "HC-001"
                key = (target.name, hc.get("findingId", ""), hc.get("description", "")[:60])
                if key not in seen:
                    seen.add(key)
                    if hc["risk"] == "HIGH":
                        self.add("HC-001", target,
                                 f"Health Check reporta riesgo ALTO sobre "
                                 f"'{target.name}' ({' - '.join(parts)}; match "
                                 f"{method}, confianza {confidence}). "
                                 f"Detalle: {detail}")
                    else:
                        self.add("HC-002", target,
                                 f"Health Check reporta riesgo MEDIO sobre "
                                 f"'{target.name}' ({' - '.join(parts)}; match "
                                 f"{method}, confianza {confidence}). "
                                 f"Detalle: {detail}", gate="INFO")
                object_risks.append(dict(
                    risk=hc["risk"], findingId=hc.get("findingId", ""),
                    description=hc.get("description", ""), detail=detail,
                    object=target.name, objectUuid=target.uuid,
                    matchMethod=method, confidence=confidence))
                continue
            if norm_app and len(norm_app) >= 6 and (norm_app in text_norm
                    or norm_app in normalize_name(hc.get("appName", ""))):
                check = "HC-002"
                key = (check, hc.get("findingId", ""), hc.get("description", "")[:60])
                if key not in seen:
                    seen.add(key)
                    self.add("HC-002", pkg_obj,
                             f"Health Check reporta riesgo {hc['risk']} sobre la "
                             f"aplicación desplegada ({' - '.join(parts)}). "
                             f"Detalle: {detail}", gate="INFO")
                app_risks.append(dict(
                    risk=hc["risk"], findingId=hc.get("findingId", ""),
                    description=hc.get("description", ""), detail=detail,
                    matchMethod="byApplication", confidence="HIGH"))
                continue
            stats["unmatched"] += 1
            platform_risks.append(dict(
                risk=hc["risk"], findingId=hc.get("findingId", ""),
                description=hc.get("description", ""), detail=detail,
                matchMethod="none", confidence="-"))
        if platform_risks:
            n_high = sum(1 for r in platform_risks if r["risk"] == "HIGH")
            self.add("HC-003", pkg_obj,
                     f"El Health Check reporta {len(platform_risks)} riesgo(s) de "
                     f"plataforma que no citan objetos del paquete "
                     f"({n_high} altos): trasladarlos al equipo correspondiente.",
                     gate="INFO")
        self.hc_info.update(
            rows=len(hc_findings),
            objectRisks=object_risks, applicationRisks=app_risks,
            platformRisks=platform_risks, matchStats=stats)
        self.hc_totals = dict(
            high=sum(1 for h in hc_findings if h["risk"] == "HIGH"),
            medium=sum(1 for h in hc_findings if h["risk"] == "MEDIUM"),
        )


def infer_dominant_prefix(objects: List[AppianObject]) -> Optional[str]:
    counter: Counter = Counter()
    total = 0
    for obj in objects:
        if obj.objectType not in ("expressionRule", "interface", "constant",
                                  "decision", "processModel", "recordType"):
            continue
        total += 1
        m = re.match(r"^([A-Za-z]{2,6})[_ ]", obj.name)
        if m:
            counter[m.group(1).upper()] += 1
    if not counter or total < 3:
        return None
    prefix, count = counter.most_common(1)[0]
    return prefix if count >= max(3, 0.6 * total) else None


# ---------------------------------------------------------------------------
# Gates y monitorización
# ---------------------------------------------------------------------------

GATE_CHECK_IDS = {cid for g in GATES for cid in g["checks"]}


def build_gates(analyzer: Analyzer, justifications: Dict[str, dict],
                just_report: dict) -> List[Dict]:
    """El veredicto depende SOLO de los gates: FAIL sin justificar => NO_APTO;
    REVIEW/JUSTIFIED => APTO_CON_CONDICIONES; todo PASS/NA => APTO.
    Los hallazgos heurísticos no afectan al veredicto (salvo gate opcional
    G11 de calidad)."""
    stats = analyzer.stats
    hc_status = analyzer.hc_info.get("status", "MISSING")

    def justification_text(key: str) -> str:
        j = justifications.get(key)
        return j["text"] if j else ""

    gates_out: List[Dict] = []
    for gate in GATES:
        gid = gate["id"]
        related = [f for f in analyzer.findings if f.checkId in gate["checks"]]
        fails = [f for f in related if f.gateStatus == "FAIL"]
        reviews = [f for f in related if f.gateStatus == "REVIEW"]
        status = "PASS"
        details = gate["detail"]

        if gid == "G01":
            status = "REVIEW"
            details = ("Aplicar las recomendaciones de la sección "
                       "monitoringRecommendations y confirmar la monitorización tras el despliegue.")
        elif gid == "G02":
            if not stats.get("hcProvided"):
                status = "REVIEW"
                details = ("No se aportó informe de Health Check (--health-check); "
                           "adjuntarlo para validar este control.")
            elif hc_status == "EMPTY":
                status = "REVIEW"
                details = ("El Health Check aportado está vacío (cabeceras sin filas "
                           "interpretables); no se puede validar este control.")
            elif analyzer.hc_info.get("stale"):
                status = "REVIEW"
                details = (f"El Health Check tiene {analyzer.hc_info.get('ageDays')} días "
                           f"(máximo {analyzer.hc_info.get('maxAgeDays')}): está caducado, "
                           "aportar uno reciente.")
            else:
                status = "FAIL" if fails else "PASS"
        elif gid in ("G03", "G04"):
            if fails:
                status = "FAIL"
            elif reviews:
                status = "REVIEW"
                details = ("Hay modelos de proceso cuya configuración no se pudo "
                           "verificar offline (ver hallazgos).")
            elif not stats.get("processModels"):
                status = "NA"
        elif gid == "G05":
            if fails:
                status = "FAIL"
                details = (f"{len(fails)} objeto(s) sin referencias en la aplicación: "
                           "confirmar en Appian (pueden usarse desde otra aplicación), "
                           "borrarlos o justificar a OT.")
            elif reviews:
                status = "REVIEW"
                details = ("Paquete parcial u objetos no analizables: las dependencias "
                           "externas no se pueden verificar offline.")
        elif gid == "G06":
            if not stats.get("perfProvided"):
                status = "REVIEW"
                details = "No se aportaron resultados de pruebas de rendimiento (--perf-results); aportarlos o justificar a OT."
            else:
                status = "FAIL" if stats.get("perfFailures") else "PASS"
        elif gid == "G07":
            if fails:
                status = "FAIL"
            elif reviews:
                status = "REVIEW"
                details = ("Hay tareas de usuario con escalados no interpretables "
                           "o modelos no analizables.")
            elif not stats.get("userTasks"):
                status = "NA"
        elif gid == "G08":
            if fails:
                status = "FAIL"
            elif reviews:
                status = "REVIEW"
            elif not stats.get("syncedRecords"):
                status = "NA"
        elif gid == "G09":
            if fails:
                status = "FAIL"
            elif reviews:
                status = "REVIEW"
        elif gid == "G10":
            if fails:
                status = "FAIL"
            elif reviews:
                status = "REVIEW"
                details = ("Hay temporizadores cuyo horario no se pudo verificar: revisar "
                           "manualmente contra la ventana prohibida y el horario de menor "
                           "carga en Site Gestión de Procesos > Batch model process management.")
            elif not stats.get("scheduledProcesses"):
                status = "NA"

        # Justificación: la clave del gate justifica todo el gate; si no,
        # todas las findings FAIL deben estar justificadas.
        justification = justifications.get(gid)
        if justification:
            just_report["applied"].append(dict(
                key=gid, scope="gate", **justification))
            if status in ("FAIL", "REVIEW"):
                status = "JUSTIFIED"
        elif status == "FAIL" and fails and all(f.justification for f in fails):
            status = "JUSTIFIED"
        gates_out.append(dict(
            id=gid,
            title=gate["title"],
            status=status,
            statusLabel=GATE_STATUS_LABEL[status],
            findings=len(related),
            relatedChecks=gate["checks"],
            details=details,
            justification=justification["text"] if justification else "",
            justificationRequired=status in ("FAIL", "REVIEW"),
        ))

    if analyzer.quality_gate["enabled"]:
        unjustified_high = [f for f in analyzer.findings
                            if f.severity == "HIGH" and not f.justification
                            and f.checkId not in GATE_CHECK_IDS]
        qg_status = "FAIL" if len(unjustified_high) > analyzer.quality_gate["maxHigh"] \
            else "PASS"
        gates_out.append(dict(
            id="G11",
            title="Calidad de código",
            status=qg_status,
            statusLabel=GATE_STATUS_LABEL[qg_status],
            findings=len(unjustified_high),
            relatedChecks=[],
            details=(f"Hallazgos heurísticos de severidad alta sin justificar: "
                     f"{len(unjustified_high)} (máximo permitido: "
                     f"{analyzer.quality_gate['maxHigh']})."),
            justification="",
            justificationRequired=qg_status == "FAIL",
        ))
    return gates_out


EXIT_BY_VERDICT = {"APTO": 0, "APTO_CON_CONDICIONES": 3, "NO_APTO": 1, "ERROR": 2}


def gate_verdict(gates: List[Dict], errors: List[str]) -> Tuple[str, str]:
    if errors:
        return "ERROR", ("Error de análisis: " + " | ".join(errors[:3]))
    if any(g["status"] == "FAIL" for g in gates):
        return "NO_APTO", "No apto para PRO: hay gates en incumplimiento sin justificar a OT."
    if any(g["status"] in ("REVIEW", "JUSTIFIED") for g in gates):
        return "APTO_CON_CONDICIONES", ("Apto con condiciones: hay controles pendientes de "
                                        "revisión manual o justificados a OT.")
    return "APTO", "Apto para PRO: todos los controles se cumplen."


def build_monitoring(objects: List[AppianObject]) -> List[Dict]:
    by_type: Dict[str, List[str]] = {}
    for obj in objects:
        if obj.objectType in MONITORING_CATALOG:
            by_type.setdefault(obj.objectType, []).append(obj.name)
    out = []
    for otype, names in sorted(by_type.items()):
        out.append(dict(
            objectType=otype,
            objectTypeLabel=OBJECT_TYPE_LABELS.get(otype, otype),
            objects=sorted(names)[:50],
            objectCount=len(names),
            recommendations=MONITORING_CATALOG[otype],
        ))
    return out


# ---------------------------------------------------------------------------
# Informe
# ---------------------------------------------------------------------------

def compute_score(findings: List[Finding], n_objects: int) -> float:
    """Score 0-100 normalizado por número de objetos analizados."""
    penalty = sum(SEVERITY_WEIGHT[f.severity] for f in findings)
    return round(max(0.0, 100.0 - penalty / max(1, n_objects)), 1)


def apply_justifications(findings: List[Finding], justifications: Dict[str, dict],
                         allow_generic: bool, just_report: dict) -> None:
    """Prioridad: 'CHECK:Objeto' > 'Gxx' (gate, en build_gates) > 'CHECK'
    genérico (solo si allowGenericJustifications)."""
    used = set()
    for f in findings:
        specific = justifications.get(f"{f.checkId}:{f.objectName}")
        generic = justifications.get(f.checkId)
        if specific is not None:
            f.justification = specific["text"]
            used.add(f"{f.checkId}:{f.objectName}")
            just_report["applied"].append(dict(
                key=f"{f.checkId}:{f.objectName}", scope="object", **specific))
        elif generic is not None:
            if allow_generic:
                f.justification = generic["text"]
                used.add(f.checkId)
                just_report["applied"].append(dict(
                    key=f.checkId, scope="check", **generic))
            else:
                just_report["ignored"].append(dict(
                    key=f.checkId, scope="check", **generic,
                    reason="Justificación genérica ignorada: activar "
                           "allowGenericJustifications para aplicarla."))
                just_report["ignored_keys"].add(f.checkId)
    for key, j in justifications.items():
        if key in used or re.match(r"^G\d{2}$", key) \
                or key in just_report["ignored_keys"]:
            continue
        just_report["pending"].append(dict(key=key, **j))


def build_report(package_path: str, objects: List[AppianObject],
                 analyzer: Analyzer, justifications: Dict[str, dict]) -> dict:
    findings = analyzer.findings
    just_report: Dict = dict(applied=[], ignored=[], pending=[], ignored_keys=set())
    apply_justifications(findings, justifications,
                         analyzer.allow_generic_justifications, just_report)
    findings_sorted = sorted(
        findings, key=lambda f: (SEVERITY_ORDER[f.severity], f.objectName, f.checkId))
    for i, f in enumerate(findings_sorted, 1):
        f.findingId = f"F{i:04d}"

    gates = build_gates(analyzer, justifications, just_report)
    pending_keys = {p["key"] for p in just_report["pending"]}
    for g in gates:
        if g["justificationRequired"] and not g["justification"] \
                and g["id"] not in pending_keys:
            pending_keys.add(g["id"])
            just_report["pending"].append(dict(key=g["id"], scope="gate"))
        for f in findings:
            key = f"{f.checkId}:{f.objectName}"
            if f.checkId in g["relatedChecks"] and f.gateStatus == "FAIL" \
                    and not f.justification and g["status"] != "JUSTIFIED" \
                    and key not in pending_keys:
                pending_keys.add(key)
                just_report["pending"].append(dict(key=key, scope="object"))
    just_report["ignored_keys"] = sorted(just_report["ignored_keys"])
    verdict, verdict_detail = gate_verdict(gates, analyzer.analysis["errors"])

    by_severity = Counter(f.severity for f in findings)
    by_category = Counter(f.categoryLabel for f in findings)
    by_type = Counter(f.objectTypeLabel for f in findings)

    weight_per_object: Counter = Counter()
    for f in findings:
        weight_per_object[(f.objectName, f.objectTypeLabel)] += SEVERITY_WEIGHT[f.severity]
    top_objects = [
        dict(objectName=name, objectType=otype,
             findings=sum(1 for f in findings if f.objectName == name),
             weight=round(w, 1))
        for (name, otype), w in weight_per_object.most_common(10) if w > 0
    ]

    # Un resultado por objeto del paquete, con sus hallazgos anidados.
    findings_by_obj: Dict[Tuple[str, str], List[Finding]] = {}
    package_findings: List[Finding] = []
    obj_keys = {(o.name, o.uuid) for o in objects}
    for f in findings_sorted:
        key = (f.objectName, f.objectUuid)
        if key in obj_keys:
            findings_by_obj.setdefault(key, []).append(f)
        else:
            package_findings.append(f)

    def obj_entry(o: AppianObject) -> dict:
        ffs = findings_by_obj.get((o.name, o.uuid), [])
        sev = Counter(f.severity for f in ffs)
        weight = sum(SEVERITY_WEIGHT[f.severity] for f in ffs)
        return dict(
            name=o.name, type=o.objectType, typeLabel=o.objectTypeLabel,
            uuid=o.uuid, file=o.file,
            hasDescription=bool(o.description.strip()),
            status="OK" if not ffs else "FINDINGS",
            statusLabel="Correcto" if not ffs else "Con hallazgos",
            findingsCount=len(ffs),
            bySeverity=dict(high=sev.get("HIGH", 0), medium=sev.get("MEDIUM", 0),
                            low=sev.get("LOW", 0), info=sev.get("INFO", 0)),
            weight=round(weight, 1),
            findings=[asdict(f) for f in ffs],
        )

    objects_out = sorted((obj_entry(o) for o in objects),
                         key=lambda e: (-e["weight"], e["typeLabel"], e["name"].lower()))

    used_checks = {f.checkId for f in findings}
    catalog = [
        dict(checkId=cid, title=CHECKS[cid]["title"],
             category=CHECKS[cid]["category"],
             categoryLabel=CATEGORY_LABEL[CHECKS[cid]["category"]],
             defaultSeverity=CHECKS[cid]["severity"],
             description=CHECKS[cid]["description"],
             recommendation=CHECKS[cid]["recommendation"],
             reference=CHECKS[cid].get("reference", ""))
        for cid in sorted(CHECKS) if cid in used_checks
    ]

    hc = analyzer.hc_info
    hc_section = dict(
        status=hc.get("status", "MISSING"),
        provided=bool(analyzer.stats.get("hcProvided")),
        file=os.path.basename(analyzer.hc_path) if analyzer.hc_path else "",
        date=hc.get("date"),
        ageDays=hc.get("ageDays"),
        maxAgeDays=analyzer.hc_max_age_days,
        stale=bool(hc.get("stale")),
        rows=hc.get("rows", 0),
        objectRisks=hc.get("objectRisks", []),
        applicationRisks=hc.get("applicationRisks", []),
        platformRisks=hc.get("platformRisks", []),
        matchStats=hc.get("matchStats", dict(byUuid=0, byName=0, unmatched=0)),
    )
    _obj = hc_section["objectRisks"]
    _plat = hc_section["applicationRisks"] + hc_section["platformRisks"]
    hc_section.update(
        packageHighRisks=sum(1 for r in _obj if r["risk"] == "HIGH"),
        packageMediumRisks=sum(1 for r in _obj if r["risk"] == "MEDIUM"),
        platformHighRisks=sum(1 for r in _plat if r["risk"] == "HIGH"),
        platformMediumRisks=sum(1 for r in _plat if r["risk"] == "MEDIUM"),
        matchedFindings=_obj,
    )

    inv = analyzer.manifest
    inventory = dict(
        source=inv.get("source", "") if inv else "(sin manifiesto)",
        kind=inv.get("kind", "") if inv else "",
        packageName=inv.get("packageName", "") if inv else "",
        applicationUuid=inv.get("applicationUuid", "") if inv else "",
        expectedObjects=inv.get("expectedObjects", len(objects)) if inv else len(objects),
        analyzedObjects=inv.get("analyzedObjects", len(objects)) if inv else len(objects),
        byType=[dict(type=t, typeLabel=MANIFEST_TYPE_LABELS.get(t.lower(), t), count=n)
                for t, n in sorted((inv.get("byType") or {}).items())] if inv else [],
        missingUuids=inv.get("missingUuids", []) if inv else [],
        externalPrecedents=inv.get("externalPrecedents", []) if inv else [],
    )

    score = compute_score(findings, len(objects))
    return dict(
        report=dict(
            tool="Appian Static Analyzer",
            version=VERSION,
            package=os.path.basename(package_path),
            analyzedAt=datetime.now(timezone.utc).isoformat(timespec="seconds"),
            appianVersion=analyzer.appian_version,
            dominantPrefix=analyzer.dominant_prefix or "",
            totalObjects=len(objects),
            totalFindings=len(findings),
            batchWindow=analyzer.batch_window_text,
        ),
        summary=dict(
            qualityScore=score,
            scoreMethod=("100 - (peso de hallazgos / objetos analizados); "
                         "pesos: alta 8, media 3, baja 1, info 0"),
            qualityLevel=("Excelente" if score >= 90 else
                          "Bueno" if score >= 75 else
                          "Mejorable" if score >= 50 else "Crítico"),
            bySeverity=dict(
                high=by_severity.get("HIGH", 0),
                medium=by_severity.get("MEDIUM", 0),
                low=by_severity.get("LOW", 0),
                info=by_severity.get("INFO", 0),
            ),
            byCategory=[dict(category=k, findings=v) for k, v in by_category.most_common()],
            byObjectType=[dict(objectType=k, findings=v) for k, v in by_type.most_common()],
            topObjects=top_objects,
        ),
        deploymentGate=dict(
            verdict=verdict,
            verdictLabel={"APTO": "APTO PARA PRO",
                          "APTO_CON_CONDICIONES": "APTO CON CONDICIONES",
                          "NO_APTO": "NO APTO PARA PRO",
                          "ERROR": "ERROR DE ANÁLISIS"}[verdict],
            verdictDetail=verdict_detail,
            exitCode=EXIT_BY_VERDICT[verdict],
            pendingJustifications=[g["id"] for g in gates
                                   if g["justificationRequired"] and not g["justification"]],
            gates=gates,
        ),
        inventory=inventory,
        monitoringRecommendations=build_monitoring(objects),
        healthCheck=hc_section,
        analysis=analyzer.analysis,
        justifications={k: v for k, v in just_report.items()
                        if k != "ignored_keys"},
        objects=objects_out,
        packageFindings=[asdict(f) for f in package_findings],
        findings=[asdict(f) for f in findings_sorted],
        checksCatalog=catalog,
    )


def write_csv(path: str, findings_dicts: List[dict]) -> None:
    cols = ["findingId", "checkId", "severity", "severityLabel", "category",
            "categoryLabel", "objectType", "objectTypeLabel", "objectName",
            "objectUuid", "file", "line", "title", "message", "recommendation",
            "snippet", "justification", "reference"]
    with open(path, "w", newline="", encoding="utf-8-sig") as fh:
        writer = csv.DictWriter(fh, fieldnames=cols, delimiter=";")
        writer.writeheader()
        for row in findings_dicts:
            writer.writerow({c: row.get(c, "") for c in cols})


def build_verdict_json(report: dict, analyzer: Analyzer) -> dict:
    g = report["deploymentGate"]
    hc = report["healthCheck"]
    inv = report["inventory"]
    cov = report["analysis"].get("coverage", {})
    return dict(
        verdict=g["verdict"],
        verdictLabel=g["verdictLabel"],
        exitCode=EXIT_BY_VERDICT[g["verdict"]],
        gates=[dict(id=gt["id"], status=gt["status"], title=gt["title"],
                    findings=gt["findings"], justification=gt["justification"])
               for gt in g["gates"]],
        pendingJustifications=g["pendingJustifications"],
        healthCheck=dict(status=hc["status"], date=hc["date"],
                         ageDays=hc["ageDays"], stale=hc["stale"]),
        coverage=cov,
        package=dict(name=inv.get("packageName") or report["report"]["package"],
                     kind=inv.get("kind", ""),
                     applicationUuid=inv.get("applicationUuid", "")),
        analyzerVersion=VERSION,
        generatedAt=report["report"]["analyzedAt"],
    )


def write_markdown(path: str, report: dict) -> None:
    """Resumen Markdown para $GITHUB_STEP_SUMMARY o comentario de PR."""
    g = report["deploymentGate"]
    hc = report["healthCheck"]
    cov = report["analysis"].get("coverage", {})
    icons = {"PASS": "✅", "FAIL": "❌", "REVIEW": "🔍",
             "JUSTIFIED": "📝", "NA": "➖"}
    lines = [
        f"# Gate de despliegue a PRO — {report['report']['package']}",
        "",
        f"**Veredicto: {g['verdictLabel']}** — {g['verdictDetail']}",
        "",
        "| Gate | Control | Estado | Hallazgos |",
        "|------|---------|--------|-----------|",
    ]
    for gt in g["gates"]:
        lines.append(f"| {gt['id']} | {gt['title']} | "
                     f"{icons.get(gt['status'], '')} {gt['statusLabel']} | "
                     f"{gt['findings']} |")
    lines.append("")
    if hc["status"] != "MISSING":
        lines.append(f"**Health Check**: {hc['status']} "
                     f"({hc['file'] or '—'}, fecha: {hc['date'] or 'desconocida'}"
                     + (f", {hc['ageDays']} días{' — CADUCADO' if hc['stale'] else ''}"
                        if hc.get('ageDays') is not None else "") + ")")
    else:
        lines.append("**Health Check**: no aportado")
    if cov:
        lines.append(
            f"**Cobertura**: {cov.get('manifestObjects', 0)} objetos del "
            f"manifiesto, {cov.get('analyzedFiles', cov.get('parsedOk', 0))} "
            f"ficheros analizados, {cov.get('parseFailed', 0)} no parseables "
            f"({cov.get('ratio', 0):.0%})")
    fail_checks = {c for gt in g["gates"] if gt["status"] == "FAIL"
                   for c in gt["relatedChecks"]}
    fails = [f for f in report["findings"]
             if f.get("gateStatus") == "FAIL" and f["checkId"] in fail_checks
             and not f.get("justification")]
    if fails:
        lines += ["", "## Hallazgos que bloquean", ""]
        for f in fails[:30]:
            loc = f"{f['file']}:{f['line']}" if f.get("line") else f["file"]
            lines.append(f"- **{f['checkId']}** `{f['objectName']}` ({loc}) — "
                         f"{f['message']}")
        if len(fails) > 30:
            lines.append(f"- ... y {len(fails) - 30} más (ver informe JSON)")
    pend = [p["key"] for p in report["justifications"].get("pending", [])]
    if pend:
        lines += ["", "## Pendientes de justificación a OT", ""]
        lines += [f"- `{k}`" for k in pend[:30]]
    heur = [f for f in report["findings"] if f["checkId"] not in fail_checks
            and f["severity"] != "INFO"][:10]
    if heur:
        lines += ["", "## Buenas prácticas (no bloqueantes)", ""]
        for f in heur:
            lines.append(f"- [{f['severityLabel']}] **{f['checkId']}** "
                         f"`{f['objectName']}` — {f['title']}")
    lines.append("")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))


GATE_ICONS = {"PASS": "[OK]", "FAIL": "[X] ", "REVIEW": "[?] ",
              "JUSTIFIED": "[J] ", "NA": "[- ]"}


def print_summary(report: dict, stream=sys.stdout) -> None:
    r, s, g = report["report"], report["summary"], report["deploymentGate"]
    sev = s["bySeverity"]
    lines = [
        "",
        "=" * 74,
        f"  ANÁLISIS ESTÁTICO APPIAN · {r['package']}",
        "=" * 74,
        f"  Veredicto gate PRO : {g['verdictLabel']}",
        f"  Objetos analizados : {r['totalObjects']}",
        f"  Hallazgos          : {r['totalFindings']}  "
        f"(Alta: {sev['high']} · Media: {sev['medium']} · "
        f"Baja: {sev['low']} · Info: {sev['info']})",
        f"  Puntuación         : {s['qualityScore']}/100 ({s['qualityLevel']})",
        f"  Prefijo detectado  : {r['dominantPrefix'] or '(ninguno)'}",
    ]
    inv = report.get("inventory", {})
    if inv.get("source"):
        types = ", ".join(f"{t['type']}: {t['count']}" for t in inv.get("byType", []))
        lines.append(f"  Manifiesto         : {inv['expectedObjects']} objetos declarados "
                     f"({inv['source']}){' · ' + types if types else ''}")
    hc = report.get("healthCheck", {})
    if hc.get("provided"):
        obj_risks = hc.get("objectRisks", [])
        lines.append(f"  Health Check       : {hc['file']} ({hc.get('status', '')}) · "
                     f"riesgos sobre objetos del paquete: "
                     f"{sum(1 for r in obj_risks if r['risk'] == 'HIGH')} altos, "
                     f"{sum(1 for r in obj_risks if r['risk'] == 'MEDIUM')} medios")
    lines += [
        "-" * 74,
        "  Checklist previo a PRO:",
    ]
    for gate in g["gates"]:
        icon = GATE_ICONS.get(gate["status"], "    ")
        lines.append(f"   {icon} {gate['id']} {gate['title']} — {gate['statusLabel']}"
                     + (f" ({gate['findings']} hallazgos)" if gate["findings"] else ""))
    lines.append("-" * 74)
    lines.append(f"  Objetos del paquete ({len(report['objects'])}):")
    for o in report["objects"]:
        sev = o["bySeverity"]
        detail = (f"A:{sev['high']} M:{sev['medium']} B:{sev['low']} I:{sev['info']}"
                  if o["findingsCount"] else "sin hallazgos")
        mark = " ✔" if o["findingsCount"] == 0 else ""
        lines.append(f"    · {o['name']} ({o['typeLabel']}): {detail}{mark}")
    lines.append("-" * 74)
    highs = [f for f in report["findings"] if f["severity"] in ("HIGH", "MEDIUM")]
    if highs:
        lines.append("  Hallazgos Alta/Media:")
        for f in highs[:25]:
            loc = f":{f['line']}" if f["line"] else ""
            just = " (justificado)" if f["justification"] else ""
            lines.append(f"   [{f['severityLabel'][:1]}] {f['checkId']} "
                         f"{f['objectName']}{loc} — {f['title']}{just}")
        if len(highs) > 25:
            lines.append(f"   ... y {len(highs) - 25} más (ver JSON/CSV)")
    lines.append("=" * 74)
    print("\n".join(lines), file=stream)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def load_config(path: str) -> dict:
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Análisis estático de paquetes de Appian con gate de despliegue a PRO.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("packages", nargs="+",
                        help="Uno o varios .zip exportados de Appian (o directorios extraídos)")
    parser.add_argument("-o", "--output",
                        help="Ruta del informe JSON (solo con un paquete; por defecto <paquete>_analisis.json)")
    parser.add_argument("--output-dir", help="Directorio donde dejar los informes (útil con varios paquetes)")
    parser.add_argument("--csv", nargs="?", const="AUTO", default=None,
                        help="Exporta los hallazgos a CSV (';'). Sin valor: <paquete>_hallazgos.csv")
    parser.add_argument("--prefix", help="Prefijo de aplicación esperado (p. ej. ACME); si no, se infiere")
    parser.add_argument("--app-name", help="Nombre de la aplicación en el Health Check (para cruzar riesgos a nivel de aplicación)")
    parser.add_argument("--health-check", help="Informe de Health Check de Appian (.xlsx, .csv o .json); si no se indica, el gate G02 queda en revisión manual")
    parser.add_argument("--hc-max-age-days", type=int, default=DEFAULT_HC_MAX_AGE_DAYS,
                        help="Antigüedad máxima del Health Check en días (si el fichero tiene fecha)")
    parser.add_argument("--min-coverage", type=float, default=None,
                        help="Cobertura mínima manifestObjects vs analizados (0-1); por debajo el veredicto es ERROR")
    parser.add_argument("--verdict-json", help="Escribe un JSON mínimo con el veredicto y los gates")
    parser.add_argument("--markdown", help="Escribe un resumen Markdown (GITHUB_STEP_SUMMARY / comentario de PR)")
    parser.add_argument("--perf-results", help="Resultados de pruebas de rendimiento (.json o .csv con name/status)")
    parser.add_argument("--justifications", help="JSON con justificaciones a OT (clave: checkId, 'checkId:Objeto' o gate 'G03')")
    parser.add_argument("--config", help="JSON de configuración (thresholds, batchWindow, severityOverrides, excludeChecks, prefix)")
    parser.add_argument("--batch-window", default=f"{DEFAULT_BATCH_WINDOW[0]}-{DEFAULT_BATCH_WINDOW[1]}",
                        help="Ventana horaria PROHIBIDA para procesos batch (HH:MM-HH:MM)")
    parser.add_argument("--exclude-checks", default="",
                        help="Checks a excluir, separados por comas (p. ej. NAM-001,DOC-001)")
    parser.add_argument("--fail-on", choices=["HIGH", "MEDIUM", "LOW"],
                        help="Código de salida 1 si hay hallazgos de esta severidad o superior")
    parser.add_argument("--gate", action="store_true",
                        help="Código de salida 1 si el veredicto es NO APTO PARA PRO")
    parser.add_argument("--max-expression-lines", type=int, default=DEFAULT_THRESHOLDS["max_expression_lines"])
    parser.add_argument("--max-rule-inputs", type=int, default=DEFAULT_THRESHOLDS["max_rule_inputs"])
    parser.add_argument("--max-pm-nodes", type=int, default=DEFAULT_THRESHOLDS["max_pm_nodes"])
    parser.add_argument("--quiet", action="store_true", help="No imprime el resumen por consola")
    args = parser.parse_args(argv)

    config = load_config(args.config) if args.config else {}

    thresholds = dict(DEFAULT_THRESHOLDS)
    thresholds.update({k: v for k, v in config.get("thresholds", {}).items()
                       if k in thresholds})
    thresholds["max_expression_lines"] = args.max_expression_lines
    thresholds["max_rule_inputs"] = args.max_rule_inputs
    thresholds["max_pm_nodes"] = args.max_pm_nodes

    excluded = {c.strip().upper() for c in args.exclude_checks.split(",") if c.strip()}
    excluded |= {str(c).upper() for c in config.get("excludeChecks", [])}
    unknown = excluded - set(CHECKS)
    if unknown:
        print(f"AVISO: checks desconocidos excluidos: {', '.join(sorted(unknown))}", file=sys.stderr)

    severity_overrides = {str(k).upper(): str(v).upper()
                          for k, v in config.get("severityOverrides", {}).items()
                          if str(v).upper() in SEVERITY_ORDER}

    window_text = config.get("batchWindow", args.batch_window)
    parts = window_text.split("-")
    batch_window = (parts[0].strip(), parts[1].strip()) if len(parts) == 2 else DEFAULT_BATCH_WINDOW

    prefix = args.prefix or config.get("prefix")
    if args.min_coverage is not None:
        config["minCoverage"] = args.min_coverage
    config["hcMaxAgeDays"] = args.hc_max_age_days

    # Health Check: entrada explícita (--health-check). Sin él, G02 queda
    # en revisión manual; si se pasa y no se puede leer => ERROR.
    hc_findings = None
    hc_error = ""
    hc_meta: Dict = {}
    if args.health_check:
        try:
            rows = read_hc_rows(args.health_check)
            hc_findings = load_health_check(args.health_check)
            hc_meta["date"] = detect_hc_date(args.health_check, rows)
            hc_meta["rows_total"] = len(rows)
        except Exception as exc:
            hc_error = f"No se pudo leer el Health Check '{args.health_check}': {exc}"
            hc_findings = None
    perf_results = load_perf_results(args.perf_results) if args.perf_results else None
    justifications = load_justifications(args.justifications) if args.justifications else {}

    if args.output and len(args.packages) > 1:
        print("AVISO: --output se ignora con varios paquetes; usa --output-dir.", file=sys.stderr)

    exit_code = 0
    worst_rank = 0  # APTO < APTO_CON_CONDICIONES < NO_APTO < ERROR
    rank = {"APTO": 0, "APTO_CON_CONDICIONES": 1, "NO_APTO": 2, "ERROR": 3}
    consolidated = []
    for pkg in args.packages:
        analysis_errors: List[str] = []
        if hc_error:
            analysis_errors.append(hc_error)
        reader = PackageReader(pkg)
        try:
            reader.load()
        except PackageError as exc:
            analysis_errors.append(str(exc))
        except Exception as exc:
            analysis_errors.append(f"No se pudo leer el paquete '{pkg}': {exc}")

        analyzer = Analyzer(prefix=prefix.upper() if prefix else None,
                            thresholds=thresholds, excluded_checks=excluded,
                            severity_overrides=severity_overrides,
                            batch_window=batch_window, config=config)
        analyzer.analysis["errors"] = analysis_errors
        analyzer.hc_path = args.health_check or ""

        objects: List[AppianObject] = []
        file_stats = {"ok": 0, "failed": 0}
        if not analysis_errors:
            objects = parse_package(reader.files, analyzer.add,
                                    parse_errors=analyzer.analysis["parseErrors"],
                                    file_stats=file_stats)
            if not reader.files or not objects:
                analyzer.analysis["errors"].append(
                    f"'{pkg}' no contiene ficheros XML analizables.")

            log = parse_export_log(reader.files)
            log_names = log["names"]
            for obj in objects:
                if obj.uuid in log_names and (
                        not obj.name or obj.name == obj.uuid
                        or re.match(r"^(_?[a-z]-)?[0-9a-fA-F-]{20,}", obj.name)):
                    obj.name = log_names[obj.uuid]
            for item in log["problems"]:
                analyzer.analysis["warnings"].append(
                    f"El export no incluyó '{item['name'] or item['uuid']}' "
                    f"({item['type']}): ver Problemas en META-INF/export.log.")
            for item in log["warnings"]:
                analyzer.analysis["warnings"].append(
                    f"Advertencia de export sobre '{item['name'] or item['uuid']}' "
                    f"({item['type']}).")

            analyzer.manifest = parse_manifest(reader.files, objects, log)
            analyzer.app_name = args.app_name or ""
            analyzer.appian_version = parse_appian_version(reader.files)
            analyzer.properties_files = {p: t for p, t in reader.files.items()
                                         if p.lower().endswith(".properties")}

            # Cobertura: ficheros de objetos parseados vs objetos del manifiesto
            manifest_n = (analyzer.manifest.get("expectedObjects", 0)
                          if analyzer.manifest else 0)
            ratio = (min(1.0, file_stats["ok"] / manifest_n)
                     if manifest_n else 1.0)
            analyzer.analysis["coverage"] = dict(
                manifestObjects=manifest_n,
                analyzedObjects=len(objects),
                analyzedFiles=file_stats["ok"] + file_stats["failed"],
                parsedOk=file_stats["ok"],
                parseFailed=file_stats["failed"],
                ratio=round(ratio, 3))
            if manifest_n and ratio < analyzer.min_coverage:
                analyzer.analysis["errors"].append(
                    f"Cobertura de análisis {ratio:.0%} por debajo del mínimo "
                    f"{analyzer.min_coverage:.0%} (manifiesto: {manifest_n}, "
                    f"ficheros parseados: {file_stats['ok']}).")

        # Health Check: estado/fecha/caducidad
        if args.health_check:
            if hc_error or hc_findings is None:
                analyzer.hc_info["status"] = "UNREADABLE"
            elif not hc_findings:
                analyzer.hc_info["status"] = "EMPTY"
            else:
                analyzer.hc_info["status"] = "OK"
            analyzer.hc_info["date"] = hc_meta.get("date")
            age = None
            if hc_meta.get("date"):
                try:
                    d = datetime.strptime(hc_meta["date"], "%Y-%m-%d")
                    age = (datetime.now() - d).days
                except ValueError:
                    age = None
            analyzer.hc_info["ageDays"] = age
            analyzer.hc_info["stale"] = (
                age is not None and age > analyzer.hc_max_age_days)
        else:
            analyzer.hc_info["status"] = "MISSING"

        analyzer.analyze(objects, hc_findings=hc_findings,
                         perf_results=perf_results,
                         design_guidance=parse_design_guidance(reader.files),
                         package_name=os.path.basename(pkg))
        report = build_report(pkg, objects, analyzer, justifications)

        base = os.path.splitext(os.path.basename(pkg.rstrip("/")))[0]
        out_dir = args.output_dir or os.path.dirname(os.path.abspath(pkg)) or "."
        os.makedirs(out_dir, exist_ok=True)
        if args.output and len(args.packages) == 1:
            out_path = args.output
        else:
            out_path = os.path.join(out_dir, f"{base}_analisis.json")
        with open(out_path, "w", encoding="utf-8") as fh:
            json.dump(report, fh, ensure_ascii=False, indent=2)

        csv_path = None
        if args.csv is not None:
            if args.csv != "AUTO" and len(args.packages) == 1:
                csv_path = args.csv
            else:
                csv_path = os.path.join(out_dir, f"{base}_hallazgos.csv")
            write_csv(csv_path, report["findings"])

        if not args.quiet:
            print_summary(report)
            print(f"\n  Informe JSON: {out_path}")
            if csv_path:
                print(f"  Informe CSV : {csv_path}")
            print()

        consolidated.append(dict(
            package=report["report"]["package"],
            output=out_path,
            qualityScore=report["summary"]["qualityScore"],
            verdict=report["deploymentGate"]["verdict"],
            verdictLabel=report["deploymentGate"]["verdictLabel"],
            totalObjects=report["report"]["totalObjects"],
            totalFindings=report["report"]["totalFindings"],
            bySeverity=report["summary"]["bySeverity"],
        ))

        if args.verdict_json:
            with open(args.verdict_json, "w", encoding="utf-8") as fh:
                json.dump(build_verdict_json(report, analyzer), fh,
                          ensure_ascii=False, indent=2)
        if args.markdown:
            write_markdown(args.markdown, report)

        verdict = report["deploymentGate"]["verdict"]
        worst_rank = max(worst_rank, rank.get(verdict, 0))
        if args.fail_on:
            threshold = SEVERITY_ORDER[args.fail_on]
            if any(SEVERITY_ORDER[f["severity"]] <= threshold for f in report["findings"]):
                exit_code = max(exit_code, 1)
        if verdict == "ERROR":
            exit_code = max(exit_code, 2)
        elif args.gate:
            exit_code = max(exit_code, EXIT_BY_VERDICT[verdict])

    if len(consolidated) > 1:
        out_dir = args.output_dir or "."
        consolidated_path = os.path.join(out_dir, "analisis_consolidado.json")
        with open(consolidated_path, "w", encoding="utf-8") as fh:
            json.dump(dict(
                tool="Appian Static Analyzer", version=VERSION,
                analyzedAt=datetime.now(timezone.utc).isoformat(timespec="seconds"),
                packages=consolidated,
            ), fh, ensure_ascii=False, indent=2)
        if not args.quiet:
            print(f"  Consolidado : {consolidated_path}\n")

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
