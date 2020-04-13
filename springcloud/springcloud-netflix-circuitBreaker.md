##### 服务熔断 (Circuit Breaker -- Hystrix)

**停用 Spring Cloud Circuit Breaker Hystrix**
`spring.cloud.circuitbreaker.hystrix.enabled=false`

**配置 *Hystrix Circuit Breakers***
*默认的配置*
创建一个 `Customize` 的 *bean*， 传递一个  `HystrixCircuitBreakerFactory` 或者 `ReactiveHystrixCircuitBreakerFactory`

```java
@Bean
public Customizer<HystrixCircuitBreakerFactory> defaultConfig() {
    return factory -> factory.configureDefault(id -> HystrixCommand.Setter
            .withGroupKey(HystrixCommandGroupKey.Factory.asKey(id))
            .andCommandPropertiesDefaults(HystrixCommandProperties.Setter()
            .withExecutionTimeoutInMilliseconds(4000)));
}
```

*Reactive Example*

```java
@Bean
public Customizer<ReactiveHystrixCircuitBreakerFactory> defaultConfig() {
    return factory -> factory.configureDefault(id -> HystrixObservableCommand.Setter
            .withGroupKey(HystrixCommandGroupKey.Factory.asKey(id))
            .andCommandPropertiesDefaults(HystrixCommandProperties.Setter()
                    .withExecutionTimeoutInMilliseconds(4000)));
}
```

*制定自己的 Circuit Breaker 配置*
和提供一个默认的配置相似，可自定义一个 *Custom Bean* 传递一个 `HystrixCircuitBreakerFactory`

```java
@Bean
public Customizer<HystrixCircuitBreakerFactory> customizer() {
    return factory -> factory.configure(builder -> builder.commandProperties(                   HystrixCommandProperties.Setter().withExecutionTimeoutInMilliseconds(2000)), "foo", "bar");
}
```

*Reactive*

```java
@Bean
public Customizer<ReactiveHystrixCircuitBreakerFactory> customizer() {
    return factory -> factory.configure(builder -> builder.commandProperties(HystrixCommandProperties.Setter().withExecutionTimeoutInMilliseconds(2000)), "foo", "bar");
}
```

---

###### Hystrix Client 使用

依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
</dependency>
```

启动类：

```java
@SpringBootApplication
@EnableCircuitBreaker
public class Application {
    public static void main(String[] args) {
        new SpringApplicationBuilder(Application.class).web(true).run(args);
    }
}

@Component
public class StoreIntegration {
    @HystrixCommand(fallbackMethod = "defaultStores")
    public Object getStores(Map<String, Object> parameters) {
        //do stuff that might fail
    }
    public Object defaultStores(Map<String, Object> parameters) {
        return /* something useful */;
    }
}
```

`@HystrixCommand` 由一个名为 `javanica` 的 *Netflix contrib* 库提供。
*Spring Cloud* 会自动将带有该批注的 *Spring bean* 包装在连接到 *Hystrix* 断路器的代理中。
断路器计算何时断开和闭合电路，以及在发生故障时应采取的措施。

###### Hystrix Dashborad 引入

`spring-cloud-starter-netflix-hystrix-dashboard` 依赖。

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-hystrix-dashboard</artifactId>
</dependency>
```

在启动类上添加注解 `@EnableHystrixDashboard` ， 然后访问 `/hystrix` 和 `/hystrix.stream`