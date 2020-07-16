# Client Certificate Based Authentication With Apache

Refer from: https://manintheit.org/security/ssl-client-certificate-authentication-with-apache/

### Creating CA Certificate

We use this certificate for only signing certificates that we use for the clients and our web servers. It should be kept very secure. If it is disclosed other certificates signed with this certificate will be disclosed as well.
```
openssl genrsa -des3 -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -out ca.crt
```

### Creating a Key and CSR for the Client

Creating a client certificate is the same as creating Server certificate.
```
openssl req -newkey rsa:2048 -nodes -keyout client.key -out client.csr
```

### Signing the client certificate with previously created CA.

Not: Do not forget to change serial each time you sign new certificate, otherwise may get serial conflict error in the web browsers.
```
[root@centos7 certs]# openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
Signature ok
subject=/C=TR/L=Default City/O=Client Certificate/CN=Client Certificate
Getting CA Private Key
Enter pass phrase for ca.key:
```

### Creating a Key and CSR for the Server(Apache Virtual Host ankara.example.com)
```
openssl req -newkey rsa:2048 -nodes -keyout ankara.key -out ankara.csr
```

### Signing Server Certificate with previously created CA.

Do not forget to change serial number. As it may conflict with existing one.
```
openssl x509 -req -days 365 -in ankara.csr -CA ca.crt -CAkey ca.key -set_serial 02 -out ankara.crt
```

### Apache Configuration for the Authentication with Client Certificate

This sample configuration shows how to force server to request client certificate.
```
<Directory /srv/ankara/www>
	Require all granted
</Directory>


<VirtualHost *:443>
	SSLEngine On
	SSLCertificateFile /etc/httpd/conf.d/certs/ankara.crt
	SSLCertificateKeyFile /etc/httpd/conf.d/certs/ankara.key
	ServerName ankara.example.com
	DocumentRoot /srv/ankara/www 
	SSLVerifyClient require
	SSLVerifyDepth 5
	SSLCACertificateFile "/etc/httpd/conf.d/certs/ca.crt"
</VirtualHost>
```

The depth actually is the maximum number of intermediate certificate issuers, i.e. the number of CA certificates which are max allowed to be followed while verifying the client certificate. A depth of 0 means that self-signed client certificates are accepted only, the default depth of 1 means the client certificate can be self-signed or has to be signed by a CA which is directly known to the server (i.e. the CA’s certificate is under SSLCACertificatePath), etc.

Reference: https://httpd.apache.org/docs/2.4/mod/mod_ssl.html

### Experimenting with Curl

Without specifying the client certificate

```
gokay@ankara:~/certs$ curl https://ankara.example.com -v
* Rebuilt URL to: https://ankara.example.com/
* Trying 192.168.122.30...
* Connected to ankara.example.com (192.168.122.30) port 443 (#0)
* found 148 certificates in /etc/ssl/certs/ca-certificates.crt
* found 597 certificates in /etc/ssl/certs
* ALPN, offering http/1.1
* gnutls_handshake() failed: Handshake failed
* Closing connection 0
curl: (35) gnutls_handshake() failed: Handshake failed
``` 

With client certificate
```
gokay@ankara:~/certs$ curl https://ankara.example.com --key client.key --cert client.crt --cacert ca.crt -v
* Rebuilt URL to: https://ankara.example.com/
* Trying 192.168.122.30...
* Connected to ankara.example.com (192.168.122.30) port 443 (#0)
* found 1 certificates in ca.crt
* found 597 certificates in /etc/ssl/certs
* ALPN, offering http/1.1
* SSL connection using TLS1.2 / ECDHE_RSA_AES_128_GCM_SHA256
* server certificate verification OK
* server certificate status verification SKIPPED
* common name: ankara.example.com (matched)
* server certificate expiration date OK
* server certificate activation date OK
* certificate public key: RSA
* certificate version: #1
* subject: C=TR,L=Default City,O=Ankara LTD,CN=ankara.example.com
* start date: Sun, 24 Dec 2017 10:00:20 GMT
* expire date: Mon, 24 Dec 2018 10:00:20 GMT
* issuer: C=TR,L=Default City,O=BlueTech CA,OU=CA,CN=BlueTech CA
* compression: NULL
* ALPN, server did not agree to a protocol
> GET / HTTP/1.1
> Host: ankara.example.com
> User-Agent: curl/7.47.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Sun, 24 Dec 2017 10:21:15 GMT
< Server: Apache/2.4.6 (CentOS) OpenSSL/1.0.2k-fips
< Last-Modified: Sun, 24 Dec 2017 10:19:51 GMT
< ETag: "3b-5611363e4a8e0"
< Accept-Ranges: bytes
< Content-Length: 59
< Content-Type: text/html; charset=UTF-8
< 
<h1>My Secure Page Ankara</h1>
<h2>ankara.example.com</h2>
* Connection #0 to host ankara.example.com left intact
```

### Converting certificate and to pkcs12 format

If you want to import a certificate to a web browser, you have to convert your existing certificate other than PEM format. For the Mozilla Firefox, you need to convert it  to pkcs12 format.
```
openssl pkcs12 -export -out ankara.pfx -inkey ankara.key -in ankara.crt -certfile ca.crt
```

Only thing we need to do it import ankara.pfx to our browser.

Disabling Client Certificate Authentication

Comment out last three lines between the <VirtualHost> and </VirtualHost> directive.
```
<Directory /srv/ankara/www>
	Require all granted
</Directory>


<VirtualHost *:443>
	SSLEngine On
	SSLCertificateFile /etc/httpd/conf.d/certs/ankara.crt
	SSLCertificateKeyFile /etc/httpd/conf.d/certs/ankara.key
	ServerName ankara.example.com
	DocumentRoot /srv/ankara/www 
	#SSLVerifyClient require
	#SSLVerifyDepth 5
	#SSLCACertificateFile "/etc/httpd/conf.d/certs/ca.crt"
</VirtualHost>
```

Only thing that we need to do is specifying CA certificate or providing  -k option to curl for insecure SSL connection.
```
gokay@ankara:~/certs$ curl https://ankara.example.com  --cacert ca.crt 
<h1>My Secure Page Ankara</h1>
<h2>ankara.example.com</h2>
```
