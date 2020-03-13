介绍

> redis 最开始使用主从模式做集群，若 master 宕机需要手动配置 slave 转为 master。后来为了高可用提出来**哨兵**模式，该模式下有一个哨兵监视 master 和 slave，若 master 宕机可自动将 slave 转为 master，但它也有一个问题，就是不能动态扩充。所以在3.x提出cluster集群模式。

###### redis 配置

```xml
bind 本机ip
port 50001
daemonize yes # redis后台运行
appendonly yes # aof日志开启，有需要就开启，它会每次写操作都记录一条日志
pidfile /var/run/redis_7000.pid # pidfile 文件
cluster-enabled yes # 开启集群  
cluster-config-file nodes_7000.conf # 集群的配置，配置文件首次启动自动生成
cluster-node-timeout 15000 # 请求超时，默认 15 秒，可自行修改
requirepass ssxx # 设置 redis 访问密码
masterauth ssxx # 设置 redis 集群间的访问密码，同上面密码一致
```

###### docker 启动 redis

```bash
docker run -d \
-p $1:6379 \
-v /$2/conf/redis.conf:/usr/local/etc/redis/redis.conf \
-v /$2/data:/data \
--name redis01 \
redis:alpine redis-server /usr/local/etc/redis/redis.conf
```

##### 集群床架

> 注意：redis 5 版本以前使用 *ruby* 脚本，redis5 由 *C* 语言开发

```bash
redis-cli -a redis --cluster create --cluster-replicas 1 10.10.37.123:50001 10.1
0.37.123:50002 10.10.37.123:50003 10.10.37.123:50004 10.10.37.123:50005 10.10.37.123:50006
# 启动一主 n 从的服务器节点 (cluster-replicas n 一个主对应 n 个从)
# 表示创建一个 master 对应一个 slave，--cluster-replicas 2 表示一个 master 两个 slave

cluster info    # 查看集群信息
cluster nodes   # 查看节点列表

cluster forget node-id # 删除节点
redis-cli --cluster del-node <ip>:<port> <node_id>
```

删除节点步骤

```bash
1. 首先删除 slave 节点
	redis-cli --cluster del-node <ip>:<port> <node_id>
2. 将被删除的 slave 对应的 master 节点的 slot 进行 reshard 到其他节点
	redis-cli --cluster reshard <master的ip:port> \
	--cluster-from <同一个master的node_id> 
	--cluster-to <接收slot的master的node_id> 
	--cluster-slots <将要参与分片的slot数量，这里就是待删除节点的全部slot> 
	--cluster-yes
--cluster-from: 表示分片的源头节点，即从这个标识指定的参数节点上将分片分配出去给别的节点，参数节点可以有多个，用逗号分隔。
--cluster-to: 和--cluster-from相对，标识接收分片的节点，这个参数指定的节点只能有一个。
--cluster-slots: 参与重新分片的slot号。
--cluster-yes: 不用显示分片的过程信息，直接后台操作。

3. 将 reshard 后的 master 执行删除操作
	redis-cli --cluster del-node <ip>:<port> <node_id>
```

