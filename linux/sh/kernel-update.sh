#!/bin/bash

# 1. 添加 ELRepo
echo $(date "+%Y-%m-%d %H:%M:%S") " Install Linux Kernel" >> pxe.log
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y yum-plugin-fastestmirror yum-utils
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
yum clean all && yum makecache

# 2. 安装
# yum --enablerepo=elrepo-kernel install kernel-ml 5.x 版本
yum --enablerepo=elrepo-kernel install -y kernel-lt

# 3. 设置内核为安装的新内核
grub2-set-default 0 && grub2-mkconfig -o /etc/grub2.cfg
grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"

echo $(date "+%Y-%m-%d %H:%M:%S") " Install Linux Kernel Ending" >> pxe.log