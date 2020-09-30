#!/bin/bash

# update environment
# 1. shutdown firewalld and configure selinux
echo $(date "+%Y-%m-%d %H:%M:%S") "shutdown firewalld and configure selinux" >> pxe.log
systemctl disable firewalld
sed -ri '/^SELINUX=/s/^(.*)$/SELINUX=disabled/' /etc/selinux/config

echo $(date "+%Y-%m-%d %H:%M:%S") "update system kernel params" >> pxe.log
cat <<EOF > /etc/sysctl.d/optimize.conf
vm.swappiness = 0
vm.overcommit_memory = 1
vm.panic_on_oom = 0

fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 89100
fs.file-max = 52706963
fs.nr_open = 52706963
fs.may_detach_mounts = 1

net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-arptables = 1

net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp.keepaliv.probes = 3
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp.max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp.max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.top_timestamps = 0
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla

net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 16384
EOF

sysctl -p /etc/sysctl.d/optimize.conf

echo $(date "+%Y-%m-%d %H:%M:%S") "swapoff" >> pxe.log
sed -ri '/swap/s/^(.*)$/#\1/' /etc/fstab

# 2. config repository
echo $(date "+%Y-%m-%d %H:%M:%S") "yum repository config" >> pxe.log
mkdir -p /etc/yum.repos.d/backup
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# upgrade system
echo $(date "+%Y-%m-%d %H:%M:%S") "upgrade system" >> pxe.log
yum clean all && yum makecache
yum upgrade -y

# 3. Install basic packags
echo $(date "+%Y-%m-%d %H:%M:%S") "Install basic packags" >> pxe.log
yum clean all && yum makecache
yum install -y gcc g++ make automake vim tree yum-utils iptables iptables-services iptables-utils firewalld net-tools lrzsz
yum install -y epel-release && yum install -y htop
yum install -y openssh

systemctl stop postfix && systemctl disable postfix
systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save

# 4. Vim config
echo $(date "+%Y-%m-%d %H:%M:%S") "vim config" >> pxe.log
cat <<EOF > /root/.vimrc
syntax on
set tabstop=4
set autoindent
EOF

cat /root/.vimrc >> /etc/vimrc

# 5. ssh config
echo $(date "+%Y-%m-%d %H:%M:%S") "ssh config" >> pxe.log
wget -P /tmp ftp://192.168.10.21/pub/sh/id_rsa.pub && mkdir -p /root/.ssh && cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys

# 6. config timezone
echo $(date "+%Y-%m-%d %H:%M:%S") "config timezone" >> pxe.log
yum install -y ntpdate
systemctl enable ntpdate
sed -ri '/YNC_HWCLOCK=/s/no/yes/' /etc/sysconfig/ntpdate
sed -ri 's/^(server.*)$/#\1/' /etc/ntp.conf
cat <<EOF >> /etc/ntp.conf
server 0.cn.pool.ntp.org
server 1.cn.pool.ntp.org
server 2.cn.pool.ntp.org
server 3.cn.pool.ntp.org
EOF
systemctl start ntpdate
# ntpdate ntp.aliyun.com
ntpdate cn.pool.ntp.org

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true

# 7. install docker
echo $(date "+%Y-%m-%d %H:%M:%S") "install docker" >> pxe.log
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum install -y containerd.io-1.2.13-3.2.el7 \
docker-ce-19.03.12-3.el7 \
docker-ce-cli-19.03.12-3.el7

if [[ ! -d /etc/docker ]]; then
    mkdir -p /etc/docker
fi

cat <<EOF > /etc/docker/daemon.json
{
    "registry-mirrors": ["https://9ebf40sv.mirror.aliyuncs.com"],
    "graph": "/data/docker",
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {"max-size": "100m"}
}
EOF

systemctl enable docker

# 便于查看 ipvs 的代理规则
yum install -y ipset ipvsadm

# 8. Install laste kernel
echo $(date "+%Y-%m-%d %H:%M:%S") "Install laste kernel" >> pxe.log
mkdir -p /tmp/kernel
wget -P /tmp/kernel ftp://192.168.10.21/pub/kernel/kernel-lt-4.4.237-1.el7.elrepo.x86_64.rpm
wget -P /tmp/kernel ftp://192.168.10.21/pub/kernel/kernel-lt-devel-4.4.237-1.el7.elrepo.x86_64.rpm
yum localinstall -y /tmp/kernel/kernel-lt*.rpm

grub2-set-default 0 && grub2-mkconfig -o /etc/grub2.cfg
grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"

# 9. kubernetes environment config
echo $(date "+%Y-%m-%d %H:%M:%S") "kubernetes environment config" >> pxe.log
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# config environment
modprobe overlay
modprobe br_netfilter
# IPVS needs module - package ipset
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum clean all && yum makecache