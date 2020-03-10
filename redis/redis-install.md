##### Redis 简介

> REmote DIctionary Server (Redis) 是一个由 Salvatore Sanfilippo 写的 key-value 存储系统。
> Redis 是一个开源的使用 ANSI C 语言编写、遵守 BSD 协议、支持网络、可基于内存亦可持久化的日志型、Key-Value 数据库，并提供多种语言的 API。
> 它通常被称为数据结构服务器，因为值（value）可以是 
> 字符串(String), 哈希(Hash), 列表(list), 集合(sets) 和有序集合(sorted sets)等类型。

##### Redis 源码安装

```bash
make
# 指定安装路径
make PREFIX=/usr/local/redis install
```

可执行文件

```bash
redis-server       服务器端
redis-cli          客户端
redis-benchmark    调试
redis-check-dump   数据导出
redis-check-aof    数据导入
```

配置文件

```bash
# 默认为 no 不以守护进程的方式运行(会占用一个终端) 
daemonize yes
bind 0.0.0.0
databases 16
masterauth redis
```

启动脚本

```bash
cat << EOF> /usr/lib/systemd/system/redis.service
[Unit]
Description=Redis
Documentation=http://download.redis.io
After=network.target
[Service]
PIDFile=/var/run/redis.pid
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/redis.conf --daemonize no
ExecStop=/usr/local/redis/bin/redis-cli shutdown
[Install]
WantedBy=multi-user.target
EOF
```

关闭 redis

```bash
redis-cli -h 127.0.0.1 -p 6379 shutdown
```

