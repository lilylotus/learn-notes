#### 1. 查看内核版本

```bash
# uname -r # 3.10.0-1062.el7.x86_64
# uname -a # Linux localhost.localdomain 3.10.0-1062.el7.x86_64 #1 SMP Wed Aug 7 18:08:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```

#### 2. 更新内核

> *ELRepo* 仓库是基于社区的用于企业级 Linux 仓库，提供对 RedHat Enterprise (RHEL) 和其它基于 RHEL 的 Linux 发行版（CentOS、Scientific、Fedora 等）的支持。
> ELRepo 聚焦于和硬件相关的软件包，包括文件系统驱动、显卡驱动、网络驱动、声卡驱动和摄像头驱动等。

<font color="red">官方 CentOS7</font> http://elrepo.org/linux/kernel/el7/x86_64/RPMS/

```bash
1. 启用 ELRepo 仓库
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

2. 安装仓库
yum install -y yum-plugin-fastestmirror yum-utils
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
# 或者
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

3. 列出可用的 kernel 版本
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available

4. 安装 kernel 版本 (ml - mainline stable, lt - long term support)
yum --enablerepo=elrepo-kernel install kernel-lt
# kernel-ml 中 ml 是 [mainline stable] 的缩写，elrepo-kernel 是最新的稳定主线版本。
# kernel-lt 中 lt 是 [long term support] 的缩写，elrepo-kernel 长期支持版本。
# --enablerepo 选项开启 CentOS 系统上的指定仓库，默认开启的是 elrepo，这里用 elrepo-kernel 替换

```

##### 下载 rpm 内核安装

```bash
#!/bin/bash
kernels=(https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-4.4.237-1.el7.elrepo.x86_64.rpm https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-devel-4.4.237-1.el7.elrepo.x86_64.rpm)

for kernel in ${kernels[@]};
do
	echo "down kernel ${kernel}"
done

# header 可以在内核更新完成后在安装
```

#### 3. 设置 grub2

> 内核安装好后，需要设置为默认启动选项并重启后才会生效

1. 查看系统所有的内核版本

   ```bash
   sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
   0 : CentOS Linux (4.4.230-1.el7.elrepo.x86_64) 7 (Core)
   1 : CentOS Linux (3.10.0-1062.el7.x86_64) 7 (Core)
   2 : CentOS Linux (0-rescue-65ce6bce221449d4b65dc5c2e14e7448) 7 (Core)
   ```
   
2. 指定某个版本
   可以通过 `grub2-set-default 0` 命令或编辑 `/etc/default/grub` 文件来设置

   ```bash
   # 其中 0 来自上一步的 awk 命令
   # 设置 GRUB_DEFAULT=0，通过上面查询显示的编号为 0 的内核作为默认内核
   sudo grub2-set-default 0 && grub2-mkconfig -o /etc/grub2.cfg
   sudo grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"
   # 或者
   sudo grub2-set-default 'CentOS Linux (4.4.230-1.el7.elrepo.x86_64) 7 (Core)'
   ```
   
3. 编辑 *`/etc/default/grub`* 文件

   ```bash
   vim /etc/default/grub
   
   GRUB_TIMEOUT=5
   GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
   GRUB_DEFAULT=0
   GRUB_DISABLE_SUBMENU=true
   GRUB_TERMINAL_OUTPUT="console"
   GRUB_CMDLINE_LINUX="spectre_v2=retpoline rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet"
   GRUB_DISABLE_RECOVERY="true"
   ```
   
4. 生成 grub 配置文件并重启

   ```bash
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg
   sudo reboot
   ```

#### 4. 验证

   通过 `uname -r` 查看，可以发现已经生效了。

```
# uname -r
4.15.6-1.el7.elrepo.x86_64
```

#### 5. 删除旧内核

内核有两种删除方式：通过 `yum remove` 命令或通过 `yum-utils` 工具。

1. 通过 **yum remove** 命令

   ```bash
   # 查看所有内核
   $ rpm -qa | grep kernel
   kernel-3.10.0-1062.el7.x86_64
   kernel-tools-3.10.0-1062.el7.x86_64
   kernel-tools-libs-3.10.0-1062.el7.x86_64
   
   # 删除旧版本内核
   $ yum remove kernel-3.10.0-1062.el7.x86_64 \
   kernel-tools-3.10.0-1062.el7.x86_64 \
   kernel-tools-libs-3.10.0-1062.el7.x86_64
   ```

2. 通过 **yum-utils** 工具

   > 如果安装的内核不多于 3 个，`yum-utils` 工具不会删除任何一个
   > 只有在安装的内核大于 3 个时，才会自动删除旧内核
   
   ```bash
yum install yum-utils
   # 删除旧版本
   package-cleanup --oldkernels
   ```
   
   

