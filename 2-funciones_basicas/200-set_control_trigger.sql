-- psql "dbname=tickets user=AlFoNs password=PoStGrEs2021" -f "2-set_control_trigger.sql"

-- ============================================================================
-- Function: set_control_trigger
--
-- Llamado desde todos los triggers con el fin de actualizar el ID del usuario
-- de Insert y Update, a fin de no guardar el nombre, que ocuparia mucho
-- en base al nombre de conexion "current_user", obtenemos "mast_user.Id"
-- ============================================================================

--DROP FUNCTION IF EXISTS set_control_trigger CASCADE;
DROP FUNCTION IF EXISTS set_control_trigger ;
CREATE OR REPLACE FUNCTION set_control_trigger () RETURNS TRIGGER AS
$$
DECLARE
	v_Id	INTEGER;
BEGIN
    -- https://www.it-swarm-es.com/es/postgresql/error-cadena-entre-comillas-sin-terminar-en-o-cerca-de/969133907/

	SELECT Id INTO v_Id FROM user_syst WHERE NameUser = current_user;
	IF NOT FOUND THEN
		IF current_user = 'AlFoNs' AND TG_TABLE_NAME = 'user_syst' THEN
			-- En la definicion de la B.D se crea un usuario por defecto que se llama "AlFoNs"
			-- con lo cual daría error, al no existir sobre la tabla 'user_syst'
			v_Id := 1;
		ELSE
			RAISE EXCEPTION 'El usuario: % no esta definido en la tabla user_syst', current_user;
		END IF;
	END IF;

	CASE
		WHEN TG_OP = 'INSERT' THEN
			NEW.IdCreate := v_ID;
		  --NEW.DtCreate := NOW() Definido en el "CREATE TABLE"
		  
		WHEN TG_OP = 'UPDATE' THEN
			NEW.IdUpdate := v_ID;
			NEW.DtUpdate := NOW();
	END CASE;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
