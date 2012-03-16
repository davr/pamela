#!/bin/sh

# Upload automatically generated mac-to-name mappings to the server
# NOTE: You need to add this to crontab manually

avahi-browse -a -t|tr "," " "|grep :.*:.*:.*:|sed -e 's/.*IPv. \(.*\) \[\(.*\)].*/\2,\1/g' -e 's/$/,20/' > /tmp/mapping

arp-scan -I eth0 -R --localnet|tr "," " "|sed -e 's/\(.*\)\t\(.*\)\t\(.*\)/\1,\2,\3/g'|grep :.*:.*: | grep -v DUP > /tmp/arpscan

rm -f /tmp/arps

cat /tmp/arpscan | while read i; do
IP=`echo $i|cut -f1 -d,`
MAC=`echo $i|cut -f2 -d,`
NAME=`echo $i|cut -f3 -d,`
echo $MAC >> /tmp/arps
echo $MAC,$NAME,10 >> /tmp/mapping
if [ "$1" != "noava" ]; then
 AVA=`avahi-resolve -a $IP|cut -f2-|sed -e 's/\.local//g'`
else
 AVA=
fi
if [ "$AVA" != "" ]; then
  echo $MAC,$AVA,19 >> /tmp/mapping
fi

done




POST=`cat /tmp/mapping|tr "\n" ";"|sed -e 's/;$//g'`
OUT='http://acemonstertoys.org/pamela/upload_m.php'
wget "${OUT}" --no-check-certificate -O - --quiet --post-data "data=${POST}"

POST=`cat /tmp/arps|tr "\n" ","|sed -e 's/,$//g'`
OUT='http://acemonstertoys.org/pamela/upload.php'
wget "${OUT}" --no-check-certificate -O - --quiet --post-data "data=${POST}"

 
