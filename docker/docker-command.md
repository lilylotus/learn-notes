#### 一.  docker 命令解析

```bash
attach      Attach local standard input, output, and error streams to a running container
build       Build an image from a Dockerfile
commit      Create a new image from a container's changes
cp          Copy files/folders between a container and the local filesystem
create      Create a new container
diff        Inspect changes to files or directories on a container's filesystem
events      Get real time events from the server
exec        Run a command in a running container
export      Export a container's filesystem as a tar archive
history     Show the history of an image
images      List images
import      Import the contents from a tarball to create a filesystem image
info        Display system-wide information
inspect     Return low-level information on Docker objects
kill        Kill one or more running containers
load        Load an image from a tar archive or STDIN
login       Log in to a Docker registry
logout      Log out from a Docker registry
logs        Fetch the logs of a container
pause       Pause all processes within one or more containers
port        List port mappings or a specific mapping for the container
ps          List containers
pull        Pull an image or a repository from a registry
push        Push an image or a repository to a registry
rename      Rename a container
restart     Restart one or more containers
rm          Remove one or more containers
rmi         Remove one or more images
run         Run a command in a new container
save        Save one or more images to a tar archive (streamed to STDOUT by default)
search      Search the Docker Hub for images
start       Start one or more stopped containers
stats       Display a live stream of container(s) resource usage statistics
stop        Stop one or more running containers
tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
top         Display the running processes of a container
unpause     Unpause all processes within one or more containers
update      Update configuration of one or more containers
version     Show the Docker version information
wait        Block until one or more containers stop, then print their exit codes
```



#### 二. 具体的命令解释

1. docker 运行容器命令 [**docker run**]

   ```bash
   docker run \
   -d \ # 以后台的方式运行
   -i \ # 交互式终端，一般使用 -it
   -t \ # 分配一个 tty
   -v \ # 挂在本地卷到运行容器
   --name \ # 指定容器运行时的名称
   --rm \ # 在容器退出时自动删除
   -p # 小写 p 指定端口映射关系
   -P # 随机映射端口到指定暴露的端口
   
   # 示例
   docker run -d \
   --name mysql \
   --rm \
   -v /data/conf:/etc/mysql/mysql.conf.d \
   -p 43306:3306 \
   mysql:5.7.20
   ```

2. 容器运行起来后的操作

   - *docker attach* 依附在正在运行容器
     `docker attach aa/[容器名称]`

   - *dockers exec* 在运行的容器上运行一条命令
     `docker exec aa[容器 ID/容器名称] /bin/bash -c 'echo "hello docker exec" > /root/exec.txt'`

     ```bash
     -d # 以在后台的方式运行命令
     -i # 以和容器交互的方式运行命令
     -t # 分配一个新的 tty 终端
     
     docker exec -it ubuntu /bin/bash
     docker exec -d ubuntu /bin/bash -c 'echo "hello docker exec" > /root/exec.txt
     ```

   - *docker cp* 在容器和客户端之间复制文件

     ```bash
     docker cp [容器名称/容器 ID]:路径 客户端路径
     docker cp 客户端文件路径 [容器名称/容器 ID]:路径
     
     # 注意： 多次复制同意文件是覆盖操作
     
     # 示例
     docker cp aa:/root/exec.txt .
     docker cp new.txt aa:/root
     ```

   - *docker top* 查看容器正在运行的程序

     ```bash
     docker top mysql-master
     ```

   - 查看容器状态

     ```bash
     1. docker stats mysql # 查看运行的内存、cpu 等信息
     2. docker logs # 查看日志信息
     	-f # 跟随着日志的输出信息
     	-t # 更新展示日志的间隔时间
     	docker logs -f mysql
     3. docker inspect mysql # 查看容器基础信息
     4. docker ps [-q|-a] # 查看正在运行的容器列表
     5. docker port mysql # 查看端口占用情况
     ```

   - 运行容器控制操作

     ```bash
     1. docker start mysql # 启动已经正常停止的容器
     2. docker stop mysql # 停止容器
     3. docker restart mysql # 关闭在启动容器
     ```

   - 备份和恢复镜像

     ```bash
     备份：
     docker save mysql -o mysql.tar
     
     恢复：
     docker load -i mysql.tar
     ```

   - 镜像和容器的删除

     ```bash
     docker rm (容器 ID/容器名称)
     docker rmi (镜像 ID/镜像名称)
     ```
     
