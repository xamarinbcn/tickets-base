-- ****************************************************************************
--
--					ALS
--
--	Este documento contiene datos propiedad intelectual de ALS
--	Este documento no puede ser  publicado,  copiado o cedido 
--	total o parcialmente sin permiso escrito de ALS
--
--	Autor......: ALS
--	Descripcion: Estructura de directorios a utilizar en un proyecto Postgres
--				 Directorios utlizados por la shell de generación 
--				 "generar_database_procedures.sh"
--	Fichero....: README.txt
--	Revision...: 01/12/20201
--
-- ****************************************************************************

-- ==================================================================================
-- Estructura de directorios:
-- 
-- 	Directorios			Comentario
-- 	-------------------	-----------------------------------------------------------
-- 	1-create_database	Definicion de los parametros generales de la B.Definicion
-- 	
-- 	2-funciones_basicas	Funciones llamadas desde los triggers
-- 						Procedures basicas de todo proyecto
-- 						
-- 	3-create table		Definicion de las tablas
-- 						Se compilaran por orden alfabetico los ficheros SQL
-- 						por si hay dependencias entre las tablas, 
-- 						a fin de primero crear las tablas básicas
-- 						y luego el resto de tablas del proyecto
-- 						
-- 	4-Utilidades		Funciones y procedures generales a todos los proyectos
-- 						Se compilaran por orden alfabetico los ficheros SQL
-- 	
-- 	5-Procedures		Funciones y procedures propias del proyecto
-- 							Se compilaran por orden alfabetico los ficheros SQL
-- ==================================================================================

Ejecucion de la shell

./generar_database_procedue.sh
