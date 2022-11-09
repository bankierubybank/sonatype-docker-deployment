#!/bin/sh

PATH="."
SERVER_KEY="$PATH/server.key"
SERVER_CSR="$PATH/server.csr"
SERVER_CRT="$PATH/server.crt"
EXTFILE="$PATH/cert_ext.cnf"
OPENSSL_CMD="/usr/bin/openssl"

# generating server key
echo "Generating private key"
$OPENSSL_CMD genrsa -out $SERVER_KEY 4096 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to generate $SERVER_KEY"
   exit 1
fi

# Generating Certificate Signing Request using config file
echo "Generating Certificate Signing Request"
$OPENSSL_CMD req -new -key $SERVER_KEY -out $SERVER_CSR -config $EXTFILE 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to generate $SERVER_CSR"
   exit 1
fi

echo "Generating self signed certificate"
$OPENSSL_CMD x509 -req -days 3650 -in $SERVER_CSR -signkey $SERVER_KEY -out $SERVER_CRT -extfile $EXTFILE 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to generate self-signed certificate file $SERVER_CRT"
fi