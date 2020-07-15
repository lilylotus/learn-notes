#### 1. 查看内核版本

```bash
# uname -r # 3.10.0-1062.el7.x86_64
# uname -a # Linux localhost.localdomain 3.10.0-1062.el7.x86_64 #1 SMP Wed Aug 7 18:08:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```

#### 2. 更新内核

```bash
添加 ELRepo 仓库
1. 添加 ELRepo 公共 key
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

2. 安装仓库
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
或
yum install -y https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm

3. 查看内核
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available

4. 安装最新内核
yum --enablerepo=elrepo-kernel install kernel-ml
yum --enablerepo=elrepo-kernel install kernel-lt

kernel-ml 中的ml是英文【mainline stable】的缩写，elrepo-kernel中罗列出来的是最新的稳定主线版本。
kernel-lt 中的lt是英文【long term support】的缩写，elrepo-kernel中罗列出来的长期支持版本。


--enablerepo 选项开启 CentOS 系统上的指定仓库。默认开启的是 elrepo，这里用 elrepo-kernel 替换。
```

#### 3. 设置 grub2 (内核安装好后，需要设置为默认启动选项并重启后才会生效)

1. 查看系统所有的内核版本

   ```bash
   sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
   	0 : CentOS Linux (3.10.0-1062.el7.x86_64) 7 (Core)
   	1 : CentOS Linux (0-rescue-112cc911ddf149e280388fa6c1c8fa61) 7 (Core)
   ```
   
2. 指定某个版本
   可以通过 `grub2-set-default 0` 命令或编辑 `/etc/default/grub` 文件来设置

   ```bash
   其中 0 来自上一步的 awk 命令：
   sudo grub2-set-default 0
   grub2-set-default 'CentOS Linux (4.4.207-1.el7.elrepo.x86_64) 7 (Core)'
   ```
   
3. 编辑 grub 文件

   ```bash
   # vi /etc/default/grub
   
   GRUB_TIMEOUT=5
   GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
   GRUB_DEFAULT=0
   GRUB_DISABLE_SUBMENU=true
   GRUB_TERMINAL_OUTPUT="console"
   GRUB_CMDLINE_LINUX="crashkernel=auto console=ttyS0 console=tty0 panic=5"
   GRUB_DISABLE_RECOVERY="true"
   GRUB_TERMINAL="serial console"
   GRUB_TERMINAL_OUTPUT="serial console"
   GRUB_SERIAL_COMMAND="serial --speed=9600 --unit=0 --word=8 --parity=no --stop=1"
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
   # rpm -qa | grep kernel # 查看所有内核
   # yum remove kernel-tools-libs-3.10.0-514.26.2.el7.x86_64 # 删除旧版本内核
   ```

2. 通过 **yum-utils** 工具

   ```bash
   yum install yum-utils
   package-cleanup --oldkernels
   ```

   

