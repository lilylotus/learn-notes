### 配置匿名用户

```
anonymous_enable=YES　　　　　　　　　   # 打开匿名用户模式
write_enable=YES　　 　　　　　　　　　　 # 打开全局写权限
anon_upload_enable=YES　　　　　　　　　 # 开启匿名用户上传权限
anon_mkdir_write_enable=YES　　　　　 　# 开启匿名用户创建目录的权限
anon_other_write_enable=YES　　　　　 　# 开启匿名用户可以删除目录和文件
anon_world_readable_only=YES　　　　　  # 开启匿名用户下载权限
anon_umask=022　　　　　　　　    　　    # 设置匿名用户可以下载自己上传的文件
```

## 文件传输协议

**`FTP`**

- 文件传输协议 (`FTP`) 是一种基于 `TCP` 协议在客 `C/S` 架构的协议，占用 `20` 和 `21` 端口

**`TFTP`**

- 简单文件传输协议 (`TFTP`) 是一种基于 `UDP` 协议在客 `C/S` 架构的协议，占用 `69` 端口
- `TFTP` 的命令功能不如 `FTP` 服务强大，甚至不能遍历目录，在安全性方面也弱于 `FTP` 服务
- 因为 `TFTP` 不需要客户端的权限认证，也就减少了无谓的系统和网络带宽消耗，效率更高

### FTP 协议概述

`FTP`是一种在互联网中进行文件传输的协议，基于**客户端/服务器**（`C/S`）模式，默认使用 `20`、`21` 号端口，其中端口 `20`（**数据端口**）用于进行数据传输，端口 `21`（**命令端口**）用于接受客户端发出的相关`FTP`命令与参数。`FTP`服务器普遍部署于内网中，具有容易搭建、方便管理的特点。而且有些`FTP`客户端工具还可以支持文件的多点下载以及断点续传技术，因此`FTP`服务得到了广大用户的青睐。

- 命令连接
  - 传输`TCP`的文件管理类命令给服务端
  - 直到用户退出才关闭连接，否则一直连接
- 数据连接
  - 数据传输，按需创建及关闭的连接
  - 数据传输可以为文本或二进制格式传输

### FTP 工作模式

`FTP`服务器是按照`FTP`协议在互联网上提供文件存储和访问服务的主机，`FTP`客户端则是向服务器发送连接请求，以建立数据传输链路的主机。`FTP`协议有下面两种工作模式。

- 主动模式 ： `FTP` 服务器主动向客户端发起连接请求

  - 命令连接：`Client:50000 --> Server:21`
  - 数据连接：`Server:20/tcp --> Client:50000+1`
  - 模式缺点：客户端有防火墙，一般会禁止服务的主动连接

- 被动模式：`FTP` 服务器等待客户端发起连接请求(`FTP` 的默认工作模式)

  - 命令连接：`Client:50000 --> Server:21`
  - 数据连接：`Client:50000+1 --> Server:随机端口` ==> 通过命令连接得知这个随机端口
  - 模式缺点：服务器端需要修改防火墙规则并开放`21`和这个随机端口

防火墙一般是用于过滤从外网进入内网的流量，因此有些时候需要将`FTP`的工作模式设置为主动模式，才可以传输数据。但是因为客户端主机一般都设有防火墙，会禁止服务器的连接请求，所有适当的`iptables`规则变得越来越重要了。

## vsftpd 服务程序

> **`vsftpd`**(非常安全的`FTP`守护进程)是一款运行在`Linux`操作系统上的 FTP 服务程序，不仅完全开源而且免费，此外，还具有很高的安全性、传输速度，以及支持虚拟用户验证等其他`FTP`服务程序具备的特点。

### 安装服务

- 安装服务端程序

```bash
yum install vsftpd
yum install ftp
```

- 配置 FTP 服务

```bash
# 程序的主配置文件为/etc/vsftpd/vsftpd.conf
[root@localhost ~]# cat /etc/vsftpd/vsftpd.conf
anonymous_enable=YES
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=NO
listen_ipv6=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
```

### 配置文件

**共享目录**

- **匿名用户**(映射为`ftp`用户)共享资源位置：`/var/ftp`
- **系统用户**通过`ftp`访问的资源的位置：用户自己的家目录
- **虚拟用户**通过`ftp`访问的资源的位置：给虚拟用户指定的映射成为的系统用户的家目录

