#!/bin/bash - 

set -o nounset                              # Treat unset variables as an error
for id in 1 2 3 4
do
	iptables -I INPUT -p tcp --dport 590$id -j ACCEPT
	iptables -I INPUT -p tcp --dport 580$id -j ACCEPT
done

vncserver :1
vncserver :2
vncserver :3
vncserver -geometry 1280x1024 :4
