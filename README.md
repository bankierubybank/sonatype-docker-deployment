# Sonatype Nexus RM & IQ Docker Deployment

### Generate Self-signed Certificate to use with Sonatype Nexus RM
#### Generate PEM format certificate
1. Edit certs/01_cert_ext.cnf file
1. Run cert-gen.sh, it will prompt for pass phase
```
Generating Root CA private key
Enter pass phrase for ./certs/rootca.key:
Verifying - Enter pass phrase for ./certs/rootca.key:
Generating Root CA certificate
Enter pass phrase for ./certs/rootca.key:
Generating Intermediate CA private key
Enter pass phrase for ./certs/intermediate.key:
Verifying - Enter pass phrase for ./certs/intermediate.key:
Generating Intermediate CSR
Enter pass phrase for ./certs/intermediate.key:
Signing Intermediate CA certificate
Enter pass phrase for ./certs/rootca.key:
Generating Server private key and CSR
Signing Server certificate
Enter pass phrase for ./certs/intermediate.key:
Creating Full Chain
```

#### Convert certificate from PEM format to PKCS12 format
``` openssl pkcs12 -export -in certs/fullchain.pem -inkey certs/server.key -out jkeystore.p12 ```

#### Convert certificate from PKCS12 format to JKS format
``` keytool -importkeystore -destkeystore keystore.jks -deststoretype PKCS12 -srcstoretype PKCS12 -srckeystore jkeystore.p12 ```

### Preparation for deploy NXRM (Bind Mount ONLY)
```
mkdir -p repository-data/etc/{ssl,jetty}
mv nexus.properties repository-data/etc
mv jetty/* repository-data/etc/jetty
mv keystore.jks repository-data/etc/ssl
chown -R 200:200 repository-data
```

### Deploy Sonatype Nexus RM
``` docker compose up -d repository ```

### Post-configration for deploy NXRM (Volume ONLY)
First getting volume mountpoint using ``` docker volume inspect repository-data ```
Then copy below files to the volume (Replace VOLUME-MOUNTPOINT with exact path from above command)
```
mv nexus.properties VOLUME-MOUNTPOINT/etc
mv -R jetty VOLUME-MOUNTPOINT/etc
mkdir -p VOLUME-MOUNTPOINT/etc/ssl
mv keystore.jks VOLUME-MOUNTPOINT/etc/ssl
```
After that, restart the container using ``` docker compose restart ```

### Accessing Sonatype Nexus RM
1. Open web browser and navigate to http://localhost:8081





https://hub.docker.com/r/sonatype/nexus3