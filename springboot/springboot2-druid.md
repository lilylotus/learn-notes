##### Spring Boot 2.x 使用 Druid 数据库连接池

pom.xml

```
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid-spring-boot-starter</artifactId>
    <version>1.1.10</version>
</dependency>
```

> 还要添加一个 Druid 数据库连接池的 Bean 配置。
> 引入的 Druid 的数据库包，但是没有使用。

```java
@Configuration
public class DruidConfig {
    @Bean(initMethod = "init", destroyMethod = "close")
    @ConfigurationProperties(prefix = "spring.datasource.druid")
    public DruidDataSource druidDataSource() {
        return new DruidDataSource();
    }
}
```

