## jdk 线程 dump

```bash
$ jstack -l <pid> > jdk-stack.txt
```

[Java 线程堆栈分析工具 （IBM Thread and Monitor Dump Analyzer for Java (TMDA)）](https://www.ibm.com/support/pages/ibm-thread-and-monitor-dump-analyzer-java-tmda)

## jdk 内存 dump

```bash
$ jmap -dump:format=b,file=<filename> <pid>
```

[Java 内存 dump 分析工具 (Memory Analyzer (MAT))](https://www.eclipse.org/mat/)

> 修改启动 jdk11 支持配置 MemoryAnalyzer.ini 文件
>
> 在 `-startup` 参数前添加
> -vm
> C:/kits/Java/jdk-11.0.11/bin/javaw.exe

