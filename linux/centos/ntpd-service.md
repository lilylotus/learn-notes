## 1. 时间时区概念

- UTC
  - 整个地球分为二十四时区，每个时区都有自己的本地时间，在国际无线电通信场合，为了统一起见，使用一个统一的时间，称为通用协调时。
- GMT
  - 格林威治标准时间指位于英国伦敦郊区的皇家格林尼治天文台的标准时间，因为本初子午线被定义在通过那里的经线(`UTC`与`GMT`时间基本相同)。
- CST
  - 中国标准时间
  - `CST = UTC+8 = GMT+8`
- DST
  - 夏令时指在夏天太阳升起的比较早时，将时间拨快一小时，以提早日光的使用，中国不使用。

```bash
# 查看当前服务器时区
timedatectl

# 列出时区并设置时区
timedatectl list-timezones
timedatectl set-timezone Asia/Shanghai
```

## 2. ntpd 与 ntpdate

`ntpd`在实际同步时间时是一点点的校准过来时间的，最终把时间慢慢的校正对。而`ntpdate`不会考虑其他程序是否会阵痛，直接调整时间。一个是校准时间，一个是调整时间。

因为许多应用程序依赖连续的时钟，而使用`ntpdate`这样的时钟跃变，有时候会导致很严重的问题，如数据库事务操作等。

不够安全：`ntpdate`的设置依赖于`ntp`服务器的安全性，攻击者可以利用一些软件设计上的缺陷，拿下`ntp`服务器并令与其同步的服务器执行某些消耗性的任务。

不够精确：一旦`ntp`服务器宕机，跟随它的服务器也就会无法同步时间。与此不同，`ntpd`不仅能够校准计算机的时间，而且能够校准计算机的时钟。

不够优雅：由于`ntpdate`是急变，而不是使时间变快或变慢，依赖时序的程序会出错。例如，如果`ntpdate`发现你的时间快了，则可能会经历两个相同的时刻，对某些应用而言，这是致命的。理想的做法是使用`ntpd`来校准时钟，而不是调整计算机时钟上的时间。

## 3. 部署 NTP 服务

> 使用`NTP`公共时间服务器池同步你的服务器时间，部署完成之后，这样集群会自动定期进行服务的同步，如此以来集群的时间就保持一致了。

**服务软件的安装**

```bash
# 查看是否安装
rpm -q ntp

# 如果没有安装过的话，可以执行此命令安装
yum install ntpdate ntp -y
```

**服务的基本配置**(`/etc/ntp.conf`)

```
# For more information about this file, see the man pages
# ntp.conf(5), ntp_acc(5), ntp_auth(5), ntp_clock(5), ntp_misc(5), ntp_mon(5).

driftfile /var/lib/ntp/drift

# 新增:日志目录
logfile /var/log/ntpd.log

# Permit time synchronization with our time source, but do not
# permit the source to query or modify the service on this system.
restrict default nomodify notrap nopeer noquery

# Permit all access over the loopback interface. This could
# be tightened as well, but to do so would effect some of
# the administrative functions.
# 还要确保localhost足够权限，这个常用的IP地址用来指Linux服务器本身
restrict 127.0.0.1
restrict ::1
# 这一行的含义是授权172.16.128.0网段上的所有机器可以从这台机器上查询和同步时间
restrict 172.16.128.0 mask 255.255.255.0 nomodify notrap

# Hosts on local network are less restricted.
#restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).

# 删减:注释掉NTP服务原有的配置
#server 0.centos.pool.ntp.org iburst
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst

# 新增:时间服务器列表
# 指定我们需要同步的时间服务器地址，可以有多个
server 0.cn.pool.ntp.org iburst
server 1.cn.pool.ntp.org iburst
server 2.cn.pool.ntp.org iburst
server 3.cn.pool.ntp.org iburst

# 新增:当外部时间不可用时可以使用本地时间
server 172.16.128.171 iburst
fudge 127.0.0.1 stratum 10

# 新增:允许上层时间服务器主动修改本机时间
# 其中restrict语句控制允许哪些网络查询和同步时间
restrict 0.cn.pool.ntp.org nomodify notrap noquery
restrict 1.cn.pool.ntp.org nomodify notrap noquery
restrict 2.cn.pool.ntp.org nomodify notrap noquery
......
```

**设置系统开机自启动**

