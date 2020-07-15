#### 1. 安装需要的软件

```bash
yum clean all && yum makecache
yum install -y vsftpd dhcp xinetd syslinux tftp-server vim
systemctl enable vsftpd dhcpd tftp xinetd
```

#### 2. 配置 dhcp 服务

/etc/dhcp/dhcpd.conf

```bash
ddns-update-style none;
ignore client-updates;
default-lease-time 259200;
max-lease-time 518400;
option domain-name-servers 10.10.37.2;
# 上面是 DNS 的 IP 设定,这个设定值会修改客户端的 /etc/resolv.conf

# 2. 关于动态分配的 IP
subnet 10.10.37.0 netmask 255.255.255.0 {
	range 10.10.37.10 10.10.37.20;
	option routers 10.10.37.2; 
	option subnet-mask 255.255.255.0;
	next-server 10.10.37.2;
	# the configuration  file for pxe boot
	filename "pxelinux.0";
}
```

#### 3. 配置 tftp 服务

```bash
/etc/xinetd.d/tftp
disable		= yes 改为 no
```

#### 4. 文件准备

```bash
mkdir -p /var/lib/tftpboot/{centos7,pxelinux.cfg}
mkdir -p /var/ftp/pub/{centos,ksdir}
mount /dev/sr0 /var/ftp/pub/centos
cp /var/ftp/pub/centos/images/pxeboot/{initrd.img,vmlinuz} /var/lib/tftpboot/centos7/
cp /usr/share/syslinux/{vesamenu.c32,menu.c32,pxelinux.0} /var/lib/tftpboot
```

#### 5. 自动安装脚本

```bash
#!/bin/bash

# 安装软件
yum clean all && yum makecache
yum install -y vsftpd dhcp xinetd syslinux tftp-server vim
systemctl enable vsftpd dhcpd tftp xinetd

# 创建文件夹
mkdir -p /var/lib/tftpboot/{centos7,pxelinux.cfg}
mkdir -p /var/ftp/pub/{centos7,ksdir}
mount /dev/sr0 /var/ftp/pub/centos7
cp /var/ftp/pub/centos7/images/pxeboot/{initrd.img,vmlinuz} /var/lib/tftpboot/centos7/
cp /usr/share/syslinux/{vesamenu.c32,menu.c32,pxelinux.0} /var/lib/tftpboot

# 配置 dhcp
cat <<EOF > /etc/dhcp/dhcpd.conf
ddns-update-style none;
ignore client-updates;
default-lease-time 259200;
max-lease-time 518400;
option domain-name-servers 192.168.50.0;
subnet 192.168.50.0 netmask 255.255.255.0 {
        range 192.168.50.50 192.168.50.80;
        option routers 192.168.50.1; 
        option subnet-mask 255.255.255.0;
        next-server 192.168.50.119;
        filename "pxelinux.0";
}
EOF

# 配置 tftp
sed -ri 's/.*disable.*/        disable                 = no/g' /etc/xinetd.d/tftp

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
  append initrd=centos7/initrd.img ks=ftp://10.10.37.100/pub/ksdir/ks7.cfg
label 2
  menu label ^Install Network CentOS 7
  kernel centos7/vmlinuz
  append initrd=centos7/initrd.img ks=ftp://10.10.37.100/pub/ksdir/ks7-net.cfg
label 2
  menu label ^Install Network LVM CentOS 7
  kernel centos7/vmlinuz
  append initrd=centos7/initrd.img ks=ftp://10.10.37.100/pub/ksdir/ks7-net-lvm.cfg
label 4
  menu default
  menu label Boot from ^local drive
  localboot 0xffff
  menu end
EOF

# 创建 ks 文件
touch /var/ftp/pub/ksdir/{ks7.cfg,ks7-net.cfg,ks7-net-lvm.cfg}


systemctl restart vsftpd
systemctl restart dhcpd
systemctl restart tftp
systemctl restart xinetd
```

