### 1. 下载 MySQL 安装包

mysql-5.7.22-winx64.zip

### 2. 配置环境变量

变量名：MYSQL_HOME
变量值：E:\mysql5.7.23
path 里添加：%MYSQL_HOME%\bin

### 3. 在 MYSQL_HOME 配置目录和文件

1. 创建 **data** 目录
2. 创建 **my.ini** 文件

```
[default]
default-character-set = utf8mb4

[mysqld]
port = 3306
character_set_server = utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect = 'SET NAMES utf8mb4'
basedir = C:\install\mysql
datadir = C:\install\mysql\data
server-id = 1
default-storage-engine = INNODB
sql-mode = "STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

log-output = FILE
log-error   = error.log
log-bin = binlog

slow_query_log = 1
slow_query_log_file = slow.log
long_query_time = 10
binlog_format = row
expire_logs_days = 15
log_bin_trust_function_creators = 1
max_connections = 150
table_open_cache = 2000
tmp_table_size = 16M

[client]
default-character-set = utf8mb4
```



collation_connection 、collation_database 、collation_server 是什么没关系

| 系统变量                 | 描述                       |
| ------------------------ | -------------------------- |
| character_set_client     | 客户端来源数据使用的字符集 |
| character_set_connection | 连接层字符集               |
| character_set_database   | 当前选中数据库的默认字符集 |
| character_set_server     | 默认的内部操作字符集       |
| character_set_results    | 查询结果字符集             |



### 4. 初始化数据库

`mysqld --initialize-insecure [--user=mysql]`
**注意：**管理员操作

### 5. 注册启动服务 MySQL

注册服务： `mysqld -install MySQL57`

启动服务： `net start MySQL57`

### 6. 修改密码和创建用户

```bash
update user set authentication_string=password('mysql') where user='root';
flush privileges;
commit;

create database test DEFAULT CHARACTER SET utf8mb4;
create user 'test'@'%' identified by 'mysql';
grant all privileges on test.* to 'test'@'%' with grant option;

create table test (
    -> id int not null auto_increment,
    -> name varchar(255) not null,
    -> age int not null,
    -> address varcahr(255),
    -> primary key(id))ENGINE=InnoDB default charset=utf8mb4;
```



### 7. 备份脚本

```
rem auther:wang
rem date:20190526
rem ******MySQL backup start********
@echo off
forfiles /p "E:\MySQLdata_Bak\mysql_backup" /m backup_*.sql -d -7 /c "cmd /c del /f @path"
set "Ymd=%date:~0,4%%date:~5,2%%date:~8,2%0%time:~1,1%%time:~3,2%%time:~6,2%"
"E:\mysql5.7.23\bin\mysqldump" -uroot -p123456 -P3306 --default-character-set=utf8mb4 -R -E --single-transaction  --all-databases > "E:\MySQLdata_Bak\mysql_backup\backup_%Ymd%.sql"
@echo on
rem ******MySQL backup end********
```