### 配置参数

> 常用配置参数都为主配置文件，`/etc/vsftpd/vsftpd.conf`的常用配置。

- **通用基础配置**

| 参数                            | 作用                                                         |
| :------------------------------ | :----------------------------------------------------------- |
| **`listen=[YES|NO]`**           | 是否以独立运行的方式监听服务                                 |
| **`listen_address=IP地址`**     | 设置要监听的 IP 地址                                         |
| **`listen_port=21`**            | 设置 FTP 服务的监听端口                                      |
| **`download_enable＝[YES|NO]`** | 是否允许下载文件                                             |
| **`max_clients=0`**             | 最大客户端连接数，0 为不限制                                 |
| **`max_per_ip=0`**              | 同一 IP 地址的最大连接数，0 为不限制                         |
| **`chown_uploads=[YES|NO]`**    | 是否允许改变上传文件的属主                                   |
| **`chown_username=whoever`**    | 改变上传文件的属主为 whoever                                 |
| **`pam_service_name=vsftpd`**   | 让 vsftpd 使用 pam 完成用户认证，使用的文件为/etc/pam.d/vsftpd |

- **匿名用户的配置**

| 参数                                   | 作用                                                         |
| :------------------------------------- | :----------------------------------------------------------- |
| **`anonymous_enable=[YES|NO]`**        | 是否允许匿名用户访问                                         |
| **`anon_upload_enable=[YES|NO]`**      | 是否允许匿名用户上传文件                                     |
| **`anon_mkdir_write_enable=[YES|NO]`** | 是否允许匿名用户创建目录                                     |
| **`anon_other_write_enable=[YES|NO]`** | 是否开放匿名用户的其他写入权限（包括重命名、删除等操作权限） |
| **`anon_umask=022`**                   | 匿名用户上传文件的 umask 值                                  |
| **`anon_root=/var/ftp`**               | 匿名用户的 FTP 根目录                                        |
| **`anon_max_rate=0`**                  | 匿名用户的最大传输速率（字节/秒），0 为不限制                |

- **系统用户的配置**

| 参数                                           | 作用                                                         |
| :--------------------------------------------- | :----------------------------------------------------------- |
| **`anonymous_enable=NO`**                      | 禁止匿名访问模式                                             |
| **`local_enable=[YES|NO]`**                    | 是否允许本地用户登录 FTP                                     |
| **`write_enable=[YES|NO]`**                    | 是否开放本地用户的其他写入权限                               |
| **`local_umask=022`**                          | 本地用户上传文件的 umask 值                                  |
| **`local_root=/var/ftp`**                      | 本地用户的 FTP 根目录                                        |
| **`local_max_rate=0`**                         | 本地用户最大传输速率（字节/秒），0 为不限制                  |
| **`userlist_enable=[YES|NO]`**                 | 开启用户作用名单文件功能                                     |
| **`userlist_deny=[YES|NO]`**                   | 启用禁止用户名单，名单文件为 ftpusers 和/etc/vsftpd/user_list |
| **`chroot_local_user=[YES|NO]`**               | 是否将用户权限禁锢在 FTP 家目录中，以确保安全                |
| **`chroot_list_enable=[YES|NO]`**              | 禁锢文件中指定的 FTP 本地用户于其家目录中                    |
| **`chroot_list_file=/etc/vsftpd/chroot_list`** | 指定禁锢文件位置，需要和 chroot_list_enable 一同开启         |

- **日志功能**

| 参数                                | 作用                                 |
| :---------------------------------- | :----------------------------------- |
| **`xferlog_enable=[YES|NO]`**       | 是否开启 FTP 日志功能                |
| **`xferlog_std_format=[YES|NO]`**   | 是否以标准格式保持日志               |
| **`xferlog_file=/var/log/xferlog`** | 指定保存日志的文件名称，需要一同开启 |

## vsftpd 认证模式

>  **`vsftpd` 作为更加安全的文件传输的服务程序，允许用户以三种认证模式登录到 `FTP` 服务器上**

- 匿名开放模式
  - 匿名开放模式是一种最不安全的认证模式，任何人都可以无需密码验证而直接登录到`FTP`服务器。这种模式一般用来访问不重要的公开文件，在生产环境中尽量不要存放重要文件，不建议在生产环境中如此行事。
