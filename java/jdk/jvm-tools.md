# jdk 自带检查工具

- jps -- 虚拟机进程查看工具

- jstat -- 虚拟机统计监视工具

- jinfo -- 虚拟机配置信息工具

- jmap -- 虚拟机内存映象工具

- jhat -- 虚拟机HeapDump分析工具

- jstack -- java堆栈跟踪工具

- Jconsole和VisualVM

- - visualVM分析OutOfMemoryError异常

## jps - 虚拟机进程查看工具

```bash
$ jsp -l
```

##  jstat – 虚拟机统计监视工具

```bash
# 格式：jstat [option]  lvmid  interval  count
$ jstat -gc <pid> 250 20
# 每 250 毫秒查询一次进程垃圾收集状况，一共查询 20 次
```

##  jinfo – 虚拟机配置信息工具

```bash
# 格式 jinfo [option] <pid>

$ jinfo -sysprops 1248
# 打印 java 系统属性信息

```

##  jmap – 虚拟机内存映象工具

```bash
# dump jvm 运行内存信息
$ jmap -dump:format=b,file=jvm-dump.bin <pid>
```

##  jhat – 虚拟机 HeapDump 分析工具

```bash
$ jhat <jmap dump file>
```

##  jstack – 堆栈跟踪工具

```bash
$ jstack -l <pid>
```

