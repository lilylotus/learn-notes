###### 此 *Spring-boot* 版本要求 *1.5.22.RELEASE*

1. *Java 7* (+) 和 *Spring Framework 4.3.25.RELEASE* (+)  <font color="blue">推荐 Java 8</font>
2. *Maven* [3.2+]
3. *Gradle* [2.9, 3.x]
4. *Servlet* 容器 <font color="blue">可部署在任何 Servlet 3.0+ 兼容的容器</font>

| Name         | Servlet Version | Java Version |
| ------------ | --------------- | ------------ |
| Tomcat 8     | 3.1             | Java 7+      |
| Tomcat 7     | 3.0             | Java 6+      |
| Jetty 9.3    | 3.1             | Java 8+      |
| Jetty 9.2    | 3.1             | Java 7+      |
| Jetty 8      | 3.0             | Java 6+      |
| Undertow 1.3 | 3.1             | Java 7+      |

***版本信息*** https://github.com/spring-projects/spring-boot/wiki

###### *Springboot start*

*maven pom.xml*

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <!-- Inherit defaults from Spring Boot -->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.22.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <!-- relativePath 始终从仓库中获取，不从本地路径获取
		如为空值将始终从仓库中获取，不从本地路径获取 -->
    <!-- relativePath 元素中的地址–本地仓库–远程仓库 -->
    
    <!-- 不用依赖 spring-boot-starter-parent -->
    <dependencyManagement>
        <dependencies>
            <dependency>
                <!-- Import dependency management from Spring Boot -->
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>1.5.22.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <groupId>cn.nihility</groupId>
    <artifactId>springboot-learn-mvn</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>springboot-learn-mvn</name>
    <description>Demo project for Spring Boot</description>
    
    <properties>
        <java.version>1.8</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <!-- Package as an executable jar -->
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

*gradle build.gradle*

```java
plugins {
    id 'org.springframework.boot' version '1.5.22.RELEASE'
    id 'java'
}

jar {
    baseName = 'myproject'
    version =  '0.0.1-SNAPSHOT'
}

repositories {
    jcenter()
}

dependencies {
    compile("org.springframework.boot:spring-boot-starter-web")
    testCompile("org.springframework.boot:spring-boot-starter-test")
}
```

###### *Spring boot 依赖* *spring-boot-starter-x*

**Table 13.3. Spring Boot technical starters**

