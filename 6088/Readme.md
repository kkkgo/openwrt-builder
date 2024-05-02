## 1. Setting up DNS
The system's built-in dnsmasq has been patched, and DNS is directly managed by mosdns.  
Edit `/etc/mosdns.yaml`,  
In the first section, set your primary DNS, such as PaoPaoDNS:  
```yaml
# set your local dns here.
#        - addr: "udp://10.10.10.7"  # Uncomment this, with your paopaodns
        - addr: "udp://119.29.29.29" # Comment this

```
In the second section, set your failover DNS, such as your local ISP’s DNS server:  
```yaml
# set your isp dns here.
        - addr: "udp://202.96.128.86"
        - addr: "udp://202.96.134.33"
        - addr: "udp://223.5.5.5"
```
In the third section, remove 28 if you need IPv6 records.  
```yaml
# no v6 dns
        - matches: "qtype 64 65 28"
          exec: reject 0
```

## 2. Editing `/usr/bin/cron_min.sh`
- Tasks executed every minute.
- Automatically checks if mosdns is running.
- `check_ppp.sh` is for detecting WAN disconnections and automatically redialing.
- Uncomment to enable the flytrap script:
```shell
#    sh /usr/bin/flytrap.sh && echo 1 >/tmp/flytrap
```
- You can edit `/usr/bin/flytrap.sh` to customize the trigger ban ports. Read: https://blog.03k.org/post/flytrap.html
- If `ue-ddns.sh` script is generated in the system and chosen for hotplug, it will be executed automatically. (Located in `/etc/hotplug.d/iface/*@*.sh`) . Read: https://blog.03k.org/post/ue-ddns.html 

## 3. Reloading mosdns
Start: `/usr/bin/mosdns.sh start`
Stop: `/usr/bin/mosdns.sh stop`
Restart: `/usr/bin/mosdns.sh restart` Or reload: `/usr/bin/mosdns.sh reload`