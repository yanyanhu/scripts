#!/bin/bash

sudo yum install -y httpd
sudo service httpd status
sudo service httpd start
sudo service httpd status
sudo chkconfig httpd on

# In AWS Linux, the Apache config file is located in
# /etc/httpd/conf/httpd.conf
