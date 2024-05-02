#!/bin/sh
/usr/bin/mosdns.sh start_service
/usr/bin/check_ppp.sh
ls /etc/hotplug.d/iface/*@*.sh 2>/dev/null && sh /etc/hotplug.d/iface/*@*.sh

if grep -q 1 /tmp/flytrap; then
    echo "flytrap ok."
else
    echo "apply flytrap..."
#    sh /usr/bin/flytrap.sh && echo 1 >/tmp/flytrap
fi
