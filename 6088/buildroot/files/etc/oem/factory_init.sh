#!/bin/sh
. /etc/oem/band.txt
maceth0=$(cat /sys/class/net/eth0/address | tr -d ':')
# version
if [ -z "$BAND_NAME" ]; then
    BAND_NAME="03k.org"
fi
sed -i "s/BAND_NAME/$BAND_NAME/" /etc/openwrt_release

# hostname
if [ -z "$BAND_NAME" ]; then
    HOST_NAME="Router"
else
    if [ -z "$BAND_NAME_ADDMAC" ]; then
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
if [ -n "$BAND_ROOT_PASS" ]; then
    if [ -n "$PASS_PUBKEY" ]; then
        BAND_ROOT_PASS=$(echo -n "$maceth0""$PASS_PUBKEY" | sha256sum | grep -Eo "^[a-z0-9]{18}")
    fi
    hashed_password=$(openssl passwd -1 "$BAND_ROOT_PASS")
    sed -i "s|^root:[^:]*:|root:$hashed_password:|" /etc/shadow
fi

#  wlan patch
if [ -n "$PASS_PUBKEY" ]; then
    BAND_WLAN_PASS=$(echo -n "$maceth0""$PASS_PUBKEY" | sha256sum | tr -cd '0-9' | grep -Eo "[0-9]{18}$")
    BAND_SSID="$BAND_SSID"@"$maceth0"
fi
# 7981
if [ "$CHIP" = "7981" ]; then
    if [ -z "$BAND_SSID" ]; then
        BAND_SSID="MT7981"
    fi
    uci set wireless.MT7981_1_1=wifi-device
    uci set wireless.MT7981_1_1.type='mtwifi'
    uci set wireless.MT7981_1_1.phy='ra0'
    uci set wireless.MT7981_1_1.hwmode='11g'
    uci set wireless.MT7981_1_1.band='2g'
    uci set wireless.MT7981_1_1.dbdc_main='1'
    uci set wireless.MT7981_1_1.txpower='100'
    uci set wireless.MT7981_1_1.country='CN'
    uci set wireless.MT7981_1_1.mu_beamformer='1'
    uci set wireless.MT7981_1_1.noscan='1'
    uci set wireless.MT7981_1_1.serialize='1'
    uci set wireless.MT7981_1_1.htmode='HT20'
    uci set wireless.default_MT7981_1_1=wifi-iface
    uci set wireless.default_MT7981_1_1.device='MT7981_1_1'
    uci set wireless.default_MT7981_1_1.network='lan'
    uci set wireless.default_MT7981_1_1.mode='ap'
    uci set wireless.default_MT7981_1_1.ssid="$BAND_SSID"_2.4G
    uci set wireless.MT7981_1_2=wifi-device
    uci set wireless.MT7981_1_2.type='mtwifi'
    uci set wireless.MT7981_1_2.phy='rax0'
    uci set wireless.MT7981_1_2.hwmode='11a'
    uci set wireless.MT7981_1_2.band='5g'
    uci set wireless.MT7981_1_2.dbdc_main='0'
    uci set wireless.MT7981_1_2.txpower='100'
    uci set wireless.MT7981_1_2.country='CN'
    uci set wireless.MT7981_1_2.mu_beamformer='1'
    uci set wireless.MT7981_1_2.noscan='0'
    uci set wireless.MT7981_1_2.serialize='1'
    uci set wireless.MT7981_1_2.htmode='HE80'
    uci set wireless.default_MT7981_1_2=wifi-iface
    uci set wireless.default_MT7981_1_2.device='MT7981_1_2'
    uci set wireless.default_MT7981_1_2.network='lan'
    uci set wireless.default_MT7981_1_2.mode='ap'
    uci set wireless.default_MT7981_1_2.ssid="$BAND_SSID"_5G
    if [ -n "$BAND_WLAN_PASS" ]; then
        if [ -z "$PASS_PUBKEY" ]; then
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
    if [ -z "$BAND_SSID" ]; then
        BAND_SSID="MT7986"
    fi
    uci set wireless.MT7986_1_1=wifi-device
    uci set wireless.MT7986_1_1.type='mtwifi'
    uci set wireless.MT7986_1_1.phy='ra0'
    uci set wireless.MT7986_1_1.hwmode='11g'
    uci set wireless.MT7986_1_1.band='2g'
    uci set wireless.MT7986_1_1.dbdc_main='1'
    uci set wireless.MT7986_1_1.txpower='100'
    uci set wireless.MT7986_1_1.mu_beamformer='1'
    uci set wireless.MT7986_1_1.noscan='1'
    uci set wireless.MT7986_1_1.serialize='1'
    uci set wireless.MT7986_1_1.htmode='HT20'
    uci set wireless.MT7986_1_1.country='AU'
    uci set wireless.default_MT7986_1_1=wifi-iface
    uci set wireless.default_MT7986_1_1.device='MT7986_1_1'
    uci set wireless.default_MT7986_1_1.network='lan'
    uci set wireless.default_MT7986_1_1.mode='ap'
    uci set wireless.default_MT7986_1_1.ssid="$BAND_SSID"_2.4G
    uci set wireless.MT7986_1_2=wifi-device
    uci set wireless.MT7986_1_2.type='mtwifi'
    uci set wireless.MT7986_1_2.phy='rax0'
    uci set wireless.MT7986_1_2.hwmode='11a'
    uci set wireless.MT7986_1_2.band='5g'
    uci set wireless.MT7986_1_2.dbdc_main='0'
    uci set wireless.MT7986_1_2.txpower='100'
    uci set wireless.MT7986_1_2.country='CN'
    uci set wireless.MT7986_1_2.mu_beamformer='1'
    uci set wireless.MT7986_1_2.noscan='0'
    uci set wireless.MT7986_1_2.serialize='1'
    uci set wireless.MT7986_1_2.htmode='HE80'
    uci set wireless.default_MT7986_1_2=wifi-iface
    uci set wireless.default_MT7986_1_2.device='MT7986_1_2'
    uci set wireless.default_MT7986_1_2.network='lan'
    uci set wireless.default_MT7986_1_2.mode='ap'
    uci set wireless.default_MT7986_1_2.ssid="$BAND_SSID"_5G
    if [ -n "$BAND_WLAN_PASS" ]; then
        if [ -z "$PASS_PUBKEY" ]; then
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
if [ -n "$BAND_CIDR" ]; then
    uci set network.lan.ipaddr=$BAND_CIDR
    uci commit network
fi

rm -rf /etc/oem