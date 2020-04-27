#!/bin/bash
if [ -z "$1" ]; then echo "no dir given"; exit 1; fi
TEMP=$1/temp

. $1/temp/panoo.sh

# Time Stamp
TS=`date +%Y%m%d-%H%M%S`

# http://deploy.maongo.com/panoo-central.1.0.0.zip 

# download to temp
# curl https://panoo.com/download/central/panoo-central.aii992.tar.gz --output temp/central.tgz
if [ ! -f $TEMP/files/panoo-central.$PANOO_INSTCODE.tar.gz ]; then
	curl https://panoo.com/download/central/panoo-central.$PANOO_INSTCODE.tar.gz --output $TEMP/files/panoo-central.$PANOO_INSTCODE.tar.gz 2>&1 \
		| stdbuf -o0 tr "\r" "\n" | stdbuf -o0 cut -c-3 | whiptail --gauge "Progress" 20 64 0
fi

# move existing folder to the side if any
if [ -d $PANOO_ROOT/central ]; then
	mv $PANOO_ROOT/central $PANOO_ROOT/backup-central-$TS
fi

# extract 'central' directory into PANOO_ROOT
sudo -u $PANOO_USER tar xf $TEMP/files/panoo-central.$PANOO_INSTCODE.tar.gz --directory $PANOO_ROOT

