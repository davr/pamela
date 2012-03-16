# check a log from dhcpdump and look for client names.
# Usually when a device requests an address via DHCP, it sends both
# its mac address and its name. We store those as a mac->name mapping, to upload to pamela


tail -n3000 /home/pamela/pamela/scanner/dhcpraw.log | tr "\n\t" "@ " | sed -e 's/--------------------------------------------------------------------------/\n/g' -e 's/^.*CHADDR: \([0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*\).*Host name *\([^@]*\)@.*$/\1,\2,FOUNDIT\n/gm' | tr "@" "\n" | grep FOUNDIT|sort|uniq|grep -v ")"|sed -e 's/FOUNDIT/17/' > /tmp/mapping2
POST=`cat /tmp/mapping2|tr "\n" ";"|sed -e 's/;$//g'`
OUT='http://acemonstertoys.org/pamela/upload_m.php'
wget "${OUT}" --no-check-certificate -O - --quiet --post-data "data=${POST}"
