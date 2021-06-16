##### 1. docker mysql 容器启动配置

<font color="red">注意：</font> mysql 的配置文件名称 <font color="red">my.cnf</font>

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
# master
[client]
default-character-set=utf8mb4

[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
default-storage-engine=INNODB

default_time_zone='+8:00'

# replication
server-id=100
log-bin=mysql-bin
log-bin-index=mysql-bin.index
binlog_format=mixed
sync-binlog=1
binlog-ignore-db=mysql
binlog_ignore_db=information_schema
binlog_ignore_db=performation_schema
binlog_ignore_db=sys

[mysql]
default-character-set=utf8mb4
```

```properties
# slave
[client]
default-character-set=utf8mb4

[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
default-storage-engine=INNODB

default_time_zone='+8:00'

# replication
server-id=200
log-bin=mysql-bin
log-bin-index=mysql-bin.index
binlog_format=mixed
sync-binlog=1
log-slave-updates=0
relay-log=mysql-relay-bin
relay-log-index=mysql-relay-bin.index
read-only=1
slave_net_timeout=10

binlog-ignore-db=mysql
binlog_ignore_db=information_schema
binlog_ignore_db=performation_schema
binlog_ignore_db=sys

[mysql]
default-character-set=utf8mb4
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
    # networks:
    #   backend:
    #     ipv4_address: 172.18.10.10

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
    # networks:
    #   backend:
    #     ipv4_address: 172.18.10.11

# networks:
#   backend:
#     external:
#       name: mnet
```

.env

```properties
MYSQL_VERSION=5.7.28

MASTER_PORT=50000
MASTER_PASSWORD=mysql
MASTER_CONTAINER_NAME=master
MASTER_DIR_CONF=/data/compose/mysql/master/conf
MASTER_DIR_DATA=/data/compose/mysql/master/data
MASTER_DIR_LOG=/data/compose/mysql/master/logs

SLAVE_PORT=50001
SLAVE_PASSWORD=mysql
SLAVE_CONTAINER_NAME=slave
SLAVE_DIR_CONF=/data/compose/mysql/slave/conf
SLAVE_DIR_DATA=/data/compose/mysql/slave/data
SLAVE_DIR_LOG=/data/compose/mysql/slave/logs
```

