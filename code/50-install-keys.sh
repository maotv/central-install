#!/bin/bash
# read config file given as argument
echo "# install part $0 $1"
INSTALL_ROOT=$1
if [ -z "$INSTALL_ROOT" ]; then
	echo "INSTALL_ROOT not given as argument."
	exit 1	
fi

INST=$INSTALL_ROOT
TEMP=$INSTALL_ROOT/temp
source $TEMP/panoo.sh

WT="whiptail --backtitle PanooCentral"


# secrets are unpacked in step 30-unpack-central
SECRETS="$TEMP/secrets"
source $SECRETS/about.sh

PANOO_CA="$PANOO_ROOT/ca"
mkdir -p "$PANOO_CA"


# certreqs  certs  crl  intermed-ca.cert.pem  intermed-ca.cnf  intermed-ca.req.pem  newcerts  private  temp
mkdir -p "$PANOO_CA/certreqs"
mkdir -p "$PANOO_CA/certs"
mkdir -p "$PANOO_CA/crl"
mkdir -p "$PANOO_CA/newcerts"
mkdir -p "$PANOO_CA/private"
mkdir -p "$PANOO_CA/temp"
mkdir -p "$PANOO_CA/bin"

cp "$INST/data/ca-build-server.sh" "$PANOO_CA/bin"
chmod 755 "$INST/data/ca-build-server.sh"

cp "$INST/data/ca-build-central.sh" "$PANOO_CA/bin"
chmod 755 "$INST/data/ca-build-central.sh"

cp "$SECRETS/customer-ca.cert.pem" "$PANOO_CA/customer-ca.cert.pem"
cp "$SECRETS/customer-ca.key.pem" "$PANOO_CA/private/customer-ca.key.pem"
cp "$INST/data/customer-ca.cnf" "$PANOO_CA/customer-ca.cnf"
cp "$INST/data/server.template.cnf" "$PANOO_CA/server.template.cnf"

sed -i -e "s|%%PANOO_CUSTOMER%%|$PANOO_CUSTOMER|" $PANOO_CA/customer-ca.cnf

echo "Panoo Root is $PANOO_ROOT"
export PANOO_ROOT=$PANOO_ROOT
$PANOO_CA/bin/ca-build-central.sh "$PANOO_ROOT"
$PANOO_CA/bin/ca-build-server.sh "$PANOO_ROOT"

exit 0