| Name                           | Description                                                  |
| ------------------------------ | ------------------------------------------------------------ |
| `spring-boot-starter-jetty`    | Starter for using Jetty as the embedded servlet container. An alternative to [`spring-boot-starter-tomcat`](https://docs.spring.io/spring-boot/docs/1.5.22.RELEASE/reference/html/using-boot-build-systems.html#spring-boot-starter-tomcat) |
| `spring-boot-starter-log4j2`   | Starter for using Log4j2 for logging. An alternative to [`spring-boot-starter-logging`](https://docs.spring.io/spring-boot/docs/1.5.22.RELEASE/reference/html/using-boot-build-systems.html#spring-boot-starter-logging) |
| `spring-boot-starter-logging`  | Starter for logging using Logback. Default logging starter   |
| `spring-boot-starter-tomcat`   | Starter for using Tomcat as the embedded servlet container. Default servlet container starter used by [`spring-boot-starter-web`](https://docs.spring.io/spring-boot/docs/1.5.22.RELEASE/reference/html/using-boot-build-systems.html#spring-boot-starter-web) |
| `spring-boot-starter-undertow` | Starter for using Undertow as the embedded servlet container. An alternative to [`spring-boot-starter-tomcat`](https://docs.spring.io/spring-boot/docs/1.5.22.RELEASE/reference/html/using-boot-build-systems.html#spring-boot-starter-tomcat) |

###### *Spring boot* 配置

`@Configuration` 可以配置在 *class* 上，`@Import` 注解可以添加额外的配置 (*配置类*)，
`@ComponentScan` 可以配置来自动注入要扫描的组件包
`@ImportResource` 添加到配置类 (`@Configuration`) 上，可以引入 *xml* 配置信息

###### *spring boot* 自动配置

添加 `@EnableAutoConfiguration` 或者 `@SpringBootApplication` 到 `@Configuration` 配置类

排除特定的自动配置

```java
@Configuration
@EnableAutoConfiguration(exclude={DataSourceAutoConfiguration.class})
public class MyConfiguration { }
```

添加自动扫描 *依赖注入* -> 添加  `@ComponentScan` 到配置类

`@SpringBootApplication` 一个注解包含了三个功能
`@Configuration` + `@EnableAutoConfiguration` + `@ComponentScan`

1. `@EnableAutoConfiguration` 允许 *spring boot* 自动配置机制
2. `@ComponentScan` 自动配置 *应用* 所在的包 (**推荐配置**)
3. `@Configuration` 允许注册在上下文中额外的 *bean* 和添加额外的配置类 (*class*)

可自定义的配置

```java
@Configuration
@EnableAutoConfiguration
@Import({ MyConfig.class, MyAnotherConfig.class })
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

###### 运行 *spring boot*

maven 运行

```java
mvn spring-boot:run
配置 mvn 参数 ： export MAVEN_OPTS=-Xmx1024m -XX:MaxPermSize=128M
```

gradle 运行

```bash
gradle bootRun
配置 gradle 运行参数： export JAVA_OPTS=-Xmx1024m -XX:MaxPermSize=128M
```

debug 模式运行
`java -jar springboot.jar --debug`

###### *springboot* 开发工具插件 *spring boot Developer tools*

```xml
maven :
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>

gradle :
dependencies {
	compileOnly("org.springframework.boot:spring-boot-devtools")
}
```

###### *Restart* （重新启动） 或者 *Reload* （重新加载）

###### 加载配置文件

*spring boot* 默认加载 *application.properties* 文件在下位置

1. `/config` 的子目录在当前目录
2. 当前目录
3. *classpath* 路径 `/config` *package*
4. *classpath* 根路径

配置默认的 *配置文件名称 (application.properties)* `spring.config.name / spring.config.location`

*以配置位置相反的顺序搜索文件*
默认的配置路径  `classpath:/,classpath:/config/,file:./,file:./config/`
搜索顺序为：`file:./config/,file:./,classpath:/config/,classpath:/`

当用户自定义配置后：`classpath:/custom-config/,file:./customconfig/`
搜索顺序：`file:./custom-config/,classpath:custom-config/,file:./config,file:./,classpath:/config/,classpath:/`

###### 定义配置文件使用特定的 *属性文件*

在 `application.properteis` 中配置，命名惯例是 `applicaiton-{profile}.properties`
当没有 *profile* 被激活的时候，默认的配置就是 *default* -> `application-default.properties`

<font color="red">如果配置了多个 *profile*，那么最后加载的会覆盖前加载的属性</font>

配置文件中的占位符 *${}*

```yaml
app.name=MyApp
app.description=${app.name} is a spring boot application
```

###### YAML 加载

`YamlPropertiesFactoryBean` 会加载 *yaml* 作为 *Properties*
`YamlMapFactoryBean` 会加载 *YAML* 作为 *map*

```yaml
environments:
    dev:
        url: https://dev.example.com
        name: Developer Setup
    prod:
        url: https://another.example.com
        name: My Cool App

--->
environments.dev.url=https://dev.example.com
environments.dev.name=Developer Setup
environments.prod.url=https://another.example.com
environments.prod.name=My Cool App

-------------------------
my:
   servers:
       - dev.example.com
       - another.example.com
--->
my.servers[0]=dev.example.com
my.servers[1]=another.example.com
       
属性值绑定：
@ConfigurationProperties(prefix="my")
public class Config {
    private List<String> servers = new ArrayList<String>();
    public List<String> getServers() {
        return this.servers;
    }
}
```

*spring boot* 属性值批量绑定 `@ConfigurationProperties(prefix="prefix")`
*注意：* `my.servers` 的值可能会被高优先级覆盖，可写为

```yaml
my
  servers: dev.example.com,another.example.com
```

###### 在一个 *yaml* 文件中配置多个 *profile* 使用 `---` 分隔符

```yaml
server:
  address: 192.168.1.100
  
spring:
  profiles:
    active: development # 127.0.0.1
---
spring:
  profiles: development
server:
  address: 127.0.0.1
---
spring:
  profiles: production
server:
  address: 192.168.1.110
```

在上面的示例中，`server.address` 属性会是 `127.0.0.1` 如果 *development* *profile* 被激活

<font color="red">*YAML* 文件不能通过 `@PropertySource` 引入，`@PropertySource` 仅能引入 *properties* 配置文件</font>
<font color="blue">使用 `@ConfigurationProperties` 要在配置类中添加 `@EnableConfigurationProperties` 注册配置</font>

```java
@Component
@ConfigurationProperties(prefix = "my")
public class Config { } // 这样就不需要在主配置类中加入 @EnableConfigurationProperties

-----------------------------------------------
@ConfigurationProperties(prefix = "my")
public class Config { } // 需要在主配置中加入 @EnableConfigurationProperties

@SpringBootApplication
@EnableConfigurationProperties(Config.class)
public class SpringbootApplication { }
```

`@ConfigurationProperties` 也可以用在 `@Bean` 注解类上面

```java
@ConfigurationProperties(prefix = "bar")
@Bean
public BarComponent barComponent() {}
```

###### 松数据绑定

```java
@ConfigurationProperties(prefix="person")
public class OwnerProperties {
    private String firstName;
}

-> yml
firstName: name
first-name: name
first_name: name
```

| Property            | Note                                                         |
| ------------------- | ------------------------------------------------------------ |
| `person.firstName`  | Standard camel case syntax.                                  |
| `person.first-name` | Dashed notation, recommended for use in `.properties` and `.yml` files. |
| `person.first_name` | Underscore notation, alternative format for use in `.properties` and `.yml` files. |
| `PERSON_FIRST_NAME` | Upper case format. Recommended when using a system environment variables. |

###### `@ConfigurationProperties` 的数据校验

```java
@ConfigurationProperties(prefix="foo")
@Validated
public class FooProperties {
    @NotNull
    private InetAddress remoteAddress;
    @Valid // 校验值的内置属性
    private final Security security = new Security();
}
```

| Feature                                                      | `@ConfigurationProperties` | `@Value` |
| ------------------------------------------------------------ | -------------------------- | -------- |
| [Relaxed binding](https://docs.spring.io/spring-boot/docs/1.5.22.RELEASE/reference/html/boot-features-external-config.html#boot-features-external-config-relaxed-binding) | Yes                        | No       |
| [Meta-data support](https://docs.spring.io/spring-boot/docs/1.5.22.RELEASE/reference/html/configuration-metadata.html) | Yes                        | No       |
| `SpEL` evaluation                                            | No                         | Yes      |

Finally, while you can write a `SpEL` expression in `@Value`, such expressions are not processed from [Application property files](https://docs.spring.io/spring-boot/docs/1.5.22.RELEASE/reference/html/boot-features-external-config.html#boot-features-external-config-application-property-files).

###### Profiles

*profiles* 提供了一种方式分隔部分配置
任意的 `@Configuration` 和 `@Component` 都可以注解 `@Profile`

```java
@Configuration
@Profile("production")
public class ProductionConfiguration { } -> 这个对象仅在 production 激活时在引用
```

`spring.profiles.active=dev,production`

添加 *profiles* 激活

```yaml
spring.profiles: prod
spring.profiles.include: # 当 prod 激活时会同时引用 proddb 和 prodmq
  - proddb
  - prodmq
```



###### *spring boot* 日志

> Logback 没有 `FATAL` 等级，对应的是  `ERROR`
> 配置 *DEBUG* `java -jar application.jar --debug`   -> *trace=true*
> 或者在 `application.properties` 中指定 `debug=true`

文件输出
`logging.file` 或者 `logging.path`**Table 26.1. Logging properties**

| `logging.file` | `logging.path`     | Example    | Description                                                  |
| -------------- | ------------------ | ---------- | ------------------------------------------------------------ |
| *(none)*       | *(none)*           |            | Console only logging.                                        |
| Specific file  | *(none)*           | `my.log`   | Writes to the specified log file. Names can be an exact location or relative to the current directory. |
| *(none)*       | Specific directory | `/var/log` | Writes `spring.log` to the specified directory. Names can be an exact location or relative to the current directory. |

<font color="red">日志系统的初始化早于应用程序的生命周期，在 `ApplicationContext` 初始化之前，查找日志属性值会查找不到</font>

###### 日志等级配置

`TRACE, DEBUG, INFO, WARN, ERROR, FATAL, OFF`
根日志配置 `logging.level.root`

```yaml
logging.level.root=WARN
logging.level.org.springframework.web=DEBUG
logging.level.org.hibernate=ERROR
```

日志配置文件 `classpath:`  <font color="blue">推荐使用 `-spring` 的日志文件命名</font>

| Logging System          | Customization                                                |
| ----------------------- | ------------------------------------------------------------ |
| Logback                 | `logback-spring.xml`, `logback-spring.groovy`, `logback.xml` or `logback.groovy` |
| Log4j2                  | `log4j2-spring.xml` or `log4j2.xml`                          |
| JDK (Java Util Logging) | `logging.properties`                                         |

###### logback 的扩展

*注意：* logback 的拓展应用仅能用于 `logback-spring.xml` 配置，`logback.xml` 不行

```xml
<springProfile name="staging">
    <!-- configuration to be enabled when the "staging" profile is active -->
</springProfile>

<springProfile name="dev, staging">
    <!-- configuration to be enabled when the "dev" or "staging" profiles are active -->
</springProfile>

<springProfile name="!production">
    <!-- configuration to be enabled when the "production" profile is not active -->
</springProfile>
```

环境属性引用 `<springProperty>` 标签

```xml
<springProperty scope="context" name="fluentHost" source="myapp.fluentd.host"
        defaultValue="localhost"/>
<appender name="FLUENT" class="ch.qos.logback.more.appenders.DataFluentAppender">
    <remoteHost>${fluentHost}</remoteHost>
</appender>
```



##### WEB 开发

添加依赖 `spring-boot-starter-web` 模块

###### *Spring MVC auto-configuration*

*spring boot 对 Spring MVC 自动配置会引入*

- Inclusion of `ContentNegotiatingViewResolver` and `BeanNameViewResolver` beans.
- Support for serving static resources, including support for WebJars .
- Automatic registration of `Converter`, `GenericConverter`, `Formatter` beans.
- Support for `HttpMessageConverters`.
- Automatic registration of `MessageCodesResolver`.
- Static `index.html` support.
- Custom `Favicon` support.dd
- Automatic use of a `ConfigurableWebBindingInitializer` bean.

*HttpMessageConverters*

```java
@Configuration
public class MyConfiguration {
    @Bean
	public HttpMessageConverters coustomConverters() {
        return new HttpMessageConverters(additional, another);
    }
}
```

静态内容 (资源)
默认的资源映射到 `/**`
可自定义静态资源映射路径 `spring.mvc.static-path-pattern=/resources/**`

`Servlets, Filters, and listeners` 扫描
`@WebServlet`, `@WebFilter`, 和 `@WebListener` 会被 `@ServletComponentScan` 自动注册



*Spring boot* 数据库操作
使用 `spring-boot-starter-jdbc` 或者 `spring-boot-starter-data-jpa` 会自动依赖 `tomcat-jdbc`
<font color="red">指定特定数据库连接池的类型 `spring.datasource.type` 是十分重要的，若是运行在 *Tomcat* 容器中 `tomcat-jdbc` 会默认提供</font>
<font color="blue">自定义数据库链接池 `dataSource` *bean* 后，自动配置就不会使用</font>

添加依赖： `Spring boot 2.x` 后默认使用 *dataSource*  *HikariCP*
`Spring boot 1.5.x` 默认使用 *tomcat jdbc*

```xml
<!-- include HikariCP spring boot 2.x -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jdbc</artifactId>
</dependency>
```

`spring.datasource.*`

```properties
spring.datasource.url=jdbc:mysql://localhost/test
spring.datasource.username=dbuser
spring.datasource.password=dbpass
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
```

> `driver-class-name`  可以不用提供，*Spring boot* 可以自动推断

调整具体实现数据库的参数 `spring.datasource.tomcat.*`, `spring.datasource.hikari.*` 等

```properties
# Number of ms to wait before throwing an exception if no connection is available.
spring.datasource.tomcat.max-wait=10000
# Maximum number of active connections that can be allocated from this pool at the same time.
spring.datasource.tomcat.max-active=50
```

spring 的 `JdbcTemplate` 和 `NamedParameterJdbcTemplate` 会自动配置，可以直接 `@Autowired`

```java
@Component
public class MyBean {
    private final JdbcTemplate jdbcTemplate;
    @Autowired
    public MyBean(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }
}
```



##### *Spring boot NoSQL*

###### *spring boot redis*

```yaml
spring:
  redis:
    host: 10.10.37.114
    port: 6379
```

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class RedisTest {
    @Autowired
    private StringRedisTemplate redisTemplate;
    @Test
    public void testRedis() {
        Assert.assertNotNull(redisTemplate);
        Boolean redis = redisTemplate.hasKey("redis");
        Assert.assertEquals(redis, Boolean.TRUE);
        String key = redisTemplate.opsForValue().get("redis");
        Assert.assertEquals(key, "Hello Redis Spring Boot");
    }
}
```



##### *spring boot caching*

> spring boot 不需要任何 *caching* 的配置，仅需在启动配置类中添加 `@EnableCaching` 注解

```java
@SpringBootApplication
@EnableCaching
public class SpringbootApplication { }

@Component
@Cacheable("cacheKey")
public int computePiDecimal(int i) { }
```

会下去查询 *cacheKey* 是否有缓存值，若不存在则执行方法后缓存值，下次在调用是查询 *redisKey* 是否有缓存值，有则直接返回缓存值不会调用方法执行

> 若是缓存的基础在一个 *bean* 但是此没有接口，那么须在 `@EnableCaching(proxyTargetClass = true)`