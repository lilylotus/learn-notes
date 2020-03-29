#!/bin/bash

# 1. 添加 ELRepo
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
yum clean all && yum makecache

# 2. 安装
# yum --enablerepo=elrepo-kernel install kernel-ml 5.x 版本
yum --enablerepo=elrepo-kernel install -y kernel-lt

# 3. 设置内核为安装的新内核
kernel=`awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg | grep "4\.4"`
echo "update kernel version = [$kernel]"
if [[ $kernel == "" ]]; then
	echo "kernel update failure"
else
	echo "set last kernel as default kernel"
	grub2-set-default "'$kernel'"
	#reboot
	# 重启系统
fi