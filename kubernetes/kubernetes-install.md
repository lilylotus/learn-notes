#### 设置系统主机名以及 Host 文件的相互解析

```bash
hostnamectl set-hostname --static k8s-master01
```

#### 安装依赖包

```bash
yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables iptables-services curl sysstat libseccomp wget vim net-tools git

yum install -y conntrack
yum install -y ntpdate
yum install -y ntp
yum install -y ipvsadm
yum install -y ipset
yum install -y jq
yum install -y iptables
yum install -y iptables-services
yum install -y curl
yum install -y sysstat
yum install -y libseccomp
yum install -y wget
yum install -y vim
yum install -y net-tools
yum install -y git
```

#### 设置防火墙为 Iptables 并设置空规则

```bash
systemctl stop firewalld && systemctl disable firewalld && iptables -F
```

#### 关闭 SELINUX 和交换空间

```bash
swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```

#### 调整内核参数，对于 K8S

```bash
cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
net.ipv4.tcp_tw_recycle = 0
vm.swappiness = 0
vm.overcommit_memory = 1
vm.panic_on_oom = 0
fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 1048576
fs.file-max = 52706963
fs.nr_open = 52706963
EOF

sysctl -p /etc/sysctl.d/kubernetes.conf
```

#### 调整系统时区

```bash
# 设置系统时区为 中国/上海
timedatectl set-timezone Asia/Shanghai
# 将当前的 UTC 时间写入硬件时钟
timedatectl set-local-rtc 0
# 重启依赖于系统时间的服务
systemctl restart rsyslog && systemctl restart crond
```

#### 关闭系统不需要服务

```bash
systemctl stop postfix && systemctl disable postfix
```

#### 设置 rsyslogd 和 systemd journald

```bash
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
```

#### 升级内核



#### 安装脚本

```bash
#!/bin/bash

#  1.
if [[ "$1" == "" ]]; then
	echo "请输入 hostname"
	exit 1
else
	echo "设置 hostname 为 $1"
	hostnamectl set-hostname --static $1
fi

# 2. 
#yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables iptables-services curl sysstat libseccomp wget vim net-tools git
yum install -y conntrack
yum install -y ntpdate
yum install -y ntp
yum install -y ipvsadm
yum install -y ipset
yum install -y iptables
yum install -y iptables-services
yum install -y curl
yum install -y sysstat
yum install -y libseccomp
yum install -y wget
yum install -y vim
yum install -y net-tools
yum install -y git
yum install -y epel-release && yum install -y htop
yum install -y jq

# 3. 
systemctl stop firewalld && systemctl disable firewalld
systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save

# 4. 
swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# 5. 
cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
net.ipv4.tcp_tw_recycle = 0
vm.swappiness = 0 # 禁止使用 swap 空间，只有当系统 OOM 时才允许使用它
vm.overcommit_memory = 1 # 不检查物理内存是否够用
vm.panic_on_oom = 0 # 开启 OOM
fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 1048576
fs.file-max = 52706963
fs.nr_open = 52706963
net.ipv6.conf.all.disable_ipv6 = 1
net.netfilter.nf_conntrack_max = 2310720
EOF

sysctl -p /etc/sysctl.d/kubernetes.conf

# 6. 
timedatectl set-local-rtc 0
systemctl restart rsyslog && systemctl restart crond
systemctl stop postfix && systemctl disable postfix

# 7. 
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

# 8. 升级内核
# 1. 添加 ELRepo
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
yum clean all && yum makecache

# 2. 安装内核
# yum --enablerepo=elrepo-kernel install kernel-ml 5.x 版本
yum --enablerepo=elrepo-kernel install -y kernel-lt

# 3. 设置内核为安装的新内核
kernel=`awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg | grep '4.4.207'`
echo "update kernel version = [$kernel]"
if [[ $kernel == "" ]]; then
	echo "kernel update failure"
else
	echo "set last kernel as default kernel"
	grub2-set-default $kernel
	reboot
	# 重启系统
fi

# 安装 kubernetes
# 1.16.6  1.15.8 -> docker 18.09.
yum install -y conntrack ntpdate ntp ipvsadm ipset jq sysstat libseccomp
yum install -y kubeadm-1.16.6 kubectl-1.16.6 kubelet-1.16.6
systemctl enable kubelet.service
```

###### kubernetes 组件镜像下载

```bash
#!/bin/bash
version=1.16.6
images=`kubeadm config images list --kubernetes-version=$version`
for image in $images
do
        echo "pull image [$image]"
        docker pull $image
        pb=`pwd`/bak/$( echo $image |  cut -d '/' -f2 | cut -d ':' -f1 ).tar
        echo "save image [$image] to [$pb]"
        docker save -o $pb $image
done

cd `pwd`/bak
tar czvf kubeadm-images-$version.tar.gz *.tar

#!/bin/bash
version=1.16.6
tar -zx -f kubeadm-images-$version.tar.gz
ls *.tar > /tmp/images-list.txt
for image in $(cat /tmp/images-list.txt) ; do
	docker load -i $image;
done
rm -rf /tmp/images-list.txt

k8s.gcr.io/kube-apiserver:v1.16.6
k8s.gcr.io/kube-controller-manager:v1.16.6
k8s.gcr.io/kube-scheduler:v1.16.6
k8s.gcr.io/kube-proxy:v1.16.6
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.3.15-0
k8s.gcr.io/coredns:1.6.2
```

###### 国内镜像下载

```bash
# kubeadm config images list --kubernetes-version=$version
# 下载镜像 (version = 1.16.6)
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.16.6
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.16.6
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.16.6
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.16.6
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.15-0
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.6.2

# 更改标签 (k8s.gcr.io/kube-apiserver:v1.16.6)
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.16.6  k8s.gcr.io/kube-apiserver:v1.16.6
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.16.6  k8s.gcr.io/kube-controller-manager:v1.16.6
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.16.6  k8s.gcr.io/kube-scheduler:v1.16.6
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.16.6  k8s.gcr.io/kube-proxy:v1.16.6
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1  k8s.gcr.io/pause:3.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.15-0  k8s.gcr.io/etcd:3.3.15-0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.6.2  k8s.gcr.io/coredns:1.6.2

# 删除标签
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.16.6
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.16.6
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.16.6
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.16.6
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.15-0
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.6.2

# 保存镜像
docker save -o kube-apiserver.tar k8s.gcr.io/kube-apiserver:v1.16.6
docker save -o kube-controller-manager.tar k8s.gcr.io/kube-controller-manager:v1.16.6
docker save -o kube-scheduler.tar k8s.gcr.io/kube-scheduler:v1.16.6
docker save -o kube-proxy.tar k8s.gcr.io/kube-proxy:v1.16.6
docker save -o pause.tar k8s.gcr.io/pause:3.1
docker save -o etcd.tar k8s.gcr.io/etcd:3.3.15-0
docker save -o coredns.tar k8s.gcr.io/coredns:1.6.2

# 打包
tar czvf kubeadm-images-1166.tar.gz *.tar
```

