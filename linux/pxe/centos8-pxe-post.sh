#!/bin/bash

# update environment
# 1. shutdown firewalld and configure selinux
echo $(date "+%Y-%m-%d %H:%M:%S") "shutdown firewalld and configure selinux" >> /root/pxe.log
systemctl stop firewalld.service
systemctl disable firewalld.service
sed -ri '/^SELINUX=/s/^(.*)$/SELINUX=disabled/' /etc/selinux/config

# 2. config repository
echo $(date "+%Y-%m-%d %H:%M:%S") "yum repository config" >> /root/pxe.log
mkdir -p /etc/yum.repos.d/backup
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
yum clean all && yum makecache && yum upgrade -y

# 3. Install basic packags
echo $(date "+%Y-%m-%d %H:%M:%S") "Install basic packags" >> /root/pxe.log
yum install -y gcc g++ make automake vim tree yum-utils iptables iptables-services iptables-utils firewalld net-tools
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
echo $(date "+%Y-%m-%d %H:%M:%S") "vim config" >> /root/pxe.log
cat <<EOF >> /etc/vimrc
syntax on
set tabstop=4
set autoindent
EOF

# 5. ssh config
echo $(date "+%Y-%m-%d %H:%M:%S") "ssh config" >> ${LOGPATH}
wget -P /root ftp://${PXESERVER}/pub/sh/id_rsa.pub && mkdir -p /root/.ssh ; cat /root/id_rsa.pub >> /root/.ssh/authorized_keys

# 6. config timezone
echo $(date "+%Y-%m-%d %H:%M:%S") "config timezone" >> /root/pxe.log
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai

# 7. install docker
echo $(date "+%Y-%m-%d %H:%M:%S") "install docker" >> /root/pxe.log
# yum install -y yum-utils device-mapper-persistent-data lvm2
# yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#yum install -y containerd.io-1.2.13-3.2.el7 \
#docker-ce-19.03.12-3.el7 \
#docker-ce-cli-19.03.12-3.el7

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

# systemctl enable docker
echo $(date "+%Y-%m-%d %H:%M:%S") "Finish PXE Install" >> /root/pxe.log
