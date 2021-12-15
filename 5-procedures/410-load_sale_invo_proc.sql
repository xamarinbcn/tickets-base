-- psql "dbname=tickets user=AlFoNs password=PoStGrEs2021" -f "410-load_sale_invo_proc.sql"

-- ============================================================================
-- Verificaciones de la tabla LOAD
--
-- 1) Verificar que los campos NOT NULL, esten informados
-- 2) Verificar que el tipo de campo sea el correcto: Date, Time, Numeric....
-- ============================================================================
DROP PROCEDURE IF EXISTS util_verify_value;
CREATE OR REPLACE PROCEDURE util_verify_value(
	p_id_load		INTEGER,	-- ID del registro de la tabla de carga
	p_table_load	CHAR(30),	-- Tabla de carga, con todos los campos CHAR()
	p_table_ins		CHAR(30)	-- Tabla a insertar los datos, con los campos formateador
 ) AS $$
 DECLARE
	rec			RECORD;
	m_type		CHARACTER VARYING;	-- hay este tipo largo -> time without time zone
	v_date		DATE;
	v_time		TIME;
	v_smallint	SMALLINT;
	v_integer	INTEGER;
	v_double	DOUBLE PRECISION;
	
	v_field1 	TEXT;
	v_field2 	TEXT;
	v_query		TEXT;
BEGIN
	p_table_ins = TRIM(p_table_ins);
	
	-- ------------------------------------------------------------------------
	-- Obetner todos los campos de la tabla LOAD
	-- ------------------------------------------------------------------------

	v_field1 = '';
	v_field2 = '';
	
	FOR rec IN SELECT attname
				 FROM pg_attribute
				WHERE attrelid = p_table_load::regclass 
				  AND atttypid = 'char'::regtype		-- Solo los campos CHAR() 
				  AND attnum > 0 						-- Que no sean campos del sistema
				ORDER BY attnum							-- Ordenado según la tabla
	LOOP
		rec.attname = TRIM(rec.attname);
		IF v_field1 = '' THEN
			v_field1 = '''' || TRIM(rec.attname) || '''';
		ELSE
			v_field1 = TRIM(v_field1) || ',' || '''' || TRIM(rec.attname) || '''';
		END IF;
		
		IF v_field2 = '' THEN
			v_field2 = TRIM(rec.attname);
		ELSE
			v_field2 = TRIM(v_field2) || ',' || TRIM(rec.attname);
		END IF;
	END LOOP;
	
	-- ------------------------------------------------------------------------
	-- Convertir los campos de la tabla LOAD, en un Array de 2 columnas
	-- ------------------------------------------------------------------------

