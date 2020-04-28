#!/bin/bash
if [ -z "$1" ]; then echo "no dir given"; exit 1; fi

INST=$1
TEMP=$INST/temp

. $INST/temp/panoo.sh

PANOO_ETC="$PANOO_ROOT/etc"
if [ -d $PANOO_ETC ]; then
	whiptail --msgbox "$PANOO_ETC exists. Will not change existing files." 10 64
else 
	mkdir $PANOO_ETC
fi

if [ ! -f "$PANOO_ETC/panoo.sh" ]; then
	cp $TEMP/panoo.sh $PANOO_ETC
fi

if [ ! -f "$PANOO_ETC/id_central" ]; then
	ssh-keygen -q -t rsa -b 2048 -m PEM -N "" -C "PanooCentral" -f "$PANOO_ETC/id_central"
fi

cp $INST/data/config.template.json $TEMP/central.json

sed -i "s|%%PANOO_ROOT%%|$PANOO_ROOT|" $TEMP/central.json
sed -i "s|%%PANOO_USER%%|$PANOO_USER|" $TEMP/central.json
sed -i "s|%%PANOO_INSTANCE%%|$PANOO_INSTANCE|" $TEMP/central.json
sed -i "s|%%PANOO_PASS%%|$PANOO_PASS|" $TEMP/central.json

if [ ! -f "$PANOO_ETC/central.json" ]; then
	cp "$TEMP/central.json" "$PANOO_ETC/central.json"
fi