-- =====================================================================================
-- 75 · SCA2 · Comprobación ANTES de ejecutar 73 y 74 (solo lectura: no cambia nada)
-- Ejecutar con el MISMO usuario que va a lanzar 73 y 74 (user_sca2_anulaciones).
-- Devuelve un único JSON. Mirar primero «resultado»:
--   OK ...  -> se pueden ejecutar 73 y 74.
--   NO ...  -> no ejecutar; el motivo dice qué falta.
-- Referencia TEST (17/11/2026): 22 tablas, 588 columnas, 57 índices, owner user_sca2_anulaciones.
-- =====================================================================================
WITH
esperadas(tabla) AS (SELECT unnest(ARRAY['sca2_cat_causa','sca2_cat_concepto','sca2_cat_detalle','sca2_cat_motivo','sca2_cat_tipo_argumento','sca2_cat_valor_concepto','sca2_datos_basicos_solicitud','sca2_datos_cabecera','sca2_datos_perfiles_pca','sca2_datos_poliza_autos','sca2_datos_poliza_hogar','sca2_datos_poliza_vida','sca2_datos_productor','sca2_datos_solicitud','sca2_error','sca2_llamada_servicio','sca2_niveles_cobertura_autos','sca2_otras_solicitudes_cabecera','sca2_solicitud','sca2_tarea','sca2_transicion','sca2_trazabilidad_cliente'])),
indices_test(indice) AS (SELECT unnest(ARRAY['ix_sca2_datos_basicos_solicitud_id_solicitud','ix_sca2_datos_cabecera_id_solicitud','ix_sca2_datos_perfiles_pca_id_solicitud','ix_sca2_datos_poliza_autos_id_solicitud','ix_sca2_datos_poliza_hogar_id_solicitud','ix_sca2_datos_poliza_vida_id_solicitud','ix_sca2_datos_productor_id_solicitud','ix_sca2_datos_solicitud_id_solicitud','ix_sca2_error_estado_fecha_creacion','ix_sca2_error_fecha_creacion','ix_sca2_error_id_solicitud','ix_sca2_llamada_servicio_fecha_inicio','ix_sca2_llamada_servicio_id_solicitud','ix_sca2_niveles_cobertura_autos_id_solicitud','ix_sca2_otras_solicitudes_cabecera_id_solicitud','ix_sca2_solicitud_caducidad_tarea','ix_sca2_solicitud_created_at','ix_sca2_solicitud_num_poliza_created_at','ix_sca2_tarea_fecha_creacion','ix_sca2_tarea_id_solicitud','ix_sca2_tarea_pendiente_tipo_fecha','ix_sca2_transicion_fecha','ix_sca2_transicion_id_solicitud','ix_sca2_trazabilidad_cliente_fecha','sca2_cat_causa_pkey','sca2_cat_concepto_pkey','sca2_cat_detalle_pkey','sca2_cat_motivo_pkey','sca2_cat_tipo_argumento_pkey','sca2_cat_valor_concepto_pkey','sca2_datos_basicos_solicitud_pkey','sca2_datos_cabecera_pkey','sca2_datos_perfiles_pca_pkey','sca2_datos_poliza_autos_pkey','sca2_datos_poliza_hogar_pkey','sca2_datos_poliza_vida_pkey','sca2_datos_productor_pkey','sca2_datos_solicitud_pkey','sca2_error_pkey','sca2_llamada_servicio_pkey','sca2_niveles_cobertura_autos_pkey','sca2_otras_solicitudes_cabecera_pkey','sca2_solicitud_ID_SOLICITUD_key','sca2_solicitud_pkey','sca2_tarea_pkey','sca2_transicion_CLAVE_IDEMPOTENCIA_key','sca2_transicion_pkey','sca2_trazabilidad_cliente_pkey','ux_sca2_cat_causa','ux_sca2_cat_concepto','ux_sca2_cat_detalle','ux_sca2_cat_motivo','ux_sca2_cat_tipo_argumento_activo','ux_sca2_cat_valor_concepto','ux_sca2_datos_cabecera_id_solicitud','ux_sca2_error_pendiente_clave','ux_sca2_tarea_pendiente_solicitud_tipo'])),
rol AS (SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'user_sca2_anulaciones') AS existe),
esq AS (SELECT n.oid, pg_get_userbyid(n.nspowner) AS owner FROM pg_namespace n WHERE n.nspname = 'sca2_anulaciones'),
obj AS (
  SELECT c.relname, c.relkind, pg_get_userbyid(c.relowner) AS owner,
         pg_has_role(current_user, c.relowner, 'MEMBER') AS modificable,
         CASE WHEN c.relkind = 'r' AND has_schema_privilege(c.relnamespace, 'USAGE') AND has_table_privilege(c.oid, 'SELECT')
              THEN (xpath('/row/c/text()', query_to_xml(
                     format('SELECT count(*) AS c FROM sca2_anulaciones.%I', c.relname), false, true, '')))[1]::text::bigint
         END AS filas
    FROM pg_class c JOIN esq ON c.relnamespace = esq.oid
   WHERE c.relkind IN ('r','p','v','m','S','i')),
