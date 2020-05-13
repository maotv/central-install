#!/bin/bash

if [ -z "$PANOO_ROOT" ]; then
	echo "PANOO_ROOT is not set"
	exit 1
fi
source $PANOO_ROOT/etc/panoo.sh


# 
CA_HOME="$PANOO_ROOT/ca"

# Timestamp
DATE=`date +%Y%m%d-%H%M%S`

# Hostname
HOSTNAME="$PANOO_HOST"

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
touch ${CA_HOME}/temp/customer-ca.index
touch ${CA_HOME}/temp/customer-ca.index.attr


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
cat  ${CA_HOME}/certs/${CN}.cert.pem  ${CA_HOME}/customer-ca.cert.pem  ${CA_HOME}/panoo-root-ca.cert.pem > ${CA_HOME}/certs/${CN}.chain.pem

# cat $TARGET/server.cnf
echo ""
echo "Source: $TARGET"
