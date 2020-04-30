#!/bin/bash

if [ "$UID" -eq 0 ]; then
    echo "running sudo"
    MODE="sudo"
else
    INSTALL_USER=`id -u -n`
    MODE="user"
fi

ROOT=`pwd`
TEMP="$ROOT/temp"
PARENT="$(dirname "$ROOT")"

mkdir -p -m 777 $TEMP


if [ -d "$ROOT/panoo-files" ]; then
    INSTALL_FILES="$ROOT/panoo-files"
elif [ -d "$PARENT/panoo-files" ]; then
    INSTALL_FILES="$PARENT/panoo-files"
elif [ -d "$HOME/panoo-files" ]; then
    INSTALL_FILES="$HOME/panoo-files"
else 
    INSTALL_FILES="$TEMP/files"
    mkdir -p -m 777 $TEMP/files
fi

echo "INSTALL_FILES is $INSTALL_FILES"


echo "INSTALL_FILES=\"$INSTALL_FILES\"" > $TEMP/defaults.sh
cat $ROOT/data/defaults.sh >> $TEMP/defaults.sh

# ask for some basics and put them in panoo.sh
# we need to run this as root ssince we 
bash $ROOT/code/10-write-config.sh "$ROOT" "$INSTALL_FILES" || exit 1
source $ROOT/temp/panoo.sh

if [ "$UID" -eq 0 ]; then
    SUDO="sudo -u $PANOO_USER /bin/bash"
else
    SUDO="/bin/bash"
fi

if [ "$UID" -eq 0 ]; then
    $SUDO ./code/20-install-as-root.sh $ROOT || exit 1
else
    $SUDO ./code/21-install-as-user.sh $ROOT || exit 1
fi


$SUDO ./code/30-unpack-central.sh $ROOT || exit 1
$SUDO ./code/40-panoo-etc.sh $ROOT || exit 1
$SUDO ./code/50-install-keys.sh $ROOT || exit 1

if [ "$UID" -eq 0 ]; then
    $SUDO ./code/90-start-service.sh $ROOT || exit 1
fi