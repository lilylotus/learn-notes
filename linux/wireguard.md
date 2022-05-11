# install wireguard

```bash
yum install -y yum-utils epel-release
yum-config-manager --setopt=centosplus.includepkgs=kernel-plus --enablerepo=centosplus --save
sed -e 's/^DEFAULTKERNEL=kernel$/DEFAULTKERNEL=kernel-plus/' -i /etc/sysconfig/kernel
yum install -y kernel-plus wireguard-tools


yum install -y epel-release elrepo-release
yum install -y yum-plugin-elrepo
yum install -y kmod-wireguard wireguard-tools

```

# quick start

[quick start](https://www.wireguard.com/quickstart/)

## key generate

```bash
umask 077
wg genkey > privatekey
wg pubkey < privatekey > publickey

# do this all at once
wg genkey | tee privatekey | wg pubkey > publickey

```

## configuration wireguard network

```bash

ip link add wg0 type wireguard
ip addr add dev wg0 10.0.0.1/24
wg set wg0 private-key ./private
ip link set wg0 up

wg

wg set wg0 peer <要连接 wireguard 的 public-key> allowed-ips <要访问的服务器 ip> endpoint <wireguard 所在服务器 ip 和监听的端口>
host1: wg set wg0 peer g6Bt3ANZBFrRW4LKHOdYWZyt92B63gtS/DoP63PIqw8= allowed-ips 10.0.0.2/32 endpoint 192.168.110.128:42213
host2: wg set wg0 peer 54ap5/0gjK6Jpm1WUYAp8fnmQsJke+CknB+2W7OnaEI= allowed-ips 10.0.0.1/32 endpoint 192.168.110.129:34204

host1: ping 10.0.0.1 (ok)
host2: ping 10.0.0.2 (ok)

```

or

```bash
ip link add dev wg0 type wireguard
wg set wg0 private-key /tmp/key peer 54ap5/0gjK6Jpm1WUYAp8fnmQsJke+CknB+2W7OnaEI= allowed-ips 192.168.4.0/24 endpoint demo.wireguard.io:12912
ip addr add 192.168.4.2/24 dev wg0
ip link set wg0 up
ping 192.168.4.1
wg


```


## wireguard configuration file

[Wireguard Config Generator](https://www.wireguardconfig.com/)
[How to easily configure WireGuard](https://www.stavros.io/posts/how-to-configure-wireguard/)

### default configuration

```
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```

在 */etc/wireguard/* 目录中创建 **wg0.conf** 的配置文件

#### Just a single connection

server 配置：

```
[Interface]
Address = 192.168.2.1
PrivateKey = <server's privatekey>
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <client's publickey>
AllowedIPs = 192.168.2.2/32
```

client 配置：

```
[Interface]
Address = 192.168.2.2
PrivateKey = <client's privatekey>
ListenPort = 21841

[Peer]
PublicKey = <server's publickey>
Endpoint = <server's ip>:51820
AllowedIPs = 192.168.2.0/24

# This is for if you're behind a NAT and
# want the connection to be kept alive.
PersistentKeepalive = 25
```

Forwarding all your traffic through:

```
[Interface]
Address = 192.168.2.2
PrivateKey = <client's privatekey>
ListenPort = 21841

[Peer]
PublicKey = <server's publickey>
Endpoint = <server's ip>:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

执行命令: `wg-quick up wg0` , `wg-quick down wg0`

### server (Wireguard Config Generator)

[Wireguard Config Generator](https://www.wireguardconfig.com/)

IP Address	10.1.0.1/24
Listen Port	51820
Private Key	YKmJqA3mvHGY9vET7pi82GEH+4Dcsqcq+IJAxPYnnFs=
Public Key	aWM8YIDo6baWtTnCc0QfOqSayLqZ2ghpbh/ov/beEww=

```
[Interface]
Address = 10.1.0.1/24
ListenPort = 51820
PrivateKey = YKmJqA3mvHGY9vET7pi82GEH+4Dcsqcq+IJAxPYnnFs=
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens32 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens32 -j MASQUERADE

[Peer]
PublicKey = +s3P0qNNmC7yHrX+Uw1/g9/yMIs+CDg8qOQwwKTS208=
PresharedKey = T+d2X/+l513QlD8r8cIfwRz5DnlO5Cwgl+G/b5ZTxT4=
AllowedIPs = 10.1.0.2/32

[Peer]
PublicKey = jZv78iGhwPosLKK9IfD87oOG2yYZM+NekdZhTJly9yM=
PresharedKey = gfHjUtcDALo07d0LQPIoCBqVOVVLva0s2RcVmvPkYT8=
AllowedIPs = 10.1.0.3/32
```

### client

IP Address	10.1.0.2/24
Listen Port	51820
Private Key	EImrG6bCsMjkxBBW1nfFhnHswm4O421OvWqEAnEk82s=
Public Key	+s3P0qNNmC7yHrX+Uw1/g9/yMIs+CDg8qOQwwKTS208=

```
[Interface]
Address = 10.1.0.2/24
ListenPort = 51820
PrivateKey = EImrG6bCsMjkxBBW1nfFhnHswm4O421OvWqEAnEk82s=

[Peer]
PublicKey = aWM8YIDo6baWtTnCc0QfOqSayLqZ2ghpbh/ov/beEww=
PresharedKey = T+d2X/+l513QlD8r8cIfwRz5DnlO5Cwgl+G/b5ZTxT4=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 192.168.110.129:51820
PersistentKeepalive = 25
```