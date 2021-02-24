#!/bin/bash
echo "# install part $0 $1"
INSTALL_ROOT=$1
if [ -z "$INSTALL_ROOT" ]; then echo "INSTALL_ROOT missing"; exit 1; fi
source $INSTALL_ROOT/temp/panoo.sh

# Time Stamp
TS=`date +%Y%m%d-%H%M%S`

# move existing folder to the side if any
if [ -d $PANOO_ROOT/central ]; then
	mv $PANOO_ROOT/central $PANOO_ROOT/remove-central-$TS
fi

if [ "$PANOO_INSTCODE" = "git" ]; then
#	git clone git@codebasehq.com:maongo/panoo/panoo-central.git "$PANOO_ROOT/central" --progress 2>&1 | awk '{print $7}' # | whiptail --gauge "Please wait while we are sleeping..." 6 72 0
	git clone git@codebasehq.com:maongo/panoo/panoo-central.git "$PANOO_ROOT/central" # --progress 2>&1 | stdbuf -e 0 -o 0 tr "\r" "\n" | stdbuf -oL awk '{print $3}' | tr '%' ' ' # | whiptail --gauge "Please wait while we are sleeping..." 6 72 0
	exit $?
fi


#if [ ! -f "$INSTALL_FILES/panoo-central.$PANOO_INSTCODE.tar.gz" ]; then
#	echo "Download https://panoo.com/download/central/panoo-central.$PANOO_INSTCODE.tar.gz => $INSTALL_FILES/panoo-central.$PANOO_INSTCODE.tar.gz"
#	(curl https://panoo.com/download/central/panoo-central.$PANOO_INSTCODE.tar.gz --output $INSTALL_FILES/panoo-central.$PANOO_INSTCODE.tar.gz) 2>&1 \
#		| stdbuf -o0 tr "\r" "\n" | stdbuf -o0 cut -c-3 | whiptail --gauge "Downloading panoo-central.$PANOO_INSTCODE.tar.gz" 10 72 0
#fi

if [ -f "$INSTALL_FILES/panoo-central.$PANOO_INSTCODE.tar.gz" ]; then
	tar xf $INSTALL_FILES/panoo-central.$PANOO_INSTCODE.tar.gz --directory $PANOO_ROOT
else
	echo "cannot find $INSTALL_FILES/panoo-central.$PANOO_INSTCODE.tar.gz"
	exit 1
fi

# if [ ! "$PANOO_INSTCODE" = "git" ]; then
#	if [ ! -f "$INSTALL_FILES/panoo-secrets.$PANOO_INSTCODE.tar.gz" ]; then
#		curl https://panoo.com/download/central/panoo-secrets.$PANOO_INSTCODE.tar.gz --output $INSTALL_FILES/panoo-secrets.$PANOO_INSTCODE.tar.gz 2>&1 \
#			| stdbuf -o0 tr "\r" "\n" | stdbuf -o0 cut -c-3 | whiptail --gauge "Downloading panoo-secrets.$PANOO_INSTCODE.tar.gz" 10 72 0
#	fi
# fi

if [ -f "$INSTALL_FILES/panoo-secrets.$PANOO_INSTCODE.tar.gz" ]; then
	tar xf $INSTALL_FILES/panoo-secrets.$PANOO_INSTCODE.tar.gz --directory $TEMP
elif [ -f "$INSTALL_FILES/panoo-secrets.tar.gz" ]; then
	tar xf $INSTALL_FILES/panoo-secrets.tar.gz --directory $TEMP
elif [ -f "$INSTALL_FILES/../panoo-secrets.tar.gz" ]; then
	tar xf $INSTALL_FILES/../panoo-secrets.tar.gz --directory $TEMP
else
	echo "cannot find $INSTALL_FILES/panoo-secrets.$PANOO_INSTCODE.tar.gz"
	exit 1
fi




