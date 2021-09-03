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

---

### 二. 限流算法

[参考限流文档，掘金](https://juejin.cn/post/6870396751178629127)

#### 1. 计数限流 （*）

每次请求来的时候看看计数器的值，如果超过阈值要么拒绝。非常的简单粗暴，计数器的值要是存内存中就算单机限流算法。存中心存储里，例如 Redis 中，集群机器访问就算分布式限流算法。

优点就是：简单粗暴，单机在 Java 中可用 Atomic 等原子类、分布式就 Redis incr。

缺点就是：假设允许的阈值是 1 万，此时计数器的值为 0， 当 1 万个请求在前 1 秒内一股脑儿的都涌进来，这突发的流量可是顶不住的。缓缓的增加处理和一下子涌入对于程序来说是不一样的。

而且一般的限流都是为了限制在指定时间间隔内的访问量，因此还有个算法叫固定窗口。

#### 2. 固定窗口限流

它相比于计数限流主要是多了个时间窗口的概念。计数器每过一个时间窗口就重置。规则如下：

- 请求次数小于阈值，允许访问并且计数器 +1；
- 请求次数大于阈值，拒绝访问；
- 这个时间窗口过了之后，计数器清零；

##### 固定窗口临界问题

- **一段时间内（不超过时间窗口）系统服务不可用**。比如窗口大小为 1s，限流大小为 100，然后恰好在某个窗口的第 1ms 来了 100 个请求，然后第 2ms-999ms 的请求就都会被拒绝，这段时间用户会感觉系统服务不可用。
- **窗口切换时可能会产生两倍于阈值流量的请求**。比如窗口大小为 1s，限流大小为 100，然后恰好在某个窗口的第 999ms 来了 100 个请求，窗口前期没有请求，所以这 100 个请求都会通过。再恰好，下一个窗口的第 1ms 来了 100 个请求，也全部通过了，那也就是在 2ms 之内通过了 200 个请求，而我们设定的阈值是 100，通过的请求达到了阈值的两倍。

#### 3. 滑动窗口限流

计数器滑动窗口算法是计数器固定窗口算法的改进，解决了固定窗口切换时可能会产生两倍于阈值流量请求的缺点。

滑动窗口限流解决固定窗口临界值的问题，可以保证在任意时间窗口内都不会超过阈值。相对于固定窗口，滑动窗口除了需要引入计数器之外还需要记录时间窗口内每个请求到达的时间点，因此**对内存的占用会比较多**。

规则如下，假设时间窗口为 1 秒：

- 记录每次请求的时间
- 统计每次请求的时间至往前推1秒这个时间窗口内请求数，并且 1 秒前的数据可以删除。
- 统计的请求数小于阈值就记录这个请求的时间，并允许通过，反之拒绝。

但是滑动窗口和固定窗口都**无法解决短时间之内集中流量的突击**。

所想的限流场景，例如每秒限制 100 个请求。希望请求每 10ms 来一个，这样流量处理就很平滑，但是真实场景很难控制请求的频率。因此可能存在 5ms 内就打满了阈值的情况。这种情况还是有变型处理的，例如设置多条限流规则。不仅限制每秒 100 个请求，再设置每 10ms 不超过 2 个。

**滑动窗口可与 TCP 的滑动窗口不一样**。TCP 的滑动窗口是接收方告知发送方自己能接多少“货”，然后发送方控制发送的速率。

#### 4. 漏桶算法（*）

水滴持续滴入漏桶中，底部定速流出。如果水滴滴入的速率大于流出的速率，当存水超过桶的大小的时候就会溢出。

- 请求来了放入桶中
- 桶内请求量满了拒绝请求
- 服务定速从桶内拿请求处理

水滴对应的就是请求，特点就是**宽进严出**，无论请求多少，请求的速率有多大，都按照固定的速率流出，对应的就是服务按照固定的速率处理请求

面对突发请求，服务的处理速度和平时是一样的，其实不是想要的，在面对突发流量希望在系统平稳的同时，提升用户体验即能更快的处理请求，而不是和正常流量一样，循规蹈矩的处理（看看，之前滑动窗口说流量不够平滑，现在太平滑了又不行，难搞啊）。

#### 5. 令牌桶算法（*）

令牌桶其实和漏桶的原理类似，只不过漏桶是**定速地流出**，而令牌桶是**定速地往桶里塞入令牌**，然后请求只有拿到了令牌才能通过，之后再被服务器处理。当然令牌桶的大小也是有限制的，假设桶里的令牌满了之后，定速生成的令牌会丢弃。

- 定速的往桶内放入令牌
- 令牌数量超过桶的限制，丢弃
- 请求来了先向桶内索要令牌，索要成功则通过被处理，反之拒绝

**Semaphore 信号量**，信号量可控制某个资源被同时访问的个数，其实和拿令牌思想一样，一个是拿信号量，一个是拿令牌。只不过信号量用完了返还，而咱们令牌用了不归还，因为令牌会定时再填充。

令牌桶和漏桶的区别就在于一个是加法，一个是减法。

可以看出令牌桶在应对突发流量的时候，桶内假如有 100 个令牌，那么这 100 个令牌可以马上被取走，而不像漏桶那样匀速的消费。所以在**应对突发流量的时候令牌桶表现的更佳**。