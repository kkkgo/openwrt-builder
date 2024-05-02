## 1、miwifi unblock ssh flash web uboot
. /lib/upgrade/platform.sh
switch_layout boot; do_flash_failsafe_partition ax6-ipq807x-u-boot.bin "0:APPSBL"  
`ax6-ipq807x-u-boot.bin	MD5	879CE0E75F180EF0BC497ED18535CC71`
## 2、flash big stock
192.168.1.100->web uboot 192.168.1.1-> ax6qsdknand-ipq807x_64-single.img
`ax6qsdknand-ipq807x_64-single.img	MD5	2CC72B255B064BEA0F46880BD85FEC82`
## 3、flash your complied stock-squashfs-factory.ubi
**[complie with Redmi AX6 (custom U-Boot layout) (Redmi AX6 (stock layout)]**  
192.168.1.100->web uboot 192.168.1.1-> immortalwrt-qualcommax-ipq807x-redmi_ax6-stock-squashfs-factory.ubi
