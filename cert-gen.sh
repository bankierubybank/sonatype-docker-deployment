#!/bin/sh
OPENSSL_CMD="/usr/bin/openssl"

CERT_PATH="./certs"

ROOT_CONFIG="$CERT_PATH/01_rootCA.cnf"
INTERMEDIATE_CONFIG="$CERT_PATH/01_intermediate.cnf"
EXTFILE="$CERT_PATH/01_cert_ext.cnf"

ROOTCA_KEY="$CERT_PATH/rootca.key"
ROOTCA_CRT="$CERT_PATH/rootca.crt"

INTERMEDIATE_KEY="$CERT_PATH/intermediate.key"
INTERMEDIATE_CSR="$CERT_PATH/intermediate.csr"
INTERMEDIATE_CRT="$CERT_PATH/intermediate.crt"

SERVER_KEY="$CERT_PATH/server.key"
SERVER_CSR="$CERT_PATH/server.csr"
SERVER_CRT="$CERT_PATH/server.crt"

FULLCHAIN="$CERT_PATH/fullchain.pem"

touch $CERT_PATH/root_index.txt
touch $CERT_PATH/intermediate_index.txt

echo 1000 > $CERT_PATH/root_serial
echo 1000 > $CERT_PATH/intermediate_serial

# Generate Root CA private key
echo "Generating Root CA private key"
$OPENSSL_CMD genrsa -aes256 -out $ROOTCA_KEY 4096 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to generate $ROOTCA_KEY"
   exit 1
fi
# Generate Root CA certifcate
echo "Generating Root CA certificate"
$OPENSSL_CMD req -config $ROOT_CONFIG -key $ROOTCA_KEY -new -x509 -days 7300 -sha256 -extensions v3_ca -out $ROOTCA_CRT 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to generate $ROOTCA_CRT"
fi

# Generate Intermediate CA private key
echo "Generating Intermediate CA private key"
$OPENSSL_CMD genrsa -aes256 -out $INTERMEDIATE_KEY 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to generate $INTERMEDIATE_KEY"
   exit 1
fi
# Generate Intermediate CSR
echo "Generating Intermediate CSR"
$OPENSSL_CMD req -config $INTERMEDIATE_CONFIG -new -sha256 -key $INTERMEDIATE_KEY -out $INTERMEDIATE_CSR 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to generate CSR $INTERMEDIATE_CSR"
fi
# Sign Intermediate CA certifcate
echo "Signing Intermediate CA certificate"
$OPENSSL_CMD ca -config $ROOT_CONFIG -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in $INTERMEDIATE_CSR -out $INTERMEDIATE_CRT -batch 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to sign $INTERMEDIATE_CRT"
fi

# Generating Server key and CSR
echo "Generating Server private key and CSR"
$OPENSSL_CMD req -config $EXTFILE -nodes -newkey rsa:2048 -sha256 -keyout $SERVER_KEY -out $SERVER_CSR 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to generate $SERVER_KEY or $SERVER_CSR"
   exit 1
fi
# Sign Server certifcate
echo "Signing Server certificate"
$OPENSSL_CMD ca -config $INTERMEDIATE_CONFIG -extensions server_cert -extfile $EXTFILE -days 375 -notext -md sha256 -in $SERVER_CSR -out $SERVER_CRT -batch 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to generate self-signed certificate file $SERVER_CRT"
fi

# Create full chain
echo "Creating Full Chain"
cat $SERVER_CRT $INTERMEDIATE_CRT $ROOTCA_CRT > $FULLCHAIN 2>/dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Failed to create full chain certificate file $FULLCHAIN"
fi