```
# 默认为CentOS7的配置，CentOS6中需要使用chkconfig命令
systemctl enable ntpd
systemctl enable ntpdate
systemctl is-enabled ntpd

# 在ntpd服务启动时，先使用ntpdate命令同步时间，确保没什么问题
ntpdate -u 1.cn.pool.ntp.org

# 启动NTP服务器
# 默认为CentOS7的配置，CentOS6中需要使用service命令
systemctl start ntpdate
systemctl start ntpd

# 加入防火墙
firewall-cmd --permanent --add-service=ntp
firewall-cmd --reload
```

**将正确时间写入硬件**

```bash
ss -tlunp | grep ntp
ntpq -p
hwclock -w
```

**客户端使用配置**

```
# (1) 以服务进程方式实时同步
# 编辑客户端的配置文件(/etc/ntp.conf)，添加如下内容
server 172.16.128.171

# (2) 重启服务
# 修改任意节点服务器的NTP配置文件都需要重起ntpd服务
systemctl restart ntpd

# (3) 设置定时任务进行时间校对
# 需安装ntpdate，每天24点更新同步时间
crontab -e
0 0 * * * /usr/sbin/sntp -P no -r 172.16.128.171; hwclock -w

# 使用如下命令查看节点同步状态
[root@localhost ~]# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
================================================================
 218.189.210.3   118.143.17.82    2 u    7   64    1  101.974  -33.967   0.000
 209.58.185.100  .INIT.          16 u    -   64    0    0.000    0.000   0.000
 103-226-213-30- .INIT.          16 u    -   64    0    0.000    0.000   0.000
 
 
remote：即NTP主机的IP或主机名称。
注意最左边的符号，如果由“+”则代表目前正在作用钟的上层NTP，
如果是“*”则表示也有连上线，不过是作为次要联机的NTP主机。

refid：参考的上一层NTP主机的地址
st：即stratum阶层
when：几秒前曾做过时间同步更新的操作
poll：下次更新在几秒之后
reach：已经向上层NTP服务器要求更新的次数
delay：网络传输过程钟延迟的时间
offset：时间补偿的结果
jitter：Linux系统时间与BIOS硬件时间的差异时间


# 查询你的ntp服务器同步信息
[root@localhost ~]# ntpdate -q  0.hk.pool.ntp.org
server 203.95.213.129, stratum 2, offset -0.020632, delay 0.06477
server 209.58.185.100, stratum 2, offset -0.011884, delay 0.06216
server 218.189.210.4, stratum 0, offset 0.000000, delay 0.00000
server 218.189.210.3, stratum 2, offset -0.036728, delay 0.11096
 6 Apr 12:51:43 ntpdate[10190]: adjust time server 209.58.185.100 offset -0.011884 sec
```



---

# **Chrony时间同步服务**

## 1. 软件介绍

> **Chrony 是一个开源的自由软件，它能帮助你保持系统时钟与时钟服务器同步，因此让你的时间保持精确。它由两个程序组成，分别是 chronyd 和 chronyc。**

**工作模式**

- **chronyd**是一个后台运行的守护进程，用于调整内核中运行的系统时钟和时钟服务器同步。它确定计算机增减时间的比率，并对此进行补偿。
- **chronyc**提供了一个用户界面，用于监控性能并进行多样化的配置。它可以在`chronyd`实例控制的计算机上工作，也可以在一台不同的远程计算机上工作。

**软件优势**

- 在初始同步后，它不会停止时钟，以防对需要系统时间保持单调的应用程序造成影响。
- 在应对临时非对称延迟时（例如，在大规模下载造成链接饱和时）提供了更好的稳定性。
- 无需对服务器进行定期轮询，因此具备间歇性网络连接的系统仍然可以快速同步时钟。
- 能够更好地响应时钟频率的快速变化，这对于具备不稳定时钟的虚拟机或导致时钟频率发生变化的节能技术而言非常有用。
- 更快的同步只需要数分钟而非数小时时间，从而最大程度减少了时间和频率误差，这对于并非全天 24 小时运行的台式计算机或系统而言非常有用

## 2. 安装启用

> CentOS7 已经默认安装有 Chrony 工具，其既可作时间服务器服务端，也可作客户端。而且性能比 ntp 要好很多、配置简单、管理方便

- **[1] 安装启动**

```bash
# 安装服务
yum install -y chrony

# 启动服务
systemctl start chronyd.service

# 设置开机自启动，默认就是enable的
systemctl enable chronyd.service
```

- **[2] 防火墙配置**

```bash
# 因NTP使用123/UDP端口协议，所以允许NTP服务即可
firewall-cmd --add-service=ntp --permanent
firewall-cmd --reload
chronyc -a makestep
```

