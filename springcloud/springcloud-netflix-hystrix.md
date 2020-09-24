### [Hystrix : Circuit Breaker](https://docs.spring.io/spring-cloud-netflix/docs/2.2.5.RELEASE/reference/html/#circuit-breaker-spring-cloud-circuit-breaker-with-hystrix)

#### 禁用 Spring Cloud Circuit Breaker Hsytrix

```properties
spring.cloud.circuitbreaker.hystrix.enabled=false
```

#### 配置 Hystrix Circuit Breakers

为了给所有的 *circuit breaker* 提供一个默认的配置，创建一个自定义的 `Customizer` *bean*，通过 `HystrixCircuitBreakerFactory` 或者 `ReactiveHystrixCircuitBreakerFactory`

```java
@Bean
public Customizer<HystrixCircuitBreakerFactory> defaultConfig() {
    return factory -> factory.configureDefault(id -> HystrixCommand.Setter
            .withGroupKey(HystrixCommandGroupKey.Factory.asKey(id))
            .andCommandPropertiesDefaults(HystrixCommandProperties.Setter()
            .withExecutionTimeoutInMilliseconds(4000)));
}
```

**Reactive Example**

```java
@Bean
public Customizer<ReactiveHystrixCircuitBreakerFactory> defaultConfig() {
    return factory -> factory.configureDefault(id -> HystrixObservableCommand.Setter
            .withGroupKey(HystrixCommandGroupKey.Factory.asKey(id))
            .andCommandPropertiesDefaults(HystrixCommandProperties.Setter()
                    .withExecutionTimeoutInMilliseconds(4000)));
}
```

##### 指定的 Circuit Breaker 配置

```java
@Bean
public Customizer<HystrixCircuitBreakerFactory> customizer() {
    return factory -> factory.configure(builder -> builder.commandProperties(
                    HystrixCommandProperties.Setter().withExecutionTimeoutInMilliseconds(2000)), "foo", "bar");
}
```

**Reactive**

```java
@Bean
public Customizer<ReactiveHystrixCircuitBreakerFactory> customizer() {
    return factory -> factory.configure(builder -> builder.commandProperties(
                    HystrixCommandProperties.Setter().withExecutionTimeoutInMilliseconds(2000)), "foo", "bar");
}
```

#### Circuit Breaker: Hystrix Clients

较低级别的服务中的服务故障可能会导致级联故障，直至用户。当调用一个特定的服务超过 `circuitBreaker.requestVolumeThreshold` （默认：20 requests）然后失败的比例大于 `circuitBreaker.errorThresholdPercentage` （默认：>50%）在一个滚动窗口定义的 `metrics.rollingStats.timeInMilliseconds` （默认：10 seconds），该 *circuit breaker* 打开然后调用无法完成。在出现错误和断路的情况下，开发人员可以提供备用功能。

*Hystrix* 备用防止级联错误。

开路可停止级联故障，并让不堪重负的服务有时间得以恢复。回退可以是另一个受 *Hystrix* 保护的调用，静态数据或合理的空值。可以将回退链接在一起，以便第一个回退进行其他业务调用，然后回退到静态数据。

#### 引入 Hystrix

```groovy
implementation 'org.springframework.cloud:spring-cloud-starter-netflix-hystrix'
implementation 'org.springframework.cloud:spring-cloud-starter-netflix-hystrix-dashboard'
```

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

`@HystrixCommand` 注解由 *Netflix contrib* 库提供称为 *javanica*。*Spring Cloud* 自动的使用代理包装含有该注解的 *Spring bean* 和 *Hystrix circuit breaker* 连接。断路器计算何时断开和闭合电路，以及在发生故障时应采取的措施。

要配置 `@HystrixCommand`，可以将 `commandProperties` 属性与 `@HystrixProperty` 注解一起使用。