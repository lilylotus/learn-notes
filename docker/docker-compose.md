#### 一. 安装

```bash
wget -O https://github.com/docker/compose/releases/download/1.25.3/docker-compose-Linux-x86_64

curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

#### Networking In Compose

`docker-compose` 使用的 `version` 版本号。[docker-compose 官方文档](https://docs.docker.com/compose/compose-file/)  [docker-compose 网络配置文档](https://docs.docker.com/compose/networking/)

[docker-compose v3 文档说明](https://docs.docker.com/compose/compose-file/compose-file-v3)

| **Compose file format** | **Docker Engine release** |
| :---------------------- | :------------------------ |
| 3.8                     | 19.03.0+                  |
| 3.7                     | 18.06.0+                  |
| 3.6                     | 18.02.0+                  |
| 3.5                     | 17.12.0+                  |

默认情况下，Compose 会为应用设置单个网络。服务的每个容器都加入默认网络，并且都可以被该网络上的其他容器访问，并且可以在与容器名称相同的主机名下被发现。

> 注意：您的应用程序网络指定一个基于“项目名称”的名称，该名称基于其所在目录的名称。您可以使用 `--project-name` 标志或 `COMPOSE_PROJECT_NAME` 环境变量来覆盖项目名称。

示例：

```yaml
# 该文件在 myapp 的目录中
version: "3.8"
services:
  web:
    build: .
    ports:
      - "8000:8000"
  db:
    image: postgres
    ports:
      - "8001:5432"
```

当运行命令 `docker-compose up` ，将会发生如下事情：
1. 一个叫 `myapp_default` 网络被创建
2. 一个容器使用 `web` 的配置被创建，它使用 `web` 名称加入 `myapp_default` 网络。
3. 一个容器使用 `db` 的配置被创建，它使用 `db` 名称加入 `myapp_default` 网络。

> 注意： In v2.1+, overlay networks are always attachable
> 从 Compose 文件格式 2.1 开始，overlay networks （覆盖网络） are always created as attachable（可连接的），and this is not configurable. This means that standalone containers can connect to overlay networks.
> 从 Compose 文件格式 3.x 开始，可以选择配置 attachable 属性为 false

现在每个 容器都可以查找主机名 `web` / `db` 然后得到恰当的容器的 IP 地址。例如： `web` 的应用代码可以通过 URL `postgres://db:5432` 连接然后开始使用 Postgres 数据库。
十分要注意的是在 `HOST_PORT` 和 `CONTAINER_PORT` 之间的区别。在上面的示例中，`HOST_PORT` 是 `8001`，容器的 `CONTAINER_PORT` 是 `5432` （postgres 默认的）。网络的服务到服务的通信使用 `CONTAINER_PORT`。当 `HOST_PORT` 被定义，服务也可以在群（swarm）外访问。
如 `web` 容器，使用连接字符串连接 `db` 可能像 `postgres://db:5432`，在物理主机连接字符串就如 `postgres://{DOCKER_IP}:8001`

#####  Update containers

如果对服务（service）的配置作了改变，运行 `docker-compose up` 去更新它，老的容器会被移除掉，新的一个会使用不同的 IP 地址但是相同的名称加入网络。运行中的容器可以查找主机名来连接到新的地址，但是旧的地址停止工作。

如果有任何容器打开了到旧容器的连接，则它们将被关闭。容器有责任检测这种情况，再次查找名称并重新连接。

##### Link

```yaml
version: "3.8"
services:
  web:
    build: .
    links:
      - "db:database"
  db:
    image: postgres
```

链接 （Link）允许您定义额外的别名，通过该别名可以从另一个服务访问服务。不需要它们就可以使服务进行通信-默认情况下，任何服务都可以以该服务的名称访问任何其他服务。上面示例，`web` 可以使用主机名 `db` 和 `database` 访问  `db` 容器。

##### Multi-host networking （多主机联网）

将 Compose 应用程序部署到 Swarm 集群时，可以使用内置的覆盖 (`overlay`) 驱动程序来启用容器之间的多主机通信，而无需更改Compose文件或应用程序代码。

