#!/bin/sh
# init lock
sed -i "s|^root:[^:]*:|root:$(openssl passwd -1 /proc/sys/kernel/random/uuid):|" /etc/shadow

. /etc/oem/band.txt

while true; do
    ping -c 1 -W 1 192.168.1.1 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        iwc=$(iwinfo | grep MBit | wc -l)
        if [ "$iwc" = "2" ]; then
            if ps -ef | grep -v "grep" | grep drop | grep 192.168.1.1; then
                break
            fi
        fi
    fi
    sleep 1
done

maceth0=$(cat /sys/class/net/eth0/address | tr -d ':')

# version
if [ "$BAND_NAME" = "null" ]; then
    BAND_NAME="03k.org"
fi
sed -i "s/BAND_NAME/$BAND_NAME/" /etc/openwrt_release

# hostname
if [ "$BAND_NAME" = "null" ]; then
    HOST_NAME="Router"
else
    if [ "$BAND_NAME_ADDMAC" = "null" ]; then
        HOST_NAME="$BAND_NAME"
    else
        HOST_NAME="$BAND_NAME""_""$maceth0"
    fi
    # login hit
    login_js=/www/luci-static/resources/view/bootstrap/sysauth.js
    sed -i "s/Authorization Required/$HOST_NAME/g" $login_js
fi
uci set system.@system[0].hostname="$HOST_NAME"
uci commit system

# root pass patch
if [ "$BAND_ROOT_PASS" != "null" ]; then
    if [ "$PASS_PUBKEY" != "null" ]; then
        BAND_ROOT_PASS=$(echo -n "$maceth0""$PASS_PUBKEY" | sha256sum | grep -Eo "^[a-z0-9]{18}")
    fi
    hashed_password=$(openssl passwd -1 "$BAND_ROOT_PASS")
    sed -i "s|^root:[^:]*:|root:$hashed_password:|" /etc/shadow
fi

#  wlan patch
if [ "$PASS_PUBKEY" != "null" ]; then
    BAND_WLAN_PASS=$(echo -n "$maceth0""$PASS_PUBKEY" | sha256sum | tr -cd '0-9' | grep -Eo "[0-9]{18}$")
    BAND_SSID="$BAND_SSID"@"$maceth0"
fi
# 7981
if [ "$CHIP" = "7981" ]; then
    if [ "$BAND_SSID" = "null" ]; then
        BAND_SSID="MT7981"
    fi
    uci set wireless.MT7981_1_1.htmode='HT20'
    uci set wireless.MT7981_1_2.htmode='HE80'
    uci set wireless.default_MT7981_1_1.ssid="$BAND_SSID"_2.4G
    uci set wireless.default_MT7981_1_2.ssid="$BAND_SSID"_5G
    if [ "$BAND_WLAN_PASS" != "null" ]; then
        if [ "$PASS_PUBKEY" = "null" ]; then
            uci set wireless.MT7981_1_2.channel='52'
            uci set wireless.MT7981_1_1.channel='11'
        fi
        uci set wireless.default_MT7981_1_2.encryption='sae-mixed'
        uci set wireless.default_MT7981_1_1.encryption='psk-mixed'
        uci set wireless.default_MT7981_1_2.key="$BAND_WLAN_PASS"
        uci set wireless.default_MT7981_1_1.key="$BAND_WLAN_PASS"
    fi
fi
# 7986
if [ "$CHIP" = "7986" ]; then
    if [ "$BAND_SSID" = "null" ]; then
        BAND_SSID="MT7986"
    fi
    uci set wireless.MT7986_1_1.htmode='HT20'
    uci set wireless.MT7986_1_2.htmode='HE80'
    uci set wireless.default_MT7986_1_1.ssid="$BAND_SSID"_2.4G
    uci set wireless.default_MT7986_1_2.ssid="$BAND_SSID"_5G
    if [ "$BAND_WLAN_PASS" != "null" ]; then
        if [ "$PASS_PUBKEY" = "null" ]; then
            uci set wireless.MT7986_1_2.channel='52'
            uci set wireless.MT7986_1_1.channel='11'
        fi
        uci set wireless.default_MT7986_1_2.encryption='sae-mixed'
        uci set wireless.default_MT7986_1_1.encryption='psk-mixed'
        uci set wireless.default_MT7986_1_1.key="$BAND_WLAN_PASS"
        uci set wireless.default_MT7986_1_2.key="$BAND_WLAN_PASS"
    fi
fi

uci commit wireless

# cidr patch
if [ "$BAND_CIDR" != "null" ]; then
    uci set network.lan.ipaddr=$BAND_CIDR
    uci commit network
fi
rm -rf /etc/oem && reboot
