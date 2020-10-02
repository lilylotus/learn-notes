#### windows bash 文件在 linux 使用文件行结尾报错

```bash
查看：
cat -A filename (windows: -> #!/bin/bash^M$ ， unix -> #!/bin/bash$)
od -t x1 filename (0d 0a 表示为 dos 格式，0a 为 unix 格式)
:
sed 命令
sed -i "s/\r//" filename 或者 sed -i "s/^M//" filename
------------------
打开文件，执行，保存
set ff=unix 
```

#### ssh 免密登录

`/etc/ssh/sshd_config`

```
PasswordAuthentication no
#启用密钥验证
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitRootLogin yes
```

.ssh/authorized_keys 文件，放置客户端的公钥

```
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 60022 -j ACCEPT
# 配置防火墙
```

#### ntp 时间同步

`/etc/ntp.conf`

```
driftfile  /var/lib/ntp/drift
pidfile   /var/run/ntpd.pid
logfile /var/log/ntp.log
restrict    default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
server 127.127.1.0
fudge  127.127.1.0 stratum 10
server ntp.aliyun.com iburst minpoll 4 maxpoll 10
restrict ntp.aliyun.com nomodify notrap nopeer noquery
```

##### ubuntu 20.04 ntp 同步

sudo timedatectl set-ntp true <font color="red">Failed to set ntp: NTP not supported</font>

```bash
sudo apt-get install systemd-timesyncd
# Failed :Unit systemd-timesyncd.service is masked
sudo systemctl unmask systemd-timesyncd.service
sudo timedatectl set-ntp true

# status
sudo systemctl status systemd-timesyncd.service
```

