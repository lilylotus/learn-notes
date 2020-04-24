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

要暴露 `hystrix.stream`

```yaml
management:
  endpoints:
    web:
      exposure:
        include: 'hystrix.stream' #暴露hystrix监控端点
```



#### 2. Hystrix 的 @HystrixCommand 注解

##### 2.1 参数详情

### @HystrixCommand中的常用参数

- fallbackMethod：指定服务降级处理方法；
- ignoreExceptions：忽略某些异常，不发生服务降级；
- commandKey：命令名称，用于区分不同的命令；
- groupKey：分组名称，Hystrix 会根据不同的分组来统计命令的告警及仪表盘信息；
- threadPoolKey：线程池名称，用于划分线程池。

#### 3. Hystrix 的缓存

> 当系统并发量越来越大时，我们需要使用缓存来优化系统，达到减轻并发请求线程数，提供响应速度的效果。

##### 3.1 相关注解

- @CacheResult
  开启缓存，默认所有参数作为缓存的key，cacheKeyMethod 可以通过返回 String 类型的方法指定 key
- @CacheKey
  指定缓存的 key，可以指定参数或指定参数中的属性值为缓存 key，cacheKeyMethod 还可以通过返回 String 类型的方法指定
- @CacheRemove
  移除缓存，需要指定 commandKey

##### 3.2 示例

```java
@GetMapping("/testCache/{id}")
public CommonResult testCache(@PathVariable Long id) {
    userService.getUserCache(id); // 直接调用三次
    userService.getUserCache(id);
    userService.getUserCache(id);
    return new CommonResult("操作成功", 200);
}
```

添加缓存

```java
@CacheResult(cacheKeyMethod = "getCacheKey")
@HystrixCommand(fallbackMethod = "getDefaultUser", commandKey = "getUserCache")
public CommonResult getUserCache(Long id) {
    LOGGER.info("getUserCache id:{}", id);
    return restTemplate.getForObject(userServiceUrl + "/user/{1}", CommonResult.class, id);
}

/** 为缓存生成 key 的方法 */
public String getCacheKey(Long id) {
    return String.valueOf(id);
}
```

删除缓存

```java
@CacheRemove(commandKey = "getUserCache", cacheKeyMethod = "getCacheKey")
@HystrixCommand
public CommonResult removeCache(Long id) {
    LOGGER.info("removeCache id:{}", id);
    return restTemplate.postForObject(userServiceUrl + "/user/delete/{1}", null, CommonResult.class, id);
}
```

使用过后要关闭

```java
@Component
@WebFilter(urlPatterns = "/*",asyncSupported = true)
public class HystrixRequestContextFilter implements Filter {
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HystrixRequestContext context = HystrixRequestContext.initializeContext();
        try {
            filterChain.doFilter(servletRequest, servletResponse);
        } finally {
            context.close();
        }
    }
}
```

