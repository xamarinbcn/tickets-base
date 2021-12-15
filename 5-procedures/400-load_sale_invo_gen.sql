 -- psql "dbname=tickets user=AlFoNs password=PoStGrEs2021" -f "400-load_sale_invo_gen.sql"

 DROP PROCEDURE IF EXISTS load_sale_invo_gen;
 CREATE OR REPLACE PROCEDURE load_sale_invo_gen(
	p_maxim_mast_soci 	INTEGER,
	p_maxim_mast_shop 	INTEGER,
	p_maxim_mast_depa 	INTEGER,
	p_maxim_mast_vend 	INTEGER,
	p_maxim_mast_tpv 	INTEGER,
	p_maxim_mast_clie 	INTEGER,
	p_maxim_mast_fami 	INTEGER,
	p_maxim_mast_arti 	INTEGER
) AS $$
DECLARE
	v_count_mast_soci	INTEGER := 1;
	v_count_mast_shop	INTEGER := 1;
	v_count_mast_depa	INTEGER := 1;
	v_count_mast_vend	INTEGER := 1;
	v_count_mast_tpv	INTEGER := 1;
	v_count_mast_clie	INTEGER := 1;
	v_count_mast_fami	INTEGER := 1;
	v_count_mast_arti	INTEGER := 1;
	
	v_saleinvo			DATE;			-- saleinvo character(10) Fecha sale / Venta
	v_dateinvo 			DATE;			-- Fecha invoice / factura
	v_payminvo			DATE;			-- Fecha payment / pago
	
	v_niv1fami			CHAR(2);
	v_niv2fami			CHAR(2);
	v_niv3fami			CHAR(2);
	v_niv4fami			CHAR(2);
	v_niv5fami			CHAR(2);
	v_codearti			CHAR(10);
	
	counter_mast_soci	INTEGER;
	counter_mast_shop	INTEGER;
	counter_mast_depa	INTEGER;
	counter_mast_vend	INTEGER;
	counter_mast_tpv	INTEGER;
	counter_mast_clie	INTEGER;
	counter_mast_fami	INTEGER;
	counter_mast_arti	INTEGER;
	
	v_numreg			float8;
