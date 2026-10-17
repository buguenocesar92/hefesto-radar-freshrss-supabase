-- SOLO en proyecto Supabase nuevo dedicado a datos de FreshRSS.
-- Ejecutar con postgres en SQL Editor. No borra datos.
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM pg_tables WHERE schemaname='public') THEN
  RAISE EXCEPTION 'public debe estar vacio';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='freshrss_app') THEN
  CREATE ROLE freshrss_app LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
 END IF;
END $$;
GRANT CONNECT ON DATABASE postgres TO freshrss_app;
GRANT USAGE, CREATE ON SCHEMA public TO freshrss_app;
ALTER ROLE freshrss_app IN DATABASE postgres SET search_path=public;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE freshrss_app IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE freshrss_app IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE freshrss_app IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
-- Asignar la clave generada en .env mediante psql administrativo: \password freshrss_app
