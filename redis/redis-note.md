#### 1. redis 操作

| 命令 | 功能 |
| ---- | ---- |
| redis-server | redis 服务器 |
| redis-cli | redis 命令行客户端 |
| redis-benchmark | redis 性能测试工具 |
| redis-check-aof | aof 文件修复工具 |
| redis-check-dump | rdb 文件检查工具 |

```bash
# 启动 redis server 带配置
$ redis-server redis.conf

# 连接 redis server
$ redis-cli -h 127.0.0.1 -p 6379 -n 10
-> -n <db> Database number
```

#### 2. redis 配置 [redis.conf]

##### 2.1 允许外部访问/配置密码

```properties
port 6379
#bind 127.0.0.1
protected-mode no (yes)
requirepass redis
```