- 本地用户模式
  - 本地用户模式是通过`Linux`系统本地的账户密码信息进行认证的模式，相较于匿名开放模式更安全，而且配置起来相对简单。但是如果被黑客破解了账户的信息，就可以畅通无阻地登录`FTP`服务器，从而完全控制整台服务器。
- 虚拟用户模式
  - 虚拟用户模式是这三种模式中最安全的一种认证模式，它需要为`FTP`服务单独建立用户数据库文件，虚拟出用来进行口令验证的账户信息，而这些账户信息在服务器系统中实际上是不存在的，仅供`FTP`服务程序进行认证使用。这样，即使黑客破解了账户信息也无法登录服务器，从而有效降低了破坏范围和影响。

---

### 匿名访问模式

> **`vsftpd` 服务程序默认开启了匿名开放模式，我们需要做的就是开放匿名用户的上传、下载文件的权限，以及让匿名用户创建、删除、更名文件的权限。**

```bash
# 匿名访问模式主配置文件
[root@localhost ~]# vim /etc/vsftpd/vsftpd.conf
anonymous_enable=YES
anon_umask=022
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES

local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=NO
listen_ipv6=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
```

```bash
# 在vsftpd服务程序的匿名开放认证模式下，其账户统一为anonymous，密码为空
# 连接到FTP服务器后，默认访问的是/var/ftp目录，我们可以在其中进行创建、删除等操作
[root@localhost ~]# ftp 192.168.10.10
Connected to 192.168.10.10 (192.168.10.10).
220 (vsFTPd 3.0.2)
Name (192.168.10.10:root): anonymous
331 Please specify the password.
Password:此处敲击回车即可
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> cd pub
250 Directory successfully changed.
ftp> mkdir files
550 Permission denied.


# 系统显示拒绝创建目录，这是为什么呢？
# 查看该目录的权限得知，只有root管理员才有写入权限，开放ftp用户权限(该账户在系统中已经存在)
[root@localhost ~]# ls -ld /var/ftp/pub
drwxr-xr-x. 3 root root 16 Jul 13 14:38 /var/ftp/pub

[root@localhost ~]# chown -Rf ftp /var/ftp/pub
[root@localhost ~]# ls -ld /var/ftp/pub
drwxr-xr-x. 3 ftp root 16 Jul 13 14:38 /var/ftp/pub
```

### 本地用户模式

```bash
# 本地用户模式主配置文件
[root@localhost ~]# vim /etc/vsftpd/vsftpd.conf
anonymous_enable=NO

local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
connect_from_port_20=YES
listen=NO
listen_ipv6=YES

pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
xferlog_enable=YES
xferlog_std_format=YES
```

```bash
# 现在已经完全可以本地用户的身份登录FTP服务器了，但是使用root无法登陆
[root@localhost ~]# ftp 192.168.10.10
Connected to 192.168.10.10 (192.168.10.10).
220 (vsFTPd 3.0.2)
Name (192.168.10.10:root): root
530 Permission denied.
Login failed.
ftp>

# 这是因为，为了系统的安全，默认禁止root等用户登录FTP服务被系统拒绝访问
# 因为vsftpd服务程序所在的目录中，默认存放着两个名为用户名单的文件，ftpusers和user_list
# 在ftpusers和user_list两个用户文件中将root用户删除就可以登录了
[root@localhost ~]# cat /etc/vsftpd/user_list
root
bin
daemon

[root@localhost ~]# cat /etc/vsftpd/ftpusers
root
bin
daemon

# 在采用本地用户模式登录FTP服务器后，默认访问的是该用户的家目录，因此不存在写入权限不足的情况
# 如果不关闭SELinux，则需要再次开启SELinux域中对FTP服务的允许策略
[root@localhost ~]# setsebool -P ftpd_full_access=on

# 即可以使用系统用户进行FTP服务的登录了
[root@localhost ~]# ftp 192.168.10.10
Connected to 192.168.10.10 (192.168.10.10).
220 (vsFTPd 3.0.2)
Name (192.168.10.10:root): escape
331 Please specify the password.
Password:此处输入该用户的密码
230 Login successful.
Remote system type is UNIX.
```

