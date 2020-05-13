#!/bin/bash
echo "# install part $0 $1"
[ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1; }

# read config file given as argument
INSTALL_ROOT=$1
if [ -z "$INSTALL_ROOT" ]; then
	echo "INSTALL_ROOT not given as argument."
	exit 1	
fi

TEMP=$INSTALL_ROOT/temp
source $TEMP/panoo.sh

WT="whiptail --backtitle PanooCentral"




# =============================================================
#
# Service
#
# =============================================================
SERVICE="$TEMP/panoo-central.service"

echo "[Unit]" > $SERVICE
echo "Description=Panoo Central" >> $SERVICE
echo "" >> $SERVICE
echo "[Service]" >> $SERVICE
echo "ExecStart=$PANOO_ROOT/central/index.js" >> $SERVICE
echo "Restart=always" >> $SERVICE
echo "User=$PANOO_USER" >> $SERVICE
echo "# Note Debian/Ubuntu uses 'nogroup', RHEL/Fedora uses 'nobody'" >> $SERVICE
echo "Group=nogroup" >> $SERVICE
echo "Environment=PATH=/usr/bin:/usr/local/bin:/bin" >> $SERVICE
echo "Environment=PANOO_ROOT=$PANOO_ROOT" >> $SERVICE
echo "WorkingDirectory=$PANOO_ROOT/central" >> $SERVICE
echo "[Install]" >> $SERVICE
echo "WantedBy=multi-user.target" >> $SERVICE

cp "$TEMP/panoo-central.service" "/etc/systemd/system/panoo-central.service"
chmod 644 /etc/systemd/system/panoo-central.service


$WT --msgbox "PanooCentral is ready to go." 20 78
systemctl enable panoo-central
systemctl start panoo-central
