#!/bin/sh
if ps | grep -v "grep" | grep -q mosdns; then
    echo "mosdns running ok."
else
    echo "Start mosdns..."
    mosdns start -d /etc -c mosdns.yaml &
fi
/usr/bin/check_ppp.sh
#/etc/hotplug.d/iface/ddns.sh

if grep -q 1 /tmp/flytrap; then
    echo "flytrap ok."
else
    echo "apply flytrap..."
#    sh /usr/bin/flytrap.sh && echo 1 >/tmp/flytrap
fi
