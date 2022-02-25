#!/bin/bash

PXESERVER=192.168.110.128
LOGPATH=/root/post-pxe.log

# update environment
# shutdown firewalld and configure selinux
echo $(date "+%Y-%m-%d %H:%M:%S") "shutdown firewalld and configure selinux" >> ${LOGPATH}

systemctl stop firewalld.service
systemctl disable firewalld.service
sed -ri '/^SELINUX=/s/^(.*)$/SELINUX=disabled/' /etc/selinux/config


echo $(date "+%Y-%m-%d %H:%M:%S") "update system kernel params" >> ${LOGPATH}
cat <<EOF > /etc/sysctl.d/optimize.conf
net.ipv4.ip_forward = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
EOF

sysctl -p /etc/sysctl.d/optimize.conf

# 修改 swap 虚拟内存的使用规则，设置为10 说明当内存使用量超过 90% 才会使用 swap 空间
echo "10" >/proc/sys/vm/swappiness


# 设置系统打开文件最大数
cat >> /etc/security/limits.conf <<EOF
    * soft nofile 65535
    * hard nofile 65535
EOF

# 2. config repository
echo $(date "+%Y-%m-%d %H:%M:%S") "yum repository config" >> ${LOGPATH}
mkdir -p /etc/yum.repos.d/backup
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# upgrade system
echo $(date "+%Y-%m-%d %H:%M:%S") "upgrade system" >> ${LOGPATH}
yum clean all && yum makecache faste && yum upgrade -y

# 3. Install basic packags
echo $(date "+%Y-%m-%d %H:%M:%S") "Install basic packags" >> ${LOGPATH}
yum install -y gcc gcc-c++ make automake vim tree yum-utils iptables iptables-services iptables-utils firewalld net-tools
yum install -y epel-release && yum install -y htop
yum install -y openssh-server openssh-clients

grep "^.PermitRootLogin" /etc/ssh/sshd_config > /dev/null || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
grep "^.RSAAuthentication" /etc/ssh/sshd_config > /dev/null || echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
grep "^.PubkeyAuthentication" /etc/ssh/sshd_config > /dev/null || echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
sed -ri -e '/^#PubkeyAuthentication/s/#//' -e '/^PubkeyAuthentication/s/no/yes/' /etc/ssh/sshd_config
sed -ri -e '/^#RSAAuthentication/s/#//' -e '/^RSAAuthentication/s/no/yes/' /etc/ssh/sshd_config
sed -ri -e '/^#PermitRootLogin/s/#//' -e '/^PermitRootLogin/s/no/yes/' /etc/ssh/sshd_config

systemctl stop postfix && systemctl disable postfix
iptables -F && iptables -X && iptables -Z

# 4. Vim config
echo $(date "+%Y-%m-%d %H:%M:%S") "vim config" >> ${LOGPATH}

cat <<EOF > /etc/vimrc
syntax on
set tabstop=4
set autoindent
EOF

# 5. ssh config
echo $(date "+%Y-%m-%d %H:%M:%S") "ssh config" >> ${LOGPATH}
wget -P /root ftp://${PXESERVER}/pub/sh/id_rsa.pub && mkdir -p /root/.ssh || cat /root/id_rsa.pub >> /root/.ssh/authorized_keys

# 6. config timezone
echo $(date "+%Y-%m-%d %H:%M:%S") "config timezone" >> ${LOGPATH}
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai

# 7. install docker
echo $(date "+%Y-%m-%d %H:%M:%S") "install docker" >> ${LOGPATH}

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

# 8. Install laste kernel
# https://elrepo.org/linux/kernel/el7/x86_64/RPMS/
echo $(date "+%Y-%m-%d %H:%M:%S") "Install laste kernel" >> ${LOGPATH}
mkdir -p /root/kernel
wget -P /root/kernel ftp://${PXESERVER}/pub/kernel/kernel-lt-5.4.155-1.el7.elrepo.x86_64.rpm
wget -P /root/kernel ftp://${PXESERVER}/pub/kernel/kernel-lt-devel-5.4.155-1.el7.elrepo.x86_64.rpm
yum install -y /root/kernel/*.rpm

grub2-set-default 0 && grub2-mkconfig -o /etc/grub2.cfg
grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"

echo $(date "+%Y-%m-%d %H:%M:%S") "Finish PXE Install" >> ${LOGPATH}