--	v_query := 'SELECT UNNEST (array[''codesoci'', ''namesoci'', ''saleinvo'']) AS field,' || 
--				     ' UNNEST (array[codesoci, namesoci, saleinvo]) '      || ' AS value'  ||

	v_query := 'SELECT UNNEST (array[' || TRIM(v_field1) || ']) AS field,' || 
				     ' UNNEST (array[' || TRIM(v_field2) || ']) AS value'  ||
			  ' FROM '       || p_table_load ||
	         ' WHERE id =  ' || p_id_load;
			 
	-- ------------------------------------------------------------------------
	-- Validaciones del contenido de cada campo de la tabla LOAD
	-- para el registro pasado como parametro a la procedure
	-- ------------------------------------------------------------------------

	FOR rec IN EXECUTE v_query
	LOOP
		rec.field = TRIM(rec.field);
	
		-- 1- Verificar que los campos NOT NULL, esten informados
		IF rec.value IS NULL OR LENGTH(rec.value) = 0 THEN
			IF EXISTS(SELECT attnotnull
						FROM pg_attribute
					   WHERE attrelid = p_table_ins::regclass
					     AND attname  = rec.field
					     AND attnotnull IS TRUE) THEN
				RAISE INFO 'Campo:% NOT PERMITE NULL', rec.field;
			END IF;
		ELSE			
			SELECT atttypid::regtype
			  INTO m_type
			  FROM pg_attribute
		     WHERE attrelid = p_table_ins::regclass
			   AND attname  = rec.field
			   AND NOT attisdropped;		
			IF NOT FOUND THEN
				RAISE EXCEPTION 'Campo:[%].Campo no definido en la tabla:[%]', rec.field, p_table_ins;			
			END IF;			
			m_type = TRIM(m_type);
			
			CASE m_type
				WHEN 'date'	THEN			-- 2- Verificar tipo de dato: DATE (formado DD-MM-YYYY)
					BEGIN
						v_date = rec.value;
						EXCEPTION
							WHEN OTHERS THEN
								RAISE INFO 'Campo:[%] Valor:[%].Fecha incorrecta', rec.field, rec.value;
					END;
				WHEN 'time',				-- 3- Verificar tipo de dato: TIME (formato HH:MM)
					 'time without time zone' THEN
					BEGIN
						CASE LENGTH(rec.value)
							WHEN 1 THEN	rec.value = '0' || TRIM(rec.value) || ':00';
							WHEN 2 THEN	rec.value =        TRIM(rec.value) || ':00';
							WHEN 4 THEN	rec.value =        TRIM(rec.value) || '0';
						END CASE;
						
						v_time = rec.value;
						EXCEPTION
							WHEN OTHERS THEN
								RAISE INFO 'Campo:[%] Valor:[%].Hora incorrecta', rec.field, rec.value;
					END;
				WHEN 'smallint'	THEN		-- 4- Verificar tipo de dato: NUMERICO -> SMALLINT
					BEGIN
						v_smallint = rec.value;
						EXCEPTION
							WHEN OTHERS THEN
								RAISE INFO 'Campo:[%] Valor:[%].Valor numérico SMALLINT incorrecto', rec.field, rec.value;
					END;
				WHEN 'integer' THEN			-- 5- Verificar tipo de dato: NUMERICO -> INTEGER
					BEGIN
						v_integer = rec.value;
						EXCEPTION
							WHEN OTHERS THEN
								RAISE INFO 'Campo:[%] Valor:[%].Valor numérico INTEGER incorrecto', rec.field, rec.value;
					END;
				WHEN 'numeric'	THEN		-- 6- Verificar tipo de dato: NUMERICO -> DECIMAL
					BEGIN
						v_double = rec.value;
						EXCEPTION
							WHEN OTHERS THEN
								IF strpos(rec.value, '.') > 0 THEN
									RAISE INFO 'Campo:[%] Valor:[%].Tiene un PUNTO como separador decimal', rec.field, rec.value;								
								ELSE
									RAISE INFO 'Campo:[%] Valor:[%].Valor numérico DECIMAL incorrecto', rec.field, rec.value;
								END IF;
					END;
				WHEN 'character'	THEN	-- 7- Tipos de datos para los cuales no es necesario realizar acciones	

				ELSE
					RAISE EXCEPTION 'Campo:[%] Valor:[%].Tipo de campo [%] NO controlado en procedure "util_verify_value"', rec.field, rec.value, m_type;
			END CASE;
		END IF;		
	END LOOP;
END;
$$ LANGUAGE plpgsql;


-- ===========================================================================
-- ===========================================================================

DROP PROCEDURE IF EXISTS load_sale_invo_proc;
CREATE OR REPLACE PROCEDURE load_sale_invo_proc() AS $$
DECLARE
	rec						RECORD;
	cur						REFCURSOR := 'curs';
	
	-- ================================================-
	-- Gestion de errores
	-- ================================================-
	v_pg_context 			TEXT;
	v_message_text 			TEXT;
	v_constraint_name		TEXT;
	v_pg_exception_hint 	TEXT;
	v_pg_exception_detail 	TEXT;
	v_errTexto				syst_text_err.errTexto%TYPE;
BEGIN

	-- ------------------------------------------------------------------------
	-- Verifica si ya se crearon los F.K que se borraron en la carga masiva
	-- ------------------------------------------------------------------------

	IF NOT EXISTS (SELECT constraint_name
					 FROM information_schema.table_constraints
				    WHERE constraint_name = 'f_load_sale_invo_idfile') THEN
