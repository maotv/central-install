#!/bin/bash
# read config file given as argument
echo "# install part $0 $1"
INSTALL_ROOT=$1
if [ -z "$INSTALL_ROOT" ]; then
	echo "INSTALL_ROOT not given as argument."
	exit 1	
fi

INST=$INSTALL_ROOT
TEMP=$INSTALL_ROOT/temp
source $TEMP/panoo.sh

$PANOO_ROOT/central/database/freshdb.sh $TEMP/panoo.sh
#node $PANOO_ROOT/central/database/freshdb.js