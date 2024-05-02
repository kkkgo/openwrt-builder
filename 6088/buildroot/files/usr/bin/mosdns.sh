#!/bin/sh
IPREX4='([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
get_local() {
    uci show network.lan.ipaddr | grep -Eo "$IPREX4" | head -1
}
start_dns() {
    if ps | grep -v "grep" | grep -q /tmp/mosdns; then
        echo "mosdns running ok."
    else
        echo "try to run mosdns..."
        rm /tmp/mosdns*.yaml
        sed "s/{local_net}/$(get_local)/g" /etc/mosdns.yaml >/tmp/mosdns"$(get_local)".yaml
        mosdns start -d /tmp -c /tmp/mosdns"$(get_local)".yaml &
    fi
}
stop_dns() {
    if ps | grep -v "grep" | grep -q /tmp/mosdns; then
        echo "try to kill mosdns..."
        killall mosdns
    fi
    sleep 1
    if ps | grep -v "grep" | grep -q /tmp/mosdns; then
        echo "try to kill mosdns..."
        killall mosdns
    fi
}
if [ "$1" = "get_local" ]; then
    get_local
fi
if [ "$1" = "start" ]; then
    start_dns
fi
if [ "$1" = "stop" ]; then
    stop_dns
fi
if [ "$1" = "restart" ] || [ "$1" = "reload" ]; then
    stop_dns
    start_dns
fi
