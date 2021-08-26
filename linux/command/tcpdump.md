## tcpdump 命令

 转储网络上的数据流 (dump traffic on a network)

参数：

- -c count ：Exit after receiving count packets.
- -i interface ： `any` - 所有的网络接口，`eth0` - 针对 eth0 接口
- -n ：Don't convert host addresses to names.  This can be used to avoid DNS lookups.
- -nn ：Don't convert protocol and port numbers etc. to names either.
- -v / -vv / -vvv ： 打印更加详细的信息输出
- -w file ： 把输入写入到指定文件



TCP 数据包符号含义

```
S (SYN), F(FIN), P (PUSH), R (RST), U (URG), W (ECN CWR), E (ECN-Echo) or `.' (ACK), or `none' if no flags are set.
```

示例

```bash
# 监听 ens33 网络接口，的 tcp 端口为 80 的流量
tcpdump -nn -i ens33 tcp and port 80

# 保存到文件
tcpdump -nn -w nginx.cap -i ens33 tcp and port 80

# 监听访问 百度 的连接
tcpdump -nn -w baidu.cap -i ens33 host 180.101.49.11 and tcp

# 展示详细信息
tcpdump -nn -vv -i ens33 tcp and port 80
```

监视指定网络接口的数据包

```bash
tcpdump -i eth0
```

监视指定主机的数据包，进入或离开 server 的数据包

```bash
tcpdump -i eth0 host server

# 截获主机 node1 发送的所有数据
tcpdump -i ens33 src host node1

# 监视所有发送到主机 node1 的数据包
tcpdump -i ens33 dst host node1

# 监视指定主机和端口的数据包
tcpdump -i ens33 port 8080 and host node1
```

```bash
tcpdump src 1.1.1.1
tcpdump dst 1.0.0.1

tcpdump port 3389
tcpdump src port 1025

tcpdump icmp [tcp/udp/icmp]

# and / or
tcpdump -nnvvS src 10.5.2.3 and dst port 3389
```

扫描结果

```
# nginx
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens33, link-type EN10MB (Ethernet), capture size 262144 bytes
10:26:17.132140 IP 192.168.10.1.59224 > 192.168.10.6.80: Flags [S], seq 2370004641, win 64240, options [mss 1460,nop,wscale 8,nop,nop,sackOK], length 0
10:26:17.132201 IP 192.168.10.6.80 > 192.168.10.1.59224: Flags [S.], seq 4115938895, ack 2370004642, win 29200, options [mss 1460,nop,nop,sackOK,nop,wscale 7], length 0
10:26:17.132276 IP 192.168.10.1.59224 > 192.168.10.6.80: Flags [.], ack 1, win 4106, length 0
10:26:17.142306 IP 192.168.10.1.59224 > 192.168.10.6.80: Flags [P.], seq 1:77, ack 1, win 4106, length 76: HTTP: GET / HTTP/1.1
10:26:17.142349 IP 192.168.10.6.80 > 192.168.10.1.59224: Flags [.], ack 77, win 229, length 0
10:26:17.142467 IP 192.168.10.6.80 > 192.168.10.1.59224: Flags [P.], seq 1:239, ack 77, win 229, length 238: HTTP: HTTP/1.1 200 OK
10:26:17.142578 IP 192.168.10.6.80 > 192.168.10.1.59224: Flags [P.], seq 239:851, ack 77, win 229, length 612: HTTP
10:26:17.142629 IP 192.168.10.1.59224 > 192.168.10.6.80: Flags [.], ack 851, win 4102, length 0
10:26:17.143521 IP 192.168.10.1.59224 > 192.168.10.6.80: Flags [F.], seq 77, ack 851, win 4102, length 0
10:26:17.143582 IP 192.168.10.6.80 > 192.168.10.1.59224: Flags [F.], seq 851, ack 78, win 229, length 0
10:26:17.143675 IP 192.168.10.1.59224 > 192.168.10.6.80: Flags [.], ack 852, win 4102, length 0


# https://www.baidu.com
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens33, link-type EN10MB (Ethernet), capture size 262144 bytes
10:29:53.863031 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [S], seq 3836429234, win 29200, options [mss 1460,sackOK,TS val 2731977 ecr 0,nop,wscale 7], length 0
10:29:53.876844 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [S.], seq 1798592075, ack 3836429235, win 64240, options [mss 1460], length 0
10:29:53.876944 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [.], ack 1, win 29200, length 0
10:29:54.310694 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [P.], seq 1:196, ack 1, win 29200, length 195
10:29:54.311062 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [.], ack 196, win 64240, length 0
10:29:54.322114 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [P.], seq 1:80, ack 196, win 64240, length 79
10:29:54.322160 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [.], ack 80, win 29200, length 0
10:29:54.323032 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [P.], seq 80:3859, ack 196, win 64240, length 3779
10:29:54.323136 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [.], ack 3859, win 36500, length 0
10:29:54.323876 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [P.], seq 3859:4206, ack 196, win 64240, length 347
10:29:54.323922 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [.], ack 4206, win 39420, length 0
10:29:54.338617 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [P.], seq 196:322, ack 4206, win 39420, length 126
10:29:54.339329 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [.], ack 322, win 64240, length 0
10:29:54.349977 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [P.], seq 4206:4257, ack 322, win 64240, length 51
10:29:54.350549 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [P.], seq 322:428, ack 4257, win 39420, length 106
10:29:54.350857 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [.], ack 428, win 64240, length 0
10:29:54.364408 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [P.], seq 4257:5726, ack 428, win 64240, length 1469
10:29:54.364435 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [.], ack 5726, win 42340, length 0
10:29:54.365036 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [P.], seq 5726:7158, ack 428, win 64240, length 1432
10:29:54.365562 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [P.], seq 428:459, ack 7158, win 45260, length 31
10:29:54.365781 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [F.], seq 459, ack 7158, win 45260, length 0
10:29:54.365785 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [.], ack 459, win 64240, length 0
10:29:54.365951 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [.], ack 460, win 64239, length 0
10:29:54.375706 IP 180.101.49.11.443 > 192.168.10.6.39764: Flags [FP.], seq 7158:7189, ack 460, win 64239, length 31
10:29:54.375762 IP 192.168.10.6.39764 > 180.101.49.11.443: Flags [R], seq 3836429694, win 0, length 0
```