###### Specify custom networks (指定自定义网络)

代替使用默认的应用网络，可以自定属于自己的网络使用顶级的 `network` 关键字。这使您可以创建更复杂的拓扑 (topologies) 并指定自定义网络驱动程序和选项。还可以使用它将服务连接到不受 Compose 管理的外部创建的网络。

每个服务都可以使用服务级 `network` 关键字指定要连接的网络，该网络是在顶级 `network` 关键字下引用条目的名称的列表。

这是一个定义两个自定义网络的示例 Compose 文件。 `proxy` 服务与 `db` 服务是隔离的，因为它们不共享公共网络 - 只有 `app` 可以与两者通信。

```yaml
version: "3.8"
services:

  proxy:
    build: ./proxy
    networks:
      - frontend
  app:
    build: ./app
    networks:
      - frontend
      - backend
  db:
    image: postgres
    networks:
      - backend

networwks:
  frontend:
    # Use a  custom driver
    driver: custom-driver-1
  backend:
    # Use a custom driver which takes special option
    driver: custom-driver-2
    driver_opts:
      foo: "1"
      bar: "2"

```

通过为每个连接的网络设置 `ipv4_address` 或 `ipv6_address`，可以为网络配置静态IP地址。也可以为网络指定一个自定义名称（从 3.5 版开始）

```yaml
version: "3.5"
networks:
  frontend:
    name: custom_frontend
    driver: custom-driver-1
```

##### Configure the default network

除了（或同时）指定自己的网络，您还可以通过在 `networks` 关键字以下的 `default` 命名的位置定义一个条目来更改应用程序范围默认网络的设置

```yaml
version: "3"
services:
  web:
    build: .
    ports:
      - "8000:8000"
  db:
    image: postgres
networks:
  default:
    driver: custom-driver-1
```

##### Use a pre-existing network

```yaml
networks:
  default:
    external:
      name: my-pre-existing-network
```

Compose 不会尝试创建名为 `[projectname] _default` 的网络，而是查找名为 `my-pre-existing-network` 的网络并将您的应用程序的容器连接到该网络。

##### 指定 ip 地址

```yml
version: "3.7"

services:
  app:
    image: nginx:alpine
    networks:
      app_net:
        ipv4_address: 172.16.238.10
        ipv6_address: 2001:3984:3989::10
  app2:
    image: busybox:latest
    # 执行指定命令
    command: sh -c "tail -f /dev/null"
    networks:
      app_net:
        ipv4_address: 172.16.238.20

networks:
  app_net:
    ipam:
      driver: default
      config:
        - subnet: "172.16.238.0/24"
        - subnet: "2001:3984:3989::/64"
```



#### 二. 命令使用

> 通常使用步骤
>
> 1. 定义好 *Dockerfile* 稍后可以在任意地方复制
> 2. 定义 *docker-compose.yaml* 文件，配置好容器运行的步骤
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
7.1 使用已有的网络
networks:
  backend:
    external:
      name: exist-network
7.2 使用自定义网络
networks:
  backend:
    driver: bridge
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

## volumes 绑定

```yaml
version: "3.9"

volumes:
  resources:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /volumes
  mysql:
    driver: local
  redis:
    driver: local
      
services:
  ubuntu:
    image: ubuntu:22.04
    container_name: ubuntu
    restart: always
    volumes:
      - resources:/mnt/data

  mariadb:
    image: mariadb:10.6
    container_name: mariadb
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=mariadb
      - MYSQL_USER=mariadb
      - MYSQL_PASSWORD=mariadb
      - MYSQL_DATABASE=mariadb
    command: ["--max-allowed-packet=128M", "--innodb-log-file-size=64M"]
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-u", "root", "--password=mariadb"]
      interval: 10s
      timeout: 5s
      retries: 5
    volumes:
      - mysql:/var/lib/mysql
      
  redis:
    image: redis:6
    container_name: redis
    restart: always
    command: ["--databases", "1"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    volumes:
      - redis:/data
```

