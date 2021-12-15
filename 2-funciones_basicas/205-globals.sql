-- Se puden definir variable en el fichero 'postgresql.conf'
-- https://www.postgresql.org/docs/9.1/runtime-config-custom.html
--
-- Otra modalidad voa variables del S.O
-- https://dba.stackexchange.com/questions/97095/set-session-custom-variable-to-store-user-id

-- psql "dbname=tickets user=AlFoNs password=PoStGrEs2021" -f "205-globals.sql"

DROP FUNCTION IF EXISTS globals_debug_info;
CREATE OR REPLACE FUNCTION globals_debug_info()
  RETURNS integer AS
  $$SELECT 1 $$ LANGUAGE sql IMMUTABLE;
  