- 镜像构建
  
     ```bash
     docker commit 
      -a, --author string  Author (e.g., "John Hannibal Smith <hannibal@a-team.com>")
       -m, --message string   Commit message
       -p, --pause            Pause container during commit (default true)
     ```
     
     
     
#### 三. docker 的镜像构建 *dockerfile*

     ```bash
     docker built -t test/myapp . # 注意最后的 . ,表示当前目录
     ```
     
     - *dockerfile 的格式*
     
       ```bash
       FROM ImageName [必须是在首行]
       
       1. RUN
       	RUN <command> (shell form, the command is run in a shell, which by default is /bin/sh -c on Linux or cmd /S /C on Windows)
       	RUN ["executable", "param1", "param2"] (exec form)
       
       # RUN [ "sh", "-c", "echo $HOME" ]
       
       2. CMD # 注意 CMD 仅可以在 dokerfile 出现一次，多个仅最后一个生效
       CMD ["executable","param1","param2"]
       	(exec form, this is the preferred form)
       CMD ["param1","param2"]
       	(as default parameters to ENTRYPOINT)
       CMD command param1 param2
       	(shell form)
       
       3. EXPOSE <port> [<port>/<protocol>...] # 暴露端口
       EXPOSE 80/udp
       EXPOSE 80
       # docker run -p 80:80/tcp 80:80/udp ... 这个要写两遍
       
       4. ADD
       ADD [--chown=<user>:<group>] <src>... <dest>
       ADD [--chown=<user>:<group>] ["<src>",... "<dest>"]
       (this form is required for paths containing whitespace)
       
       5. COPY
       COPY [--chown=<user>:<group>] <src>... <dest>
       COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
       (this form is required for paths containing whitespace)
       
       6. ENTRYPOINT
       ENTRYPOINT ["executable", "param1", "param2"] (exec form, preferred)
       ENTRYPOINT command param1 param2 (shell form)
       
       # 注意： CMD 可以被外边命令替换， ENTRYPOINT 不会被外命令替换，若要替换加 --entrypoint
       
       7. VOLUME # 挂在卷
       VOLUME ["/data"]
       ```
     
       **dockerfile 至少要存在 CMD 或 ENTRYPOINT 其中一个**
     
       - ENTRYPOINT 是在容器可执行时被定义的
       - CMD 时作为 ENTRYPOINT 的参数或者在容器启动时执行
       - CMD 可以被容器执行的外来命令替换掉

#### 四. docker 网络 weave

```bash
1. 启动 weave 会在 docker 中启动一个容器
	# weave launch [要链接的 docker host ip 地址]
	# weave launch 10.10.37.119
2. 停止 weave
	# weave stop
3. weave 创建一个容器
	# eval $(weave env)
		其作用是将后续的 docker 命令发给 weave proxy 处理。
		如果要恢复之前的环境，可执行 eval $(weave env --restore)
	# docker run --name box01 -itd busybox

4. 两机互联
	host1: 10.10.37.118
		# weave launch
		# eval $(weave env)
		# docker run --name box01 --rm -itd busybox
		# docker exec -it box01 ping ubox01
			> PING ubox01 (10.44.0.0): 56 data bytes
	host2: 10.10.37.119
		# weave launch 10.10.37.118
		# eval $(weave env)
		# docker run --name ubox01 --rm -itd busybox
		# docker exec -it ubox01 ping box01
			> PING box01 (10.32.0.1): 56 data bytes
```

