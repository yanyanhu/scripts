#!/bin/bash


# The certificate to export from ACM and installed in the proxy server
PROXY_CERT_ARN=$1
PASS_PHRASE=$2
PASS_PHRASE_FILE=/tmp/passphrase-file-tmp

# 00-GenerateTempPassphraseFile
echo "00-generatepassphrazefile"
echo $PASS_PHRASE > $PASS_PHRASE_FILE
cat $PASS_PHRASE_FILE

# 01-getcertificate
echo "01-getcertificate"
aws acm export-certificate --certificate-arn $PROXY_CERT_ARN --passphrase $PASS_PHRASE --region ap-southeast-1 | jq -r '"\(.Certificate)"' > /tmp/study.pem

# 02-getcertificatechain
echo "02-getcertificatechain"
aws acm export-certificate --certificate-arn $PROXY_CERT_ARN --passphrase $PASS_PHRASE --region ap-southeast-1 | jq -r '"\(.CertificateChain)"' > /tmp/studyca.pem

# 03-getprivatekeywithpassword
echo "03-getprivatekeywithpassword"
aws acm export-certificate --certificate-arn $PROXY_CERT_ARN --passphrase $PASS_PHRASE --region ap-southeast-1 | jq -r '"\(.PrivateKey)"' > /tmp/studypwd.key

# 04-getprivatekeywithoutpassword
echo "04-getprivatekeywithoutpassword"
sudo openssl rsa -in /tmp/studypwd.key -out /tmp/study.key -passin file:/$PASS_PHRASE_FILE

# 05-Removeprivatekeywithpwdfromtmp
echo "05-Removeprivatekeywithpwdfromtmp"
sudo rm /tmp/studypwd.key

# 06-Movefilestohttpd
echo "06-Movefilestohttpd"
sudo mv /tmp/study* /etc/pki/httpd/

# 07-Changeownership
echo "07-Changeownership"
sudo chown root:root /etc/pki/httpd/*

# 08-RemoveDefaultVirtualConf
#echo "08-RemoveDefaultVirtualConf"
#sudo rm /etc/httpd/conf.d/ssl.conf

# 09-CleanupTempPassphraseFile
echo "09-CleanupTempPassphraseFile"
sudo rm $PASS_PHRASE_FILE

echo "Done"
