# redis HA 高可用

高可用，也叫 **HA（High Availability）**，是分布式系统架构设计中必须考虑的因素之一，它通常是指，通过设计减少系统不能提供服务的时间。

redis 高可用的三种模式：**主从模式**，**哨兵模式**，**集群模式**。

## 主从模式

一主可以多从

#### 主节点配置

主节点按正常配置

#### 从节点配置

```properties
# 配置文件中按以下方式添加主节点的 ip 和端口即可
replicaof 192.168.1.1 6379
#若主节点配置了授权密码则需要指定密码
masterauth 密码
#主节点通过以下方式设置授权密码
requirepass 密码
#客户端连接后需要先验证密码
auth 密码

# 从 redis2.6 开始，从节点默认是只读的
slave-read-only yes

#可通过以下指令查看当前连接的服务的主从信息
info replication
```

当主节点宕机后，从节点执行命令 `slaveof no one`，可以关闭从服务器的复制功能，同时原来同步的所得的数据集都不会被丢弃。

## 哨兵模式

master 宕机，哨兵会自动选举 master 并将其它的 slave 指向新的 master。

在主从模式下，redis 同时提供了哨兵命令 `redis-sentinel`，哨兵是一个独立的进程，作为进程，它会独立运行。其原理是哨兵进程向所有的 redis 机器发送命令，等待 Redis 服务器响应，从而监控运行的多个 Redis 实例。

哨兵可以有多个，一般为了便于决策选举，使用奇数个哨兵。

*redis.conf*  的配置和主从配置一置，仅添加哨兵的配置。

哨兵进程都需要一个哨兵的配置文件 `sentinel.conf`，所有哨兵配置是一样的。

```properties
# 禁止保护模式
protected-mode no
# 配置监听的主服务器，这里 sentinel monitor 代表监控，mymaster 代表服务器的名称，可以自定义
# 192.168.1.10 代表监控的主服务器，6379 代表端口，2 代表只有两个或两个以上的哨兵认为主服务器不可用的时候，才会进行 failover 操作。
sentinel monitor mymaster 192.168.1.10 6379 2
# sentinel author-pass 定义服务的密码，mymaster 是服务名称，123456是Redis服务器密码
sentinel auth-pass mymaster 123456

# 指出 master 地址和端口以及仲裁数
sentinel monitor mymaster 127.0.0.1 6379 2
# 与 master 通讯超时时间,达到超时时间则 sdown+1
sentinel down-after-milliseconds mymaster 60000
# 同一个 master,开始新的故障转移的时间(将是上一次的两倍)
# 若 slave 连接到错误的 master 超过这个时间后 slave 将被重新连接到正确的 master
# 取消正在进行中的故障转移等待时间
# 按照 parallel-syncs 指定的配置进行复制的时间,超时候将不再受 parallel-syncs 的限制
sentinel failover-timeout mymaster 180000
# 发生故障转移后,同时进行同步的副本数量
sentinel parallel-syncs mymaster 1
```

**启用哨兵**

首先启动主节点，然后一台一台启动从节点。
redis 集群启动完成后，分别启动哨兵集群所在机器的三个哨兵
使用 `redis-sentinel /path/to/sentinel.conf` 命令。

哨兵模式的启动模式有两种方式：

```bash
$ redis-sentinel sentinel.conf

$ redis-server sentinel.conf --sentinel

# 查看哨兵信息
redis> info sentinel
```

<font color="red">注意：</font>

- 哨兵至少需要 3 个实例，来保证自己的健壮性。
- 哨兵 + Redis 主从的部署架构，是**不保证数据零丢失**的，只能保证 Redis 集群的高可用性。
- 对于哨兵 + Redis 主从这种复杂的部署架构，尽量在测试环境和生产环境，都进行充足的测试和演练。

- 哨兵应与分布式的形式存在，若哨兵仅部署一个则实际上没有办法提高可用性，当仅有的哨兵进程遇到问题退出后，则无法完成故障恢复;
- 三个哨兵应该部署在相互的独立的计算机或虚拟机中;

## 集群模式

先说一个误区：**Redis 的集群模式本身没有使用一致性 hash 算法，而是使用 slots 插槽**。

修改 *redis.conf* 配置文件

```properties
# 开启 redis 的集群模式
cluster-enabled yes
# 集群模式下的配置文件名称和位置, 这个文件是集群启动后自动生成的，不需要手动配置。
cluster-config-file redis-cluster.conf
```

集群方式启动：

```bash
$ redis-trib.rb create --replicas 1 192.168.1.11:6379 192.168.1.21:6379 192.168.1.12:6379 192.168.1.22:6379 192.168.1.13:6379 192.168.1.23:6379

$ redis-cli --cluster create 10.211.55.9:7001 10.211.55.9:7002 10.211.55.9:7003 10.211.55.9:7004 10.211.55.9:7005 10.211.55.9:7006 --cluster-replicas 1

# 登录集群
$ redis-cli -c -h 192.168.1.11 -p 6379 -a 123456 

# 集群状态
redis> cluster info
# 集群节点信息
redis> cluster nodes
```

