#!/bin/sh
#
# Dump DHCP traffic to log file, for pulling out hostnames

while true; do
 dhcpdump -i eth0 >> dhcpraw.log
sleep 30
done

