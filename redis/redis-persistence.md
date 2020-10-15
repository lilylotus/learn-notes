### Redis 持久化

Redis 支持两份持久化方式：

- RDB： 在指定的时间间隔能对你的数据进行快照存储。
- AOF：记录每次对服务器写的操作,当服务器重启的时候会重新执行这些命令来恢复原始的数据。

### 持久化配置

#### RDB 持久化配置

```
# 时间策略
save 900 1
save 300 10
save 60 10000

# 文件名称
dbfilename dump.rdb

# 文件保存路径
dir /home/work/app/redis/data/

# 如果持久化出错，主进程是否停止写入
stop-writes-on-bgsave-error yes

# 是否压缩
rdbcompression yes

# 导入时是否检查
rdbchecksum yes
```

持久化时间策略

- `save 900 1` 表示 900s 内有 1 条写入命令就触发一次快照
- `save 300 10` 表示 300s 内有 10 条写入命令就触发一次快照

`stop-writes-on-bgsave-error yes` 是非常重要的一项配置，当备份进程出错时，主进程就停止接受新的写入操作，是为了保护持久化的数据一致性问题。如果自己的业务有完善的监控系统，可以禁止此项配置， 否则请开启。

压缩的配置 `rdbcompression yes`，建议没有必要开启，Redis 本身就属于 CPU 密集型服务器，再开启压缩会带来更多的 CPU 消耗，相比硬盘成本，CPU 更值钱。

禁用 RDB 配置，也是非常容易的，只需要在 save 的最后一行写上：`save ""`

针对 RDB 持久化手动触发方式：
- save：会阻塞当前 Redis 服务器，直到持久化完成，线上应该禁止使用。
- bgsave：该触发方式会 fork 一个子进程，由子进程负责持久化过程，因此阻塞只会发生在 fork 子进程的时候。

自动触发时机点：

- 根据我们的 `save m n` 配置规则自动触发
- 从节点全量复制时，主节点发送 rdb 文件给从节点完成复制操作，主节点会触发  `bgsave`
- 执行 `debug reload`
- 执行 `shutdown` 时，如果没有开启 aof，也会触发

#### AOF 配置

```bash
# 是否开启aof
appendonly yes

# 文件名称
appendfilename "appendonly.aof"

# 同步方式
appendfsync everysec

# aof重写期间是否同步
no-appendfsync-on-rewrite no

# 重写触发配置
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# 加载aof时如果有错如何处理
aof-load-truncated yes

# 文件重写策略
aof-rewrite-incremental-fsync yes
```

`appendfsync` 有三种模式：

- always：把每个写命令都立即同步到 aof，很慢，但是很安全
- everysec：每秒同步一次，是折中方案
- no：redis 不处理交给 OS 来处理，非常快，但是也最不安全

一般情况推荐 **everysec** 配置

`aof-load-truncated yes`  如果该配置启用，在加载时发现 aof 尾部不正确，会向客户端写入一个 log，但是会继续执行，如果设置为 no ，发现错误就会停止，必须修复后才能重新加载。

手动命令触发 `bgrewriteaof`
自动触发，根据配置规则来触发，自动触发的整体时间还跟 Redis 的定时任务频率有关系。