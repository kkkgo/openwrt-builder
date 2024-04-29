#!/bin/bash
git clone --depth=1 https://github.com/immortalwrt/immortalwrt.git /src
./scripts/feeds update -a
./scripts/feeds install -a

chmod +x /src/files/usr/bin/*

# remove hijack udp 53
dnsmasqfile=/src/package/network/services/dnsmasq/files/dnsmasq.init
sed -i 's/iptables /echo -n #/g' "$dnsmasqfile"
sed -i 's/ip6tables /echo -n #/g' "$dnsmasqfile"
sed -i 's/nft /echo -n #/g' "$dnsmasqfile"
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

cp /src/ax6.config /src/.config
make download -j4
make -j4
cp /src/6088.config /src/.config
make download -j4
make -j4
make clean
rm -rf /src/.git