## MySQL 主从复制

### 1. 原理

同步操作通过 3 个线程实现。

1. 主服务器将数据的更新记录到二进制日志中（记录被称作二进制日志事件）-- 主库线程
2. 从库将主库的二进制日志复制到本地的中继日志（relay log）-- 从库 I/O 线程
3. 从库读取中继日志中的事件，将其重放到数据中 -- 从库 SQL 线程

### 2. 配置

#### 2.1 配置 master

##### 2.1.1 创建从库连接主库的用户

安全起见，创建一个新用户用于从库连接主库。

```
# 1. 创建用户
CREATE USER 'remote'@'%' IDENTIFIED BY 'mysql';
# 2. 授权，只授予复制和客户端访问权限
GRANT replication slave,replication client ON *.* to 'remote'@'%';
```

##### 2.1.2 修改配置文件

在 `/etc/my.cnf` 在 `[mysqld]` 下添加

```
log-bin=mysql-bin
log-bin-index=mysql-bin.index
binlog_format=mixed
server-id=100
sync-binlog=1
character-set-server=utf8mb4
```

配置说明

> log-bin：设置二进制日志文件的基本名；
> log-bin-index：设置二进制日志索引文件名；
> binlog_format：控制二进制日志格式，进而控制了复制类型，三个可选值
>   -STATEMENT：语句复制
>   -ROW：行复制
>   -MIXED：混和复制，默认选项
> server-id：服务器设置唯一 ID，默认为 1，推荐取 IP 最后部分；
> sync-binlog：默认为 0。为保证不会丢失数据，需设置为1，用于强制每次提交事务时，同步二进制日志到磁盘上。

保存文件并重启 `systemctl restart mysqld`

##### 2.1.2 备份主库

* 从数据库都是刚刚装好且数据都是一致的，直接执行 `show master status` 查看日志坐标。
* 主库可以停机，则直接拷贝所有数据库文件。
* 主库是在线生产库，可采用 `mysqldump` 备份数据，因为它对所有存储引擎均可使用。

```mysql
# 为了获取一个一致性的快照，需对所有表设置读锁
flush tables with read lock;
# 获取二进制日志的坐标，关注 Position 字段值
show master status;
```

备份数据

```mysql
# 针对事务性引擎
mysqldump -uroot -ptiger --all-database -e --single-transaction --flush-logs --max_allowed_packet=1048576 --net_buffer_length=16384 > /data/all_db.sql

# 针对 MyISAM 引擎，或多引擎混合的数据库
mysqldump -uroot --all-database -e -l --flush-logs --max_allowed_packet=1048576 --net_buffer_length=16384 > /data/all_db.sql
```

恢复主库的写操作

```mysql
unlock tables;
```

#### 2.2 配置 slave

##### 2.2.1 修改配置文件

在 `/etc/my.cnf` 在 `[mysqld]` 添加

```
log-bin=mysql-bin
binlog_format=mixed
log-slave-updates=0
server-id=200
relay-log=mysql-relay-bin
relay-log-index=mysql-relay-bin.index
read-only=1
slave_net_timeout=10
```

配置说明

> log-slave-updates：控制 slave 上的更新是否写入二进制日志，默认为 0；若 slave 只作为从服务器，则不必启用；若 slave 作为其他服务器的 master，则需启用，启用时需和 log-bin、binlog-format 一起使用，这样 slave 从主库读取日志并重做，然后记录到自己的二进制日志中；
> relay-log：设置中继日志文件基本名；
> relay-log-index：设置中继日志索引文件名；
> read-only：设置 slave 为只读，但具有 super 权限的用户仍然可写；
> slave_net_timeout：设置网络超时时间，即多长时间测试一下主从是否连接，默认为 3600 秒，即 1 小时，这个值在生产环境过大，我们将其修改为 10 秒，即若主从中断 10 秒，则触发重新连接动作。

##### 2.2.2 导入备份数据/统一二进制坐标

导入备份

```mysql
mysql -uroot -p < /data/all_db.sql
```

统一二进制日志的坐标

```
change master to
master_host='192.168.2.21',
master_user='remote',
master_password='mysql',
master_port=3306,
master_log_file='mysql-bin.000001',
master_log_pos=120;
```

##### 2.2.3 启动主从复制

```
# 启动从库 slave 线程
start salve;
# 查看从服务器复制功能状态
show slave status \G;
```

说明

> Slave_IO_Running：此进程负责 slave 从 master 上读取 binlog 日志，并写入 slave 上的中继日志。
> Slave_SQL_Running：此进程负责读取并执行中继日志中的 binlog 日志。