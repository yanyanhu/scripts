# Generate RSA public key from ssh pub key
ssh-keygen -f id_rsa.pub -e -m pem > pub1

# Generate RSA public key from RSA private key
openssl rsa -in id_rsa -pubout -out pub2
