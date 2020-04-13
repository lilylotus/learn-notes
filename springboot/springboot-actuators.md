###### spring boot actuator 是什么？

本质上，执行器为我们的应用带来了生产就绪功能。
监视我们的应用程序，收集指标，了解流量或数据库状态对于这种依赖性变得微不足道。
该库的主要优点是，我们可以获得生产级工具，而不必自己真正实现这些功能。

*Actuator* 主要用于公开有关正在运行的应用程序的操作信息-运行状况，指标，信息，转储，环境等。
它使用 *HTTP* 端点或 *JMX Bean* 使我们能够与其交互。

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```



##### Spring Boot 1.x Actuator

> *1.x* 版本执行器遵循 `R/W` 模型，这意味着我们可以对其进行读取或写入。
> 我们可以检索指标或应用程序的运行状况。另外，我们可以优雅地终止我们的应用程序或更改日志记录配置。
> 为了使它工作，*Actuator* 要求 *Spring MVC* 通过 *HTTP* 公开其端点。不支持其他技术。

###### *Endpoints* 暴露接口

**在 1.x 中，*Actuator* 有自己的安全模型。它利用了 *Spring Security* 构造，但是需要与应用程序的其余部分独立配置。**
而且，大多数端点都是敏感的-表示它们不是完全公开的，换句话说，大多数信息将被省略-而少数端点不是敏感的。
以下是Boot提供的一些最常见的端点:

- */health* – Shows application health information (a simple *‘status'* when accessed over an unauthenticated connection or full message details when authenticated); it's not sensitive by default
- */info –* Displays arbitrary application info; not sensitive by default
- */metrics –* Shows ‘metrics' information for the current application; it's also sensitive by default
- */trace –* Displays trace information (by default the last few HTTP requests)

###### 配置现存的 Endopoints

*可以使用以下格式使用属性来自定义每个端点：* endpoints.[endpoint name].[property to customize]
*有三个属性可配置：*

- *id –* by which this endpoint will be accessed over HTTP
- *enabled* – if true then it can be accessed otherwise not
- *sensitive* – if true then need the authorization to show crucial information over HTTP

```properties
endpoints.beans.id=springbeans
endpoints.beans.sensitive=false
endpoints.beans.enabled=true
```

**/health Endpoint**
*实现了 `HealthIndicator` 接口*

```java
@Component
public class HealthCheck implements HealthIndicator {
  
    @Override
    public Health health() {
        int errorCode = check(); // perform some specific health check
        if (errorCode != 0) {
            return Health.down()
              .withDetail("Error Code", errorCode).build();
        }
        return Health.up().build();
    }
     
    public int check() {
        // Our logic to check health
        return 0;
    }
}
```

**/info Endopoint**
自定义显示：

```properties
info.app.name=Spring Sample Application
info.app.description=This is my first spring boot application
info.app.version=1.0.0
```

**/metrics Endpoint**
指标终结点发布有关OS，JVM和应用程序级别指标的信息。

```java
@Service
public class LoginServiceImpl {
 
    private final CounterService counterService;
     
    public LoginServiceImpl(CounterService counterService) {
        this.counterService = counterService;
    }
     
    public boolean login(String userName, char[] password) {
        boolean success;
        if (userName.equals("admin") && "secret".toCharArray().equals(password)) {
            counterService.increment("counter.login.success");
            success = true;
        }
        else {
            counterService.increment("counter.login.failure");
            success = false;
        }
        return success;
    }
}
```



**自定义的 Endpoint**
实现接口 `Endopoint<T>`

```java
@Component
public class CustomEndpoint implements Endpoint<List<String>> {
     
    @Override
    public String getId() {
        return "customEndpoint";
    }
 
    @Override
    public boolean isEnabled() {
        return true;
    }
 
    @Override
    public boolean isSensitive() {
        return true;
    }
 
    @Override
    public List<String> invoke() {
        // Custom logic to build the output
        List<String> messages = new ArrayList<String>();
        messages.add("This is message 1");
        messages.add("This is message 2");
        return messages;
    }
}
```

**其它配置**

```properties
#port used to expose actuator
management.port=8081 
 
#CIDR allowed to hit actuator
management.address=127.0.0.1 
 
#Whether security should be enabled or disabled altogether
management.security.enabled=false

security.user.name=admin
security.user.password=secret
management.security.role=SUPERUSER
```

---

##### Spring Boot 2.x Actuator

在2.x中，Actuator保持其基本意图，但简化了其模型，扩展了其功能并结合了更好的默认设置。
首先，该版本与技术无关。此外，它通过合并简化了其安全模型为一个应用。
最后，在各种更改中，请务必记住其中一些正在中断。这包括HTTP请求/响应以及Java API。
此外，与旧的RW（读/写）模型相反，最新版本现在支持CRUD模型。

**预定义的 Endpoint**

**some endpoints have been added, some removed and some have been restructured:**

- */auditevents –* lists security audit-related events such as user login/logout. Also, we can filter by principal or type among others fields
- */beans – r*eturns all available beans in our *BeanFactory*. Unlike */auditevents*, it doesn't support filtering
- */conditions –* formerly known as /*autoconfig*, builds a report of conditions around auto-configuration
- */configprops –* allows us to fetch all *@ConfigurationProperties* beans
- */env –* returns the current environment properties. Additionally, we can retrieve single properties
- */flyway –* provides details about our Flyway database migrations
- */health –* summarises the health status of our application
- */heapdump –* builds and returns a heap dump from the JVM used by our application
- */info –* returns general information. It might be custom data, build information or details about the latest commit
- */liquibase – b*ehaves like */flyway* but for Liquibase
- */logfile –* returns ordinary application logs
- */loggers –* enables us to query and modify the logging level of our application
- */metrics –* details metrics of our application. This might include generic metrics as well as custom ones
- */prometheus –* returns metrics like the previous one, but formatted to work with a Prometheus server
- */scheduledtasks –* provides details about every scheduled task within our application
- */sessions –* lists HTTP sessions given we are using Spring Session
- */shutdown –* performs a graceful shutdown of the application
- */threaddump –* dumps the thread information of the underlying JVM

###### health check

实现接口 `ReactiveHealthIndicator`

```java
@Component
public class DownstreamServiceHealthIndicator implements ReactiveHealthIndicator {
 
    @Override
    public Mono<Health> health() {
        return checkDownstreamServiceHealth().onErrorResume(
          ex -> Mono.just(new Health.Builder().down(ex).build())
        );
    }
 
    private Mono<Health> checkDownstreamServiceHealth() {
        // we could use WebClient to check health reactively
        return Mono.just(new Health.Builder().up().build());
    }
}
```

