#!/bin/bash
echo "# install part $0 $1"
INSTALL_ROOT=$1
if [ -z "$INSTALL_ROOT" ]; then echo "INSTALL_ROOT missing"; exit 1; fi

source $INSTALL_ROOT/temp/panoo.sh
TEMP=$INSTALL_ROOT/temp

mkdir -p "$PANOO_ROOT"
