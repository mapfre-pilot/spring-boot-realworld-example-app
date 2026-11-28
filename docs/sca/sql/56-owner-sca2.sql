ALTER SCHEMA sca2_anulaciones OWNER TO user_sca2_anulaciones;
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT c.relname, c.relkind FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
           WHERE n.nspname = 'sca2_anulaciones' AND c.relkind IN ('r','v','m','p')
  LOOP
    EXECUTE format('ALTER %s sca2_anulaciones.%I OWNER TO user_sca2_anulaciones',
                   CASE r.relkind WHEN 'v' THEN 'VIEW' WHEN 'm' THEN 'MATERIALIZED VIEW' ELSE 'TABLE' END, r.relname);
  END LOOP;
  FOR r IN SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
           WHERE n.nspname = 'sca2_anulaciones' AND c.relkind = 'S'
  LOOP
    EXECUTE format('ALTER SEQUENCE sca2_anulaciones.%I OWNER TO user_sca2_anulaciones', r.relname);
  END LOOP;
END $$;
