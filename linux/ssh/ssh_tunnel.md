### 本地端口转发
```shell
ssh -fgN -L [local_bind_addr:]local_port:remote:remote_port root@ssh_server
```

### 远程端口转发
远程端口转发表示的是将远程端口的数据转发到本地

```shell
注意： 这个是在 sshd_client 上执行的命令
ssh -fgN -R [bind_addr:]sshd_server:web_server:port sshd_server

sshd_server         sshd_client             web_server
sshd_client 可以访问 sshd_server 和 web_server, 但是 sshd_server 不能访问 sshd_client

ssh -fgN -R 50000:web_server:80 sshd_server

表示 client 请求 server 的 sshd 服务， 在 server 建立了一个套接字监听端口 50000, 他是 web_server 的 80 端口映射。
当主机连接 sshd_server 的 端口 50000 时， 此连接数据全部通过 client 和 server 的安全隧道转发给 client， 
在由 client 转发给 web_server 的 80 端口，由于 client 请求开启的转发端口是在远程主机 sshd_server 上，所以叫远程端口转发。


```
1. 表示 client 请求 server 的 sshd 服务， 在 server 建立了一个套接字监听端口 50000, 他是 web_server 的 80 端口映射。
当主机连接 sshd_server 的 端口 50000 时， 此连接数据全部通过 client 和 server 的安全隧道转发给 client， 
在由 client 转发给 web_server 的 80 端口，由于 client 请求开启的转发端口是在远程主机 sshd_server 上，所以叫远程端口转发。

2. 远程端口转发和本地端口转发最大的一个区别是，远程转发端口是由 sshd_server 上的 sshd 服务控制的，
默认配置情况下，sshd 服务只允许本地开启的远程转发端口(22333)绑定在环回地址(127.0.0.1)上，
即使显式指定了bind_addr也无法覆盖

3. 要允许本地的远程转发端口绑定在非环回地址上，需要在 sshd_server 的 sshd 配置文件中启用 GatewayPorts 项，它的默认值为 no
启动该选项后，不给定 bind_addr 或 bind_addr 设置为 * 都表示绑定在所有地址上

### 动态端口转发(SOCKS代理)
ssh支持动态端口转发，由ssh来判断发起请求的工具使用的是什么应用层协议，然后根据判断出的协议结果决定目标端口。

```ssh
ssh -fgN -D [bind_addr:]port remote
```

**ssh 只支持 socks4 和 socks5 两种代理，有些客户端工具中需要明确指明代理类型**