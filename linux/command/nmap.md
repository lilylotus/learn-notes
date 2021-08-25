## nmap 工具

Network exploration（勘探，探索） tool and security / port scanner。

### 参数

- -iR <num hosts>: Choose random targets
- -Pn: Treat all hosts as online -- skip host discovery
- -PS/PA/PU/PY[portlist]: TCP SYN/ACK, UDP or SCTP discovery to given ports (精确)
- -sn: Ping Scan - disable port scan
- -sL: List Scan - simply list targets to scan
- -sS/sT/sA/sW/sM: TCP SYN/Connect()/ACK/Window/Maimon scans
- -sU: UDP Scan
- -sN/sF/sX: TCP Null, FIN, and Xmas scans
- -v: Increase verbosity level (use -vv or more for greater effect)
- -A: Enable OS detection, version detection, script scanning, and traceroute

> nmap -v -A scanme.nmap.org
> nmap -v -sn 192.168.0.0/16 10.0.0.0/8
> nmap -v -iR 10000 -Pn -p 80
>
> nmap -PA 192.168.0.0/24 (`TCP Syn Ping`即传输层的TCP/IP扫描，通过发送和接收报文的形式进行扫描，在这种情况下每个端口都会轻易的被发现)
> nmap -PS 192.168.0.0/24 (很多防火墙会封锁`SYN`报文，所以nmap提供了`SYN`和`ACK`两种扫描方式，者的结合大大的提高了逃避防火墙的概率)
> nmap -PR 192.168.0.0/24 (ARP扫描)

<font color="red">注意：</font>当发现端口扫描不到，使用参数 `-Pn` 认为主机是启用（在线）的。

> nmap -sV -sT -Pn -p 10000-65535 47.103.87.108 (扫描成功)
>
> nmap -sV -sT -p 10000-65535 47.103.87.108 （扫描失败）提示 [Note: Host seems down. If it is really up, but blocking our ping probes, try -Pn]

### 本地端口转发

```bash
ssh -p 30022 -CNfg -L 60080:10.99.0.24:60080 yuanzhenxin@47.103.87.108

-C： 压缩数据传输。
-f：后台认证用户/密码，通常和-N连用，不用登录到远程主机。
-N：不执行脚本或命令，通常与-f连用。
-g：在-L/-R/-D参数中，允许远程主机连接到建立的转发的端口，如果不加这个参数，只允许本地主机建立连接。
-L： 本地端口:目标IP:目标端口
-T： 不分配 TTY 只做代理用
-q： 安静模式，不输出 错误/警告 信息
```

##### 扫描主机操作系统

参数 `-O` （大写）

> nmap -O 192.168.1.80

##### 指定端口或范围

默认会探测内置的 1000 个常见端口，若想制定端口范围，使用参数 `-p` :

> nmap -p 1-65535 localhost
> nmap -p 80,443 localhost


##### 同时扫描多个 IP

若是不连续的 ip 使用空格分隔：

> nmap -p 80 192.168.1.80 192.168.2.80 192.168.3.80

连续 ip 格式

> nmap -p 80 192.168.1.6,7,8,9

##### 扫描端口服务

获取端口服务信息，参数 `-sV`

> nmap -sV www.test.com

##### 指定 TCP/UDP 协议扫描

TCP 协议 `-sT` 参数，UDP 协议 `-sU`

> nmap -sT  192.168.0.80
>
> nmap -sU 192.168.0.88
