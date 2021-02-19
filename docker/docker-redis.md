##### docker redis 运行

```bash
# redis alpine
$ docker run --name redis \
-v `pwd`/conf/redis.conf:/usr/local/etc/redis/redis.conf \
-v `pwd`/data:/data \
-p 6379:6379 \
redis:alpine redis-server /usr/local/etc/redis/redis.conf

# redis debian
$ docker run -d --name redis \
-v `pwd`/data:/data \
-v `pwd`/conf/redis.conf:/etc/redis/redis.conf \
-p 46379:6379 \
redis:5.0.9 \
redis-server /etc/redis/redis.conf

cat <<EOF > /etc/apt/sources.list
deb http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb http://mirrors.aliyun.com/debian-security buster/updates main
deb-src http://mirrors.aliyun.com/debian-security buster/updates main
deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
EOF

apt-get update
apt-get install net-tools
apt-get install iputils-ping
```

##### redis 版本

```bash
# 5.x 版本
docker pull redis:5.0.9
docker pull redis:5.0.9-alpine

# 4.x 版本
docker pull redis:4.0.14
docker pull redis:4.0.14-alpine
```

##### redis 数据持久化和自定义配置文件

```bash
docker run --name some-redis -d redis redis-server --appendonly yes

# 如果持久化支持，默认存储在 /data 卷中，可以通过挂载卷方式
-v /docker/host/dir:/data

# 自定义配置文件
# dockerfile
FROM redis
COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]

# 命令
docker run --name myredis redis \
-v /myredis/conf/redis.conf:/usr/local/etc/redis/redis.conf \
redis-server /usr/local/etc/redis/redis.conf
```

#### redis sentinel

sentinel.conf 哨兵配置文件

```bash
# sentinel monitor <master-group-name> <ip> <port> <quorum>
sentinel monitor mymaster 127.0.0.1 6379 2
# sentinel <option_name> <master_name> <option_value>
sentinel down-after-milliseconds mymaster 60000
sentinel failover-timeout mymaster 180000
sentinel parallel-syncs mymaster 1

sentinel monitor resque 192.168.1.3 6380 4
sentinel down-after-milliseconds resque 10000
sentinel failover-timeout resque 180000
sentinel parallel-syncs resque 5
```

docker-compose.yml 创建 1 主 2 从

```yaml
version: "3.8"
services:
  master:
    image: redis:5.0.10
    container_name: master
    command: redis-server --requirepass mredis --masterauth mredis
    ports:
      - 6380:6379
  slave1:
    image: redis:5.0.10
    container_name: slave1
    command:  redis-server --replicaof master 6379 --requirepass mredis --masterauth mredis
    depends_on:
      - master
    ports:
      - 6381:6379
  slave2:
    image: redis:5.0.10
    container_name: slave2
    command: redis-server --replicaof master 6379 --requirepass mredis --masterauth mredis
    depends_on:
      - master
    ports:
      - 6382:6379
```

或者直接修改 redis.conf 配置文件

```properties
# master redis.conf
# 注释这一行，表示 Redis 可以接受任意 ip 的连接
# bind 127.0.0.1
# 关闭保护模式
protected-mode no
# 让 redis 服务后台运行
daemonize yes
# 对登录权限做限制，redis 每个节点的 requirepass 可以是独立、不同的
requirepass redispassword
# 设定主库的密码，用于认证，如果主库开启了 requirepass 选项这里就必须填相应的密码
masterauth masterpassword
# 配置日志路径，为了便于排查问题，指定redis的日志文件目录
logfile "/var/log/redis/redis.log"

####################################################################
# slave redis.conf
# 注释这一行，表示 Redis 可以接受任意 ip 的连接
# bind 127.0.0.1
# 关闭保护模式
protected-mode no
# 让 redis 服务后台运行
daemonize yes
# 对登录权限做限制，redis 每个节点的 requirepass 可以是独立、不同的
requirepass redispassword
# 设定主库的密码，用于认证，如果主库开启了 requirepass 选项这里就必须填相应的密码
masterauth masterpassword
# 设定 master 的 IP 和端口号，redis 配置文件中的默认端口号是 6379
# 低版本的 redis 这里会是 slaveof，意思是一样的，因为 slave 是比较敏感的词汇，所以在 redis 后面的版本中不在使用 slave 的概念，取而代之的是 replica
# 将 35.236.172.131 做为主，其余两台机器做从。ip 和端口号按照机器和配置做相应修改。
replicaof 35.236.172.131 6379
# 配置日志路径，为了便于排查问题，指定 redis 的日志文件目录
logfile "/var/log/redis/redis.log"
```

docker-compose.yml 创建哨兵 redis sentinel

```yaml
version: '3.8'
services:
  sentinel1:
    image: redis:5.0.9
    container_name: sentinel1
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    ports:
      - 26379:26379
    volumes:
      - ./sentinel1.conf:/usr/local/etc/redis/sentinel.conf
  sentinel2:
    image: redis:5.0.9
    container_name: sentinel2
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    ports:
    - 26380:26379
    volumes:
      - ./sentinel2.conf:/usr/local/etc/redis/sentinel.conf
  sentinel3:
    image: redis:5.0.9
    container_name: sentinel3
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    ports:
      - 26381:26379
    volumes:
      - ./sentinel3.conf:/usr/local/etc/redis/sentinel.conf
networks:
  default:
    external:
      name: redis-ha_default
```

sentinel.conf 哨兵配置文件

```properties
# sentinel1.conf
port 26379
dir /tmp
# 172.18.0.2 是 redis 的主节点 ip 
# 指示 Sentinel 去监视一个名为 mymaster 的主服务器， 这个主服务器的 IP 地址为 172.18.0.2 （docker inspect [containerIP] 可以获取） 端口号为 6379
# 将这个主服务器判断为失效至少需要 2 个 Sentinel 同意 （只要同意 Sentinel 的数量不达标，自动故障迁移就不会执行）
sentinel monitor mymaster 172.22.0.2 6379 2 
sentinel auth-pass mymaster mredis
# 指定了 Sentinel 认为服务器已经断线所需的毫秒数。
sentinel down-after-milliseconds mymaster 30000
# 指定了在执行故障转移时， 最多可以有多少个从服务器同时对新的主服务器进行同步， 
# 这个数字越小， 完成故障转移所需的时间就越长。
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 180000
sentinel deny-scripts-reconfig yes
```

校验

```bash
1. 进入 master redis，在 redis-cli 执行，查看从节点信息
redis> info replication
2. 查看哨兵信息
redis> sentinel master [监视的节点名称]
redis> sentinel slaves [监视的节点名称]
redis> sentinel sentinels [监视的节点名称]
```

#### redis cluster

