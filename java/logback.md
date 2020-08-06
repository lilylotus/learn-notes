#### logback 引入依赖

```java
gradle -> implementation "ch.qos.logback:logback-classic:1.2.3"
```

#### logback 配置

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
官方推荐使用的 xml 名字的格式为：logback-spring.xml 而不是 logback.xml
带 spring 后缀的可以使用 <springProfile> 这个标签
logback 中一共有 5 种有效级别，分别是 TRACE、DEBUG、INFO、WARN、ERROR，优先级依次从低到高

filter -> ch.qos.logback.classic.filter.LevelFilter -> 按照日志 level 来过滤日志，仅过滤配置的 level 日志记录
filter -> ch.qos.logback.classic.filter.ThresholdFilter -> 处理大于等于 level 的日志，小于 level 的日志抛弃
-->
<configuration debug="false" scan="true" scanPeriod="30 seconds">

    <timestamp key="BY_HOUR" datePattern="yyyyMMddHH"/>
    <timestamp key="BY_DAY" datePattern="yyyy-MM-dd"/>
    <property name="LOG_DIR" value="D:/logger/spring" />

    <!-- 普通的日志窗口输出 -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <!-- 对日志进行格式化 -->
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%xEx%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>

    <!-- 文件日志输出 -->
    <appender name="FILE" class="ch.qos.logback.core.FileAppender">
        <file>${LOG_DIR}/file/${BY_DAY}/logback-file-${BY_HOUR}.log</file>
        <append>true</append>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%xEx%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>

    <!-- 文件滚动日志基于时间的输出 -->
    <appender name="ROLL_TIME" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${LOG_DIR}/time/%d{yyyyMMdd}/logback-rolling-time-%d{yyyyMMddHH}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
            <totalSizeCap>10GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%xEx%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>

    <!-- 文件输出基于文件大小和时间 -->
    <appender name="ROLL_SIZE_TIME" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_DIR}/size-time/logback-size-time.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
            <fileNamePattern>${LOG_DIR}/size-time/%d{yyyyMMdd}/logback-size-time-%d{yyyyMMddHH}-%i.log</fileNamePattern>
            <maxFileSize>10MB</maxFileSize>
            <maxHistory>60</maxHistory>
            <totalSizeCap>10GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%xEx%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>

    <appender name="ROLLING_INFO" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_DIR}/info/logback-info.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
            <fileNamePattern>${LOG_DIR}/info/%d{yyyyMMdd}/logback-info-%d{yyyyMMddHH}-%i.log</fileNamePattern>
            <maxFileSize>10MB</maxFileSize>
            <maxHistory>60</maxHistory>
            <totalSizeCap>10GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%xEx%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 NEUTRAL ACCEPT DENY -->
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>INFO</level>
            <onMatch>ACCEPT</onMatch>
            <onMismatch>DENY</onMismatch>
        </filter>
    </appender>

    <appender name="ROLLING_WARN" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_DIR}/warn/logback-warn.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
            <fileNamePattern>${LOG_DIR}/warn/%d{yyyyMMdd}/logback-warn-%d{yyyyMMddHH}-%i.log</fileNamePattern>
            <maxFileSize>10MB</maxFileSize>
            <maxHistory>60</maxHistory>
            <totalSizeCap>10GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%xEx%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 NEUTRAL ACCEPT DENY -->
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>WARN</level>
            <onMatch>ACCEPT</onMatch>
            <onMismatch>DENY</onMismatch>
        </filter>
    </appender>

    <appender name="ROLLING_ERROR" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_DIR}/error/logback-error.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
            <fileNamePattern>${LOG_DIR}/error/%d{yyyyMMdd}/logback-error-%d{yyyyMMddHH}-%i.log</fileNamePattern>
            <maxFileSize>10MB</maxFileSize>
            <maxHistory>60</maxHistory>
            <totalSizeCap>10GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%xEx%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 NEUTRAL ACCEPT DENY -->
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>ERROR</level>
            <onMatch>ACCEPT</onMatch>
            <onMismatch>DENY</onMismatch>
        </filter>
    </appender>

    <!-- 文件输出基于窗口滚动 -->
    <appender name="WIND" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_DIR}/wind/logback-wind.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
            <fileNamePattern>${LOG_DIR}/wind/%d{yyyyMMdd}/logback-wind-%i.log</fileNamePattern>
            <minIndex>1</minIndex>
            <maxIndex>20</maxIndex>
        </rollingPolicy>
        <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
            <maxFileSize>10MB</maxFileSize>
        </triggeringPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%xEx%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>

    <!-- additivity 为 false 则子 Logger 只会在自己的 appender 输出，不会在 root 中输出 -->
    <!--<logger name="cn.nihility" level="DEBUG" addtivity="false" />
    <logger name="org.springframework.jdbc.core.JdbcTemplate" level="DEBUG" addtivity="false" />-->

    <root level="DEBUG">
        <appender-ref ref="CONSOLE" />
        <appender-ref ref="FILE" />
        <appender-ref ref="ROLL_TIME" />
        <appender-ref ref="ROLL_SIZE_TIME" />
        <appender-ref ref="ROLLING_INFO" />
        <appender-ref ref="ROLLING_WARN" />
        <appender-ref ref="ROLLING_ERROR" />
        <appender-ref ref="WIND" />
    </root>
