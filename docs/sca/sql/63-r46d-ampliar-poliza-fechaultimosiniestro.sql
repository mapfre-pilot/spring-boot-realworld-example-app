-- R46-D (10/11/2026) — Ampliar POLIZA_FECHAULTIMOSINIESTRO de la caché de cabecera SCA2
-- Motivo: en pólizas Vida la columna guarda el enlace GESVIDA (~287 caracteres) y VARCHAR(255) obligaba a recortarlo (R38-A).
-- Tabla exclusiva de SCA2: esquema sca2_anulaciones, data store SCA2 (_a-0000f069-4f37-8000-9cc8-011c48011c48_20050863),
-- record type «SCA2 Datos Cabecera» (04f597de-5acd-45b2-9ab3-277713cd00a6); 349 referencias, todas de objetos SCA2.
-- PostgreSQL. Idempotente: ampliar VARCHAR no pierde datos; no reduce si ya es mayor.
-- ESTADO EN TEST: NO EJECUTADO. updateRecordTypeField(length=1000, updateTable=true) devolvió la columna en VARCHAR(255)
-- (la tabla no la gestiona Appian) y el MCP no tiene ejecución de SQL. Lo debe ejecutar un DBA o un despliegue con script de BBDD.
DO $$
BEGIN
  IF (SELECT character_maximum_length FROM information_schema.columns
       WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_datos_cabecera'
         AND column_name = 'POLIZA_FECHAULTIMOSINIESTRO') < 1000 THEN
    ALTER TABLE sca2_anulaciones.sca2_datos_cabecera
      ALTER COLUMN "POLIZA_FECHAULTIMOSINIESTRO" TYPE VARCHAR(1000);
  END IF;
END $$;
-- Comprobación:
-- SELECT character_maximum_length FROM information_schema.columns
--  WHERE table_schema='sca2_anulaciones' AND table_name='sca2_datos_cabecera' AND column_name='POLIZA_FECHAULTIMOSINIESTRO';
