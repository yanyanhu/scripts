#!/bin/bash
#
# Upload certs to AWS through IAM
# Reference: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/configuring-https-ssl-upload.html
# Note: using certificate manager instead of IAM if supported
#


read -p "AWS_ACCESS_KEY_ID : " ID
read -p "AWS_SECRET_ACCESS_KEY : " KEY

export AWS_ACCESS_KEY_ID=$ID
export AWS_SECRET_ACCESS_KEY=$KEY

CERT_NAME=${1:-elastic-beanstalk-x509}
CERT_FILE=file://https-cert.crt
PRIVATE_KEY=file://private-key.pem

# Upload a self-signed certificate named "https-cert.crt" with a private key named "private-key.pem"
aws iam upload-server-certificate --server-certificate-name $CERT_NAME --certificate-body $CERT_FILE --private-key $PRIVATE_KEY
