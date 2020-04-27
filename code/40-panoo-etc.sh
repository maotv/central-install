#!/bin/bash
if [ -z "$1" ]; then echo "no dir given"; exit 1; fi

INST=$1
TEMP=$INST/temp

. $INST/temp/panoo.sh

PANOO_ETC="$PANOO_ROOT/etc"
if [ -d $PANOO_ETC ]; then
	whiptail --msgbox "$PANOO_ETC exists. Will not change anything." 10 64
	exit 1
fi

mkdir $PANOO_ETC
cp $TEMP/panoo.sh $PANOO_ETC

cp $INST/data/config.template.json $TEMP/central.json

sed -i "s|%%PANOO_ROOT%%|$PANOO_ROOT|" $TEMP/central.json
sed -i "s|%%PANOO_USER%%|$PANOO_USER|" $TEMP/central.json
sed -i "s|%%PANOO_INSTANCE%%|$PANOO_INSTANCE|" $TEMP/central.json
sed -i "s|%%PANOO_PASS%%|$PANOO_PASS|" $TEMP/central.json

cp $TEMP/central.json $PANOO_ROOT/etc/central.json
