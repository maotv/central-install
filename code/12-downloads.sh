#!/bin/bash
echo "# install part $0 $1"
INSTALL_ROOT=$1
if [ -z "$INSTALL_ROOT" ]; then echo "INSTALL_ROOT missing"; exit 1; fi
source $INSTALL_ROOT/temp/panoo.sh

LOGNAME=`logname`
LOGSUDO="sudo -u $LOGNAME"

# Time Stamp
TS=`date +%Y%m%d-%H%M%S`

if [ ! -f "$INSTALL_FILES/panoo-central.$PANOO_INSTCODE.tar.gz" ]; then
	echo "Download https://panoo.com/download/central/panoo-central.$PANOO_INSTCODE.tar.gz => $INSTALL_FILES/panoo-central.$PANOO_INSTCODE.tar.gz"
	(curl https://panoo.com/download/central/panoo-central.$PANOO_INSTCODE.tar.gz --output $INSTALL_FILES/panoo-central.$PANOO_INSTCODE.tar.gz) 2>&1 \
		| stdbuf -o0 tr "\r" "\n" | stdbuf -o0 cut -c-3 | whiptail --gauge "Downloading panoo-central.$PANOO_INSTCODE.tar.gz" 10 72 0
fi

if [ ! -f "$INSTALL_FILES/panoo-secrets.$PANOO_INSTCODE.tar.gz" ]; then
	echo "Download https://panoo.com/download/central/panoo-secrets.$PANOO_INSTCODE.tar.gz => $INSTALL_FILES/panoo-secrets^.$PANOO_INSTCODE.tar.gz"
	(curl https://panoo.com/download/central/panoo-secrets.$PANOO_INSTCODE.tar.gz --output $INSTALL_FILES/panoo-secrets.$PANOO_INSTCODE.tar.gz) 2>&1 \
		| stdbuf -o0 tr "\r" "\n" | stdbuf -o0 cut -c-3 | whiptail --gauge "Downloading panoo-secrets.$PANOO_INSTCODE.tar.gz" 10 72 0
fi

# iNODE_VERSION is in panoo.sh NODE_VERSION="v12.16.2"
NODE_IDENT="node-$NODE_VERSION-linux-x64"
NODE_URL="https://nodejs.org/dist/$NODE_VERSION/$NODE_IDENT.tar.gz"

if [ ! -f $INSTALL_FILES/$NODE_IDENT.tar.gz ]; then
        curl $NODE_URL --output $INSTALL_FILES/$NODE_IDENT.tar.gz 2>&1 \
                | stdbuf -o0 tr "\r" "\n" | stdbuf -o0 cut -c-3 | whiptail --gauge "Download Node $NODE_VERSION" 20 64 0
fi


