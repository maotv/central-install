#!/bin/bash
echo "# install part $0 $1"
INSTALL_ROOT=$1
if [ -z "$INSTALL_ROOT" ]; then echo "INSTALL_ROOT missing"; exit 1; fi
source $INSTALL_ROOT/temp/panoo.sh
source $INSTALL_ROOT/temp/secrets/about.sh

PANOO_ETC="$PANOO_ROOT/etc"
if [ -d $PANOO_ETC ]; then
	whiptail --msgbox "$PANOO_ETC exists. Will not change existing files." 10 64
else 
	mkdir $PANOO_ETC
fi

if [ ! -f "$PANOO_ETC/panoo.sh" ]; then
	cp $TEMP/panoo.sh $PANOO_ETC # FIXME remove passwords, install data
fi

if [ ! -f "$PANOO_ETC/id_central" ]; then
	ssh-keygen -q -t rsa -b 2048 -m PEM -N "" -C "PanooCentral" -f "$PANOO_ETC/id_central"
fi

cp $INSTALL_ROOT/temp/secrets/id_install $PANOO_ETC
#cp $INSTALL_ROOT/temp/secrets/id_install.pub $PANOO_ETC
ssh-keygen -y -f $INSTALL_ROOT/temp/secrets/id_install > $PANOO_ETC/id_install.pub

cp $INSTALL_ROOT/data/config.template.json $TEMP/central.json
cp $INSTALL_ROOT/data/empty_array.json $PANOO_ETC/box_versions.json
cp $INSTALL_ROOT/data/empty_array.json $PANOO_ETC/box_slots.json

sed -i -e "s|%%PANOO_ROOT%%|$PANOO_ROOT|" $TEMP/central.json
sed -i -e "s|%%PANOO_USER%%|$PANOO_USER|" $TEMP/central.json
sed -i -e "s|%%PANOO_HOST%%|$PANOO_HOST|" $TEMP/central.json
sed -i -e "s|%%PANOO_INSTANCE%%|$PANOO_INSTANCE|" $TEMP/central.json
sed -i -e "s|%%PANOO_PASS%%|$PANOO_PASS|" $TEMP/central.json
sed -i -e "s|%%PANOO_MAILUSER%%|$PANOO_MAILUSER|" $TEMP/central.json
sed -i -e "s|%%PANOO_MAILPASS%%|$PANOO_MAILPASS|" $TEMP/central.json

if [ ! -f "$PANOO_ETC/central.json" ]; then
	cp "$TEMP/central.json" "$PANOO_ETC/central.json"
fi