BEGIN

	v_numreg := 1;
	
	RAISE NOTICE '% -- Borrando indices de la tabla load_sale_invo', NOW();
	ALTER TABLE load_sale_invo DROP CONSTRAINT IF EXISTS f_load_sale_invo_IdFile;
	ALTER TABLE load_sale_invo DROP CONSTRAINT IF EXISTS f_load_sale_invo_IdSoci;

	-- ------------------------------------------------------------------------
	-- BUCLES
	-- ------------------------------------------------------------------------
	
    FOR counter_mast_soci IN v_count_mast_soci..p_maxim_mast_soci LOOP		
		FOR counter_mast_shop IN v_count_mast_shop..p_maxim_mast_shop LOOP
			FOR counter_mast_depa IN v_count_mast_depa..p_maxim_mast_depa LOOP
				FOR counter_mast_vend IN v_count_mast_vend..p_maxim_mast_vend LOOP
					FOR counter_mast_tpv IN v_count_mast_tpv..p_maxim_mast_tpv LOOP
						FOR counter_mast_clie IN v_count_mast_clie..p_maxim_mast_clie LOOP
							FOR counter_mast_fami IN v_count_mast_fami..p_maxim_mast_fami LOOP
								FOR counter_mast_arti IN v_count_mast_arti..p_maxim_mast_arti LOOP
								
									-- saleinvo character(10) Fecha sale / Venta
									v_saleinvo = ((now())::date + interval '1' day * ((random() * (365-0+1) + 1)::int))::date;
									
									-- dateinvo character(10) Fecha invoice / factura
									v_dateinvo = ((now())::date + interval '1' day * ((random() * (365-0+1) + 1)::int))::date;

									-- payminvo character(10) Fecha payment / pago
									v_payminvo = ((now())::date + interval '1' day * ((random() * (365-0+1) + 1)::int))::date;

									v_niv1fami = (floor(random() * ( 10-0+1) + 1)::int);
									v_niv2fami = (floor(random() * ( 10-0+1) + 1)::int);
									v_niv3fami = (floor(random() * ( 10-0+1) + 1)::int);
									v_niv4fami = (floor(random() * ( 10-0+1) + 1)::int);
									v_niv5fami = (floor(random() * ( 10-0+1) + 1)::int);
									v_codearti = (floor(random() * ( 10-0+1) + 1)::int);
									
									INSERT INTO load_sale_invo VALUES(
										DEFAULT,								-- ID
										NULL,	 								-- IdFile
										NULL,									-- IdSoci
										v_numreg,								-- LineFile
										FALSE,									-- isproces
										
										-- Nivel 1 - mast_soci - Maestro de sociedades / propietarios / clientes Deneb
										'SOCI' 			|| counter_mast_soci,	-- codesoci character(10)
										'Sociedad ' 	|| counter_mast_soci, 	-- namesoci character(25)

										-- Nivel 2 - mast_shop - Maestro de tiendas / delegaciones / sucursales / vivienda
										'SHOP'			|| counter_mast_shop, 	-- codeshop character(10)
										'Tienda '		|| counter_mast_shop, 	-- nameshop character(25)
										'Calle tienda ' || counter_mast_shop, 	-- callshop character(30)
										'080' 			|| counter_mast_shop, 	-- codpshop character(5)
										'Polacion '		|| counter_mast_shop, 	-- poblshop character(20)
										'Provincia ' 	|| counter_mast_shop, 	-- provshop character(20)
										'ES',									-- paisshop character(3)
														   NULL, 				-- latishop character(11)
														   NULL,				-- longshop character(11)
														   counter_mast_shop, 	-- zonashop character(2)
										'Zona ' 		|| counter_mast_shop,	-- zondshop character(20)

										-- Nivel 3 - mast_depa - Maestro de Departamentos / habitaciones
										'Dep'			|| counter_mast_depa,	-- codedepa character(10)
										'Departamento ' || counter_mast_depa, 	-- namedepa character(25)

										-- Nivel 4 - mast_vend - Maestro de Comercial / Cajeras / Airbnb o Booking
										'Vend'			|| counter_mast_vend, 	-- codevend character(10)
										'Vendedor '		|| counter_mast_vend, 	-- namevend character(25)
														   counter_mast_vend, 	-- zonavend character(2)
										'Zona ' 		|| counter_mast_vend, 	-- zondvend character(20)

										-- Nivel 5 - mast_tpv - Maestro de TPV / Centros de coste / Hab turisticas o larga duracion
										'Tpv ' 			|| counter_mast_tpv, 	-- codetpv character(10)
										'TPV '			|| counter_mast_tpv, 	-- nametpv character(25)

										-- 			mast_clie - Maestro clientes de fidelizacion / Pacientes
										'Clien'			|| counter_mast_clie, 	-- codeclie character(10)
										'Cliente '		|| counter_mast_clie,	-- nameclie character(25)
														   counter_mast_clie,	-- tipoclie character(2),
										'Tipo '			|| counter_mast_clie,	-- tipdclie character(20)
										'Calle '		|| counter_mast_clie,	-- callclie character(30)
										'080'			|| counter_mast_clie,	-- codpclie character(5)
										'Poblacion '	|| counter_mast_clie,	-- poblclie character(20)
										'Provincia '	|| counter_mast_clie,	-- provclie character(20)
										'ES',									-- paisclie character(10)
														   counter_mast_clie,	-- zonaclie character(2)
										'Zona '			|| counter_mast_clie,	-- zondclie character(20)
										
										-- Factura (cabecera)
														   counter_mast_shop,	-- tipoinvo character(2)
										'Tipo fcatura '	|| counter_mast_shop,	-- tipdinvo character(20)
										(floor(random() * (100000000-0+1) + 1)::int), -- ordeinvo character(10)
										(floor(random() * (100000000-0+1) + 1)::int), -- numbinvo character(10)
										(floor(random() * (100000000-0+1) + 1)::int), -- aboninvo character(10)
										(floor(random() * (23-0+1) + 1)::int),		-- hourinvo character(5)
										v_saleinvo, 							  	-- saleinvo character(10) Fecha sale / Venta
										v_dateinvo, 							   	-- dateinvo character(10) Fecha invoice / factura
										v_payminvo, 							   	-- payminvo character(10) Fecha payment / pago
										(floor(random() * (100000-0+1) + 1)::int), 	-- tbrutinvo character(11)
										(floor(random() * (100000-0+1) + 1)::int), 	-- tdiscinvo character(11)
										(floor(random() * (100000-0+1) + 1)::int), 	-- tfinainvo character(11)
										(floor(random() * (100000-0+1) + 1)::int), 	-- tbaseinvo character(11)
										(floor(random() * (100000-0+1) + 1)::int), 	-- ttaxeinvo character(11)
										(floor(random() * (100000-0+1) + 1)::int), 	-- tnetoinvo character(11)
										
										-- Factura (Lineas)
										v_numreg, 									-- lineinvo character(3)
										v_niv1fami, -- niv1fami character(2)
										'Familia ' || TRIM(v_niv1fami), 			-- des1fami character(20)
										v_niv2fami, -- niv2fami character(2)
										'Nivel 2 familia ' || TRIM(v_niv2fami), 	-- des2fami character(20)
										v_niv3fami, -- niv3fami character(2)
										'Nivel 3 familia  ' || TRIM(v_niv3fami), 	-- des3fami character(20)
										v_niv4fami, -- niv4fami character(2)
										'Nivel 4 familia  ' || TRIM(v_niv4fami), 	-- des4fami character(20)
										v_niv5fami, -- niv5fami character(2)
										'Nivel 5 familia  ' || TRIM(v_niv5fami), 	-- des5fami character(20)
										
										v_codearti, 								-- codearti character(10)
										'Articulo ' || TRIM(v_codearti), 			-- namearti character(25)
										
										(floor(random() * (    9-0+1) + 1)::int),	-- unidinvo character(2)
										(floor(random() * (  100-0+1) + 1)::int), 	-- cantinvo character(6)
										(floor(random() * (10000-0+1) + 1)::int),	-- abrutinvo character(11)
										(floor(random() * (10000-0+1) + 1)::int),	-- adiscinvo character(11)
										(floor(random() * (10000-0+1) + 1)::int),	-- afinainvo character(11)
										(floor(random() * (10000-0+1) + 1)::int),	-- abaseinvo character(11)
										(floor(random() * (10000-0+1) + 1)::int),	-- ataxeinvo character(11)
										(floor(random() * (10000-0+1) + 1)::int) 	-- anetoinvo character(11)

									);
									v_numreg = v_numreg + 1;
									
									IF (v_numreg / 10000) = ROUND(v_numreg/10000) THEN
										raise notice '% -- Registros insertados: %', NOW(), v_numreg;
										COMMIT;
									END IF;
								END LOOP;
							END LOOP;
						END LOOP;
					END LOOP;
				END LOOP;
			END LOOP;
		END LOOP;
	END LOOP;
	
	RAISE NOTICE '% -- Creando indices de la tabla load_sale_invo', NOW();

