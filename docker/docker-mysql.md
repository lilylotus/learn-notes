##### 1. docker mysql 容器启动配置

```bash
#!/bin/bash
DIR=$(pwd)
PORT=50000
NAME=mysql57

if [[ "" != "$1" ]]; then
	echo "manual container name [$1]"
	NAME=$1
fi

if [[ "" != "$2" ]]; then
	echo "manual container port [$1]"
	PORT=$2
fi

docker run -d --name $NAME \
-v $DIR/data:/var/lib/mysql \
-v $DIR/conf:/etc/mysql/conf.d \
-v $DIR/logs:/var/log/mysql \
-p $PORT:3306 \
-e MYSQL_ROOT_PASSWORD=mysql \
mysql:5.7.28
```

##### 2. mysql 配置

```properties
# mysql master my.cnf
[client]
default_character_set=utf8mb4

[mysqld]
server_id=100
character_set_server=utf8mb4
collation_server=utf8mb4_general_ci
init_connect='set names utf8mb4'
character_set_client_handshake=FALSE
default_storage_engine=INNODB
max_connections=300
# 0 都区分大小写， 1 存储在磁盘是小写的，但是比较的时候是不区分大小写
lower_case_table_names=0
skip_name_resolve
sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

#log_output=FILE
log_bin=mysql-bin
#binlog_format=MIXED
#sync_binlog=1

#binlog-do-db=test
binlog-ignore-db=mysql
binlog_ignore_db=information_schema
binlog_ignore_db=performation_schema
binlog_ignore_db=sys

log_error=/var/lib/mysql/error.log

slow_query_log=ON
long_query_time=2
slow_query_log_file=/var/lib/mysql/slow.log
log_queries_not_using_indexes=OFF

#insertoptimize
innodb_buffer_pool_size=128M
bulk_insert_buffer_size=64M
max_allowed_packet=16M
read_buffer_size=1M
read_rnd_buffer_size=16M

wait_timeout=120
interactive_timeout=120
default_time_zone='+8:00'

[mysql]
default_character_set=utf8mb4
```

```properties
# mysql slave my.cnf
[client]
default_character_set=utf8mb4

[mysqld]
server_id=200
character_set_server=utf8mb4
collation_server=utf8mb4_unicode_ci
init_connect='set names utf8mb4'
character_set_client_handshake=FALSE
default_storage_engine=INNODB
max_connections=300
lower_case_table_names=0
skip_name_resolve

log_output=FILE
log_bin=mysql-bin
binlog_format=MIXED
# 每进行 n 次事务提交之后，MySQL 将 binlog_cache 中的数据强制写入磁盘。
sync_binlog=100
# * 从主服务器接收到的更新同时要写入二进制日志
log_slave_updates=1
master_info_repository=TABLE
relay_log_info_repository=TABLE
relay_log_recovery=ON

#binlog-do-db=test
binlog-ignore-db=mysql
binlog_ignore_db=information_schema
binlog_ignore_db=performation_schema
binlog_ignore_db=sys

log_error=/var/log/mysql/error.log

slow_query_log=ON
long_query_time=2
slow_query_log_file=/var/log/mysql/slow.log
log_queries_not_using_indexes=OFF

#insertoptimize
bulk_insert_buffer_size=64M
max_allowed_packet=16M
read_buffer_size=1M
read_rnd_buffer_size=16M

wait_timeout=120
interactive_timeout=120
default_time_zone='+8:00'

[mysql]
default_character_set=utf8mb4
```

##### 3. mysql 的 authentication

```sql
use mysql;

create user 'remote'@'%' identified by '123456';
CREATE DATABASE test DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
grant all privileges on test.* to 'remote'@'%' with grant option;

# mysql master
CREATE USER 'backup'@'%' IDENTIFIED BY 'mysql';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* to 'backup'@'%';
FLUSH PRIVILEGES;
SHOW MASTER STATUS;

# mysql slave
CHANGE MASTER TO MASTER_HOST='172.17.0.2',MASTER_PORT=3306,MASTER_USER='backup',MASTER_PASSWORD='mysql',MASTER_LOG_FILE='mysql-bin.000001',MASTER_LOG_POS=154;

SHOW SLAVE STATUS \G;
START SLAVE ;
STOP SLAVE ;
RESET SLAVE ALL;

CREATE TABLE test (
id VARCHAR(64) NOT NULL PRIMARY KEY,
name VARCHAR(128) NOT NULL ,
age INT NOT NULL ,
address VARCHAR(255)
)ENGINE=INNODB ;

INSERT INTO test (id, name, age, address) values ('aaaaa', '未知', 20, '未知之地') ;
```

##### 4. mysql master/salve docker-compose

```yaml
version: '3.7'
services:
  master:
    image: "mysql:${MYSQL_VERSION}"
    container_name: "${MASTER_CONTAINER_NAME}"
    environment:
      MYSQL_ROOT_PASSWORD: "${MASTER_PASSWORD}"
    volumes:
      - "${MASTER_DIR_CONF}:/etc/mysql/conf.d"
      - "${MASTER_DIR_DATA}:/var/lib/mysql"
      - "${MASTER_LOG_DIR}:/var/log/mysql"
    ports:
      - "${MASTER_PORT}:3306"
    networks:
      backend:
        ipv4_address: 172.18.10.10

  slave:
    image: "mysql:${MYSQL_VERSION}"
    container_name: "${SLAVE_CONTAINER_NAME}"
    depends_on:
      - master
    environment:
      MYSQL_ROOT_PASSWORD: "${SLAVE_PASSWORD}"
    volumes:
      - "${SLAVE_DIR_CONF}:/etc/mysql/conf.d"
      - "${SLAVE_DIR_DATA}:/var/lib/mysql"
      - "${SLAVE_DIR_LOG}:/var/log/mysql"
    ports:
      - "${SLAVE_PORT}:3306"
    networks:
      - backend

networks:
  backend:
    external:
      name: mnet
```

.env

```properties
MYSQL_VERSION=5.7.28

MASTER_PORT=50000
MASTER_PASSWORD=mysql
MASTER_CONTAINER_NAME=mysql-master
MASTER_DIR_CONF=/data/compose/mysql/master/conf
MASTER_DIR_DATA=/data/compose/mysql/master/data
MASTER_DIR_LOG=/data/compose/mysql/master/logs

SLAVE_PORT=50001
SLAVE_PASSWORD=mysql
SLAVE_CONTAINER_NAME=mysql-slave
SLAVE_DIR_CONF=/data/compose/mysql/slave/conf
SLAVE_DIR_DATA=/data/compose/mysql/slave/data
SLAVE_DIR_LOG=/data/compose/mysql/slave/logs
```

