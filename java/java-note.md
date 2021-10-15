### JDK 时区问题

JVM 读取时区文件顺序依次为：`$TZ` > `/etc/timezone` > `/etc/localtime` > `默认GMT`

> **默认 GMT 说明**：java.util.TimeZone 类中 getDefault 方法的源代码显示，最终是会调用sun.util.calendar.ZoneInfo 类的 getTimeZone 方法。这个方法为需要的时间区域返回一个作为 ID 的 String 参数。这个默认的时间区域 ID 是从 user.timezone (system) 属性那里得到。如果 user.timezone 没有定义，它就会尝试从 user.country 和 java.home (System) 属性来得到 ID。 如果它没有成功找到一个时间区域 ID，它就会使用一个 "fallback"  的 GMT 值。换句话说， 如果它没有计算出你的时间区域 ID，它将使用 GMT 作为你默认的时间区域。

<font color="red">［推荐］Java 程序在发布后的启动脚本中，可通过 JVM 参数指定应用的时区、编码, 比如 `java -Duser.timezone=Asia/Shanghai -Dfile.encoding=utf8 DateTest` </font>

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



### java 运行，网络仅使用 ipv4 参数

```bash
java -Djava.net.preferIPv4Stack=true xxx
```

