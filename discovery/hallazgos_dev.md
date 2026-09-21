# Hallazgos SMK — dev — 2026-09-21T08:56Z

Connected Systems: 231 · Record types: 718 · Pruebas en catálogo base: 112

## Nuevos desde el último snapshot (0)

## Desaparecidos (0)

## URL cambiada (1)
- RH GD Corporativo: https://ws-gdu.pre.azure.mapfre.net:25021/ → https://alb.appian.es.int.emea.aws.mapfre.net:443/

## Sin prueba de humo en el catálogo (11)
- [DB] LCK DB AWS — apps: (LCK) Object Locking — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [PLUGIN] BDE Conexión Sharepoint — apps: Bitácora de Empresas — Revisar manualmente: operación de lectura del plugin
- [PLUGIN] CMD TEST Conexión AWS S3 2 — apps: CMD Demo Componentes — Revisar manualmente: operación de lectura del plugin
- [DB] CMD Prueba orafi053 — apps: CMD Demo Componentes — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [PLUGIN] CMP Obtener IP — apps: CMP Componentes — Revisar manualmente: operación de lectura del plugin
- [DB] CMP DB Plan Familia — apps: CMP Plan Familia — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [DB] CMP DB Respuesta Componente — apps: CMP Respuesta Componente — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [DB] FAS Schema FAS — apps: FAS Ficha Ampliada de Socio — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [HTTP] PAI_SistTest — apps: PAPELERA OT — Integración GET ligera vía CS 'PAI_SistTest' → código HTTP_ACK_AISF_KASD_FK
- [DB] TVA BD Aurora PostgreSQL — apps: Tarificador Vida Ahorro — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [DB] TI Aurora PostgreSQL — apps: Test Idoneidad — Sin record types dependientes: no hay consulta read-only posible sin crear objetos

## Runner (ejecución 23, 2026-09-21 08:58Z, motivo "Descubrimiento semanal Devin")
102/102 OK · sin regresiones respecto a la ejecución 22 (102/102 OK).

## Acciones realizadas
- URL cambiada RH GD Corporativo: actualizados `sistema`/`nombre`/`descripcion` de la fila HTTP_WS_GDU_PRE_AZURE_MAPFRE_NET_25021 en SMK_catalogoBase (código sin cambios). La fila ya existente en SMK_TEST (DEV) conserva el nombre/sistema antiguos: "Sincronizar catálogo" solo inserta filas nuevas; actualizar a mano desde Catálogo si se desea.
- Sin cobertura: 7 CS de BD sin record types, 3 plugins y 1 HTTP (PAI_SistTest, host ficticio, app PAPELERA OT) — no se crea nada; requieren decisión humana.
