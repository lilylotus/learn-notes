##### 客户端的负载均衡 (Client Side Load Balancer) -- Ribbon

*Ribbon* 是客户端负载平衡器，可让您对 *HTTP* 和 *TCP* 客户端的行为进行大量控制。
*Feign* 已经使用了 *Ribbon*，因此，如果您使用 `@FeignClient`，也适用。

Ribbon 中的中心概念是指定客户端的概念。

每个负载均衡器都是组件的一部分，这些组件可以一起工作以按需联系远程服务器，并且该组件具有您作为应用程序开发人员提供的名称（例如，使用 `@FeignClient` 批注）。
根据需要，*Spring Cloud* 通过使用 *RibbonClientConfiguration* 为每个命名客户端创建一个新的集合作为 *ApplicationContext*。
它包含（除其他事项外）一个 `ILoadBalancer`，一个 `RestClient` 和一个 `ServerListFilter`。

**使用 Ribbon**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-ribbon</artifactId>
</dependency>
```

**自定义 Ribbon 客户端**

```java
@Configuration
@RibbonClient(name = "custom", configuration = CustomConfiguration.class)
public class TestConfiguration {}
```

`@RibbonClient` 注解类配置 *Ribbon Client*，该组件自动放入 `RbiionClientConfiguraiont` 当中。
*注意：* 自定义的配置必须声明 `@Configuration` 注解

自定义 *Bean*

```java
@Configuration(proxyBeanMethods = false)
protected static class FooConfiguration {
    @Bean
    public ZonePreferenceServerListFilter serverListFilter() {
        ZonePreferenceServerListFilter filter = new ZonePreferenceServerListFilter();
        filter.setZone("myTestZone");
        return filter;
    }
    @Bean
    public IPing ribbonPing() {
        return new PingUrl();
    }
}
```

#### 2. 常用配置

```yaml
ribbon:
  ConnectTimeout: 1000 #服务请求连接超时时间（毫秒）
  ReadTimeout: 3000 #服务请求处理超时时间（毫秒）
  OkToRetryOnAllOperations: true #对超时请求启用重试机制
  MaxAutoRetriesNextServer: 1 #切换重试实例的最大个数
  MaxAutoRetries: 1 # 切换实例后重试最大次数
  NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RandomRule #修改负载均衡算法
```

#### 3. 负载算法

> 所谓的负载均衡策略，就是当 A 服务调用 B 服务时，此时 B 服务有多个实例，这时A服务以何种方式来选择调用的 B 实例，ribbon 可以选择以下几种负载均衡策略。

- com.netflix.loadbalancer.RandomRule
  从提供服务的实例中以随机的方式
- com.netflix.loadbalancer.RoundRobinRule
  以线性轮询的方式，就是维护一个计数器，从提供服务的实例中按顺序选取，第一次选第一个，第二次选第二个，以此类推，到最后一个以后再从头来过
- com.netflix.loadbalancer.RetryRule
  在 RoundRobinRule 的基础上添加重试机制，即在指定的重试时间内，反复使用线性轮询策略来选择可用实例
- com.netflix.loadbalancer.WeightedResponseTimeRule
  对 RoundRobinRule 的扩展，响应速度越快的实例选择权重越大，越容易被选择；
- com.netflix.loadbalancer.BestAvailableRule
  选择并发较小的实例
- com.netflix.loadbalancer.AvailabilityFilteringRule
  先过滤掉故障实例，再选择并发较小的实例
- com.netflix.loadbalancer.ZoneAwareLoadBalancer
  采用双重过滤，同时过滤不是同一区域的实例和故障实例，选择并发较小的实例