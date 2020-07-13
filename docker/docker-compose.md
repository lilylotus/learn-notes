#### 一. 安装

```bash
wget -O https://github.com/docker/compose/releases/download/1.25.3/docker-compose-Linux-x86_64

curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```



#### 二. 命令使用

> 通常使用步骤
>
> 1. 定义好 *Dockerfile* 稍后可以在任意地方复制
> 2. 定义 *docker-compose.yml* 文件，配置好容器运行的步骤
> 3. 运行 `docker-compose up` 运行

```yaml
version: '3'
services:
  web:
    build: .
    ports:
    - "5000:5000"
    volumes:
    - .:/code
    - logvolume01:/var/log
    links:
    - redis
  redis:
    image: redis
volumes:
  logvolume01: {}
```

> Compose 可以控制和管理容器的整个生命周期
>
> - 启动、停止、重新构建服务
> - 查看服务运行状态
> - 输出正在运行服务的日志
> - 在服务上运行一次性命令



**注意：**默认的项目名称为 *docker-compose.yml* 目录名称，自定义名称使用 *-p* 或者 *COMPOSE_PROJECT_NAME*
环境变量

#### 四. compose 属性介绍

```yaml
1. 镜像
	格式： image: 镜像名称:版本号
	举例： image: nginx:lastest
2. 容器命名
	格式： container_name: 自定义名称
	举例： container_name: nginx-web
3. 数据卷：
	格式：
		volumes:
		  - "宿主文件:容器文件"
		  - /data:/data

4. 端口
	格式：
		ports:
		  - "宿主端口:容器端口"
5. 镜像构建
	格式： build: Dockerfile 的路径
	举例：
		build: .
		build: ./df

6. 镜像依赖：
	格式：
		depends_on:
		  - 此镜像依赖的服务
		  
7. 网络
	networks:
	  - some-network
	  - other-network
	
```

#### 五. 命令帮助

```bash
  build              Build or rebuild services
  config             Validate and view the Compose file
  create             Create services
  down               Stop and remove containers, networks, images, and volumes
  events             Receive real time events from containers
  exec               Execute a command in a running container
  help               Get help on a command
  images             List images
  kill               Kill containers
  logs               View output from containers
  pause              Pause services
  port               Print the public port for a port binding
  ps                 List containers
  pull               Pull service images
  push               Push service images
  restart            Restart services
  rm                 Remove stopped containers
  run                Run a one-off command
  scale              Set number of containers for a service
  start              Start services
  stop               Stop services
  top                Display the running processes
  unpause            Unpause services
  up                 Create and start containers
  version            Show the Docker-Compose version information
```



---

#### 1. 环境搭建

```bash
# /etc/docker/daemon.json ->
{"registry-mirrors": ["https://2pcnubsp.mirror.aliyuncs.com"]}

# 安装 docker compose

```

#### 2. docker-compose 命令

```bash
# 检验文件正确性
docker-compose config

# 启动 -d 后台运行
docker-compose up [-d]

# 删除容器并停止
docker-compose down
```

#### 3. compose 模板文件

##### 3.1 mysql 

- docker-compose.yml

```yaml
version: '3.7'
  
services:
  mysql:
    image: "mysql:5.7.28"
    network_mode: "${DOCKER_NETWORK}"
    container_name: "${NAME}"
    hostname: "${NAME}"
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
    restart: always
    volumes:
      - "${DIR_MYSQL_CONF}:/etc/mysql/conf.d"
      - "${DIR_MYSQL_DATA}:/var/lib/mysql"
    ports:
      - "${MYSQL_PORT_MAPPING}:3306"
```

- .env

  ```
  DOCKER_NETWORK=bridge
  NAME=mysql-m1
  MYSQL_ROOT_PASSWORD=mysql
  MYSQL_PORT_MAPPING=50000
  DIR_MYSQL_CONF=/home/dandelion/temporary/docker-compose/mysql/conf
  DIR_MYSQL_DATA=/home/dandelion/temporary/docker-compose/mysql/data
   
  # 这个目录里的.sql/.sh 文件会在容器启动时被扫描执行
  DIR_MYSQL_INIT_SCRIPTS=/opt/dockerdata/mysql/init
  ```

##### 3.2 redis

docker-compose.yml

```yaml
version: "3.7"

services:
  redis:
    image: redis:5
    network_mode: "${DOCKER_NETWORK}"
    container_name: "${NAME}"
    hostname: "${NAME}"
    restart: always
    command: redis-server
    # 设置密码和开启AOF
    #command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes 
    volumes:
      - "${DIR_REDIS_DATA}:/data"
    ports:
      - "${REDIS_PORT_MAPPING}:6379"
```

.env

```
DOCKER_NETWORK=bridge
NAME=redis-r1
# REDIS_VERSION=5
REDIS_PASSWORD=pass
REDIS_PORT_MAPPING=6379
DIR_REDIS_DATA=/opt/dockerdata/redis/data
```

##### 3.3 RabbitMQ

docker-compose.yml

```yaml
version: '3.7'
 
services:
  rabbit:
    image: rabbitmq:3.7.7-management
    network_mode: "${DOCKER_NETWORK}"
    container_name: "${NAME}"
    hostname: "${NAME}"
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "1024k"
        max-file: "5"
    ports:
      - "${RABBIT_PORT_MAPPING}:5672"
      - "${RABBIT_MANAGEMENT_PORT_MAPPING}:15672"
    environment:
      - "RABBITMQ_DEFAULT_VHOST=${RABBITMQ_DEFAULT_VHOST}"
      - "RABBITMQ_DEFAULT_USER=${RABBITMQ_DEFAULT_USER}"
      - "RABBITMQ_DEFAULT_PASS=${RABBITMQ_DEFAULT_PASS}"
    volumes:
      - "${DIR_RABBIT_DATA}:/var/lib/rabbitmq"
```

