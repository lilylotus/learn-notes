### 配置网络

重启网络

```bash
nmcli con reload
```

### 安装需要的软件

```bash
yum clean all && yum makecache
yum install -y vsftpd dhcp-server xinetd tftp
# 开机自启
systemctl enable vsftpd dhcpd tftp xinetd
```

### 配置 dbcpd 服务

/etc/dhcp/dhcpd.conf

```conf
ddns-update-style none;
ignore client-updates;
default-lease-time 259200;
max-lease-time 518400;
option domain-name-servers 192.168.10.2;
# 上面是 DNS 的 IP 设定,这个设定值会修改客户端的 /etc/resolv.conf

# 2. 关于动态分配的 IP
subnet 192.168.10.0 netmask 255.255.255.0 {
	range 192.168.10.11 192.168.10.20;
	option routers 192.168.10.2; 
	option subnet-mask 255.255.255.0;
	next-server 192.168.10.4;
	# the configuration  file for pxe boot
	filename "pxelinux.0";
}
```

#### 配置 tftp 服务

```bash
/etc/xinetd.d/tftp
disable		= yes 改为 no
```

#### vsftpd 允许匿名

/etc/vsftpd/vsftpd.conf

```bash
anonymous_enable=NO -> YES
```

#### 文件准备

```bash
mkdir -p /var/lib/tftpboot/{centos,pxelinux.cfg}
mkdir -p /var/ftp/pub/{centos,ksdir}
mount /dev/sr0 /var/ftp/pub/centos
cp /var/ftp/pub/centos/images/pxeboot/{initrd.img,vmlinuz} /var/lib/tftpboot/centos/
cp /usr/share/syslinux/{vesamenu.c32,menu.c32,pxelinux.0} /var/lib/tftpboot
```

pxe 启动配置

```bash
# 配置 pxe default
cat <<EOF > /var/lib/tftpboot/pxelinux.cfg/default
default vesamenu.c32
prompt 0
timeout 300
display boot.msg
menu title ###### PXE Boot Menu ######
label 1
  menu label ^Install CentOS
  kernel centos/vmlinuz
  append initrd=centos/initrd.img ks=ftp://192.168.10.4/pub/ksdir/ks.cfg
label 2
  menu default
  menu label Boot from ^local drive
  localboot 0xffff
  menu end
EOF
```

```bash
# 创建 ks 文件

```