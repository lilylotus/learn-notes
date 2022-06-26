#!/bin/bash

netPrefix=10.10.80
currentNet=10.10.80.8

# 安装软件
yum clean all && yum makecache faste
yum install -y vsftpd dhcp xinetd syslinux tftp-server vim

# 创建文件夹
mkdir -p /var/lib/tftpboot/{centos7,centos8,pxelinux.cfg}
mkdir -p /var/ftp/pub/{centos7,centos8,ksdir,sh,kernel}
mount /dev/sr0 /var/ftp/pub/centos7
cp /var/ftp/pub/centos7/images/pxeboot/{initrd.img,vmlinuz} /var/lib/tftpboot/centos7/
cp /usr/share/syslinux/{vesamenu.c32,menu.c32,pxelinux.0} /var/lib/tftpboot

# 配置 dhcp
cat <<EOF > /etc/dhcp/dhcpd.conf
ddns-update-style none;
ignore client-updates;
default-lease-time 259200;
max-lease-time 518400;
option domain-name-servers ${netPrefix}.2;

subnet ${netPrefix}.0 netmask 255.255.255.0 {
        range ${netPrefix}.50 ${netPrefix}.80;
        option routers ${netPrefix}.2; 
        option subnet-mask 255.255.255.0;
        next-server ${currentNet};
        filename "pxelinux.0";
}
EOF

# 配置 tftp
sed -ri '/disable/s/yes/no/g' /etc/xinetd.d/tftp

# 配置 pxe default
cat <<EOF > /var/lib/tftpboot/pxelinux.cfg/default
default vesamenu.c32
prompt 0
timeout 300
display boot.msg
menu title ###### PXE Boot Menu ######
label 1
  menu label ^Install CentOS 7
  kernel centos7/vmlinuz
  append initrd=centos7/initrd.img ks=ftp://${currentNet}/pub/ksdir/ks7.cfg
label 2
  menu label ^Install CentOS 7 K8S
  kernel centos7/vmlinuz
  append initrd=centos7/initrd.img ks=ftp://${currentNet}/pub/ksdir/ks7-k8s.cfg
label 3
  menu label ^Install Network CentOS 8
  kernel centos8/vmlinuz
  append initrd=centos8/initrd.img ks=ftp://${currentNet}/pub/ksdir/ks8.cfg
label 4
  menu default
  menu label Boot from ^local drive
  localboot 0xffff
  menu end
EOF

# 创建 ks 文件
touch /var/ftp/pub/ksdir/{ks7.cfg,ks8.cfg,ks7-k8s.cfg}
touch /var/ftp/pub/sh/{pxe7.sh,pxe7-k8s.sh,pxe8.sh,id_rsa.pub}

systemctl restart vsftpd
systemctl restart dhcpd
systemctl restart tftp
systemctl restart xinetd