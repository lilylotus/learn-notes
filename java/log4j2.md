```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{1.} - %msg%n" />
        </Console>
        <File name="File" fileName="build/logs/spring-test.log">
            <PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{1.} - %msg%n" />
        </File>
    </Appenders>
    <Loggers>
        <Logger name="org.springframework.core" level="info" />
        <Logger name="org.springframework.util" level="warn" />
        <Root level="error">
            <AppenderRef ref="Console" />
            <AppenderRef ref="File" />
        </Root>
    </Loggers>
</Configuration>
```

注意：当和 `spring boot` 结合时，文件命名为 `log4j2-spring.xml`, 就不用在 `application.yml` 中配置
或者在 `application.yml` 中配置 `logging.config=classpath:log4j2-spring.xml`
引入 `spring boot` 依赖 `spring-boot-starter-log4j2`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- 设置 log4j2 的自身 log 级别为 WARN -->
<!-- 日志级别以及优先级排序: OFF > FATAL > ERROR > WARN > INFO > DEBUG > TRACE > ALL -->
<!-- Configuration 后面的 status，设置 log4j2 自身内部的信息输出，可以不设置，trace 时会看到 log4j2 内部各种详细输出 -->
<!-- monitorInterval: Log4j 能够自动检测修改配置 文件和重新配置本身，设置间隔秒数 -->
<configuration status="DEBUG" monitorInterval="30">

    <!--变量配置-->
    <Properties>
        <!-- [%date]日期，[%thread] 线程名，[%-5level] 级别从左显示5个字符宽度，%msg 日志消息，-->
        <!-- %n 换行符，%logger{36} 表示 Logger 名字最长36个字符 -->
        <property name="LOG_PATTERN" value="%d{yyyy-MM-dd HH:mm:ss.SSS} [%-5level] [%thread] %logger{36} - %msg%xEx%n" />
        <!-- System.setProperty("appName", "urm"); -->
        <Property name="APP_PROFILE" value="${sys:profileName}"/>
        <Property name="APP_NAME" value="${sys:appName}"/>
        <!-- 定义日志存储的路径 /${ctx:spring.application.name} -->
        <property name="FILE_PATH" value="D:/logger/${APP_NAME}/${APP_PROFILE}" />
        <property name="FILE_NAME" value="更换为你的项目名" />
    </Properties>

    <!--先定义所有的appender-->
    <appenders>
        <!-- 控制台输出配置 -->
        <console name="Console" target="SYSTEM_OUT">
            <!--输出日志的格式-->
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <!-- 只输出 level 及其以上级别的信息（onMatch），其它直接拒绝（onMismatch）-->
            <ThresholdFilter level="DEBUG" onMatch="ACCEPT" onMismatch="DENY"/>
        </console>

        <!-- 文件会打印出所有信息，这个 log 每次运行程序会自动清空，由 append 属性决定，适合临时测试用 -->
        <!-- append false 每次清空， true 附加到文件末尾 -->
        <File name="FileLog" fileName="${FILE_PATH}/file-log.log" append="false">
            <PatternLayout pattern="${LOG_PATTERN}"/>
        </File>

        <!-- 打印出 >= DEBUG 级别的信息，每次大小超过 size，则这 size 大小的日志会自动存入按年份-月份建立的文件夹下面并进行压缩，作为存档 -->
        <RollingFile name="RollingFileAll" fileName="${FILE_PATH}/rolling-file-all.log"
                     filePattern="${FILE_PATH}/$${date:yyyyMMdd}/rolling-file-all-%d{yyyyMMddHH}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <ThresholdFilter level="DEBUG" onMatch="ACCEPT" onMismatch="DENY"/>
            <Policies>
                <!-- interval, integer 型，指定两次封存动作之间的时间间隔 -->
                <!-- 需要和 filePattern 结合使用，日期格式精确到哪一位，interval 也精确到哪一个单位 -->
                <!-- %d{yyyy-MM-dd HH-mm-ss}-%i，最小的时间粒度是 ss，即秒钟 -->
                <!-- modulate, boolean型，说明是否对封存时间进行调制 -->
                <!-- modulate=true， 则封存时间将以 0 点为边界进行偏移计算。如: modulate=true，interval=4hours，
                    那么假设上次封存日志的时间为03:00，则下次封存日志的时间为 04:00， 之后的封存时间依次为 08:00，12:00，16:00 -->
                <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
                <SizeBasedTriggeringPolicy size="50 MB"/>
            </Policies>
            <!-- DefaultRolloverStrategy 属性如不设置，则默认为最多同一文件夹下 7 个文件开始覆盖 -->
            <DefaultRolloverStrategy max="20">
                <Delete basePath="${FILE_PATH}" maxDepth="2">
                    <!-- IfFileName: 匹配文件名称 -->
                    <!-- glob: 匹配2级目录深度下的以 .log.gz 结尾的备份文件 -->
                    <IfFileName glob="**/*all*.gz" />
                    <!-- IfLastModified: 匹配文件修改时间，精度要和日期滚动最小精度一致 -->
                    <!--age: 匹配超过 180 天的文件，单位D、H、M、S分别表示天、小时、分钟、秒-->
                    <IfLastModified age="1H" />
                </Delete>
            </DefaultRolloverStrategy>
        </RollingFile>

        <!-- 打印出 trace 级别的信息，每次大小超过 size，则这 size 大小的日志会自动存入按年份-月份建立的文件夹下面并进行压缩，作为存档 -->
        <RollingFile name="RollingFileTrace" fileName="${FILE_PATH}/rolling-file-trace.log"
                     filePattern="${FILE_PATH}/$${date:yyyyMMdd}/rolling-file-trace-%d{yyyyMMddHH}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Filters>
                <!-- 过滤条件有三个值：ACCEPT(接受)，DENY(拒绝)，NEUTRAL(中立)-->
                <ThresholdFilter level="TRACE" onMatch="NEUTRAL" onMismatch="DENY"/>
                <ThresholdFilter level="DEBUG" onMatch="DENY" onMismatch="NEUTRAL"/>
            </Filters>
            <Policies>
                <!-- interval, integer 型，指定两次封存动作之间的时间间隔 -->
                <!-- 需要和 filePattern 结合使用，日期格式精确到哪一位，interval 也精确到哪一个单位 -->
                <!-- %d{yyyy-MM-dd HH-mm-ss}-%i，最小的时间粒度是 ss，即秒钟 -->
                <!-- modulate, boolean型，说明是否对封存时间进行调制 -->
                <!-- modulate=true， 则封存时间将以 0 点为边界进行偏移计算。如: modulate=true，interval=4hours，
                    那么假设上次封存日志的时间为03:00，则下次封存日志的时间为 04:00， 之后的封存时间依次为 08:00，12:00，16:00 -->
                <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
                <SizeBasedTriggeringPolicy size="50 MB"/>
            </Policies>
            <!-- DefaultRolloverStrategy 属性如不设置，则默认为最多同一文件夹下 7 个文件开始覆盖 -->
            <DefaultRolloverStrategy max="20">
                <Delete basePath="${FILE_PATH}" maxDepth="2">
                    <!-- IfFileName: 匹配文件名称 -->
                    <!-- glob: 匹配2级目录深度下的以 .log.gz 结尾的备份文件 -->
                    <IfFileName glob="**/*trace*.gz" />
                    <!-- IfLastModified: 匹配文件修改时间，精度要和日期滚动最小精度一致 -->
                    <!--age: 匹配超过 180 天的文件，单位D、H、M、S分别表示天、小时、分钟、秒-->
                    <IfLastModified age="1H" />
                </Delete>
            </DefaultRolloverStrategy>
        </RollingFile>

        <!-- 打印出 debug 级别的信息，每次大小超过 size，则这 size 大小的日志会自动存入按年份-月份建立的文件夹下面并进行压缩，作为存档 -->
        <RollingFile name="RollingFileDebug" fileName="${FILE_PATH}/rolling-file-debug.log"
                     filePattern="${FILE_PATH}/$${date:yyyyMMdd}/rolling-file-debug-%d{yyyyMMddHH}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Filters>
                <!-- 过滤条件有三个值：ACCEPT(接受)，DENY(拒绝)，NEUTRAL(中立)-->
                <ThresholdFilter level="DEBUG" onMatch="NEUTRAL" onMismatch="DENY"/>
                <ThresholdFilter level="INFO" onMatch="DENY" onMismatch="NEUTRAL"/>
            </Filters>
            <Policies>
                <!-- interval, integer 型，指定两次封存动作之间的时间间隔 -->
                <!-- 需要和 filePattern 结合使用，日期格式精确到哪一位，interval 也精确到哪一个单位 -->
                <!-- %d{yyyy-MM-dd HH-mm-ss}-%i，最小的时间粒度是 ss，即秒钟 -->
                <!-- modulate, boolean型，说明是否对封存时间进行调制 -->
                <!-- modulate=true， 则封存时间将以 0 点为边界进行偏移计算。如: modulate=true，interval=4hours，
                    那么假设上次封存日志的时间为03:00，则下次封存日志的时间为 04:00， 之后的封存时间依次为 08:00，12:00，16:00 -->
                <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
                <SizeBasedTriggeringPolicy size="50 MB"/>
            </Policies>
            <!-- DefaultRolloverStrategy 属性如不设置，则默认为最多同一文件夹下 7 个文件开始覆盖 -->
            <DefaultRolloverStrategy max="20">
                <Delete basePath="${FILE_PATH}" maxDepth="2">
                    <!-- IfFileName: 匹配文件名称 -->
                    <!-- glob: 匹配2级目录深度下的以 .log.gz 结尾的备份文件 -->
                    <IfFileName glob="**/*debug*.gz" />
                    <!-- IfLastModified: 匹配文件修改时间，精度要和日期滚动最小精度一致 -->
                    <!--age: 匹配超过 180 天的文件，单位D、H、M、S分别表示天、小时、分钟、秒-->
                    <IfLastModified age="1H" />
                </Delete>
            </DefaultRolloverStrategy>
        </RollingFile>

        <!-- 打印出 info 级别的信息，每次大小超过 size，则这 size 大小的日志会自动存入按年份-月份建立的文件夹下面并进行压缩，作为存档 -->
        <RollingFile name="RollingFileInfo" fileName="${FILE_PATH}/rolling-file-info.log"
                     filePattern="${FILE_PATH}/$${date:yyyyMMdd}/rolling-file-info-%d{yyyyMMddHH}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Filters>
                <!-- 过滤条件有三个值：ACCEPT(接受)，DENY(拒绝)，NEUTRAL(中立)-->
                <!-- onMatch="ACCEPT" 匹配该级别及以上级别; onMismatch="DENY" 不匹配该级别以下的级别; >= INFO -->
                <!-- onMatch="DENY" 不匹配该级别及以上级别; onMismatch="ACCEPT" 匹配该级别以下的级别; < WARN -->
                <ThresholdFilter level="WARN" onMatch="DENY" onMismatch="NEUTRAL"/>
                <ThresholdFilter level="INFO" onMatch="ACCEPT" onMismatch="DENY"/>
            </Filters>
            <Policies>
                <!-- interval, integer 型，指定两次封存动作之间的时间间隔 -->
                <!-- 需要和 filePattern 结合使用，日期格式精确到哪一位，interval 也精确到哪一个单位 -->
                <!-- %d{yyyy-MM-dd HH-mm-ss}-%i，最小的时间粒度是 ss，即秒钟 -->
                <!-- modulate, boolean型，说明是否对封存时间进行调制 -->
                <!-- modulate=true， 则封存时间将以 0 点为边界进行偏移计算。如: modulate=true，interval=4hours，
                    那么假设上次封存日志的时间为03:00，则下次封存日志的时间为 04:00， 之后的封存时间依次为 08:00，12:00，16:00 -->
                <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
                <SizeBasedTriggeringPolicy size="50 MB"/>
            </Policies>
            <!-- DefaultRolloverStrategy 属性如不设置，则默认为最多同一文件夹下 7 个文件开始覆盖 -->
            <DefaultRolloverStrategy max="20">
                <Delete basePath="${FILE_PATH}" maxDepth="2">
                    <!-- IfFileName: 匹配文件名称 -->
                    <!-- glob: 匹配2级目录深度下的以 .log.gz 结尾的备份文件 -->
                    <IfFileName glob="**/*info*.gz" />
                    <!-- IfLastModified: 匹配文件修改时间，精度要和日期滚动最小精度一致 -->
                    <!--age: 匹配超过 180 天的文件，单位D、H、M、S分别表示天、小时、分钟、秒-->
                    <IfLastModified age="1H" />
                </Delete>
            </DefaultRolloverStrategy>
        </RollingFile>

        <!-- 打印 warn 级别的信息，每次大小超过 size，则这 size 大小的日志会自动存入按年份-月份建立的文件夹下面并进行压缩，作为存档 -->
        <RollingFile name="RollingFileWarn" fileName="${FILE_PATH}/rolling-file-warn.log"
                     filePattern="${FILE_PATH}/$${date:yyyyMMdd}/rolling-file-warn-%d{yyyyMMddHH}-%i.log.gz">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Filters>
                <!-- 过滤条件有三个值：ACCEPT(接受)，DENY(拒绝)，NEUTRAL(中立) -->
                <ThresholdFilter level="ERROR" onMatch="DENY" onMismatch="NEUTRAL"/>
                <ThresholdFilter level="WARN" onMatch="ACCEPT" onMismatch="DENY"/>
            </Filters>
            <Policies>
                <!-- interval属性用来指定多久滚动一次，默认是 1 hour -->
                <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
                <SizeBasedTriggeringPolicy size="50 MB"/>
            </Policies>
            <!-- DefaultRolloverStrategy 属性如不设置，则默认为最多同一文件夹下 7 个文件，这里设置了 20 -->
            <DefaultRolloverStrategy max="20">
                <Delete basePath="${FILE_PATH}" maxDepth="2">
                    <!-- IfFileName: 匹配文件名称 -->
                    <!-- glob: 匹配2级目录深度下的以 .log.gz 结尾的备份文件 -->
                    <IfFileName glob="**/*warn*.gz" />
                    <!-- IfLastModified: 匹配文件修改时间，精度要和日期滚动最小精度一致 -->
                    <!--age: 匹配超过 180 天的文件，单位D、H、M、S分别表示天、小时、分钟、秒-->
                    <IfLastModified age="1H" />
                </Delete>
            </DefaultRolloverStrategy>
        </RollingFile>

        <!-- 打印 error 级别的信息，每次大小超过size，则这size大小的日志会自动存入按年份-月份建立的文件夹下面并进行压缩，作为存档-->
        <RollingFile name="RollingFileError" fileName="${FILE_PATH}/rolling-file-error.log"
                     filePattern="${FILE_PATH}/$${date:yyyyMMdd}/rolling-file-error-%d{yyyyMMddHH}-%i.log.gz">
            <!--控制台只输出level及以上级别的信息（onMatch），其他的直接拒绝（onMismatch）-->
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <ThresholdFilter level="ERROR" onMatch="ACCEPT" onMismatch="DENY"/>
            <Policies>
                <!-- interval 属性用来指定多久滚动一次，默认是 1 hour-->
                <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
                <SizeBasedTriggeringPolicy size="50 MB"/>
            </Policies>
            <!-- DefaultRolloverStrategy属性如不设置，则默认为最多同一文件夹下7个文件开始覆盖-->
            <DefaultRolloverStrategy max="20">
                <Delete basePath="${FILE_PATH}" maxDepth="2">
                    <!-- IfFileName: 匹配文件名称 -->
                    <!-- glob: 匹配2级目录深度下的以 .log.gz 结尾的备份文件 -->
                    <IfFileName glob="**/*error*.gz" />
                    <!-- IfLastModified: 匹配文件修改时间，精度要和日期滚动最小精度一致 -->
                    <!--age: 匹配超过 180 天的文件，单位D、H、M、S分别表示天、小时、分钟、秒-->
                    <IfLastModified age="1H" />
                </Delete>
            </DefaultRolloverStrategy>
        </RollingFile>

        <Async name="Async">
            <AppenderRef ref="RollingFileTrace"/>
        </Async>

    </appenders>

    <!-- Logger 节点用来单独指定日志的形式，比如要为指定包下的 class 指定不同的日志级别等 -->
    <!-- 定义 logger，只有定义了 logger 并引入 appender，appender 才会生效-->
    <Loggers>
        <!-- 监控系统信息 -->
        <!-- 若是 additivity 设为 false，则子 Logger 只会在自己的 appender 里输出，而不会在父 Logger 的 appender 里输出 -->
        <!-- 过滤掉 spring 和 hibernate 的一些无用的 DEBUG 信息 -->
        <Logger name="org.springframework" level="INFO" additivity="false">
            <AppenderRef ref="Console"/>
        </Logger>
        <Logger name="org.mybatis" level="INFO" additivity="false">
            <AppenderRef ref="Console"/>
        </Logger>

        <Logger name="kl.iam" level="DEBUG"/>
        <Logger name="org.casbin" level="WARN"/>
        <Logger name="springfox.documentation" level="WARN"/>
        <Logger name="com.alibaba.nacos" level="INFO"/>
        <Logger name="com.alibaba.nacos.client.naming" level="WARN"/>
        <Logger name="com.netflix.loadbalancer" level="INFO"/>

        <Root level="ALL">
            <appender-ref ref="Console"/>
            <AppenderRef ref="FileLog"/>
            <AppenderRef ref="RollingFileAll"/>
            <AppenderRef ref="RollingFileTrace"/>
            <AppenderRef ref="RollingFileDebug"/>
            <AppenderRef ref="RollingFileInfo"/>
            <AppenderRef ref="RollingFileWarn"/>
            <AppenderRef ref="RollingFileError"/>
            <!-- Async implementation 'com.lmax:disruptor:3.4.2' -->
            <!--<AppenderRef ref="Async"/>-->
        </Root>
    </Loggers>