</configuration>
```

#### Springboot logback 配置

```xml
<!-- 添加 -->

<!--application.yml 传递参数 -->
<!-- log 文件生成目录 -->
<springProperty scope="context" name="logdir" source="resources.logdir"/>
<!-- 应用名称 -->
<springProperty scope="context" name="appname" source="resources.appname"/>
<!-- 项目基础包 -->
<springProperty scope="context" name="basepackage" source="resources.basepackage"/>

<!-- 开发环境-->
<springProfile name="dev">
    <root level="INFO">
        <appender-ref ref="consoleLog"/>
    </root>
    <!--
      additivity 是子 Logger 是否继承父 Logger 的输出源（appender） 的标志位
      在这里 additivity 配置为 false 代表如果 ${basepackage} 中有 INFO 
      级别日志则子 looger 打印 root 不打印
    -->
    <logger name="${basepackage}" level="DEBUG" additivity="false">
        <appender-ref ref="consoleLog"/>
        <appender-ref ref="fileLog"/>
    </logger>
</springProfile>
```

#### 过滤日志级别配置

需要对日志的打印要做一些范围的控制的时候，通常都是通过为各个 Appender 设置不同的 Filter 配置来实现。
在 `Logback` 中自带了两个过滤器实现：`ch.qos.logback.classic.filter.LevelFilter`和`ch.qos.logback.classic.filter.ThresholdFilter`，可以根据需要来配置一些简单的过滤规则

##### LevelFilter

`ch.qos.logback.classic.filter.LevelFilter` 过滤器的作用是通过比较日志级别来控制日志输出

`NEUTRAL` `ACCEPT` `DENY` 这几个过滤配置

```xml
<appender name="ERROR_APPENDER" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/error.log</file>ds
    <filter class="ch.qos.logback.classic.filter.LevelFilter">
        <level>ERROR</level>
        <onMatch>ACCEPT</onMatch>
        <onMismatch>DENY</onMismatch>
    </filter>
    <encoder>
        <pattern>%-4relative [%thread] %-5level %logger{30} - %msg%n</pattern>
    </encoder>
</appender>
```

##### ThresholdFilter

`ch.qos.logback.classic.filter.ThresholdFilter` 只记录 LEVEL 及以上级别的控制

```xml
<appender name="WARN_APPENDER" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/warn_error.log</file>
    <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
        <level>WARN</level>
    </filter>
    <encoder>
        <pattern>%-4relative [%thread] %-5level %logger{30} - %msg%n</pattern>
    </encoder>
</appender>
```

