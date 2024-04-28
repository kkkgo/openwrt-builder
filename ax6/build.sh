#!/bin/bash
chmod +x /src/files/usr/bin/*

# use mosdns
dnsmasqfile=/src/package/network/services/dnsmasq/files/dnsmasq.init
sed -i 's/append_parm "\$cfg" port "--port"/append_parm "\$cfg" 0 "--port"/g' "$dnsmasqfile"
sed -i '/start_service()/a \
if ps |grep -v "grep"|grep -q mosdns;then\
echo "mosdns running ok."\
else\
echo "Start mosdns..."\
mosdns start -d /etc -c mosdns.yaml &\
fi' "$dnsmasqfile"

# patch Makefile
sed -i "s/e2fsprogs//g" | sed "s/ kmod-fs-ext4//g" | sed -i "s/ uboot-envtools//g" /src/target/linux/qualcommax/Makefile
make -j4 V=sc