- **[3] 设置时区**

```bash
# 查看日期时间、时区及NTP状态
timedatectl

# 查看时区列表
timedatectl list-timezones

# 修改时
timedatectl set-timezone Asia/Shanghai

# 修改日期时间
timedatectl set-time "2015-01-21 11:50:00"

# 设置完时区后，强制同步下系统时钟
chronyc -a makestep
```

## 3. 主要配置

> **当 Chrony 启动时，它会读取 `/etc/chrony.conf` 配置文件中的设置，配置内容格式和 ntpd 服务基本相似。**

- **主要配置选项**

| 配置选项           | 含义解释                                                     |
| :----------------- | :----------------------------------------------------------- |
| `server`           | 该参数以 server 开头可以多次用于添加时钟服务器               |
| `stratumweight`    | 设置当 chronyd 从可用源中选择同步源时，每个层应该添加多少距离到同步距离；默认情况下，CentOS 中设置为 0，让 chronyd 在选择源时忽略源的层级 |
| `driftfile`        | chronyd 程序的主要行为之一；根据实际时间计算出服务器增减时间的比率，然后记录到一个文件中，在系统重启后为系统做出最佳时间补偿调整 |
| `rtcsync`          | 将启用一个内核模式，在该模式中，系统时间每 11 分钟会拷贝到实时时钟 |
| `makestep`         | 通常，chronyd 将根据需求通过减慢或加速时钟，使得系统逐步纠正所有时间偏差。在某些特定情况下，系统时钟可能会漂移过快，导致该调整过程消耗很长的时间来纠正系统时钟。该指令强制 chronyd 在调整期大于某个阀值时步进调整系统时钟，但只有在因为 chronyd 启动时间超过指定限制（可使用负值来禁用限制），没有更多时钟更新时才生效 |
| `allow/deny`       | 这里你可以指定一台主机、子网，或者网络以允许或拒绝 NTP 连接到扮演时钟服务器的机器 |
| `cmdallow/cmddeny` | 跟上面相类似，只是你可以指定哪个 IP 地址或哪台主机可以通过 chronyd 使用控制命令 |
| `bindcmdaddress`   | 该指令允许你限制 chronyd 监听哪个网络接口的命令包（由 chronyc 执行）；该指令通过 cmddeny 机制提供了一个除上述限制以外可用的额外的访问控制等级 |
| `logdir`           | 指定日志文件的目录                                           |

- 这里使用的是网络上提供的时间服务，如果本局域网内有对时服务开启的话，通过将上面的几条`serer`记录删除，增加指定局域网内的对时服务器并`restart chrony`服务即可。

```bash
[root@localhost ~]# cat /etc/chrony.conf |grep -v ^#|grep -v ^$
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst
stratumweight 0
driftfile /var/lib/chrony/drift
rtcsync
makestep 10 3
bindcmdaddress 127.0.0.1
bindcmdaddress ::1
keyfile /etc/chrony.keys
commandkey 1
generatecommandkey
noclientlog
logchange 0.5
logdir /var/log/chrony
```

## 4. 查看状态

- **[1] 检查 ntp 源服务器状态**

```bash
[root@localhost ~]# chronyc sourcestats
210 Number of sources = 3
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
dns.sjtu.edu.cn             4   3   302      6.440     90.221    +13ms   694us
dns1.synet.edu.cn           0   0     0      0.000   2000.000     +0ns  4000ms
202.118.1.130               7   5   323     -0.174      7.323  -8406ns   303us
```

- **[2] 检查 ntp 详细同步状态**

```bash
[root@localhost ~]# chronyc sources -v
210 Number of sources = 3
  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current synced, '+' = combined , '-' = not combined,
| /   '?' = unreachable, 'x' = time may be in error, '~' = time too variable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||                                                /   xxxx = adjusted offset,
||         Log2(Polling interval) -.             |    yyyy = measured offset,
||                                  \            |    zzzz = estimated error.
||                                   |           |
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^- dns.sjtu.edu.cn               3   7    13    20    +11ms[  +11ms] +/-   98ms
^? dns1.synet.edu.cn             0   8     0   10y     +0ns[   +0ns] +/-    0ns
^* 202.118.1.130                 2   6   377   125   -122us[ -305us] +/-   31ms
```

- **[3] 设置硬件时间**

```bash
# 硬件时间默认为UTC
$ timedatectl set-local-rtc 1

# 启用或关闭NTP时间同步
$ timedatectl set-ntp yes|flase

# 校准时间服务器
$ chronyc tracking
```