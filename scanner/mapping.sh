#!/bin/sh

# Upload automatically generated mac-to-name mappings to the server
# NOTE: You need to add this to crontab manually

  # Then we fall back to names obtained via zeroconf (aka avahi, aka bonjour)
avahi-browse -a -t|tr "," " "|grep :.*:.*:.*:|sed -e 's/.*IPv. \(.*\) \[\(.*\)].*/\2,\1[\2]/g' -e 's/$/,20/' > /tmp/mapping

  # Finally we fall back to the name from arp-scan (maker of the network chipset)
  # Yes I know we already ran arp-scan once...I'm too lazy to do it right
  # And yes I'm using regex instead of learning how awk works.
arp-scan -I eth0 -R --localnet|tr "," " "|sed -e 's/\(.*\)\t\(.*\)\t\(.*\)/\2,\3[\2]/g'|grep :.*:.*: | grep -v DUP | sed -e 's/$/,10/' >> /tmp/mapping

  
# A second pass for pulling names from avahi
# This time we first map mac addrs to IPs
  arp-scan -I eth0 -R --localnet|grep -v DUP|tr "," " "|sed -e 's/\(.*\)\t\(.*\)\t\(.*\)/\2,\1/g'|grep :.*:.*:  > /tmp/map1


# Then, for each IP, we run avahi-resolve to look up a hostname
for i in `cat /tmp/map1`; do
MAC=`echo $i|cut -f1 -d,`
IP=`echo $i|cut -f2 -d,`
AVA=`avahi-resolve -a $IP|cut -f2-|sed -e 's/\.local//g'`
if [ "$AVA" != "" ]; then
  echo $MAC,$AVA[$MAC],19 >> /tmp/mapping
fi

done




POST=`cat /tmp/mapping|tr "\n" ";"`

OUT='http://acemonstertoys.org/pamela/upload_m.php'
wget "${OUT}" --no-check-certificate -O - --quiet --post-data "data=${POST}"

 
