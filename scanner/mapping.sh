#!/bin/sh

# Upload automatically generated mac-to-name mappings to the server
# NOTE: You need to add this to crontab manually

  # Then we fall back to names obtained via zeroconf (aka avahi, aka bonjour)
  avahi-browse -a -t|tr "," " "|grep :.*:.*:.*:|sed -e 's/.*IPv. \(.*\) \[\(.*\)].*/\2,\1[\2]/g' -e 's/$/,20/' > /tmp/mapping

  # Finally we fall back to the name from arp-scan (maker of the network chipset)
  # Yes I know we already ran arp-scan once...I'm too lazy to do it right
  # And yes I'm using regex instead of learning how awk works.
  arp-scan -I eth0 -R --localnet|tr "," " "|sed -e 's/\(.*\)\t\(.*\)\t\(.*\)/\2,\3[\2]/g'|grep :.*:.*: | grep -v DUP | sed -e 's/$/,10/' >> /tmp/mapping

POST=`cat /tmp/mapping|tr "\n" ";"`

OUT='http://acemonstertoys.org/pamela/upload_m.php'
wget "${OUT}" --no-check-certificate -O - --quiet --post-data "data=${POST}"

 
