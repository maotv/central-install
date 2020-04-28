#!/bin/bash

if [ -z "$PANOO_ROOT" ]; then
	echo "PANOO_ROOT is not set"
	exit 1
fi


# FIXME
# PANOO_HOME=/panoof

# FIXME
CA_HOME="$PANOO_ROOT/ca"

# Timestamp
DATE=`date +%Y%m%d-%H%M%S`

# Hostname
HOSTNAME="127.0.0.1"

# Use panoo temp folder
TARGET="$PANOO_ROOT/temp/SERVER-$DATE"
mkdir -p $TARGET

# copy configuration
echo "CN = $HOSTNAME" > $TARGET/server.cnf
echo "CA_HOME = $CA_HOME" >> $TARGET/server.cnf
echo "TARGET = $TARGET" >> $TARGET/server.cnf
cat $CA_HOME/server.template.cnf >> $TARGET/server.cnf

cd $TARGET
export CN=$HOSTNAME

# Create the first key and the CSR:
# openssl req -config server.cnf -new -out ${CA_HOME}/certreqs/${HOSTNAME}.req.pem
openssl req -config server.cnf -new -out ${TARGET}/${HOSTNAME}.req.pem


openssl rand -hex 16 > ${CA_HOME}/temp/customer-ca.serial
if [ ! -f ${CA_HOME}/temp/customer-ca.index ]; then
    touch ${CA_HOME}/temp/customer-ca.index
fi


export CA_HOME="$CA_HOME"
openssl ca \
    -batch \
    -config ${CA_HOME}/customer-ca.cnf \
    -in ${TARGET}/${CN}.req.pem \
    -out ${CA_HOME}/certs/${CN}.cert.pem \
    -extensions server_ext
# openssl ca \
#     -batch \
#     -config ${CA_HOME}/customer-ca.cnf \
#     -in ${CA_HOME}/certreqs/${CN}.req.pem \
#     -out ${CA_HOME}/certs/${CN}.cert.pem \
#     -extensions server_ext



# cp ${CN}.req.pem $MYDIR/intermediate/${AUTHORITY}-ca/certreqs/  


# cat $TARGET/server.cnf
echo ""
echo "Source: $TARGET"

exit 1

PWD=`pwd`

AUTHORITY="ardaktuell"
HOSTNAME="hhlokpanoo-01.srv.ndr-net.de"

MYDIR=`pwd`
ROOTCA="$MYDIR/root-ca"
TARGET="$MYDIR/target/SERVER-$DATE"

mkdir -p $TARGET

# copy configuration
echo "CN = $HOSTNAME" > $TARGET/server.cnf
cat server.cnf >> $TARGET/server.cnf


cd $TARGET
export CN=$HOSTNAME

# Create the first key and the CSR:
openssl req -config server.cnf -new -out ${CN}.req.pem

cp ${CN}.req.pem $MYDIR/intermediate/${AUTHORITY}-ca/certreqs/


export CA_HOME="$MYDIR/intermediate/${AUTHORITY}-ca"
cd $MYDIR/intermediate/${AUTHORITY}-ca

# Create the backup key:
# openssl genrsa -out private/${CN}.backup.key.pem 3072
openssl rand -hex 16 > temp/intermed-ca.serial

openssl ca \
    -batch \
    -config intermed-ca.cnf \
    -in ./certreqs/${CN}.req.pem \
    -out ./certs/${CN}.cert.pem \
    -extensions server_ext
