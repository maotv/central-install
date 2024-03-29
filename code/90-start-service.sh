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
# Cronjob
#
# =============================================================

line="0 6 * * * export PANOO_ROOT=$PANOO_ROOT && cd $PANOO_ROOT/central && /usr/bin/node $PANOO_ROOT/central/utils/sendReport.js"
(crontab -u $PANOO_USER -l; echo "$line" ) | crontab -u $PANOO_USER -

backupline="0 4 * * * bash /panoo/central/bin/dbbackup.sh"
(crontab -u root -l; echo "$backupline" ) | crontab -u root -

# =============================================================
#
# Service
# Panoo Central
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

# =============================================================
#
# Service
# Icon Painter
#
# =============================================================
SERVICE="$TEMP/panoo-icon-painter.service"

echo "[Unit]" > $SERVICE
echo "Description=Panoo Icon Painter" >> $SERVICE
echo "" >> $SERVICE
echo "[Service]" >> $SERVICE
echo "ExecStart=$PANOO_ROOT/central/bin/icon-painter" >> $SERVICE
echo "Restart=always" >> $SERVICE
echo "User=$PANOO_USER" >> $SERVICE
echo "# Note Debian/Ubuntu uses 'nogroup', RHEL/Fedora uses 'nobody'" >> $SERVICE
echo "Group=nogroup" >> $SERVICE
echo "[Install]" >> $SERVICE
echo "WantedBy=multi-user.target" >> $SERVICE

cp "$TEMP/panoo-icon-painter.service" "/etc/systemd/system/panoo-icon-painter.service"
chmod 644 /etc/systemd/system/panoo-icon-painter.service


$WT --msgbox "PanooCentral is ready to go." 20 78
systemctl enable panoo-icon-painter
systemctl start panoo-icon-painter
