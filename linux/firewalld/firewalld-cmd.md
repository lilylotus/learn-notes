### firewalld-cmd 命令
Linux 上新用的防火墙软件，跟 iptables 差不多的工具。
firewall-cmd 是 firewalld 的字符界面管理工具，firewalld 是 centos7 的一大特性，最大的好处有两个
1. 支持动态更新，不用重启服务
2. 加入了防火墙的 “zone” 概念

firewalld 跟 iptables 比起来至少有两大好处
1. firewalld 可以动态修改单条规则，而不需要像 iptables 那样，在修改了规则后必须得全部刷新才可以生效。
2. firewalld 在使用上要比 iptables 人性化很多，即使不明白“五张表五条链”而且对 TCP/ip 协议也不理解也可以实现大部分功能。

firewalld 自身并不具备防火墙的功能，而是和 iptables 一样需要通过内核的 netfilter 来实现，
也就是说 firewalld 和 iptables 一样，他们的作用都是用于维护规则，而真正使用规则干活的是内核的 netfilter，
只不过 firewalld 和 iptables 的结 构以及使用方法不一样罢了。


### zone 介绍
所謂的 zone 就表示主機位於何種環境，需要設定哪些規則，在 firewalld 裡共有 7 個zones
> 先決定主機要設定在那個區域 zone >> 再往該 zone 設定規則 >>> 重新讀取設定檔 sudo firewall-cmd --reload

1. public： 公開的場所，不信任網域內所有連線，只有被允許的連線才能進入，一般只要設定這裡就可以了  
For use in public areas. You do not trust the other computers on the network to not harm your computer. Only selected incoming connections are accepted.
2. external： 公開的場所，應用在IP是NAT的網路  
For use on external networks with masquerading enabled especially for routers. You do not trust the other computers on the network to not harm your computer. Only selected incoming connections are accepted.
3. dmz： (Demilitarized Zone) 非軍事區，允許對外連線，內部網路只有允許的才可以連線進來  
For computers in your demilitarized zone that are publicly-accessible with limited access to your internal network. Only selected incoming connections are accepted.
4. work： 公司、工作的環境  
For use in work areas. You mostly trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.
5. home： 家庭環境  
For use in home areas. You mostly trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.
6. internal： 內部網路，應用在NAT設定時的對內網路  
For use on internal networks. You mostly trust the other computers on the networks to not harm your computer. Only selected incoming connections are accepted.
7. trusted： 接受所有的連線  
All network connections are accepted.
8. drop： 任何進入的封包全部丟棄，只有往外的連線是允許的  
Any incoming network packets are dropped, there is no reply. Only outgoing network connections are possible.
9. block： 任何進入的封包全部拒絕，並以 icmp 回覆對方 ，只有往外的連線是允許的  
Any incoming network connections are rejected with an icmp-host-prohibited message for IPv4 and icmp6-adm-prohibited for IPv6. Only network connections initiated from within the system are possible.


**firewall配置文件 /etc/firewalld/firewalld.conf**

### 修改服务
| 预定的链接信息
1. 备份 /usr/lib/firewalld/services/http.xml
2. 修改默认 端口
<port protocol="tcp" port="80"> --> <port protocol="tcp" port="8080">

| 限制某服务只能从那个 IP 进入
```bash
通常我們會限制 ssh 只能從某些 IP 來進來，我們可以使用 rich-rule 來加入
# firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.1.88" service name="ssh" accept"
或 ip subnet
# firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept"

# firewall-cmd --add-rich-rule="rule family="ipv4" source address="10.10.37.138" service name="ssh" reject" [accept]

 永久允許 192.168.0.0/24 使用 http 服務
firewall-cmd --zone=public \
  --add-rich-rule 'rule family="ipv4" source address="192.168.0.0/24" service name="http" accept' \ --permanent

列出: firewall-cmd --list-rich-rules
删除: firewall-cmd --remove-rich-rule='rule'

```
| 限制某 port 只能從哪 IP 連入
```bash
# sudo firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.12.9" port port="8080" protocol="tcp" accept"
注意：port port="8080" 不是寫錯唷！這是他的格式

添加: firewall-cmd --add-rich-rule='rule family="ipv4" source address="10.10.37.138" port port="22" protocol="tcp" reject'

删除: firewall-cmd --remove-rich-rule='rule family="ipv4" source address="10.10.37.138" port port="22" protocol="tcp" reject'
```
| 直接指定 rule 到 INPUT  chain
```bash
# sudo firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp -s "192.168.12.9" --dport 22 -j ACCEPT
這樣的寫法使用 # firewall-cmd --list-all 是看不到的，要用 iptables -L -n
```

