#### DNS

`/etc/resolv.conf` 域名解析 DNS 配置文件

```
# ali dns
nameserver 223.5.5.5
nameserver 223.6.6.6
```

#### NTP

NTP 是网络时间协议 (Network Time Protocol)，它是用来同步网络中各个计算机的时间的协议。

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

