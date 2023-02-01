## nfs 安装

```bash
# 安装 nfs 服务
yum -y install nfs-utils rpcbind

# 创建共享目录
mkdir -p /nfs/data && chmod 1777 /nfs/data

# export 文件
cat >> /etc/exports << EOF
/nfs/data *(rw,sync,root_squash)
EOF

/public 192.168.1.0/24(rw,sync)
[共享目录]	[允许谁来访问][权限]	[可用主机名][权限]	[其他主机权限]
/nfs		192.168.1.1(rw)		     localhost(rw)		*(ro,sync)
/nfs		192.168.1.0/24(rw)	   localhost(rw)		*(ro,sync)
/nfs		192.168.1.1(rw)        192.168.1.2(ro)  192.168.1.3(ro,sync)

rw： 允许客户端读写
ro： 只读
no_root_squash： 不压缩 root 的权限
all_squash：  不管什么用户，它都会把权限改为 nfsnobody ，包含管理员
sync：        数据同步模式，将共享数据的改动，同步到磁盘 ====（推荐） 稳定，数据不易丢失，但是速度慢；（默认设置）


# 配置生效
exportfs -rv    # 使配置生效，不用重启 nfs 服务器，客户端实时更新

# 启动rpcbind、nfs服务
systemctl enable rpcbind && systemctl start rpcbind 
systemctl enable nfs && systemctl start nfs

# 验证
# 查看共享目录,ip 为真实服务器 ip
showmount -e ip

选项与参数：
-a ：显示目前主机与客户端的 NFS 联机分享的状态；
-e ：显示某部主机的 /etc/exports 所分享的目录数据。

# 挂载
mount -t nfs -o 选项 服务主机:/服务器共享目录  /本地挂载没记录
mount -t nfs -o rw,sync 192.168.1.5:/public /mnt/nfsmount

mount -t nfs 127.0.0.1:/nfs/data /mount/nfs
umount /mount/nfs
```

防火墙配置

```bash
iptables -F            #清空规则
iptables -t nat -F    #清空 nat 表规则
iptables -X            #删除用户自定义的规则链
iptables -t nat -X    #删除用户自定义 nat 的规则链
iptables -t filter -P INPUT DROP    #设定全局禁止模式
iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT      #开启  22   端口允许远程
iptables -t filter -A INPUT -p tcp --dport 111 -j ACCEPT     #允许  111  端口 tcp 协议通过
iptables -t filter -A INPUT -p udp --dport 111 -j ACCEPT     #允许  111  端口 udp 协议通过
iptables -t filter -A INPUT -p tcp --dport 2049 -j ACCEPT    #允许 2049  端口 udp 协议通过
iptables -t filter -A INPUT -p udp --dport 2049 -j ACCEPT    #允许 2049  端口 udp 协议通过
iptables -t filter -A INPUT -p tcp --dport 30003 -j ACCEPT   #允许 30003 端口 udp 协议通过
iptables -t filter -A INPUT -p udp --dport 30003 -j ACCEPT   #允许 30003 端口 udp 协议通过
```

