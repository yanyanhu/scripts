# Client Certificate Based Authentication With Apache

Reference: https://manintheit.org/security/ssl-client-certificate-authentication-with-apache/

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

This sample configuration shows how to force server to request client certificate. Add the following config to `/etc/httpd/conf.d/ssl.conf``
```
Listen 9443 https

<Directory /opt/test-httpd/ankara/www>
        Require all granted
</Directory>

<VirtualHost *:9443>
        SSLEngine On
        SSLCertificateFile /etc/httpd/conf.d/certs/ankara.crt
        SSLCertificateKeyFile /etc/httpd/conf.d/certs/ankara.key
        ServerName ankara.example.com
        DocumentRoot /opt/test-httpd/ankara/www
        SSLVerifyClient require
        SSLVerifyDepth 5
        SSLCACertificateFile /etc/httpd/conf.d/certs/ca.crt
</VirtualHost>
```

The depth actually is the maximum number of intermediate certificate issuers, i.e. the number of CA certificates which are max allowed to be followed while verifying the client certificate. A depth of 0 means that self-signed client certificates are accepted only, the default depth of 1 means the client certificate can be self-signed or has to be signed by a CA which is directly known to the server (i.e. the CA’s certificate is under SSLCACertificatePath), etc.

Reference: https://httpd.apache.org/docs/2.4/mod/mod_ssl.html


Install mod_ssl:
```
sudo yum -y install mod_ssl
```

Locate the server cert and key:
```
mkdir -p /etc/httpd/conf.d/certs/
sudo cp ankara.crt /etc/httpd/conf.d/certs/
sudo cp ankara.key /etc/httpd/conf.d/certs/
```

Locate the ca cert:
```
sudo cp ca.crt /etc/httpd/conf.d/certs/
```

Create a simple index.html in the documentroot dir:
```
sudo mkdir -p /opt/test-httpd/ankara/www
```

Example index.html
```
<!doctype html>
<html>
  <head>
    <title>This is the title of the webpage!</title>
  </head>
  <body>
    <p>This is an example paragraph. Anything in the <strong>body</strong> tag will appear on the page, just like this <strong>p</strong> tag and its contents.</p>
  </body>
</html>
```

Restart Apache server:
```
sudo service httpd restart
```

### Experimenting with Curl

Without specifying the ca certificate:
```
[ec2-user@ip-172-31-100-215 tmp-certs]$ curl https://ankara.example.com:9443 -v
* Rebuilt URL to: https://ankara.example.com:9443/
*   Trying 172.31.100.215...
* TCP_NODELAY set
* Connected to ankara.example.com (172.31.100.215) port 9443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
* successfully set certificate verify locations:
*   CAfile: /etc/pki/tls/certs/ca-bundle.crt
  CApath: none
* TLSv1.2 (OUT), TLS header, Certificate Status (22):
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (OUT), TLS alert, unknown CA (560):
* SSL certificate problem: self signed certificate in certificate chain
* Closing connection 0
curl: (60) SSL certificate problem: self signed certificate in certificate chain
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
``` 

Without specifying the client certificate:
```
[ec2-user@ip-172-31-100-215 tmp-certs]$ curl -v --cacert ca.crt  https://ankara.example.com:9443
* Rebuilt URL to: https://ankara.example.com:9443/
*   Trying 172.31.100.215...
* TCP_NODELAY set
* Connected to ankara.example.com (172.31.100.215) port 9443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
* successfully set certificate verify locations:
*   CAfile: ca.crt
  CApath: none
* TLSv1.2 (OUT), TLS header, Certificate Status (22):
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Request CERT (13):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Certificate (11):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS alert, handshake failure (552):
* error:14094410:SSL routines:ssl3_read_bytes:sslv3 alert handshake failure
* Closing connection 0
curl: (35) error:14094410:SSL routines:ssl3_read_bytes:sslv3 alert handshake failure
```

With client certificate
```
[ec2-user@ip-172-31-100-215 tmp-certs]$ curl -v  --key client.key --cert client.crt --cacert ca.crt  https://ankara.example.com:9443
* Rebuilt URL to: https://ankara.example.com:9443/
*   Trying 172.31.100.215...
* TCP_NODELAY set
* Connected to ankara.example.com (172.31.100.215) port 9443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
* successfully set certificate verify locations:
*   CAfile: ca.crt
  CApath: none
* TLSv1.2 (OUT), TLS header, Certificate Status (22):
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Request CERT (13):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Certificate (11):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS handshake, CERT verify (15):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384
* ALPN, server accepted to use http/1.1
* Server certificate:
*  subject: C=XX; L=Default City; O=Default Company Ltd; CN=ankara.example.com
*  start date: Jul 16 03:42:22 2020 GMT
*  expire date: Jul 16 03:42:22 2021 GMT
*  common name: ankara.example.com (matched)
*  issuer: C=XX; L=Default City; O=Default Company Ltd
*  SSL certificate verify ok.
> GET / HTTP/1.1
> Host: ankara.example.com:9443
> User-Agent: curl/7.61.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Thu, 16 Jul 2020 04:43:09 GMT
< Server: Apache/2.4.43 () OpenSSL/1.0.2k-fips
< Upgrade: h2,h2c
< Connection: Upgrade
< Last-Modified: Thu, 16 Jul 2020 04:07:21 GMT
< ETag: "11e-5aa872d4ff049"
< Accept-Ranges: bytes
< Content-Length: 286
< Content-Type: text/html; charset=UTF-8
<
<!doctype html>
<html>
  <head>
    <title>This is the title of the webpage!</title>
  </head>
  <body>
    <p>This is an example paragraph. Anything in the <strong>body</strong> tag will appear on the page, just like this <strong>p</strong> tag and its contents.</p>
  </body>
</html>
* Connection #0 to host ankara.example.com left intact
```

### Converting certificate and to pkcs12 format
[WIP]

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
