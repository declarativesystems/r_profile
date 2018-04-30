#!/bin/bash

cat > /etc/grub.conf << END
#boot=/dev/sda
default=0
timeout=1
splashimage=(hd0,0)/grub/splash.xpm.gz
selinux=0
hiddenmenu
title CentOS (2.6.32-642.4.2.el6.x86_64) v2
        root (hd0,0)
        kernel /vmlinuz-2.6.32-642.4.2.el6.x86_64 ro root=UUID=8e2b6808-79a2-4880-9949-f3445196d75e rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet selinux=0
        initrd /initramfs-2.6.32-642.4.2.el6.x86_64.img
title CentOS (2.6.32-642.4.2.el6.x86_64) v2
        root (hd0,0)
        kernel /vmlinuz-2.6.32-642.4.2.el6.x86_64 ro root=UUID=8e2b6808-79a2-4880-9949-f3445196d75e rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  audit=0 KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet selinux=0
        initrd /initramfs-2.6.32-642.4.2.el6.x86_64.img
END
