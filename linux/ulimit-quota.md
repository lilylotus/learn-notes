centos7 磁盘等资源限制

`cat /proc/sys/fs/file-max ` 查看打开文件数量的限制

###### ulimit 全局配置文件 `/etc/security/limits.conf`

```bash
示例：
# hard limit for max opened files for linuxtechi user
linuxtechi       hard    nofile          4096
# soft limit for max opened files for linuxtechi user
linuxtechi       soft    nofile          1024

# hard limit for max number of process for oracle user
oracle           hard    nproc          8096
# soft limit for max number of process for oracle user
oracle           soft    nproc          4096

# hard limit for max opened files for sysadmin group
@sysadmin        hard         nofile            4096 
# soft limit for max opened files for sysadmin group
@sysadmin        soft         nofile            1024

----------------------------------------------------------------
文件格式
# <domain>        <type>  <item>  <value>
# <domain> can be:
#        - a user name
#        - a group name, with @group syntax
#        - the wildcard *, for default entry
#        - the wildcard %, can be also used with %group syntax,for maxlogin limit

#<type> can have the two values:
#        - "soft" for enforcing the soft limits
#        - "hard" for enforcing hard limits

#<item> can be one of the following:
#        - core - limits the core file size (KB)
#        - data - max data size (KB)
#        - fsize - maximum filesize (KB)
#        - memlock - max locked-in-memory address space (KB)
#        - nofile - max number of open file descriptors
#        - rss - max resident set size (KB)
#        - stack - max stack size (KB)
#        - cpu - max CPU time (MIN)
#        - nproc - max number of processes
#        - as - address space limit (KB)
#        - maxlogins - max number of logins for this user
#        - maxsyslogins - max number of logins on the system
#        - priority - the priority to run user process with
#        - locks - max number of file locks the user can hold
#        - sigpending - max number of pending signals
#        - msgqueue - max memory used by POSIX message queues (bytes)
#        - nice - max nice priority allowed to raise to values: [-20, 19]
#        - rtprio - max realtime priority
```



###### ulimit 命令

```bash
# ulimit -a -> 展示所有信息
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 15647
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 15647
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited

# ulimit -Hn -> -H 硬链接
# ulimit -Sn -> -S 软连接

-S    use the `soft' resource limit # 設定軟限制
-H    use the `hard' resource limit # 設定硬限制
-a    all current limits are reported# 顯示所有的配置。
-b    the socket buffer size # 設定socket buffer 的最大值。
-c    the maximum size of core files created # 設定core檔案的最大值.
-d    the maximum size of a process's data segment  # 設定執行緒資料段的最大值
-e    the maximum scheduling priority (`nice') # 設定最大排程優先順序
-f    the maximum size of files written by the shell and its children # 建立檔案的最大值。
-i    the maximum number of pending signals # 設定最大的等待訊號
-l    the maximum size a process may lock into memory #設定在記憶體中鎖定程序的最大值
-m    the maximum resident set size 
-n    the maximum number of open file descriptors # 設定最大可以的開啟檔案描述符。
-p    the pipe buffer size
-q    the maximum number of bytes in POSIX message queues
-r    the maximum real-time scheduling priority
-s    the maximum stack size
-t    the maximum amount of cpu time in seconds
-u    the maximum number of user processes  # 設定使用者可以建立的最大程序數。
-v    the size of virtual memory  # 設定虛擬記憶體的最大值
-x    the maximum number of file locks
```



---

**注意：** 对 EXT 系列文件系统，quota 仅能针对整个文件系统进行设计，无法对单一的目录进行磁盘配额；而在 xfs 的文件系统中，可以使用 quota 对目录进行磁盘配额。
核心必须支持 quota，centos7 默认支持 quota 功能。只对一般用户有效，因为 root 拥有全部的磁盘空间。
若启用 SELinux 功能，不是所有的目录都能设定 quota，默认 quota 仅能对 */home* 进行设定。

###### 配置 `/etc/fstab` 支持 quota 配置

```bash
/dev/mapper/centos /   xfs  defaults,usrquota,prjquota   0 0
# 添加 usrquota,prjquota
usrquota 用户， grpquota 群组，prjquota 单一目录，不能和 grpquota 同存
```

###### xfs_quota 命令

```bash
xfs_quota -x -c "command" [挂载点]
-x 专家模式，后续才能跟 -c 选项
-c 后面为命令

命令格式：xfs_quota  -x  -c  "指令"  [挂载点]
xfs_quota -x -c "limit [-ug] b[soft|hard]=N i[soft|hard]=N name"
xfs_quota -x -c "timer [-ug] [-bir] Ndays"

bsoft/bhard : block 的 soft/hard 限制值,可以加单位
isoft/ihard : inode 的 soft/hard 限制值

命令：
	print 列出主机文件系统信息
	df 	  和原来 df 命令一样，但是比原来 df 信息更加准确
	report 后必接支持 quota 的挂载点，列出 quota 的项目设置 [-u/-g/-p/-i/-b/-h] 选项

xfs_quota -x -c "limit -u bsoft=250M bhard=300M user" /lvm

$ edquota -g grp
$ edquota -u user
Filesystem                   blocks       soft       hard     inodes     soft     hard
/dev/mapper/lvm-lvm--lv01     307200     256000     307200          1        5       10

```

###### xfs_quota 内部指令

> 如果需要暂停使用quota限制或者重新启动quota时，可通过以下命令实现。另外，已经设置好的策略，不能单条删除，只能全部抹去再重新配置。
>
> - **disable** ：暂时取消 quota 的限制，但其实系统还是在计算 quota 中，只是没有管制而已。
> - **enable** ：恢复到正常管制的状态，与 disable 相互取消、启用。
> - **off** ：完全关闭 quota 的限制，使用了这个状态后，只有卸载再重新挂载才能再次启动 quota。
> - **remove** ：必须要在 off 的状态下才能执行的指令~这个 remove 可以可以“移除” quota 的限制设置。只要 remove -p 就可以了！

```bash
$ xfs_quota -x -c "disable -up" /home/
$ xfs_quota -x -c "state" /home/
$ xfs_quota -x -c "enable -up" /home/
$ xfs_quota -x -c "off -up" /home/
$ xfs_quota -x -c "state" /home/
$ xfs_quota -x -c "remove -p" /home/
$ xfs_quota -x -c "report -pibh" /home/
```

###### Quota 配置 prjquota

> projquota 不能与 grpquota 同时配置。针对目录的设置需要指定一个所谓的**专案名称、专案识别码**来规范才行，而且还需要用到两个设定档。其中，专案名称和识别码自己随意设定就可以。

```bash
$ echo "1:xiangyu.liu" >> /etc/projects
$ echo "xiangyu.liu:1" >> /etc/projid
$ xfs_quota -x -c "project -s xiangyu.liu"    #初始化专案名称
$ xfs_quota -x -c "report -pbih" /home
$ xfs_quota -x -c "limit -p bsoft=450M bhard=500M xiangyu.liu" /home  #设置
$ xfs_quota -x -c "report -pbih" /home        
$ dd if=/dev/zero of=/home/users/xiangyu.liu/test.img bs=1M count=510    #测试
```

`UUID=** /home xfs usrquota,grpquota,prjquota,defaults 0 0`