**注意: 永久 [--permanent] 写入的规则会存储到 /etc/firewalld/zones 和  /usr/lib/firewalld/zones/ 的最有 zone 档案里 (public.xml)**

| 从 zone 移除某項服務
```bash
# sudo firewall-cmd --zone=public --add-service=http --permanent
# sudo firewall-cmd --zone=public --remove-service=http --permanent
# sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
# sudo firewall-cmd --zone=public --remove-port=8080/tcp --permanent
```

| port forward 將從某 port number 的封包轉送另外的 port 或其他主機

**注意: 转发的话要开启防火墙伪装 --add-masquerade 或关闭 --remove-masquerade**
```bash
1. 端口 80 -> 8080
# firewall-cmd --zone=public --add-forward-port=port=80:proto=tcp:toport=8080
2. 端口 80 到其它主机 port 8080
firewall-cmd --zone=public --add-forward-port=port=80:proto=tcp:toport=8080:toaddr=10.10.37.131

3. 转发端口:
# firewall-cmd --zone=public --add-forward-port=port=40001:proto=tcp:toport=22:toaddr=10.10.37.132
# firewall-cmd --zone=public --add-forward-port=port=40001:proto=tcp:toaddr=10.10.37.132:toport=22

4. 列出所有转发端口:
# firewall-cmd --list-forward-ports
5. 删除:
# firewall-cmd --remove-forward-port=port=40001:proto=tcp:toport=22:toaddr=10.10.37.132

6. 允许来自主机 10.1.0.3 到 80 端口的 IPv4 的 TCP 流量，并将流量转发到 6532 端口上。 
# sudo firewall-cmd --zone=public --add-rich-rule='rule family=ipv4 source address=10.1.0.3 forward-port port=80 protocol=tcp to-port=6532'

7. 将主机 172.31.4.2 上 80 端口的 IPv4 流量转发到 8080 端口 （需要在区域上激活 masquerade）
# firewall-cmd --add-masquerade     # 允许防火墙伪装IP
# firewall-cmd --remove-masquerade  # 禁止防火墙伪装IP
# sudo firewall-cmd --zone=public --add-rich-rule 'rule family=ipv4 forward-port port=80 protocol=tcp to-port=8080 to-addr=172.31.4.2'

8. 允许来自主机 192.168.0.14 的所有 IPv4 流量
# sudo firewall-cmd --zone=public --add-rich-rule 'rule family="ipv4" source address=192.168.0.14 accept'

9. 拒绝来自主机 192.168.1.10 到 22 端口的 IPv4 的 TCP 流量
# sudo firewall-cmd --zone=public --add-rich-rule 'rule family="ipv4" source address="192.168.1.10" port port="22" protocol="tcp" reject'

# firewall-cmd --add-rich-rule='rule family="ipv4" source address="10.10.37.138" forward-port port="50001" protocol="tcp" to-port="22" to-addr=10.10.37.132'

```

| 添加端口
```bash
# firewall-cmd --add-port=6666/tcp
# firewall-cmd --add-port=6666-6677/tcp

查看端口
# firewall-cmd --list-ports
移除端口
# firewall-cmd --remove-port=6666/tcp --permanenet

```

### 安装 firewalld
```
    yum install -y firewalld firewalld-config
    systemctl enabled firewalld
    systemctl restart firewalld
```

### 可选择的 firewall-cmd 命令参数
```bash
# firewall-cmd --help

Usage: firewall-cmd [OPTIONS...]

General Options
  -h, --help           Prints a short help text and exists
  -V, --version        Print the version string of firewalld
  -q, --quiet          Do not print status messages

Status Options
  --state                  Return and print firewalld state
  --reload                 Reload firewall and keep state information
  --complete-reload        Reload firewall and lose state information
  --runtime-to-permanent   Create permanent from runtime configuration

The firewall-cmd command offers categories of options such as General, Status, Permanent, Zone, IcmpType,
Service, Adapt and Query Zones, Direct, Lockdown, Lockdown Whitelist, and Panic. 
Refer to the firewall-cmd man page for more information.

```

