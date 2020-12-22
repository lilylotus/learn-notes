#### 1. 网络配置

```bash
/etc/sysconfig/network-scripts/ifcfg-ens33
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="static"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
UUID="19c8177f-44ca-46f9-8d94-5e00016666e5"
DEVICE="ens33"
ONBOOT="yes"
IPADDR="10.10.37.100"
NETMASK="255.255.255.0"
GATEWAY="10.10.37.2"
DNS1="8.8.8.8"
DNS2="114.114.114.114"
```

#### 2. nmcli 网络配置

nmcli 是 redhat7 或者 centos7 之后的命令，可完成网卡所有的配置工作，并可写入配置文件，永久生效

<font color="red">Centos8 没有了 network，转为使用 nmcli 工具</font>

##### 2.1 查看网卡信息

```bash
# 所有网络
nmcli connection [c/conn] show
# 活动网络
nmcli connection show -active
# 指定网卡详细信息
nmcli connection show ens32
```

##### 2.2 设备信息

```bash
# 设备连接状态
nmcli device [d] status
# 网络设备详细信息
nmcli device [d] show
# 指定网络设备详细信息
nmcli d show ens32
```

##### 2.3 网络状态修改

```bash
# 启用网络
nmcli c up ens32
# 禁用网卡
nmcli c down ens32
# 断开设备
mncli d disconnect ens32
# 删除连接
nmcli c delete ens32
# 重新加载
nmcli c reload / nmcli connection reload
```

##### 2.4 修改网络配置

```bash
# 启动方式 BOOTPROTO=dhcp -> auto, BOOTPROTO=none -> manual
nmcli connection modify ens37 ipv4.method auto
# 修改 IP 地址, IPADDR=192.168.1.166 PREFIX=24
nmcli connection modify ens37 ipv4.addresses 192.168.1.166/24
# 修改网关 GATEWAY=192.168.1.1
nmcli connection modify ens37 ipv4.gateway 192.168.1.1

# 添加第二个IP地址（IPADDR1=172.16.10.10 PREFIX1=24）
nmcli connection modify ens37 +ipv4.addresses 192.168.123.207/24
nmcli connection modify ens37 +ipv4.addresses 192.168.0.58

# 添加DNS（DNS1=8.8.8.8）
nmcli connection modify ens37 +ipv4.dns 8.8.8.8
# 删除 DNS
nmcli connection modify ens37 -ipv4.dns 8.8.8.8
```



