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
option domain-name-servers 10.10.10.2;
# 上面是 DNS 的 IP 设定,这个设定值会修改客户端的 /etc/resolv.conf

# 2. 关于动态分配的 IP
subnet 10.10.10.0 netmask 255.255.255.0 {
	range 10.10.10.11 10.10.10.20;
	option routers 10.10.10.2; 
	option subnet-mask 255.255.255.0;
	next-server 10.10.10.2;
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
  append initrd=centos7/initrd.img ks=ftp://10.10.10.10/pub/ksdir/ks7.cfg
label 2
  menu label ^Install Network CentOS 7
  kernel centos7/vmlinuz
  append initrd=centos7/initrd.img ks=ftp://10.10.10.10/pub/ksdir/ks7-net.cfg
label 2
  menu label ^Install Network LVM CentOS 7
  kernel centos7/vmlinuz
  append initrd=centos7/initrd.img ks=ftp://10.10.10.10/pub/ksdir/ks7-net-lvm.cfg
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

net.cfg

```
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Install OS instead of upgrade
install
# Use network installation
url --url="ftp://10.10.10.10/pub/centos7"
# Use text mode install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8 --addsupport=zh_CN.UTF-8

# Network information
network  --bootproto=dhcp --device=ens32 --ipv6=auto --activate
network  --hostname=localhost.localdomain

# Install Reboot
reboot
# Root password
rootpw --iscrypted $6$/mEheoY7kFunvMmx$yVdqZWsGPnWAcHwMz3a.YOvNfzeorNFoVsMyMzM/Myali9ONorHdAjLMC4PpN/dtzE5bJob/Piut.QUQpfLmr/
# SELinux configuration
selinux --disabled
firewall --disabled
# System services
services --disabled="chronyd"
# Do not configure the X Window System
skipx
# System timezone
timezone Asia/Shanghai --isUtc
user --name=luck --password=$6$Os2WYRQPpzIEUUNa$7IWqvBKYZedtcNxf80QX7sxpms3hxBWBD1bocvkPgWh7Ahm5XKmvF6tUJKArPyNuPbgbkbV8aOW7k5q15mbew0 --iscrypted --gecos="luck"
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part /boot --fstype="xfs" --ondisk=sda --size=500
part pv.300 --fstype="lvmpv" --ondisk=sda --size=19979
volgroup centos --pesize=4096 pv.300
logvol swap  --fstype="swap" --size=1543 --name=swap --vgname=centos
logvol /  --fstype="xfs" --size=18432 --name=root --vgname=centos

%packages
@^minimal
@core
%end

%addon com_redhat_kdump --disable --reserve-mb='auto'
%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

%post
echo "Install Environment"
%end
```