chk AS (
  SELECT
    (SELECT existe FROM rol) AS rol_existe,
    (SELECT existe FROM rol) AND pg_has_role(current_user, (SELECT oid FROM pg_roles WHERE rolname = 'user_sca2_anulaciones'), 'MEMBER') AS puede_ser_owner,
    EXISTS (SELECT 1 FROM esq) AS esquema_existe,
    (SELECT owner FROM esq) AS owner_esquema,
    has_database_privilege(current_database(), 'CREATE') AS create_en_bd,
    coalesce((SELECT pg_has_role(current_user, nspowner, 'MEMBER') FROM pg_namespace WHERE nspname = 'sca2_anulaciones'), true) AS esquema_modificable,
    (SELECT coalesce(json_agg(relname ORDER BY relname), '[]'::json) FROM obj WHERE relkind IN ('r','p','v','m') AND NOT modificable) AS objetos_no_modificables,
    (SELECT count(*) FROM obj WHERE relkind = 'r') AS tablas,
    (SELECT coalesce(json_agg(tabla ORDER BY tabla), '[]'::json) FROM esperadas
      WHERE tabla NOT IN (SELECT relname FROM obj WHERE relkind = 'r')) AS tablas_que_faltan,
    (SELECT coalesce(json_agg(relname ORDER BY relname), '[]'::json) FROM obj
      WHERE relkind IN ('r','p','v','m') AND relname NOT IN (SELECT tabla FROM esperadas)) AS objetos_que_no_estan_en_test,
    (SELECT count(*) FROM information_schema.columns WHERE table_schema = 'sca2_anulaciones') AS columnas,
    (SELECT count(*) FROM obj WHERE relkind = 'i') AS indices,
    (SELECT coalesce(json_agg(relname ORDER BY relname), '[]'::json) FROM obj
      WHERE relkind = 'i' AND relname NOT IN (SELECT indice FROM indices_test)) AS indices_que_no_estan_en_test,
    (SELECT coalesce(sum(filas), 0) FROM obj WHERE relkind = 'r') AS filas_total,
    (SELECT coalesce(json_object_agg(relname, filas), '{}'::json) FROM obj WHERE relkind = 'r' AND filas > 0) AS tablas_con_filas,
    (SELECT coalesce(json_agg(relname ORDER BY relname), '[]'::json) FROM obj
      WHERE relkind = 'r' AND filas IS NULL) AS tablas_sin_permiso_select)
SELECT json_build_object(
  'resultado', CASE
     WHEN NOT rol_existe THEN 'NO: no existe el rol user_sca2_anulaciones'
     WHEN NOT puede_ser_owner THEN 'NO: ' || current_user || ' no es user_sca2_anulaciones ni miembro de ese rol'
     WHEN NOT esquema_existe AND NOT create_en_bd THEN 'NO: no existe el esquema y no hay CREATE en la BD; un DBA debe ejecutar CREATE SCHEMA sca2_anulaciones AUTHORIZATION user_sca2_anulaciones'
     WHEN NOT esquema_modificable THEN 'NO: el esquema es de ' || owner_esquema || ' y ' || current_user || ' no puede modificarlo'
     WHEN owner_esquema <> 'user_sca2_anulaciones' AND NOT create_en_bd THEN 'NO: el owner del esquema es ' || owner_esquema || '; cambiarlo a user_sca2_anulaciones exige CREATE en la BD (lo hace un DBA)'
     WHEN json_array_length(objetos_no_modificables) > 0 THEN 'NO: hay objetos de otro owner que ' || current_user || ' no puede modificar (ver objetos_no_modificables)'
     WHEN json_array_length(tablas_sin_permiso_select) > 0 THEN 'NO: sin permiso SELECT en algunas tablas (ver tablas_sin_permiso_select)'
     WHEN filas_total > 0 THEN 'OK para ejecutar, pero el esquema TIENE DATOS (ver tablas_con_filas): no vaciarlo sin revisarlo; el 74 puede fallar si los catálogos ya tienen filas'
     WHEN json_array_length(objetos_que_no_estan_en_test) > 0 THEN
          'OK para ejecutar, pero hay tablas/vistas que no están en TEST (ver objetos_que_no_estan_en_test): el 73 no las borra'
     WHEN tablas > 0 THEN 'OK: se pueden ejecutar 73 y 74 (tablas vacías; el 73 completa lo que falte y borra los índices que no están en TEST)'
     ELSE 'OK: esquema vacío o inexistente; se pueden ejecutar 73 y 74'
   END,
  'usuario', current_user,
  'base_de_datos', current_database(),
  'version_postgresql', current_setting('server_version'),
  'rol_user_sca2_anulaciones_existe', rol_existe,
  'usuario_puede_asignar_owner', puede_ser_owner,
  'esquema_existe', esquema_existe,
  'owner_esquema', owner_esquema,
  'create_en_bd', create_en_bd,
  'objetos_no_modificables', objetos_no_modificables,
  'tablas', tablas, 'tablas_que_faltan', tablas_que_faltan,
  'objetos_que_no_estan_en_test', objetos_que_no_estan_en_test,
  'columnas', columnas,
  'indices', indices, 'indices_que_no_estan_en_test', indices_que_no_estan_en_test,
  'filas_total', filas_total, 'tablas_con_filas', tablas_con_filas,
  'tablas_sin_permiso_select', tablas_sin_permiso_select
) AS verificacion_previa
FROM chk;