--	En esteas pruebas, aun no creamos las tablas syst_file y mast_soci
--	ALTER TABLE load_sale_invo ADD CONSTRAINT f_load_sale_invo_IdFile FOREIGN KEY(IdFile) REFERENCES syst_file(Id);
--	ALTER TABLE load_sale_invo ADD CONSTRAINT f_load_sale_invo_IdSoci FOREIGN KEY(IdSoci) REFERENCES mast_soci(Id);
	
END;
$$ LANGUAGE plpgsql;

--delete from load_invo_all;

-- p_maxim_mast_soci
-- p_maxim_mast_shop
-- p_maxim_mast_depa
-- p_maxim_mast_vend
-- p_maxim_mast_tpv
-- p_maxim_mast_clie
-- p_maxim_mast_fami
-- p_maxim_mast_arti
--
-- con 10 registros x nivel == 100 millones de registros
--

-- Para probar la insercion
CALL load_sale_invo_gen(2, 2, 2, 2, 2, 2, 2, 2);

-- Caso de querer generar 100 millones de registros
--CALL load_sale_invo_gen(10, 10, 10, 10, 10, 10, 10, 10);

select LineFile, NumbInvo, CodeArti, NameArti, saleinvo  from load_sale_invo FETCH FIRST 10 ROWS ONLY