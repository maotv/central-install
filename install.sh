#!/bin/bash
[ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1; }

ROOT=`pwd`

mkdir -p  ./temp
chmod 777 ./temp

# ask for some basics and put them in panoo.sh
./code/10-write-config.sh $ROOT
. $ROOT/temp/panoo.sh

./code/20-install-as-root.sh $ROOT

sudo -u $PANOO_USER ./code/30-unpack-central.sh $ROOT
sudo -u $PANOO_USER ./code/40-panoo-etc.sh $ROOT
sudo -u $PANOO_USER ./code/50-install-keys.sh $ROOT

