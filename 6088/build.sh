#!/bin/bash
chmod +x "/src/files/usr/bin/*"

# remove hijack udp 53
dnsmasqfile=/src/package/network/services/dnsmasq/files/dnsmasq.init
sed -i 's/iptables /echo -n #/g' "$dnsmasqfile"
sed -i 's/ip6tables /echo -n #/g' "$dnsmasqfile"
# use mosdns
sed -i 's/append_parm "\$cfg" port "--port"/append_parm "\$cfg" 0 "--port"/g' "$dnsmasqfile"
sed -i '/start_service()/a \
if ps |grep -v "grep"|grep -q mosdns;then\
echo "mosdns running ok."\
else\
echo "Start mosdns..."\
mosdns start -d /etc -c mosdns.yaml &\
fi' "$dnsmasqfile"

# luci settings
luciset=/src/package/emortal/default-settings/files/99-default-settings-chinese
sed -i '/system.@system\[0\].zonename/a set system.@system[0].hostname="Router"' "$luciset"

make -j4 V=sc
