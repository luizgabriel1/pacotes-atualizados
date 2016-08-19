#!/bin/bash
atual=$(pwd)

senha="grub.pbkdf2.sha512.10000.A658581A1B07B60FF33339B88D4487D969E369F57199083F9BB3DBCF760BD453C293BAC1FA9FD3763D0CE968D10C49ADE2EF933353CFABED7EFC2226DBE12478.BBF477AFC94EECA30E40AC301622A77989DABBD2C04879DA5C00263AB49EE7135B2B5C4A95264B173637B474F0FBE925C562067649CD357C60195412718F3546"
echo "$atual"
echo -e "set superusers=\"root\"\npassword_pbkdf2 root $senha " >> /etc/grub.d/40_custom
#cd ./grub
#cp ./nuvem_1.png  /boot/grub/
#GRUB_BACKGROUND="/path/to/wallpaper"

#mv /etc/default/grub /etc/default/grub.old
#cat /etc/default/grub.old | sed 's/#GRUB_BACKGROUND="\/path\/to\/wallpaper"/GRUB_BACKGROUND="\/boot\/grub\/nuvem_1.png"/' > /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

#GRUB_BACKGROUND="/boot/grub/myimage"
#cat /boot/grub/grub.cfg | sed "s/'Arch Linux'/'Arch Linux' --unrestricted/" > /boot/grub/grub.cfg 
cd $atual