-- De momento en esta Primera version, no se ha creado la tabla syst_file
--		ALTER TABLE load_sale_invo ADD CONSTRAINT f_load_sale_invo_idfile FOREIGN KEY(IdFile) REFERENCES syst_file(Id);
	END IF;
	IF NOT EXISTS (SELECT constraint_name
					 FROM information_schema.table_constraints
				    WHERE constraint_name = 'f_load_sale_invo_idsoci') THEN	
-- De momento en esta Primera version, no se ha creado la tabla mast_soci
--		ALTER TABLE load_sale_invo ADD CONSTRAINT f_load_sale_invo_idsoci FOREIGN KEY(IdSoci) REFERENCES mast_soci(Id);
	END IF;
	
	-- ------------------------------------------------------------------------
	-- Buscar los registros que aun no se han procesado
	-- ------------------------------------------------------------------------
	
	-- https://www.cybertec-postgresql.com/en/with-hold-cursors-and-transactions-in-postgresql/
	EXECUTE $_$DECLARE curs CURSOR WITH HOLD FOR
	 SELECT *
	   FROM load_sale_invo
	  WHERE isproces IS FALSE
	 $_$;
	LOOP
		FETCH cur INTO rec;
		EXIT WHEN NOT FOUND;

		BEGIN
			IF globals_debug_info() THEN		-- Definido en el fichero 'gloabls.sql'
				RAISE INFO 'rec.id: [%]', rec.id;
			END IF;
			
			-- Verificaciones para cada columna
			CALL util_verify_value(rec.id, 'load_sale_invo', 'sale_invo');
--			CALL util_verify_fk(rec.id); ALFONS FALTA CONSULTAR TABLAS pg_*
			
			-- Con el fin de indicar que ya se proceso este registro
			UPDATE load_sale_invo 
			   SET isproces = TRUE
			 WHERE id = rec.id;
--			 WHERE CURRENT OF cur;	--No se porque no me funciona de esta manera ALFONS
			
			-- GESTION DE LOS ERRORES
			
			EXCEPTION
				-- WHEN unique_violation THEN
				-- 	Si se desea hacer algo especial cuando sea esta EXCEPTION
				--
				-- WHEN query_canceled THEN
				--	.........
				
				WHEN OTHERS THEN
					-- CLOSE cur;
					-- RAISE;	-- (si se desea cancelar el proceso)
					
					GET DIAGNOSTICS v_pg_context 					= PG_CONTEXT;
					GET STACKED DIAGNOSTICS v_message_text 			= MESSAGE_TEXT,
											v_constraint_name 		= CONSTRAINT_NAME,
											v_pg_exception_hint 	= PG_EXCEPTION_HINT,
											v_pg_exception_detail 	= PG_EXCEPTION_DETAIL;
											
					IF v_message_text = SQLERRM THEN v_message_text = ''; END IF; 
					IF v_constraint_name IS NOT NULL THEN
						SELECT errTexto INTO v_errTexto FROM syst_text_err WHERE CheckName = v_constraint_name AND idioma = 'ES';
						IF v_errTexto IS NULL THEN v_errTexto = ''; END IF;
					ELSE
						v_errTexto = '';
					END IF;
					IF globals_debug_info() THEN		-- Definido en el fichero 'gloabls.sql'
						RAISE INFO   E'***********************************************************\nTRACK.: %\nERROR.: [%] - % - % - \nTEXTO.: % - %\nMSG...: %', v_pg_context, SQLSTATE, SQLERRM, v_message_text, v_pg_exception_detail, v_pg_exception_hint, v_errTexto;
						RAISE INFO   E'***********************************************************';
					END IF;
		END;
		
		-- Reduce deadlock risk
		COMMIT;
	END LOOP;
	CLOSE cur;
END;
$$ LANGUAGE plpgsql;

-- Para pruebas procesamos todos los registros
update load_sale_invo set isproces = FALSE;

CALL load_sale_invo_proc();

