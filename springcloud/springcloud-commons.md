### Spring Cloud Context: Application Context Services

*Spring Boot* 对于如何构建 *Spring* 应用程序有自己坚定的见解。列如，有对于公共的配置文件有惯例约定的位置，具有公共的用于管理和监控任务的端点。*Spring Cloud* 构建在此基础之上，添加了在系统中大多数组件需要使用或偶尔使用的功能。

#### The Bootstrap Application Context

一个 *Spring Cloud*  应用程序通过创建 *bootstrap context*  来运行，它是主应用程序的父 *context*。此上下文负责从外部源加载配置属性，并负责解密本地外部配置文件中的属性。这两个 *context* 共享一个 `Environment`，该环境是任何 *Spring* 应用程序外部属性的来源。默认情况下，*bootstrap properties*（不是 *bootstrap.properties* 文件而是在引导程序阶段 (boostrap phase) 加载的属性）具有较高的优先级，因此它们不能被本地配置覆盖。

*bootstrap context* 使用和主应用程序 *context* 不同的惯例约定路径来定位外部配置文件。除了 `application.yml` （或者 `application.properties`），可以使用 `bootstrap.yml` 配置文件，将引导程序的外部配置和主上下文很好地分开。

```yaml
# bootstrap.yml
spring:
  application:
    name: foo
  cloud:
    config:
      uri: ${SPRING_CONFIG_URI:http://localhost:8888}
```

如果要检索特定的配置文件配置，设置 `spring.profiles.active` 在 `bootstrap.yml` 当中
禁用 *bootstrap process* 配置属性 `spring.cloud.bootstrap.enabled=false`

#### Application Context Hierarchies

如果你用 `SpringApplication` 或者 `SpringApplicationBuilder` 构建 *application context*，*Bootstrap context* 添加作为该 *context* 的父级。这是 *Spring* 的一个特性，子 *context* 从它的父 *context* 继承 *property sources* 和  *profiles*，所以 *main application context* 包含了额外的 *property sources*， 和构建相同 *context* 但没有 *Spring Cloud Config* 相比。这些额外的属性是：

- "bootstrap"：若是任意的 `PropertySourceLocators` 在 *bootstrap context* 中创立和它们包含不为空的属性，一个可选的 `CompositePropertySource` 伴随高优先级出现。一个示例是 *Spring Cloud Config Server* 中的属性。
- "applicationConfig:[classpath:bootstrap.yml]" 和相关的 *Spring profiles* 激活的文件：若是有一个 `bootstrap.yml` 文件，这些属性将会被用于配置 *bootstrap context*。当它的父级 *context* 设置好后会被添加到子 *context*。它们的优先级低于 `application.yml` 和别的被添加作为创建一个 *Spring Boot application* 普通部分的任意 *property sources*。

由于 *property sources* 的优先级规则，*bootstrap* 的优先级高。但是，请注意，这些文件不包含 `bootstrap.yml` 中的任何数据，该文件的优先级很低，但可用于设置默认值。

正常的 Spring 应用程序上下文行为规则适用于属性解析：子上下文中的属性会按名称以及属性源名称覆盖父级属性。（如果子级具有与父级同名的属性源，则子级中不包含父级的值）(If the child has a property source with the same name as the parent, the value from the parent is not included in the child)

```yaml
# application.yml
spring:
  profiles:
    active: env
env:
  content: applicaiton.yml
---
# application-env.yml
env:
  content: applicaiton-env.yml
# 最后 env.content 的值是 applicaiton-env.yml
```

#### Changing the Location of Bootstrap Properties

`bootstrap.ym` 位置可以由 `spring.cloud.bootstrap.name` （默认 `bootstrap`） `spring.cloud.bootstrap.location` （默认：空）或者 `spring.cloud.bootstrap.additional-location` （默认：空） 指定。

类是于 `spring.config.*` 配置的变体。

#### Overriding the Values of Remote Properties

通过引导上下文添加到应用程序中的属性源通常是 “远程的”（例如，来自 *Spring Cloud Config Server*）。默认情况下，不能在本地覆盖它们。如果要让您的应用程序使用其自己的系统属性或配置文件覆盖远程属性，远程属性源必须通过设置 `spring.cloud.config.allowOverride=true` 来授予其权限（在本地设置此属性无效）。设置该标志后，两个更细粒度的设置将控制远程属性相对于系统属性和应用程序本地配置的位置：

- `spring.cloud.config.overrideNone=true`: Override from any local property source.
- `spring.cloud.config.overrideSystemProperties=false`: Only system properties, command line arguments, and environment variables (but not the local config files) should override the remote settings.

#### Customizing the Bootstrap Configuration

*bootstrap context* 可以配置做任何你想做的事，通过向 `/META-INF/spring.factories` 文件中在 `org.springframework.cloud.bootstrap.BootstrapConfiguration` 属性下添加条目。这里保存这逗号分隔的 *Spring*  `@Configuration` 配置类列表用来创建 *context*。可以在此处创建要对主应用程序上下文可用以进行自动装配的任何 bean。

> 注意自定义配置 `BootstrapConfiguration` 不要扫描到错误的 *package*，可以把 *cloud* 使用的包和 `@ComponentScan` 或者 `@SpringBootApplication` 扫描的包分隔开来。

引导过程通过将初始化程序注入主 *SpringApplication* 实例而结束（无论是作为独立应用程序运行还是在应用程序服务器中部署，这都是正常的Spring Boot启动顺序）。首先，从 `spring.factories` 中找到的类来创建引导上下文。然后，所有 `ApplicationContextInitializer` 类型的 `@Beans` 会被添加到主 `SpringApplication` 在它启动之前。