.env

```
# RABBIT_VERSION=3.7.7
NAME=rabbit-r1
DOCKER_NETWORK=bridge
 
RABBIT_PORT_MAPPING=5672
RABBIT_MANAGEMENT_PORT_MAPPING=15672
 
RABBITMQ_DEFAULT_VHOST=/
RABBITMQ_DEFAULT_USER=rabbit
RABBITMQ_DEFAULT_PASS=rabbit
 
DIR_RABBIT_DATA=/opt/dockerdata/rabbitmq/data
```

##### 3.4 MongoDB

docker-compose.yml

```yaml
version: '3.7'
 
services:
  mongo:
    image: 'mongo:${MONGO_VERSION}'
    network_mode: "${DOCKER_NETWORK}"
    container_name: "${NAME}"
    hostname: "${NAME}"
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "1024k"
        max-file: "5"
    environment:
      - "MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE}"
      - "MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}"
      - "MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}"
    volumes:
      - "${DIR_MONGO_DATA}:/data/db"
      - "${DIR_MONGO_INIT_SCRIPTS}:/docker-entrypoint-initdb.d/"
    ports:
      - "${MONGO_PORT_MAPPING}:27017"
    #这是覆盖掉默认启动命令让mongo不用认证。 如果用这个命令启动上边的超级用户配置要先删掉，不然启动报错
    #command: ["mongod","--noauth"]
```

.env

```
NAME=mongo
DOCKER_NETWORK=bridge
 
MONGO_VERSION=latest
MONGO_PORT_MAPPING=27017
MONGO_INITDB_DATABASE=db1
MONGO_INITDB_ROOT_USERNAME=root
MONGO_INITDB_ROOT_PASSWORD=root
 
DIR_MONGO_DATA=/opt/dockerdata/mongo/data
 
# 这个目录里的.js/.sh 文件会在容器启动时被扫描执行
DIR_MONGO_INIT_SCRIPTS=/opt/dockerdata/mongo/init
```

##### 3.5 Tomcat

docker-compose.yml

```yaml
version: '3.7'
 
services:
  tomcat:
    image: "tomcat:${TOMCAT_VERSION}"
    network_mode: "${DOCKER_NETWORK}"
    container_name: "${NAME}"
    hostname: "${NAME}"
    restart: always
    #容器内存限制、空间限制、CPU资源限制。
    #mem_limit: 1024m
    #memswap_limit: 1024m
    #cpu_quota: 30000
    logging:
      driver: "json-file"
      options:
        max-size: "1024k"
        max-file: "5"
    environment:
      - "TZ=Asia/Shanghai"
      #- JAVA_OPTS=
      #- CATALINA_OPTS=
    volumes:
      - "${DIR_TOMCAT_WEBAPPS}:/usr/local/tomcat/webapps"
      - "${DIR_TOMCAT_LOGS}:/usr/local/tomcat/logs"
      # 不能映射配置文件，启动时会找不到配置报错。想映射的话先起一个临时的tomcat然后把配置复制出来再映射
      # - "${DIR_TOMCAT_CONF}:/usr/local/tomcat/conf"
    ports:
      - "${TOMCAT_PORT_MAPPING}:8080"
```

.env

```
NAME=tomcat9
DOCKER_NETWORK=bridge
 
TOMCAT_VERSION=9.0
TOMCAT_PORT_MAPPING=8080
 
DIR_TOMCAT_WEBAPPS=/opt/dockerdata/tomcat9/webapps
DIR_TOMCAT_LOGS=/opt/dockerdata/tomcat9/logs
#DIR_TOMCAT_CONF=/opt/dockerdata/tomcat9/conf
```

##### 3.6 mysql+redis

docker-compose.yml

```yml
version: '3.7'
services:
  mysql:
    image: "mysql:${MYSQL_VERSION}"
    container_name: "${MYSQL_CONTAINER_NAME}"
#    network_mode: "${MYSQL_NETWORK_MODE}"
#    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_PASSWORD}"
    volumes:
      - "${MYSQL_DIR_CONF}:/etc/mysql/conf.d"
      - "${MYSQL_DIR_DATA}:/var/lib/mysql"
    ports:
      - "${MYSQL_PORT}:3306"
    networks:
      - backend
  redis:
    image: "redis:${REDIS_VERSION}"
#    network_mode: "${REDIS_NETWORK_MODE}"
#    restart: always
    container_name: "${REDIS_CONTAINER_NAME}"
    command: redis-server /etc/redis/redis.conf
    volumes:
      - "${REDIS_DIR_CONF}:/etc/redis/redis.conf"
      - "${REDIS_DIR_DATA}:/data"
    ports:
     - "${REDIS_PORT}:6379"
    networks:
      - backend
networks:
  backend:
```

.env

```properties
MYSQL_PORT=50000
MYSQL_PASSWORD=mysql
MYSQL_VERSION=5.7.28
MYSQL_CONTAINER_NAME=mysql
MYSQL_DIR_CONF=/data/container/compose/mysql/conf
MYSQL_DIR_DATA=/data/container/compose/mysql/data
MYSQL_NETWORK_MODE=bridge
REDIS_PORT=50001
REDIS_VERSION=4.0.14
REDIS_NETWORK_MODE=bridge
REDIS_DIR_CONF=/data/container/compose/redis/conf/redis.conf
REDIS_DIR_DATA=/data/container/compose/redis/data
REDIS_CONTAINER_NAME=redis
```

