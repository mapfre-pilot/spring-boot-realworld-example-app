# Ronda 24 — Comportamiento de la derivación a VERTI (análisis del analista, 21/10/2026)

> Entrada: «Analisis SCA2.docx — Comportamiento de la derivación a VERTI» (copia `~/sca2work/r24/Analisis_SCA2_verti.docx`). Cierra la duda #1 (pantalla Verti previa) de `43-ronda24-respuestas-analista.md`.

## 1. Regla del analista

Dos cosas independientes, gobernadas por el switch de configuración `vertiSuscripcionInteligente` (concepto funcional `SCA Concepto Funcional`, leído en SCA2 por `SCA2_ConsultaConceptosFuncionalesSuscripcionInteligenteRecord` / `SCA2_flagVerti`), el servicio de **contacto** (`determinarContacto` → VACÍO / VERTI / VENCIMIENTO / ambos) y la decisión de **Mecanizar** (mecaniza o no; «salta de nivel» NO influye):

| Switch | Contacto | Mecaniza | Pantalla «Gestión Verti/Vencimiento» | Llamada al módulo de inducción (`CMP Inducir Cliente Completo`, `CMP_PM_INDUCIR_CLIENTE`, uuid 0002ea05-adcc-8000-8c7a-7f0000014e7a) |
|---|---|---|---|---|
| cualquiera | VACÍO | cualquiera | NO | NO |
| cualquiera | VERTI/VENC. | NO mecaniza | NO | NO |
| OFF | VERTI/VENC. | Mecaniza | NO | SÍ (sin selección del usuario) |
| ON | VERTI/VENC. | Mecaniza | SÍ | SÍ (con las casillas marcadas) |

Además: la pantalla sólo tras la Contra Anulación (no en AA: lo decide el motor, no el frontal); **misma cabecera** que el resto de pantallas de SCA2, con los mismos datos; **un único botón** «continuar a anular»; la pantalla **no decide nada** del flujo. Orden: Contra Anulación → pantalla Verti/Vencimiento → pantalla de Anulación → módulo de inducción.

## 2. SCA2 hoy (R22 §5 / R13) y diferencias

| Punto | SCA2 hoy | Regla | Cambio |
|---|---|---|---|
| Cuándo sale la pantalla | `CMD CrearAccion` nodo 3 `pedirVerti` = sin selección previa ∧ última tarea cerrada = CA ∧ contacto VERTI/VENC. → sale tras **toda** CA negativa, también cuando la acción decidida es CA de nivel 2 (D4 de R23-C), y sin mirar el switch | switch ON ∧ contacto ∧ acción decidida = MECANIZAR | `pedirVerti` += `flagVerti/switch = ON` ∧ `accionCalc` = MECANIZAR |
| Inducción sin mecanizar | nodos 35/36 «¿Inducir Verti sin mecanizar?» → CMP | nunca si no mecaniza | eliminar/inertizar 35-36 |
| Inducción en Mecanizar | `CMD Mecanizar` nodo 331 `¿Inducir Verti?` = `pv!inducirVerti` (casilla marcada en la pantalla, vía token `VERTI:<selección>`); si la pantalla no salió, no induce | contacto no vacío ∧ mecaniza, independiente del switch; con selección si hubo pantalla, sin ella si no | 331 = `contacto ∈ {VERTI, VENCIMIENTO}` (ya calculado en nodo 16) ; la selección sólo informa los parámetros del CMP |
| Botones de la pantalla | CONTINUAR + CANCELAR + POSPONER (`SCA2_VertiVencimientoPrincipal` v12) | un único botón «continuar» | quitar CANCELAR y POSPONER |
| Cabecera | `a!cardLayout` propio | cabecera común | usar `rule!SCA2_DatosCabecera` (+ `SCA2_obtenerDatosCabecera`) como `SCA2_ContraAnulacionPrincipal` |
| Orden | CA → Verti → Anulación → CMP | igual | sin cambio |
| AA / fuera de norma | sin pantalla (última tarea ≠ CA) | igual (lo decide el motor) | sin cambio |

Referencia SCA (`SCA_Mecanizacion`): 46 determinarContacto → 45 `and(not(pv!flagVerti), or(mostrarVencimiento, mostrarVerti))` → 48/44 pantalla → 5 → 20 BloquearPoliza → 27 `or(mostrarVencimiento, mostrarVerti)` → 28 inducción. (Nota: en SCA el `flagVerti` entra negado en la condición de la pantalla; la tabla del analista es la que manda.)

## 3. Reparto
- **R23-C**: `SCA2_VertiVencimientoPrincipal` (un botón, cabecera común) y `SCA2 CMD CrearAccion` (condición de `pedirVerti`, quitar 35/36). Prueba con solicitudes nuevas: CA negativa → nivel 2 (sin pantalla), CA negativa → mecanizar con switch ON (pantalla) y con switch OFF (sin pantalla, con inducción).
- **R23-A** (dueña de `SCA2 CMD Mecanizar`): nodo 331 según §2.
- Decisión abierta que sigue: #2 (estado tras ANULAR PÓLIZA).
