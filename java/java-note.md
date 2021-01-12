### 获取 jvm 总运行时间

```java
ManagementFactory.getRuntimeMXBean().getUptime()
```
---

### JAVA 远程调试

JPDA（Java Platform Debugger Architecture）是 Java 平台调试体系结构的缩写。
由 3 个规范组成，分别是 JVMTI(JVM Tool Interface)，<font color="red">JDWP</font>(Java Debug Wire Protocol)，JDI(Java Debug Interface) 。

远程调试分为主动连接调试，和被动连接调试

> 主动连接调试：服务端配置监控端口，本地 IDE 连接远程监听端口进行调试，一般调试问题用这种方式。
> 被动连接调试：本地IDE监听某端口，等待远程连接本地端口。一般用于远程服务启动不了，启动时连接到本地调试分析。

#### 主动连接调试

远程服务启动添加参数

```
-agentlib:jdwp=transport=dt_socket,address=127.0.0.1:58407,suspend=y,server=n
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=50012
```

本地 IDEA 添加 remote 启动参数

```
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=50012
```

#### 被动连接调试

远程服务启动

```
-Xdebug -Xrunjdwp:transport=dt_socket,address=127.0.0.1:8000,suspend=y
```

本地 IDEA 启动参数

```
-Xdebug -Xrunjdwp:transport=dt_socket,address=127.0.0.1:8000,suspend=y
```