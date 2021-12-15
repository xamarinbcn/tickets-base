-- psql "dbname=tickets user=AlFoNs password=PoStGrEs2021" -f "3-create tables.sql"
-- psql username  -h hostname -d dbname < dump.sq

-- ============================================================================
-- TIPOS DE TABLAS SEGUN INICIALES / SCHEMAS (si se desea)
--
-- INIC		DESCRIPTION COMENT
-- ----		----------- -----------------------------------------------------------
-- syst_	SYSTEM		Tablas del sistema: Carga ficheros / Logs / Errores
-- user_	USERS		Usuarios con acceso al siste,a
-- tipo_	AUXILIARES	Tipologías
-- zona_	AUXILIARES	Zonas
-- load_	LOAD		Mismos campos tablas "M*" y "S*", pero campos NULL y CHAR
-- mast_	MASTER		Tablas maestras
--
-- sale_	SALES		Ventas: tickets, arqueo de caja, promociones
-- aggr_	AGGREGATE	Tablas de agregados desde las tablas "sale"
-- ============================================================================

-- ----------------------------------------------------------------------------
--	Mensajes de error de CHECKS
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS syst_text_err CASCADE;
CREATE TABLE IF NOT EXISTS  syst_text_err(
	CheckName	CHAR(40)	NOT NULL,
	Idioma		CHAR(2)		NOT NULL DEFAULT 'ES' CONSTRAINT c_syst_text_err_Idioma CHECK(Idioma IN ('IN','ES')),
	errTexto	TEXT		NOT NULL
	
   ,CONSTRAINT u_syst_text_err UNIQUE(CheckName, Idioma)
);
INSERT INTO syst_text_err VALUES('u_mast_soci_codesoci', 'ES', 'Indice único para código de socio');

