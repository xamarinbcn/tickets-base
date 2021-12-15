#!/bin/bash
# ****************************************************************************
# 
# 					ALS
# 
# 	Este documento contiene datos propiedad intelectual de ALS
# 	Este documento no puede ser  publicado,  copiado o cedido 
# 	total o parcialmente sin permiso escrito de ALS
# 
# 	Autor......: ALS
#	Email......: xamarinbcn@gmai.com
# 	Descripcion: Shell de generacion de D,B y procedures en Postgres
# 	Fichero....: generar_database_procedue.sh
#	Ayuda......: Revisar README.txt para saber la estructura de directorios
# 	Revision...: 01/12/20201
# 
#	La utilizacion de esta SHELL es bajo tu responsabilidad
# ****************************************************************************

# ============================================================================
# CONSIDERACIONES
# 
# Ojo hay que ejecutar dos2unix generar_database_procedue.sh 
# para convertirlo en formato UNIX de lo contratio dara error
# /bin/sh: generar_database_procedue.sh : not found
#
# ============================================================================

# ------------- Cambiar el separador de nombre de ficheros,de espacio blnaci a salto de linea
IFS_backup=$IFS
IFS=$(echo -en "\n\b")



# ------------- Variable por defecto, por si no se quiere escribir en cada ejecucion
PATRON_USER="AlFoNs"
PATRON_PASSWORD="PoStGrEs2021"
PATRON_DB="tickets"

# ----------------------------------------------------------------------------
# FUNCIONES
#
#	usage					Mostrar parametros validos
#	head					Muestra cabecera de la ejecucion
#	menu					Mneu de opciones a ejecutar
#	input					Input de las variable de entorno
#	str_exec				Ejecucion de comando y control de error
#
#	create_database			Creacion de la base de datos
#	str_psql				Ejecuta los ficheros SQL de un directorio	
# ----------------------------------------------------------------------------

usage(){
	Usage: $(basename "$0") 
}

head(){
	clear
	echo "Creacion de una nueva base de datos de DWH y de un nuevo usuario de conexión."
}

menu(){
	echo ""
	echo "Opciones:"
	echo ""
	echo "  1-ALL (crear B.D y procedures)"
	echo "  2-Compilar procedures"
	echo ""
	while true; do
		read -r -p "  Opcion: " opcion
		case $opcion in
			1) break;;
			2) break;;
			*) echo "    Opcion incorrecta";;
		esac
	done
}

input(){
	echo ""
	echo "Nombre de usuario de postgres y para poder crear la nueva base de datos"
	read -p "(INTRO por defecto $PATRON_USER): " usuario
	if [ "$usuario" == "" ]; then
		echo "         Se utilizara el usuario por defecto: $PATRON_USER"
		usuario=$PATRON_USER
	fi
	echo""
	echo "Password del usuario de postgres"
	read -p "(INTRO por defecto $PATRON_PASSWORD): " password
	if [ "$password" == "" ]; then
		echo "         Se utilizara la password: $PATRON_PASSWORD"
		password=$PATRON_PASSWORD
	fi

	echo ""
	echo "Nombre de la base de datos a crear "
	read -p "(INTRO por defecto $PATRON_DB): " database
	if [ "$database" == "" ]; then
		echo "         Se creara la base de datos: $PATRON_DB"
		database=$PATRON_DB
	fi
	echo ""
}

str_exec(){
	comando_exec="set -o pipefail; $1 2>&1 | tee error.log"
	eval $comando_exec 
	if [[ $? -ne 0  || $(grep -i 'error' error.log | wc -l) -gt 0 ]]; then
		echo "Error en la ejecución: $PWD/$1";
		echo "Ver el fichero vi error.log"
		rm error.log 2>/dev/null
		exit
	else
		rm error.log 2>/dev/null
	fi
}		

create_database(){
	cd 1-create_database
	rm tmp.sql 2>/dev/null
	
	echo ""
	echo "======================================================="
	echo "*** Creacion de la base de datos: $database"
	
	for file_name in $(ls *.sql | sort);
	do 
		echo "-------------------------------------------------------"
		echo "       $file_name";
		cp $file_name tmp.sql
		sed -i "s/AlFoNs/$usuario/" tmp.sql
		sed -i "s/PoStGrEs2021/$password/" tmp.sql
		sed -i "s/tickets/$database/" tmp.sql
		comando_str="psql -U $usuario postgres -f './tmp.sql'";
		str_exec $comando_str
		rm tmp.sql 2>/dev/null
	done
	cd ..
}

str_psql(){
	cd $1
	echo ""
	echo "======================================================="
	echo "*** $2. D.B: $database"
	
	for file_name in $(ls *.sql 2>/dev/null | sort);
	do 
		echo "-------------------------------------------------------"
		echo "       $file_name";
		comando_str='psql "dbname=$database user=$usuario password=$password" -f "$file_name"'
		str_exec $comando_str
	done
	cd ..
}

main(){
	head
	menu

	if [ "$opcion" == "1" ]; then
		input

		create_database
	else		
		usuario=$PATRON_USER
		password=$PATRON_PASSWORD
		database=$PATRON_DB
	fi

	str_psql "2-funciones_basicas" 	"Compilando las funciones basicas"
	str_psql "3-create_tables" 		"Creacion de las tablas"
	str_psql "4-librerias" 			"Compilacion de libreria de procedures"
	str_psql "5-procedures" 		"Compilacion fr procedures"
}

main "${@}"                             # Tambien puede ser -> "$@"
IFS=$IFS_backup
