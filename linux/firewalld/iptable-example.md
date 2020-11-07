## iptable 示例1

```bash
# 第一台设备的telnet服务
iptables -t nat -A PREROUTING -i eth0 -d 172.18.44.44 -p tcp --dport 2321 -j DNAT --to 100.100.100.101:23
iptables -t nat -A POSTROUTING -o eth1 -d 100.100.100.101 -p tcp --dport 23 -j SNAT --to 100.100.100.44

# 第二台设备的telnet服务
iptables -t nat -A PREROUTING -i eth0 -d 172.18.44.44 -p tcp --dport 2322 -j DNAT --to 100.100.100.102:23
iptables -t nat -A POSTROUTING -o eth1 -d 100.100.100.102 -p tcp --dport 23 -j SNAT --to 100.100.100.44

# 第一台设备的web服务
iptables -t nat -A PREROUTING -i eth0 -d 172.18.44.44 -p tcp --dport 8081 -j DNAT --to 100.100.100.101:80
iptables -t nat -A POSTROUTING -o eth1 -d 100.100.100.101 -p tcp --dport 80 -j SNAT --to 100.100.100.44

# 第二台设备的web服务
iptables -t nat -A PREROUTING -i eth0 -d 172.18.44.44 -p tcp --dport 8082 -j DNAT --to 100.100.100.102:80
iptables -t nat -A POSTROUTING -o eth1 -d 100.100.100.102 -p tcp --dport 80 -j SNAT --to 100.100.100.44
```

以第一台设备转发命令解释

第一条是 *PREROUTING* 链，只能进行 `DNAT`。
从 eth0 进入且目的 IP 为 *172.18.44.44*，端口号为 *2321* 的数据包进行目的地址更改为 100.100.100.101，端口为 23，亦即此包的目的地为第一台设备的 telnet 服务。
注：可以用 `-s` 指明数据包来源地址，但这时无法知道来源 `IP` 是多少，虽然可以用网段的做法，但用 `-d` 则必须指定唯一的是本机的 *eth0* 地址

第二条是 *POSTROUTING* 链，只能进行 `SNAT`。
对前一条已经 `DNAT` 过的数据包修改源 *IP* 地址。这个数据包达到第一台设备时，源 IP 地址、目的 IP 地址，均为 *100.100.100.0/24* 网段了。

简化版本
```bash
# 第一台设备的 telnet、web 服务
iptables -t nat -A PREROUTING -i eth0 -d 172.18.44.44 -p tcp --dport 2321 -j DNAT --to 100.100.100.101:23
iptables -t nat -A PREROUTING -i eth0 -d 172.18.44.44 -p tcp --dport 8081 -j DNAT --to 100.100.100.101:80

# 第二台设备的 telnet、web 服务
iptables -t nat -A PREROUTING -i eth0 -d 172.18.44.44 -p tcp --dport 2322 -j DNAT --to 100.100.100.102:23
iptables -t nat -A PREROUTING -i eth0 -d 172.18.44.44 -p tcp --dport 8082 -j DNAT --to 100.100.100.102:80

# 源 IP 地址 SNAT
iptables -t nat -A POSTROUTING -o eth1 -d 100.100.100.0/24 -j SNAT --to 100.100.100.44
```