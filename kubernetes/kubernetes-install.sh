#!/bin/bash

#  1. set host name
if [[ "$1" == "" ]]; then
	echo "请输入 hostname"
	exit 1
else
	echo "设置 hostname 为 $1"
	hostnamectl set-hostname --static $1
fi

# 2. configure parameters
modprobe br_netfilter
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

# 3. install need software
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum clean all && yum makecache

# 1.16.6  1.15.8 -> docker 18.09.
yum install -y conntrack ntpdate ntp ipvsadm ipset jq sysstat libseccomp
yum install -y kubeadm-1.16.6 kubectl-1.16.6 kubelet-1.16.6
systemctl enable kubelet.service

# 4. set time
timedatectl set-local-rtc 0
systemctl restart rsyslog && systemctl restart crond
systemctl stop postfix && systemctl disable postfix

# 5. save log
mkdir /var/log/journal # 持久化保存日志的目录
mkdir /etc/systemd/journald.conf.d

cat > /etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]
# 持久化保存到磁盘
Storage=persistent
# 压缩历史日志
Compress=yes
SyncIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000
# 最大占用空间 10G
SystemMaxUse=10G
# 单日志文件最大 200M
SystemMaxFileSize=200M
# 日志保存时间 2 周
MaxRetentionSec=2week
# 不将日志转发到 syslog
ForwardToSyslog=no
EOF

systemctl restart systemd-journald