-- ----------------------------------------------------------------------------
-- Tabla de carga de las ventas
--
-- Puede procesar: Tickets de TPV / Facturas / Reservas Airbnb
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS load_sale_invo CASCADE;
CREATE TABLE IF NOT EXISTS  load_sale_invo(
	Id			INTEGER  	NOT NULL CONSTRAINT p_load_sale_invo_Id  PRIMARY KEY GENERATED ALWAYS AS IdENTITY,
						 -- Para esta Primera version no se crean las tablas: syst_file,  mast_soci
	IdFile		INTEGER, --  	NOT NULL CONSTRAINT f_load_sale_invo_IdFile	REFERENCES syst_file(Id),
	IdSoci		INTEGER, --		NOT NULL CONSTRAINT f_load_sale_invo_IdSoci	REFERENCES mast_soci(Id),  
	LineFile	INTEGER		NOT NULL,		-- Con el fin de poder grabar en 'syst_file_erro.LineFile'
	isproces	BOOLEAN		DEFAULT FALSE,	-- A fin de saber si ya se proceso correctamente el registo		
	
	-- Nivel 1 - mast_soci - Maestro de sociedades / propietarios / clientes Deneb
	CodeSoci	CHAR(10),
	NameSoci	CHAR(25),				-- Nombre de la sociedaded

	-- Nivel 2 - mast_shop - Maestro de tiendas / delegaciones / sucursales / vivienda
	CodeShop	CHAR(10),
	NameShop	CHAR(25),
	CallShop	CHAR(30),				-- Calle y numero, para obtener las coordenadas GPS
	CodpShop	CHAR(5),				-- Codigo postal	FALTA tabla
	PoblShop	CHAR(20),				-- Poblacion		FALTA tabla
	ProvShop	CHAR(20),				-- Provincia
	PaisShop	CHAR(3),				-- Pais
	LatiShop	CHAR(11),				-- Latitud
	LongShop	CHAR(11),				-- Longitud

	ZonaShop	CHAR(2),				-- Codigo de zona 		  == mast_tipo.Clastipo = 'S' 
	ZonDShop	CHAR(20),				-- Descripcion de la zona == mast_tipo.NameTipo
	
	-- Nivel 3 - mast_depa - Maestro de Departamentos / habitaciones
	CodeDepa	CHAR(10),
	NameDepa	CHAR(25),
	
	-- Nivel 4 - mast_vend - Maestro de Comercial / Cajeras / Airbnb o Booking
	CodeVend	CHAR(10),
	NameVend	CHAR(25),
	ZonaVend	CHAR(2),				-- Codigo de zona 		  == mast_tipo.Clastipo = 'V' 
	ZonDVend	CHAR(20),				-- Descripcion de la zona == mast_tipo.NameTipo
	
	-- Nivel 5 - mast_tpv - Maestro de TPV / Centros de coste / Hab turisticas o larga duracion
	CodeTpv		CHAR(10),
	NameTpv		CHAR(25),	

	-- 			mast_clie - Maestro clientes de fidelizacion / Pacientes
	CodeClie	CHAR(10),
	NameClie	CHAR(25),
	TipoClie	CHAR(2),				-- Codigo de tipo cliente	== mast_tipo.Clastipo = 'T' 
	TipDClie	CHAR(20),				-- Descripcion de tipo 		== mast_tipo.NameTipo
	CallClie	CHAR(30),				-- Calle y numero, para obtener las coordenadas GPS
	CodpClie	CHAR(5),				-- Codigo postal	FALTA tabla
	PoblClie	CHAR(20),				-- Poblacion		FALTA tabla
	ProvClie	CHAR(20),				-- Provincia
	PaisClie	CHAR(3),				-- Pais
	ZonaClie	CHAR(2),				-- Codigo de zona cliente	== mast_tipo.Clastipo = 'C' 
	ZonDClie	CHAR(20),				-- Descripcion de la zona 	== mast_tipo.NameTipo

	-- Factura (cabecera)
	TipoInvo	CHAR(2),				-- Tipo de factura 		  	== mast_tipo.Clastipo = 'F' 
	TipDInvo	CHAR(20),				-- Descripcion del tipo   	== mast_tipo.NameTipo

	OrdeInvo	CHAR(10),				-- Numero de pedido / reserva
	NumbInvo	CHAR(10),				-- Numero de factura / Ticket
	AbonInvo	CHAR(10),				-- Numero de abono

	HourInvo	CHAR(5),				-- Hora de la Venta 
	SaleInvo	CHAR(10),				-- Fecha sale / Venta
	DateInvo	CHAR(10),				-- Fecha invoice / factura
	PaymInvo	CHAR(10),				-- Fecha payment / pago
	
	TBrutInvo	CHAR(11),				-- Importe Bruto (sin descuentos y sin impuestos)
	TDiscInvo	CHAR(11),				-- Importe Descuentos comerciales (antes de impuestos)	1.000.000.000 pesos == 300.000 euros
	TFinaInvo	CHAR(11),				-- Importe Descuentos financieros
	TBaseInvo	CHAR(11),				-- Importe Base (antes de impuestos)
	TTaxeInvo	CHAR(11),				-- Importe Impuestos
	TNetoInvo	CHAR(11),				-- Importe Neto a pagar
	
	-- Factura (Lineas)
	LineInvo	CHAR(3),				-- lineas de factura
	
	Niv1Fami	CHAR(2),				-- Codigo      Nivel 1			
	Des1Fami	CHAR(20),				-- Descripcion Nivel 1
	Niv2Fami	CHAR(2),				-- Codigo      Nivel 2
	Des2Fami	CHAR(20),				-- Descripcion Nivel 2
	Niv3Fami	CHAR(2),				-- Codigo      Nivel 3
	Des3Fami	CHAR(20),				-- Descripcion Nivel 3
	Niv4Fami	CHAR(2),				-- Codigo      Nivel 4
	Des4Fami	CHAR(20),				-- Descripcion Nivel 4
	Niv5Fami	CHAR(2),				-- Codigo      Nivel 5
	Des5Fami	CHAR(20),				-- Descripcion Nivel 5

	CodeArti	CHAR(10),				-- Codigo de articulo
	NameArti	CHAR(25),				-- Descripcion del articulo
	
	UnidInvo	CHAR(2),				-- Unidad de venta
	CantInvo	CHAR(6),				-- Cantidad vendida
	
	ABrutInvo	CHAR(11),				-- Importe Bruto (sin descuentos y sin impuestos)
	ADiscInvo	CHAR(11),				-- Importe Descuentos comerciales (antes de impuestos)	1.000.000.000 pesos == 300.000 euros
	AFinaInvo	CHAR(11),				-- Importe Descuentos financieros
	ABaseInvo	CHAR(11),				-- Importe Base (antes de impuestos)
	ATaxeInvo	CHAR(11),				-- Importe Impuestos
	ANetoInvo	CHAR(11)				-- Importe Neto a pagar	
);

