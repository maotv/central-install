#!/bin/bash
INSTALL_ROOT=$1
if [ -z "$INSTALL_ROOT" ]; then
	echo "INSTALL_ROOT not given as argument."
	exit 1	
fi

# [ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}
ROOT=$INSTALL_ROOT
TEMP="$ROOT/temp"

WT="whiptail --backtitle PanooCentral"
NEXTEXIT="--ok-button Next --cancel-button Exit"

if [ -f $TEMP/panoo.sh ]; then
    . $TEMP/panoo.sh
else
    . $ROOT/data/defaults.sh
fi

PANOO_USER=$($WT $NEXTEXIT --inputbox "Please enter the username for the installation" 10 78 "$PANOO_USER" 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]; then
    echo "User selected Ok and entered $PANOO_USER"
else
    exit 1
fi

PANOO_ROOT=$($WT $NEXTEXIT --inputbox "The PanooCentral Root Directory" 10 78 "$PANOO_ROOT" 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]; then
    echo "User selected Ok and entered $PANOO_ROOT"
else
    exit 1
fi

PANOO_INSTANCE=$($WT $NEXTEXIT --inputbox "The PanooCentral Instance Name" 10 78 "$PANOO_INSTANCE" 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]; then
    echo "User selected Ok and entered $PANOO_INSTANCE"
else
    exit 1
fi

PANOO_HOST=$($WT $NEXTEXIT --inputbox "The PanooCentral Hostname or IP-Address" 10 78 "$PANOO_HOST" 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]; then
    echo "User selected Ok and entered $PANOO_HOST"
else
    exit 1
fi

PANOO_ADMIN=$($WT $NEXTEXIT --inputbox "The PanooCentral Administrator Email" 10 78 "$PANOO_ADMIN" 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]; then
    echo "User selected Ok and entered $PANOO_ADMIN"
else
    exit 1
fi

RAND=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)
MULTIPASS=$($WT $NEXTEXIT --inputbox "The Password for User and Database" 10 78 $RAND 3>&1 1>&2 2>&3)
if [ $? -eq 0 ]; then
    echo "User selected Ok and entered $MULTIPASS"
else
    exit 1
fi

PANOO_INSTCODE=$($WT $NEXTEXIT --inputbox "The Panoo-Install-Code" 10 78 "$PANOO_INSTCODE" 3>&1 1>&2 2>&3)
if [ $? = 0 ]; then
    echo "User selected Ok and entered $PANOO_INSTCODE"
else
    exit 1
fi




PANOOSH="$TEMP/panoo.sh"

echo "#!/bin/sh" > $PANOOSH
echo "PANOO=\"$PANOO_ROOT\"" >> $PANOOSH
echo "CENTRAL=\"$PANOO_ROOT/central\"" >> $PANOOSH
echo "PANOO_ROOT=\"$PANOO_ROOT\"" >> $PANOOSH
echo "PANOO_USER=\"$PANOO_USER\"" >> $PANOOSH
echo "PANOO_PASS=\"$MULTIPASS\"" >> $PANOOSH
echo "PANOO_HOST=\"$PANOO_HOST\"" >> $PANOOSH
echo "PANOO_INSTANCE=\"$PANOO_INSTANCE\"" >> $PANOOSH
echo "PANOO_ADMIN=\"$PANOO_ADMIN\"" >> $PANOOSH
echo "PANOO_INSTCODE=\"$PANOO_INSTCODE\"" >> $PANOOSH
echo "INSTALL_ROOT=\"$ROOT\"" >> $PANOOSH


