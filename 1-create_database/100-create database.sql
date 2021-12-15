-- psql -U AlFoNs postgres -f "create database.sql"

-- ============================================================================
-- DATABASE
--
-- Las variables: AlFoNs, PoStGrEs2021 y tickets seran cambiadas desde la shell
-- generar_database_procedue.sh para cada ejecucion
-- ============================================================================
DROP DATABASE IF EXISTS "tickets";

-- 'Spanish_Spain.1252'
CREATE DATABASE tickets
   WITH
   OWNER      = "AlFoNs"
   ENCODING   = 'UTF8'
   TABLESPACE = pg_default
   Lc_COLLATE = 'es_ES.utf8'		-- 'en_US.utf8'
   Lc_CTYPE   = 'es_ES.utf8'		-- 'en_US.utf8'
   CONNECTION LIMIT = -1
   TEMPLATE template0;

DROP USER IF EXISTS AlFoNs;
CREATE USER AlFoNs WITH PASSWORD 'PoStGrEs2021';