-- ----------------------------------------------------------------------------
-- Tabla de ventas
--
-- Puede procesar: Tickets de TPV / Facturas / Reservas Airbnb
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS sale_invo CASCADE;
CREATE TABLE IF NOT EXISTS  sale_invo(
	Id			INTEGER  	NOT NULL CONSTRAINT p_sale_invo_Id  PRIMARY KEY GENERATED ALWAYS AS IdENTITY,	
	IdFile		INTEGER  	NOT NULL, -- CONSTRAINT f_sale_invo_IdFile	REFERENCES syst_file(Id),
	IdSoci		INTEGER		NOT NULL, -- CONSTRAINT f_sale_invo_IdSoci	REFERENCES mast_soci(Id),  

	-- Nivel 1 - mast_soci - Maestro de sociedades / propietarios / clientes Deneb
	CodeSoci	CHAR(10)	NOT NULL,
	NameSoci	CHAR(25)	NOT NULL,				-- Nombre de la sociedaded

	-- Nivel 2 - mast_shop - Maestro de tiendas / delegaciones / sucursales / vivienda
	CodeShop	CHAR(10)	NOT NULL,
	NameShop	CHAR(25)	NOT NULL,
	CallShop	CHAR(30)	NOT NULL,				-- Calle y numero	NOT NULL, para obtener las coordenadas GPS
	CodpShop	CHAR(5)		NOT NULL,				-- Codigo postal	FALTA tabla
	PoblShop	CHAR(20)	NOT NULL,				-- Poblacion		FALTA tabla
	ProvShop	CHAR(20)	NOT NULL,				-- Provincia
	PaisShop	CHAR(3)		NOT NULL,				-- Pais
	LatiShop	NUMERIC(10,8),						-- Latitud
	LongShop	NUMERIC(10,8),						-- Longitud

	ZonaShop	CHAR(2)		NOT NULL,				-- Codigo de zona 		  == mast_tipo.Clastipo = 'S' 
	ZonDShop	CHAR(20)	NOT NULL,				-- Descripcion de la zona == mast_tipo.NameTipo
	
	-- Nivel 3 - mast_depa - Maestro de Departamentos / habitaciones
	CodeDepa	CHAR(10)	NOT NULL,
	NameDepa	CHAR(25)	NOT NULL,
	
	-- Nivel 4 - mast_vend - Maestro de Comercial / Cajeras / Airbnb o Booking
	CodeVend	CHAR(10)	NOT NULL,
	NameVend	CHAR(25)	NOT NULL,
	ZonaVend	CHAR(2)		NOT NULL,				-- Codigo de zona 		  == mast_tipo.Clastipo = 'V' 
	ZonDVend	CHAR(20)	NOT NULL,				-- Descripcion de la zona == mast_tipo.NameTipo
	
	-- Nivel 5 - mast_tpv - Maestro de TPV / Centros de coste / Hab turisticas o larga duracion
	CodeTpv		CHAR(10)	NOT NULL,
	NameTpv		CHAR(25)	NOT NULL,	

	-- 			mast_clie - Maestro clientes de fidelizacion / Pacientes
	CodeClie	CHAR(10)	NOT NULL,
	NameClie	CHAR(25)	NOT NULL,
	TipoClie	CHAR(2)		NOT NULL,				-- Codigo de tipo cliente	== mast_tipo.Clastipo = 'T' 
	TipDClie	CHAR(20)	NOT NULL,				-- Descripcion de tipo 		== mast_tipo.NameTipo
	CallClie	CHAR(30)	NOT NULL,				-- Calle y numero	NOT NULL, para obtener las coordenadas GPS
	CodpClie	CHAR(5)		NOT NULL,				-- Codigo postal	FALTA tabla
	PoblClie	CHAR(20)	NOT NULL,				-- Poblacion		FALTA tabla
	ProvClie	CHAR(20)	NOT NULL,				-- Provincia
	PaisClie	CHAR(3)		NOT NULL,				-- Pais
	ZonaClie	CHAR(2)		NOT NULL,				-- Codigo de zona cliente	== mast_tipo.Clastipo = 'C' 
	ZonDClie	CHAR(20)	NOT NULL,				-- Descripcion de la zona 	== mast_tipo.NameTipo

	-- Factura (cabecera)
	TipoInvo	CHAR(2)		NOT NULL,				-- Tipo de factura 		  	== mast_tipo.Clastipo = 'F' 
	TipDInvo	CHAR(20)	NOT NULL,				-- Descripcion del tipo   	== mast_tipo.NameTipo

	OrdeInvo	CHAR(10)	NOT NULL,				-- Numero de pedido / reserva
	NumbInvo	CHAR(10)	NOT NULL,				-- Numero de factura / Ticket
	AbonInvo	CHAR(10)	NOT NULL,				-- Numero de abono

	HourInvo	TIME		NOT NULL,				-- Hora de la Venta 
	SaleInvo	DATE		NOT NULL,				-- Fecha sale / Venta
	DateInvo	DATE		NOT NULL,				-- Fecha invoice / factura
	PaymInvo	DATE		NOT NULL,				-- Fecha payment / pago
	
	TBrutInvo	DECIMAL(10,2) NOT NULL,				-- Importe Bruto (sin descuentos y sin impuestos)
	TDiscInvo	DECIMAL(10,2) NOT NULL,				-- Importe Descuentos comerciales (antes de impuestos)	1.000.000.000 pesos == 300.000 euros
	TFinaInvo	DECIMAL(10,2) NOT NULL,				-- Importe Descuentos financieros
	TBaseInvo	DECIMAL(10,2) NOT NULL,				-- Importe Base (antes de impuestos)
	TTaxeInvo	DECIMAL(10,2) NOT NULL,				-- Importe Impuestos
	TNetoInvo	DECIMAL(10,2) NOT NULL,				-- Importe Neto a pagar
	
	-- Factura (Lineas)
	LineInvo	SMALLINT	NOT NULL,				-- lineas de factura
	
	Niv1Fami	CHAR(2)		NOT NULL,				-- Codigo      Nivel 1			
	Des1Fami	CHAR(20)	NOT NULL,				-- Descripcion Nivel 1
	Niv2Fami	CHAR(2),							-- Codigo      Nivel 2
	Des2Fami	CHAR(20),							-- Descripcion Nivel 2
	Niv3Fami	CHAR(2),							-- Codigo      Nivel 3
	Des3Fami	CHAR(20),							-- Descripcion Nivel 3
	Niv4Fami	CHAR(2),							-- Codigo      Nivel 4
	Des4Fami	CHAR(20),							-- Descripcion Nivel 4
	Niv5Fami	CHAR(2),							-- Codigo      Nivel 5
	Des5Fami	CHAR(20),							-- Descripcion Nivel 5

	CodeArti	CHAR(10)	NOT NULL,				-- Codigo de articulo
	NameArti	CHAR(25)	NOT NULL,				-- Descripcion del articulo
	
	UnidInvo	CHAR(2)		NOT NULL,				-- Unidad de venta
	CantInvo	DECIMAL(6,2)	NOT NULL,			-- Cantidad vendida
	
	ABrutInvo	DECIMAL(10,2)	NOT NULL,			-- Importe Bruto (sin descuentos y sin impuestos)
	ADiscInvo	DECIMAL(10,2)	NOT NULL,			-- Importe Descuentos comerciales (antes de impuestos)	1.000.000.000 pesos == 300.000 euros
	AFinaInvo	DECIMAL(10,2)	NOT NULL,			-- Importe Descuentos financieros
	ABaseInvo	DECIMAL(10,2)	NOT NULL,			-- Importe Base (antes de impuestos)
	ATaxeInvo	DECIMAL(10,2)	NOT NULL,			-- Importe Impuestos
	ANetoInvo	DECIMAL(10,2)	NOT NULL			-- Importe Neto a pagar
		
);
CREATE UNIQUE INDEX u_sale_invo1 ON sale_invo (NumbInvo, IdSoci, LineInvo);	-- Buscar por numero de factura