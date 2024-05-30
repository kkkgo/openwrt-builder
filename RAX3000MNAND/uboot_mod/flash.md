## official RAX3000MNAND to hanwckf web U-boot:

### 1. get root ssh 
1. webui export config, get `cfg_export_config_file.conf`.    
2. run in wsl/terminal, get /etc folder.  
```shell
openssl aes-256-cbc -d -pbkdf2 -k "$CmDc#RaX30O0M@\!$" -in cfg_export_config_file.conf -out - | tar -zxvf -
```
3. edit `/etc/shadow`, remove root password.
```shell
root::19179:0:99999:7:::
```

edit `/etc/config/dropbear`, enable ssh.
```shell
config dropbear
	option enable '1'
```  
4. pack `/etc`:
```shell
tar -zcvf - etc | openssl aes-256-cbc -pbkdf2 -k "$CmDc#RaX30O0M@\!$" -out cfg_export_config_file_ssh.conf
```
5. webui import `cfg_export_config_file_ssh.conf`, reboot and ssh.
### 2. backup image
```shell
cat /proc/mtd

dev:    size   erasesize  name
mtd0: 08000000 00020000 "spi0.0"
mtd1: 00100000 00020000 "BL2"
mtd2: 00080000 00020000 "u-boot-env"
mtd3: 00200000 00020000 "Factory"
mtd4: 00200000 00020000 "FIP"
mtd5: 03d00000 00020000 "ubi"
mtd6: 02500000 00020000 "plugins"
mtd7: 00800000 00020000 "fwk"
mtd8: 00800000 00020000 "fwk2"

dd if=/dev/mtd0 |gzip > /tmp/mtd0_spi0.0.gz
dd if=/dev/mtd1 |gzip > /tmp/mtd1_BL2.gz
dd if=/dev/mtd2 |gzip > /tmp/mtd2_u-boot-env.gz
dd if=/dev/mtd3 |gzip > /tmp/mtd3_Factory.gz
dd if=/dev/mtd4 |gzip > /tmp/mtd4_FIP.gz
dd if=/dev/mtd5 |gzip > /tmp/mtd5_ubi.gz
dd if=/dev/mtd6 |gzip > /tmp/mtd6_plugins.gz
dd if=/dev/mtd7 |gzip > /tmp/mtd7_fwk.gz
dd if=/dev/mtd8 |gzip > /tmp/mtd8_fwk2.gz

# bakcup to usb
 mv /tmp/mtd*.gz /mnt/usb/sda2/
```
### 3. flash uboot
https://github.com/hanwckf/bl-mt798x/releases
get `mt7981_cmcc_rax3000m-fip-fixed-parts.bin`
```shell
root@RAX3000M:/tmp# md5sum /tmp/mt7981_cmcc_rax3000m-fip-fixed-parts.bin
a12f8f6b3f52a77e6bce0c81b68de30d  /tmp/mt7981_cmcc_rax3000m-fip-fixed-parts.bin

root@RAX3000M:/tmp# cat /proc/mtd
dev:    size   erasesize  name
mtd0: 08000000 00020000 "spi0.0"
mtd1: 00100000 00020000 "BL2"
mtd2: 00080000 00020000 "u-boot-env"
mtd3: 00200000 00020000 "Factory"
mtd4: 00200000 00020000 "FIP"
mtd5: 03d00000 00020000 "ubi"
mtd6: 02500000 00020000 "plugins"
mtd7: 00800000 00020000 "fwk"
mtd8: 00800000 00020000 "fwk2"
root@RAX3000M:/tmp# mtd write  /tmp/mt7981_cmcc_rax3000m-fip-fixed-parts.bin FIP
Unlocking FIP ...

Writing from /tmp/mt7981_cmcc_rax3000m-fip-fixed-parts.bin to FIP ...
```
Reboot and hold the reset button to web U-Boot(192.168.1.1).