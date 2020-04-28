#!/bin/bash
if [ -z "$1" ]; then echo "no dir given"; exit 1; fi
WT="whiptail --backtitle PanooCentral"

INST=$1
TEMP=$INST/temp

. $INST/temp/panoo.sh


if [ ! -f $TEMP/files/panoo-keypack.$PANOO_INSTCODE.tar.gz ]; then
	curl https://panoo.com/download/central/panoo-keypack.$PANOO_INSTCODE.tar.gz --output $TEMP/files/panoo-keypack.$PANOO_INSTCODE.tar.gz
fi

if [ ! -d $TEMP/certs ]; then
    tar xf $TEMP/files/panoo-keypack.$PANOO_INSTCODE.tar.gz --directory $TEMP
fi

KEYPACK="$TEMP/certs"

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

cp "$KEYPACK/customer-ca.cert.pem" "$PANOO_CA"
cp "$KEYPACK/customer-ca.key.pem" "$PANOO_CA/private"
cp "$INST/data/customer-ca.cnf" "$PANOO_CA/customer-ca.cnf"
cp "$INST/data/server.template.cnf" "$PANOO_CA/server.template.cnf"

sed -i "s|%%PANOO_CUSTOMER%%|xxxxxxxxxxcustomerxxxxxxxxx|" $PANOO_CA/customer-ca.cnf

echo "Panoo Root is $PANOO_ROOT"
export PANOO_ROOT=$PANOO_ROOT
$PANOO_CA/bin/ca-build-server.sh "$PANOO_ROOT"