### 命令格式
`firewall-cmd [选项 ... ]`

**选项**
```
1. 通用
-h, --help    # 显示帮助信息；
-V, --version # 显示版本信息. （这个选项不能与其他选项组合）；
-q, --quiet   # 不打印状态消息；

2. 状态选项
--state                # 显示firewalld的状态；
--reload               # 不中断服务的重新加载；
--complete-reload      # 中断所有连接的重新加载；
--runtime-to-permanent # 将当前防火墙的规则永久保存；
--check-config         # 检查配置正确性；

3. 日志
--get-log-denied         # 获取记录被拒绝的日志；
--set-log-denied=<value> # 设置记录被拒绝的日志，只能为 'all','unicast','broadcast','multicast','off' 其中的一个；

```

### 配置 firewalld
```
1. 查看配置
firewall-cmd --state                # 显示状态
firewall-cmd --get-active-zones     # 查看区域信息
firewall-cmd --get-zone-of-interface=eth0  # 查看指定接口所属区域
firewall-cmd --panic-on             # 拒绝所有包
firewall-cmd --panic-off            # 取消拒绝状态
firewall-cmd --query-panic          # 查看是否拒绝

firewall-cmd --reload           # 更新防火墙规则
firewall-cmd --complete-reload  # 两者的区别就是第一个无需断开连接，就是firewalld 特性之一动态添加规则，第二个需要断开连接，类似重启服务

# 将接口添加到区域，默认接口都在 public,  永久生效再加上 --permanent 然后 reload 防火墙
firewall-cmd --zone=public --add-interface=eth0
firewall-cmd --get-zone-of-interface=enp03s # 获取当前接口的区域

# 临时修改网络接口（enp0s3）为内部区域（internal）
firewall-cmd [--permanent] --zone=internal --change-interface=enp03s

firewall-cmd --get-zones                    # 显示支持的区域列表
firewall-cmd --set-default-zone=public      # 设置默认接口区域，立即生效无需重启
firewall-cmd --get-active-zones             # 查看当前区域
firewall-cmd --zone=public --list-all       # 显示所有公共区域（public）

firewall-cmd --zone=dmz --list-ports        # 查看所有打开的端口
firewall-cmd --zone=dmz --add-port=8080/tcp # 加入一个端口到区域

# 打开一个服务，类似于将端口可视化，服务需要在配置文件中添加，/etc/firewalld 目录下有 services 文件夹
firewall-cmd --zone=work --add-service=smtp    # 添加服务
firewall-cmd --zone=work --remove-service=smtp # 移除服务

```

### 端口转发
```bash
firewall-cmd --add-forward-port=port=80:proto=tcp:toport=8080        # 将 80 端口的流量转发至 8080
firewall-cmd --add-forward-port=port=80:proto=tcp:toaddr=192.168.0.1 # 将 80 端口的流量转发至 192.168.0.1
firewall-cmd --add-forward-port=port=80:proto=tcp:toaddr=192.168.0.1:toport=8080 # 将 80 端口的流量转发至 192.168.0.1的8080端口

```

### 常用的命令
```bash

1. List all zones
    firewall-cmd --list-all-zones
1.2 获取默认的 zone
    firewall-cmd --get-default-zone

2. 列出系统允许的服务和端口
    服务: firewall-cmd --list-services
    端口: firewall-cmd --list-ports

3. 对于一个服务允许所有的进入端口
    添加服务: firewall-cmd --zone=public --add-service=http
    列出运行的服务: firewall-cmd --zone=public --list-services
注: 永久添加需要加上参数 [--permanent]
    firewall-cmd --permanent --zone=public --add-service=http

4. 允许入口流量的端口
    firewall-cmd --add-por=[YOUR PORT]/[tcp|udp]
    example: firewall-cmd [--permanent] --add-port=222/tcp
    list open ports: firewall-cmd --list-ports

```