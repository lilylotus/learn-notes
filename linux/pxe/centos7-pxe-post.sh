#!/bin/bash

PXESERVER=192.168.110.128
LOGPATH=/root/post-pxe.log

# update environment
# shutdown firewalld and configure selinux
echo $(date "+%Y-%m-%d %H:%M:%S") "shutdown firewalld and configure selinux" >> ${LOGPATH}
systemctl disable firewalld
sed -ri '/^SELINUX=/s/^(.*)$/SELINUX=disabled/' /etc/selinux/config

echo $(date "+%Y-%m-%d %H:%M:%S") "update system kernel params" >> ${LOGPATH}
cat <<EOF > /etc/sysctl.d/optimize.conf
net.ipv4.ip_forward = 1
EOF

sysctl -p /etc/sysctl.d/optimize.conf


# 2. config repository
echo $(date "+%Y-%m-%d %H:%M:%S") "yum repository config" >> ${LOGPATH}
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# upgrade system
echo $(date "+%Y-%m-%d %H:%M:%S") "upgrade system" >> ${LOGPATH}
yum makecache
yum upgrade -y

# 3. Install basic packags
echo $(date "+%Y-%m-%d %H:%M:%S") "Install basic packags" >> ${LOGPATH}
yum install -y gcc gcc-c++ make automake vim tree yum-utils iptables iptables-services iptables-utils firewalld net-tools lrzsz
yum install -y epel-release && yum install -y htop
yum install -y openssh-server openssh-clients

grep "^.PermitRootLogin" /etc/ssh/sshd_config > /dev/null || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
grep "^.RSAAuthentication" /etc/ssh/sshd_config > /dev/null || echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
grep "^.PubkeyAuthentication" /etc/ssh/sshd_config > /dev/null || echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
sed -ri -e '/^#PubkeyAuthentication/s/#//' -e '/^PubkeyAuthentication/s/no/yes/' /etc/ssh/sshd_config
sed -ri -e '/^#RSAAuthentication/s/#//' -e '/^RSAAuthentication/s/no/yes/' /etc/ssh/sshd_config
sed -ri -e '/^#PermitRootLogin/s/#//' -e '/^PermitRootLogin/s/no/yes/' /etc/ssh/sshd_config

systemctl stop postfix && systemctl disable postfix
systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save

# 4. Vim config
echo $(date "+%Y-%m-%d %H:%M:%S") "vim config" >> ${LOGPATH}

cat <<EOF > /root/.vimrc
syntax on
set tabstop=4
set autoindent
EOF

cat /root/.vimrc >> /etc/vimrc

# 5. ssh config
echo $(date "+%Y-%m-%d %H:%M:%S") "ssh config" >> ${LOGPATH}
wget -P /tmp ftp://${PXESERVER}/pub/sh/id_rsa.pub && mkdir -p /root/.ssh && cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys

# 6. config timezone
echo $(date "+%Y-%m-%d %H:%M:%S") "config timezone" >> ${LOGPATH}
yum install -y ntpdate ntpd
systemctl enable ntpdate ntp

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true

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
echo $(date "+%Y-%m-%d %H:%M:%S") "Install laste kernel" >> ${LOGPATH}
mkdir -p /tmp/kernel
wget -P /tmp/kernel ftp://${PXESERVER}/pub/kernel/kernel-lt-5.4.155-1.el7.elrepo.x86_64.rpm
wget -P /tmp/kernel ftp://${PXESERVER}/pub/kernel/kernel-lt-devel-5.4.155-1.el7.elrepo.x86_64.rpm
yum install -y /tmp/kernel/*.rpm

grub2-set-default 0 && grub2-mkconfig -o /etc/grub2.cfg
grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"

echo $(date "+%Y-%m-%d %H:%M:%S") "Finish PXE Install" >> ${LOGPATH}
