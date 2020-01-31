#### logback 引入依赖

```java
gradle ->
implementation "ch.qos.logback:logback-classic:1.2.3"
```

#### logback 配置

```xml
<!--
官方推荐使用的 xml 名字的格式为：logback-spring.xml 而不是 logback.xml
带 spring 后缀的可以使用 <springProfile> 这个标签
logback 中一共有 5 种有效级别，分别是 TRACE、DEBUG、INFO、WARN、ERROR，优先级依次从低到高

filter -> ch.qos.logback.classic.filter.LevelFilter -> 按照日志 level 来过滤日志，仅过滤配置的 level 日志记录
filter -> ch.qos.logback.classic.filter.ThresholdFilter -> 处理大于等于 level 的日志，小于 level 的日志抛弃
-->
<?xml version="1.0" encoding="UTF-8"?>
<configuration debug="false" scan="true" scanPeriod="30 seconds">

    <timestamp key="byHour" datePattern="yyyyMMddHH"/>
    <timestamp key="byDay" datePattern="yyyy-MM-dd"/>
    <property name="log_dir" value="C:/programming/idea/practice/log" />

    <!-- 普通的日志窗口输出 -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <!-- 对日志进行格式化 -->
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>

    <!-- 文件日志输出 -->
    <appender name="FILE" class="ch.qos.logback.core.FileAppender">
        <file>${log_dir}/logbackfile/${byDay}/logback-file-${byHour}.log</file>
        <append>true</append>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>

    <!-- 文件滚动日志基于时间的输出 -->
    <appender name="ROLLFILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${log_dir}/logbacktime/%d{yyyyMMdd}/logback-rollfile-%d{yyyyMMddHH}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
            <totalSizeCap>1GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>

    <!-- 文件输出基于文件大小和时间 -->
    <appender name="ROLLSIZEFILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${log_dir}/logbacksizetime/logback-size.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <!-- each file should be at most 100MB, keep 60 days worth of history, but at most 20GB -->
            <fileNamePattern>${log_dir}/logbacksizetime/%d{yyyyMMdd}/logback-size-time-%d{yyyyMMddHH}-%i.log</fileNamePattern>
            <maxFileSize>2MB</maxFileSize>
            <maxHistory>60</maxHistory>
            <totalSizeCap>10GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>

    <!-- 文件输出基于窗口滚动 -->
    <appender name="WIND" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${log_dir}/logbackwind/logback-wind.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
            <fileNamePattern>${log_dir}/logbackwind/${byDay}/logback-wind-%i.log</fileNamePattern>
            <minIndex>1</minIndex>
            <maxIndex>20</maxIndex>
        </rollingPolicy>
        <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
            <maxFileSize>2MB</maxFileSize>
        </triggeringPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志级别过滤 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>DEBUG</level>
        </filter>
    </appender>
    
    <!-- additivity 为 false 则子 Logger 只会在自己的 appender 输出，不会在 root 中输出 -->
    <logger name="cn.nihility" level="DEBUG" addtivity="false" />
    <logger name="org.springframework.jdbc.core.JdbcTemplate" level="DEBUG" addtivity="false" />

    <root level="DEBUG">
        <appender-ref ref="CONSOLE" />
        <appender-ref ref="FILE" />
        <appender-ref ref="ROLLFILE" />
        <appender-ref ref="ROLLSIZEFILE" />
        <appender-ref ref="WIND" />
    </root>
</configuration>
```

