#!/bin/sh
if curl -Lsk --max-time 5 https://10000.gd.cn | grep -q html; then
    flag1=y
else
    flag1=n
fi
echo flag1:$flag1

if curl -Lsk --max-time 5 http://baidu.com | grep -q html; then
    flag2=y
else
    flag2=n
fi
echo flag2:$flag2

if curl -Lsk --max-time 5 http://qq.com | grep -q html; then
    flag3=y
else
    flag3=n
fi
echo flag3:$flag3

if curl -Lsk --max-time 5 http://223.5.5.5/resolve?name=qq.com | grep -q Status; then
    flag4=y
else
    flag4=n
fi
echo flag4:$flag4
if curl -Lsk --max-time 5 http://223.6.6.6/resolve?name=qq.com | grep -q Status; then
    flag5=y
else
    flag5=n
fi
echo flag5:$flag5

all=$flag1$flag2$flag3$flag4$flag5
if echo $all | grep -q nnnnn; then
    echo "wan err,restart pppoe"
    ifup wan
else
    echo pppoeok.:$all
fi
if echo $all | grep -Eq "^nnn.+"; then
    echo "dns err,restart dns"
    /usr/bin/mosdns.sh reload
fi