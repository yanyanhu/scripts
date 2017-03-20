#!/bin/bash

echo 1 > /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A PREROUTING -d $HOSTIP -p tcp --dport 35559 -j DNAT --to-destination $DESTSERVERIP:22
