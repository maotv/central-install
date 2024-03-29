#!/bin/bash
echo "# install part $0 $1"
INSTALL_ROOT=$1
if [ -z "$INSTALL_ROOT" ]; then echo "INSTALL_ROOT missing"; exit 1; fi
source $INSTALL_ROOT/temp/panoo.sh

WT="whiptail"
SSIZE="7 72"
LSIZE="20 72"

CHOWN="chown $PANOO_USER:$PANOO_USER"

# =============================================================
#
# Software Packages (mariadb, phpmyadmin, ...)
#
# =============================================================
# $WT --textbox text/software.txt $LSIZE

# Ask about Software Installation
if ($WT --yes-button "Install" --no-button "Skip" --yesno "Install required software packages?" $SSIZE); then
    apt -y install mariadb-server git curl whois ansible uuid libcairo2-dev
else
    echo "User selected No, exit status was $?."
fi


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
	# PASS=$($WT --inputbox "Enter new password for user '$PANOO_USER'" $SSIZE 3>&1 1>&2 2>&3)
	CRYPT=$(echo "$PANOO_PASS" | mkpasswd --stdin)
	useradd -m "$PANOO_USER" -U -p "$CRYPT"
fi

PANOO_HOME=$( getent passwd "$PANOO_USER" | cut -d: -f6 )


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
# node.js & npm
#
# =============================================================
# NODE_VERSION is in panoo.sh NODE_VERSION="v12.16.2"
NODE_IDENT="node-$NODE_VERSION-linux-x64"
NODE_URL="https://nodejs.org/dist/$NODE_VERSION/$NODE_IDENT.tar.gz"

#if [ ! -f $INSTALL_FILES/$NODE_IDENT.tar.gz ]; then
#	curl $NODE_URL --output $INSTALL_FILES/$NODE_IDENT.tar.gz 2>&1 \
#		| stdbuf -o0 tr "\r" "\n" | stdbuf -o0 cut -c-3 | whiptail --gauge "Progress" 20 64 0
#fi

mkdir -p $PANOO_ROOT/node

if [ ! -d $PANOO_ROOT/node/$NODE_IDENT ]; then
	tar xfz $INSTALL_FILES/$NODE_IDENT.tar.gz --directory $PANOO_ROOT/node
fi

rm -f $PANOO_ROOT/node/current
ln -s $PANOO_ROOT/node/$NODE_IDENT $PANOO_ROOT/node/current
chown $PANOO_USER:$PANOO_USER $PANOO_ROOT/node/current

rm -f /usr/local/bin/node
rm -f /usr/local/bin/npm
rm -f /usr/local/bin/npx

ln -s $PANOO_ROOT/node/current/bin/node /usr/local/bin/node
ln -s $PANOO_ROOT/node/current/bin/npm /usr/local/bin/npm
ln -s $PANOO_ROOT/node/current/bin/npx /usr/local/bin/npx




# =============================================================
#
# Panoo Database User
#
# =============================================================

# CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'user_password';
# GRANT ALL PRIVILEGES ON *.* TO 'database_user'@'localhost';

if ($WT --yes-button "Create" --no-button "Skip" --yesno "Create Database User '$PANOO_USER'?" $SSIZE); then

	# RND=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)	
	DBPASS=$PANOO_PASS # $($WT --inputbox "Enter new database password for user '$PANOO_USER'" $SSIZE $RND 3>&1 1>&2 2>&3)
	echo "Database Error Messages:" > mysql.out
	echo "CREATE USER '$PANOO_USER'@'localhost' IDENTIFIED BY '$DBPASS';" | mysql -u root >> mysql.out 2>&1
	echo "GRANT ALL PRIVILEGES ON *.* TO '$PANOO_USER'@'localhost';" | mysql -u root >> mysql.out 2>&1
	echo "CREATE DATABASE $PANOO_INSTANCE;" | mysql -u root >> mysql.out 2>&1
	$WT --textbox mysql.out $LSIZE

	echo "[client]" > $PANOO_HOME/.my.cnf
	echo "user=$PANOO_USER" >> $PANOO_HOME/.my.cnf
	echo "password=$DBPASS" >> $PANOO_HOME/.my.cnf
	$CHOWN $PANOO_HOME/.my.cnf

else
    echo "User selected No, exit status was $?."
fi



