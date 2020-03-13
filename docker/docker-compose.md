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

