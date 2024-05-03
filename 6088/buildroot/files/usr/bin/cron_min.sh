#!/bin/sh
/usr/bin/mosdns.sh start
/usr/bin/check_ppp.sh
ls /etc/hotplug.d/iface/*@*.sh 2>/dev/null && sh /etc/hotplug.d/iface/*@*.sh

if [ -f /tmp/flytrap ]; then
    echo "flytrap ok."
else
    echo "try to apply flytrap..."
#    sh /usr/bin/flytrap.sh && echo 1 >/tmp/flytrap
fi