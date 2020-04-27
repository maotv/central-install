#!/bin/bash
# read config file given as argument
. $1/temp/panoo.sh


WT="whiptail"
SSIZE="7 72"
LSIZE="20 72"

CHOWN="chown $PANOO_USER:$PANOO_USER"

# =============================================================
#
# Software Packages (mariadb, phpmyadmin, ...)
#
# =============================================================
$WT --textbox text/software.txt $LSIZE

# Ask about Software Installation
if ($WT --yes-button "Install" --no-button "Skip" --yesno "Install required software packages?" $SSIZE); then
    apt -y install mariadb-server phpmyadmin git whois
else
    echo "User selected No, exit status was $?."
fi


# =============================================================
#
# node.js & npm
#
# =============================================================
#https://nodejs.org/dist/v12.16.2/node-v12.16.2-linux-x64.tar.gz

# =============================================================
#
# Panoo User
#
# =============================================================
USERID=`id -u $PANOO_USER`
IDTEST=$?

if [ $IDTEST -eq 0 ]; then
	$WT --msgbox "User '$PANOO_USER' exists with id #$USERID" $SSIZE
else
	echo "create user"
	PASS=$($WT --inputbox "Enter new password for user '$PANOO_USER'" $SSIZE 3>&1 1>&2 2>&3)
	CRYPT=$(echo "$PASS" | mkpasswd --stdin)
	useradd -m "$PANOO_USER" -U -p "$CRYPT"
fi

PANOO_HOME=$( getent passwd "$PANOO_USER" | cut -d: -f6 )


# =============================================================
#
# Panoo Database User
#
# =============================================================

# CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'user_password';
# GRANT ALL PRIVILEGES ON *.* TO 'database_user'@'localhost';

if ($WT --yes-button "Create" --no-button "Skip" --yesno "Create Database User '$PANOO_USER'?" $SSIZE); then

	RND=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)	
	DBPASS=$($WT --inputbox "Enter new database password for user '$PANOO_USER'" $SSIZE $RND 3>&1 1>&2 2>&3)
	echo "CREATE USER '$PANOO_USER'@'localhost' IDENTIFIED BY '$DBPASS';" | mysql -u root > mysql.out 2>&1
	echo "GRANT ALL PRIVILEGES ON *.* TO '$PANOO_USER'@'localhost';" | mysql -u root >> mysql.out 2>&1
	echo "CREATE DATABASE '$PANOO_INSTANCE';" | mysql -u root >> mysql.out 2>&1
	$WT --textbox mysql.out $LSIZE

	echo "[client]" > $PANOO_HOME/.my.cnf
	echo "user=$PANOO_USER" >> $PANOO_HOME/.my.cnf
	echo "password=$DBPASS" >> $PANOO_HOME/.my.cnf
	$CHOWN $PANOO_HOME/.my.cnf

else
    echo "User selected No, exit status was $?."
fi

# =============================================================
#
# Panoo Root
#
# =============================================================

if [ -d "$PANOO_ROOT" ]; then
	$WT --msgbox "Directory '$PANOO_ROOT' exists. Please check ownership manually." $SSIZE
else
	echo "create root"
	mkdir -p "$PANOO_ROOT"
	chown $PANOO_USER:$PANOO_USER "$PANOO_ROOT"
fi


# =============================================================
#
# Service
#
# =============================================================
SERVICE="$INSTALL_ROOT/temp/panoo-central.service"

echo "[Unit]" >> $SERVICE
echo "Description=Panoo Central" >> $SERVICE
echo "" >> $SERVICE
echo "[Service]" >> $SERVICE
echo "ExecStart=$PANOO_ROOT/central/index.js" >> $SERVICE
echo "Restart=always" >> $SERVICE
echo "User=$PANOO_USER" >> $SERVICE
echo "# Note Debian/Ubuntu uses 'nogroup', RHEL/Fedora uses 'nobody'" >> $SERVICE
echo "Group=nogroup" >> $SERVICE
echo "Environment=PATH=/usr/bin:/usr/local/bin:/bin" >> $SERVICE
echo "#Environment=NODE_ENV=production" >> $SERVICE
echo "WorkingDirectory=$PANOO_ROOT/central" >> $SERVICE
echo "[Install]" >> $SERVICE
echo "WantedBy=multi-user.target" >> $SERVICE


