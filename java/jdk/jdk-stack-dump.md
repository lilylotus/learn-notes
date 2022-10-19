## java 线程堆栈信息 dump

```bash
$ jstack -l <pid> > jdk-stack.txt
```

[Java 线程堆栈分析工具 （IBM Thread and Monitor Dump Analyzer for Java (TMDA)）](https://www.ibm.com/support/pages/ibm-thread-and-monitor-dump-analyzer-java-tmda)

1. 某个 Java 进程中最耗费 CPU 的 Java 线程 : `ps -ef | grep mrf-center | grep -v grep`
2. 线程 id 转 16 进制： `printf "%x\n" <pid>`
3. jstack 找出占用线程：`jstack <pid> | grep 54ee`

## java 内存 dump

```bash
$ jmap -dump:format=b,file=<filename> <pid>

jmap -dump:[live,]format=b,file=jmap.bin <pid>
```

- `live` 参数是可选的，如果指定，则只转储堆中的活动对象；如果没有指定，则转储堆中的所有对象。
- `format=b` 表示以hprof二进制格式转储Java堆的内存。
- `file=<filename>` 用于指定快照dump文件的文件名。

[Java 内存 dump 分析工具 (Memory Analyzer (MAT))](https://www.eclipse.org/mat/)

> 修改启动 jdk11 支持配置 MemoryAnalyzer.ini 文件
>
> 在 `-startup` 参数前添加
> -vm
> C:/kits/Java/jdk-11.0.11/bin/javaw.exe

可选参数 optional：`jmap [option] <pid>`

- `-heap`： to print java heap summary

## jdk 运行信息 jinfo