</configuration>
```

#### log4j2 获取 application.yml 参数

添加事件监听器，实现接口 `org.springframework.context.event.GenericApplicationListener`

```java
@Component
public class Log4j2EventListener implements GenericApplicationListener {

    private static final Logger log = LoggerFactory.getLogger(Log4j2EventListener.class);
    private static final int DEFAULT_ORDER = Ordered.HIGHEST_PRECEDENCE + 10;

    private static Class<?>[] EVENT_TYPES = {ApplicationStartingEvent.class,
        ApplicationEnvironmentPreparedEvent.class, ApplicationPreparedEvent.class,
        ContextClosedEvent.class, ApplicationFailedEvent.class};

    private static Class<?>[] SOURCE_TYPES = {SpringApplication.class, ApplicationContext.class};

    private final Environment env;

    public Log4j2EventListener(Environment env) {
        this.env = env;
    }

    @Override
    public boolean supportsEventType(ResolvableType eventType) {
        return isAssignableFrom(eventType.getRawClass(), EVENT_TYPES);
    }

    @Override
    public boolean supportsSourceType(Class<?> sourceType) {
        return isAssignableFrom(sourceType, SOURCE_TYPES);
    }

    @Override
    public int getOrder() {
        return DEFAULT_ORDER;
    }

    @Override
    public void onApplicationEvent(ApplicationEvent event) {
        if (event instanceof ApplicationEnvironmentPreparedEvent) {
            ConfigurableEnvironment envi = ((ApplicationEnvironmentPreparedEvent) event).getEnvironment();
            MutablePropertySources mps = envi.getPropertySources();
            //PropertySource<?> ps = mps.get("applicationConfigurationProperties");
            PropertySource<?> ps = mps.get("applicationConfig: [classpath:/application.yml]");
            
            String profile = envi.getActiveProfiles()[0];
            
            if (null != ps) {
                String appName = (String) ps.getProperty("spring.application.name");
                log.info("Log4j2 Get Spring ConfigurableEnvironment Property [{}] value [{}]", "spring.application.name", appName);
                if (StringUtils.isNotBlank(appName)) {
                    MDC.put("appName", appName);
                }
            }
        }

        String appName = env.getProperty("spring.application.name");
        log.info("Log4j2 Get Spring Property [{}] value [{}]", "spring.application.name", appName);
        if (StringUtils.isNotBlank(appName)) {
            MDC.put("appName", appName);
        }

        String port = env.getProperty("server.port");
        log.info("Log4j2 Get Spring Property [{}] value [{}]", "server.port", port);
        if (StringUtils.isNotBlank(port)) {
            MDC.put("port", port);
        }

        InetAddress ip = null;
        try {
            ip = InetAddress.getLocalHost();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
        if (ip != null) {
            log.info("Log4j2 Get Spring Property [{}] value [{}]", "ip", ip.getHostAddress());
            MDC.put("ip", ip.getHostAddress());
        }

    }

    private boolean isAssignableFrom(Class<?> type, Class<?>... supportedTypes) {
        if (type != null) {
            for (Class<?> supportedType : supportedTypes) {
                if (supportedType.isAssignableFrom(type)) {
                    return true;
                }
            }
        }
        return false;
    }

}
```

`log4j2-spring.xml` 配置

```xml
<?xml version="1.0" encoding="UTF-8"?>

<configuration status="warn" monitorInterval="1000">
    <Properties>
        <Property name="APP_NAME" value="${ctx:appName}"/>
        <Property name="IP" value="${ctx:ip}"/>
        <Property name="PORT" value="${ctx:port}"/>
        
        <!-- 配置日志文件输出目录 -->
        <Property name="LOG_HOME">/data/logs/${APP_NAME}</Property>
        <Property name="LOG_NAME">${APP_NAME}</Property>
    </Properties>
</configuration>
```

##### 获取 spring boot 参数

注意：需要 ` log4j-spring-cloud-config-client` 依赖

```xml
<File name="Application" fileName="application-${spring:profiles.active[0]}.log">
  <PatternLayout>
    <pattern>%d %p %c{1.} [%t] $${spring:spring.application.name} %m%n</pattern>
  </PatternLayout>
</File>
```

