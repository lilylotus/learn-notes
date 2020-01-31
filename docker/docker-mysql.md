#### docker 运行命令

1. docker mysql

```bash
# docker run -d --rm \
--name $2 \
-v $(pwd)/data:/var/lib/mysql \
-v $(pwd)/conf:/etc/mysql/conf.d \
-p $1:3306 \
-e MYSQL_ROOT_PASSWORD=123456 \
hub.nihility.cn/library/mysql:5.7.20

```

2. mysql configuration

   ```bash
   # mysql master
   
   [client]
   default-character-set = utf8mb4
   
   [mysqld]
   character-set-server = utf8mb4
   collation-server = utf8mb4_unicode_ci
   init-connect = 'SET NAMES utf8mb4'
   character-set-client-handshake = FALSE
   
   default-storage-engine = INNODB
   
   max_connections = 300
   skip-name-resolve
   
   server-id = 1
   log-error = /var/log/mysql/mysql-error.log
   log-bin = mysql-bin
   
   log-output = FILE
   slow-query-log = 1
   slow-query-log-file = mysql-slow.log
   
   sql-mode = NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
   
   [mysql]
   default-character-set = utf8mb4
   
   # mysql slave
   
   [mysqld]
   server-id = 100
   log-bin = mysql-bin
   replicate-ignore-db = mysql
   replicate-ignore-db = sys
   replicate-ignore-db = information_schema
   replicate-ignore-db = performance_schema
   ```

3. mysql 的 authentication

   ```bash
   use mysql;
   
   create user 'remote'@'%' identified by '123456';
   create database test;
   grant all privileges on test.* to 'remote'@'%' with grant option;
   
   
   # mysql master
   CREATE USER 'backup'@'%' IDENTIFIED BY '123456';
   GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* to 'backup'@'%';
   show master status ;
   
   # mysql slave
   change master to master_host='172.17.0.3', master_user='backup', master_password='123456', master_port=3306, master_log_file='mysql-bin.000003', master_log_pos=0, master_connect_retry=30;
   
   show slave status \G
   start slave;
   ```

   

