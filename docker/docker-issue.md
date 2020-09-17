#### 1. docker 容器无法通过 IP 访问宿主机问题

##### 1.1 现象

```
# curl http://192.168.1.15:52203
curl: (7) Failed connect to 192.168.1.15:52203; No route to host
或者：
curl: (7) Failed to connect to 172.17.0.1 port 80: No route to host
```

但是

```bash
# ping 172.17.0.1
PING 172.17.0.1 (172.17.0.1) 56(84) bytes of data.
64 bytes from 172.17.0.1: icmp_seq=1 ttl=64 time=0.130 ms
```

ping 宿主是可以通的。也可以在容器内部访问其它内网和外网.

##### 1.2 解决方式

```bash
# 直接关闭 firewalld
# systemctl stop firewalld
```

正如 Docker Community Forms 所言, 这是一个已知的 Bug, 宿主机的 80 端口允许其它计算机访问, 但是不允许来自本机的 Docker 容器访问. 必须通过设置 firewalld 规则允许本机的 Docker 容器访问.
gypark 指出可以通过在 /etc/firewalld/zones/public.xml 中添加防火墙规则避免这个问题

```xml
<rule family="ipv4">
    <source address="172.17.0.0/16" />
    <accept />
</rule>
```

重启防火墙

```bash
# systemctl restart firewalld
```

#### 2. docker 下载初始化镜像列表

```bash
#!/bin/bash
IMAGES=(mysql:5.7.30 redis:4.0.14-alpine3.11 redis:4.0.14 redis:5.0.9 redis:5.0.9-alpine3.12 redis:6.0.6 redis:6.0.6-alpine3.12 busybox:1.32.0 busybox:1.32.0-glibc alpine:3.12.0 centos:centos7.7.1908 centos:centos7.8.2003 ubuntu:18.04)
for image in "${IMAGES[@]}"
do
	echo "pull image $image"
	docker pull $image
done
```

#### 3. docker 非 root 用户权限问题

把用户加到 docker 组

```bash
sudo groupadd docker
sudo gpasswd -a $USER docker
------
$ newgrp docker
```

