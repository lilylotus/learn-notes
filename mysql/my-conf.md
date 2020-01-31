#### 1. mysql 5.7 版本和以前不同

```
mysql5.7以上和5.7以下的版本存在参数配置不同

5.7以上报不存在的字段有
unknown variable 'innodb_additional_mem_pool_size=2M'
解决：移除这个配置
innodb_additional_mem_pool_size 和 innodb_use_sys_malloc 在 MySQL 5.7.4 中移除。

#unknown variable 'log-slow-queries'
解决：
mysql5.6版本以上，取消了参数log-slow-queries，更改为slow-query-log-file
还需要加上 slow_query_log = on 否则，还是没用
#log-slow-queries = /home/db/madb/log/slow-query.log
slow_query_log = on
slow-query-log-file = /home/db/madb/log/slow-query.log
long_query_time = 1

5.7以上版本使用 character_set_server=utf8 代替 default-character-set = utf8 
#unknown variable myisam_max_extra_sort_file_size=100G
5.7版本没有上面参数，去除
```

#### 2. 简短配置

```bash
[client]
default-character-set=utf8mb4

[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'
max_connections = 300
skip_name_resolve

[mysql]
default-character-set=utf8mb4
```



#### 3. 基本配置

```
[client]
port=3306

[mysql]
no-beep
# default-character-set=

[mysqld]
port=3306

# mysql根目录
basedir="D:\AppServ\mysql5.7\"
# 放所有数据库的data目录
datadir=D:\AppServ\mysql5.7\data

# character-set-server=utf8mb4

# 默认存储引擎innoDB
default-storage-engine=INNODB

# Set the SQL mode to strict
sql-mode="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

#日志输出为文件
log-output=FILE

# 是否开启sql执行结果记录，必须要设置general_log_file参数，日志的路径地址
# 即日志跟踪，1为开启，0为关闭
general-log=0
general_log_file="execute_sql_result.log"

# 配置慢查询，5.7版本默认为1
slow-query-log=1
slow_query_log_file="user-slow.log"
long_query_time=10

#默认不开启二进制日志
#log-bin=mysql-log

#错误信息文件设置，会将错误信息放在data/mysql.err文件下
log-error=mysql.err

# Server Id.数据库服务器id，这个id用来在主从服务器中标记唯一mysql服务器
server-id=1

#lower_case_table_names： 此参数不可以动态修改，必须重启数据库
#lower_case_table_names = 1  表名存储在磁盘是小写的，但是比较的时候是不区分大小写
#lower_case_table_names=0  表名存储为给定的大小和比较是区分大小写的 
#lower_case_table_names=2, 表名存储为给定的大小写但是比较的时候是小写的
lower_case_table_names=1

#限制数据的导入导出都只能在Uploads文件中操作,这个是在sql语句上的限制。
#secure-file-priv="D:\AppServ\mysql-5.7.23/Uploads"
#值为null ，也就是注释掉这个参数或者secure-file-priv=null。表示限制mysqld 不允许导入|导出
#值为/tmp/ ，即secure-file-priv="/tmp/" 表示限制mysqld 的导入|导出只能发生在/tmp/目录下
#没有具体值时，即secure-file-priv=      表示不对mysqld 的导入|导出做限制

# 最大连接数
max_connections=151
# 打开表的最大缓存数
table_open_cache=2000

# tmp_table_size 控制内存临时表的最大值,超过限值后就往硬盘写，写的位置由变量 tmpdir 决定 
tmp_table_size=16M

# 每建立一个连接，都需要一个线程来与之匹配，此参数用来缓存空闲的线程，以至不被销毁，
# 如果线程缓存中有空闲线程，这时候如果建立新连接，MYSQL就会很快的响应连接请求。
# 最大缓存线程数量
thread_cache_size=10
```

#### 3. MYISAM 引擎配置

```
#*** MyISAM Specific options  MyISAM引擎的配置
# MySQL重建索引时所允许的最大临时文件的大小
myisam_max_sort_file_size=100G

myisam_sort_buffer_size=8M
key_buffer_size=8M
read_buffer_size=0
read_rnd_buffer_size=0
```

#### 4. InnoDB 配置

```
#*** INNODB Specific options InnoDB存储引擎的配置

# InnoDB表的目录共用设置。没有在 my.cnf 进行设置，InnoDB 将使用MySQL的 datadir 目录为缺省目录。
# 如果设定一个空字串,可以在 innodb_data_file_path 中设定绝对路径
#innodb_data_home_dir=

# 通常设置为 1，意味着在事务提交前日志已被写入磁盘， 事务可以运行更长以及服务崩溃后的修复能力。
# 如果你愿意减弱这个安全，或你运行的是比较小的事务处理，可以将它设置为 0 ，以减少写日志文件的磁盘 I/O。
innodb_flush_log_at_trx_commit=1

# InnoDB 将日志写入日志磁盘文件前的缓冲大小
innodb_log_buffer_size=1M

# InnoDB 用来高速缓冲数据和索引内存缓冲大小。
innodb_buffer_pool_size=8M

innodb_log_file_size=48M

# InnoDB 会试图将 InnoDB 服务的使用的操作系统进程小于或等于这里所设定的数值。默认为8
innodb_thread_concurrency=9

innodb_autoextend_increment=64
innodb_buffer_pool_instances=8
innodb_concurrency_tickets=5000
innodb_old_blocks_time=1000
innodb_open_files=300
innodb_stats_on_metadata=0
innodb_file_per_table=1
innodb_checksum_algorithm=0

back_log=80
flush_time=0
join_buffer_size=256K
max_allowed_packet=4M
max_connect_errors=100
open_files_limit=4161
sort_buffer_size=256K
table_definition_cache=1400
binlog_row_event_max_size=8K
sync_master_info=10000
sync_relay_log=10000
sync_relay_log_info=10000
```

