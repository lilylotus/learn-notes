###### docker 运行是限制

```bash
# This (size) will allow to set the container rootfs size to 120G at creation time
$ docker run -it --storage-opt size=120G fedora /bin/bash

# -v 挂载 volume， -w 命令在指定目录中执行， --read-only 只读方式挂载
$ docker  run [--read-only]  -v `pwd`:`pwd` -w `pwd` -i -t  ubuntu pwd

# 指定网络， --network
$ docker run -itd --network=my-net [--ip=10.10.9.75] busybox

# 挂载下级容器 volume (--volumes-from)
$ docker run --volumes-from 12345 --volumes-from  3453:ro -it ubuntu pwd

# 挂载本地设备 (--device), 还可以在挂载后面加上 (read,write,mkno) :rwmss
$ docker run --device=/dev/sdc:/dev/xvdc \
			--device=/dev/sdd \
			--device=/dev/zero:/dev/nlo \
			-it ubuntu ls -l /dev/{xvdc,sdd,nulo}

# 限制容器， (--ulimit) <type>=<soft limit>[:<hard limit>]
$ docker run -it --ulimit nofile=1024:1024 debian sh -c "ulimit -n"
$ docker run -d -u daemon --ulimit nproc=3 busybox tops
# nproc is designed by Linux to set the maximum number of processes available to a user, not to a container. For example, start four containers with daemon user

# 内存限制 (-m, --memory) [b,k,m,g 最小 4 M]
$ docker run -m 1G ubuntu # 能使用的内存大小 1G ，交换空间为 1G， 总 2G

# 限制交换空间大小 (--memory-swap) [内存 + 交换空间 大小，必须比内存大] (若为 -1 不限制大小)
$ docker run -m 1G --memory-swap 3G ubuntu # 此时，内存为 1G， 交换为 2G， 总 3G
```



###### 内存限制

```bash
# Dockerfile
FROM ubuntu:18.04
RUN apt-get update && apt-get install -y net-tools htop stress

$ docker build -t ustress .
$ docker run -it --rm -m 300M --memory-swap -1 ustress /bin/bash # 没有现象 swap 内存
$ stress --vm 1 --vm-bytes 500M
PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND                 2181 root      20   0  520240 218936    276 D  34.2  5.4   0:15.53 stress
# 这就会产生 VIRT 虚拟内存为 500M， 而真实的内存在 300M 左右徘徊

$ docker run -it --rm -m 300M --memory-swap 300M ustress /bin/bash
stress: info: [11] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
stress: FAIL: [11] (415) <-- worker 12 got signal 9
stress: WARN: [11] (417) now reaping child worker processes
stress: FAIL: [11] (451) failed run completed in 0s
# 此次因为没有虚拟内存，导致直接进程直接被 OOM kill 了
```



###### <font color="red">docker 在内存限制是报错：</font>

>  WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.

```bash
编辑 /etc/default/grub

GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

$ sudo update-grub
```



