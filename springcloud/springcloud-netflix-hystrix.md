### [Hystrix : Circuit Breaker](https://docs.spring.io/spring-cloud-netflix/docs/2.2.5.RELEASE/reference/html/#circuit-breaker-spring-cloud-circuit-breaker-with-hystrix)

[详细参数配置参考，Hystrix 配置参数解析](https://zhenbianshu.github.io/2018/09/hystrix_configuration_analysis.html)

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

---

## Cloud Hystrix 使用配置

### 每个方法单独配置

#### 熔断配置

> 在 5 秒内有 6 个请求访问，且请求失败率为 50%，那么 Hystrix 会启动熔断机制，处于半开状态，在 3 秒后会放行 1 个请求，若是请求还是失败，继续熔断，3 秒后在放行。请求成功，关闭熔断。

```java
@HystrixCommand(
    commandProperties = {
        @HystrixProperty(name = HystrixPropertiesManager.CIRCUIT_BREAKER_REQUEST_VOLUME_THRESHOLD, value = "6"),
        @HystrixProperty(name = HystrixPropertiesManager.METRICS_ROLLING_STATS_TIME_IN_MILLISECONDS, value = "5000"),
        @HystrixProperty(name = HystrixPropertiesManager.CIRCUIT_BREAKER_ERROR_THRESHOLD_PERCENTAGE, value = "50"),
        @HystrixProperty(name = HystrixPropertiesManager.CIRCUIT_BREAKER_SLEEP_WINDOW_IN_MILLISECONDS, value = "3000")
    },  fallbackMethod = "requestCircuitBreakerFallbackMethod"
)
public String requestCircuitBreaker(Integer random) {
    return restTemplate.getForObject("http://eurekaClient/hystrix/requestCircuitBreaker/{random}", String.class, random);
}
```

#### 请求超时/请求失败，请求降级

> 自定义了一个线程池来管理这个请求方法，指定超时时间为 2 秒。

```java
@HystrixCommand(threadPoolKey = "requestTimeOut",
    threadPoolProperties = {
        @HystrixProperty(name = "coreSize", value = "2"),
        @HystrixProperty(name = "maxQueueSize", value = "10"),
        @HystrixProperty(name = "queueSizeRejectionThreshold", value = "10"),
        @HystrixProperty(name = "keepAliveTimeMinutes", value = "2")
    },
    commandProperties = {
        @HystrixProperty(name = "execution.isolation.thread.timeoutInMilliseconds", value = "2000")
}, fallbackMethod = "requestTimeOutFallbackMethod")
public String requestTimeOut() {
    return restTemplate.getForObject("http://eurekaClient/hystrix/requestTimeOut", String.class);
}

@HystrixCommand(threadPoolKey = "requestError",
    threadPoolProperties = {
            @HystrixProperty(name = "coreSize", value = "5"),
            @HystrixProperty(name = "maxQueueSize", value = "10"),
            @HystrixProperty(name = "queueSizeRejectionThreshold", value = "10")
    }, fallbackMethod = "requestErrorFallbackMethod")
public String requestError() {
    return restTemplate.getForObject("http://eurekaClient/hystrix/requestError", String.class);
}
```

### 全局配置

参考配置参数类 `HystrixPropertiesManager`，`HystrixCommandProperties`，`HystrixThreadPoolProperties$Setter`

```yaml
hystrix:
  command:
    # 这里的 default 代表默认的所有的 command
    # 可以换成某一个特定的 command 的 key，默认就是方法的名字
    default:
      execution:
        isolation:
          #strategy: SEMAPHORE
          thread:
            timeoutInMilliseconds: 2000
            coreSize: 20
      metrics:
        rollingStats:
          timeInMilliseconds: 5000
      circuitBreaker:
        requestVolumeThreshold: 6
        errorThresholdPercentage: 50
        sleepWindowInMilliseconds: 3000
  threadpool:
    default:
      allowMaximumSizeToDivergeFromCoreSize: true
      coreSize: 20
      maximumSize: 1000
      maxQueueSize: -1
      keepAliveTimeMinutes: 1
```

