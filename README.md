# Sonatype Nexus RM & IQ Docker Deployment

### Generate Self-signed Certificate to use with Sonatype Nexus RM
#### Generate PEM format certificate
1. Edit cert_ext.cnf file
1. Run cert-gen.sh

#### Convert certificate from PEM format to PKCS12 format
``` openssl pkcs12 -export -in server.crt -inkey server.key -out jkeystore.p12 ```

#### Convert certificate from PKCS12 format to JKS format
``` keytool -importkeystore -destkeystore jkeystore.jks -deststoretype PKCS12 -srcstoretype PKCS12 -srckeystore jkeystore.p12 ```

### Deploy Sonatype Nexus RM
``` docker compose up -d nexus-rm ```

### Accessing Sonatype Nexus RM
1. Open web browser and navigate to http://localhost:8081

https://hub.docker.com/r/sonatype/nexus3