#### 1. spring 配置解析

##### 1.1 spring context 加载配置

两种 *context* 公用一个 *Environment*  ， *applicaiton.yml / bootstrap.yml*
<font color="red">注意：由于 bootstrap.yml 的加载优先级最低还不在 spring bootstrap 阶段加载，不应该配置数据，但可以放置默认值</font>
<font color="blue">application.yml 的优先级高于 bootstrap.yml</font>

```yml
spring:
  application:
    name: foo
  cloud:
    config:
      uri: ${SPRING_CONFIG_URI:http://localhost:8888}
```

`spring.application.name` 配置到 `bootstrap.yml` 或者 `application.yml`。
若是作为 *spring* 的 *context id*，那么必定配置到 `bootstrap.yml` 当中。
 `spring.profiles.active` 选择指定的 *profile*，仍然配置  `bootstrap.[properties | yml]`
`spring.cloud.bootstrap.enabled=false` 禁止 *bootstrap* 处理。

<font color="red">注意： spring cloud 的远程配置不能覆盖本地配置属性。</font>

`spring.cloud.config.allowOverride=true` 若是想让远程配置覆盖本地配置，需要在远程配置文件中声明，**注意：** 在本地配置文件中声明不起作用
`spring.cloud.config.overrideNone=true` 可覆盖任意本地属性
`spring.cloud.config.overrideSystemProperties=false` 不可覆盖系统属性或手动配置属性

##### 1.2 spring boot 扫描配置文件顺序

`applicaiton.yml / applicaiton.properties`

```
工程根目录:	./config/
工程根目录：	./
classpath:	/config/
classpath:	/
```

加载的优先级顺序是从上向下加载，并且所有的文件都会被加载
上面位置加载的配置项会覆盖下面位置加载的配置项，形成互补配置

手动指定位置：`java -jar xxxx.jar --spring.config.location=app/application.yml`
多个配置中间用空格分开

---

Spring Cloud Config 提供了 *server-side* 和 *client-side* 的支持为分布式系统中的外部配置。使用 Config Server，您可以在中心地方管理所有环境中应用程序的外部属性。客户端和服务端的概念映射与 *spring*  的 `Environment` 和 `PropertySource` 抽象完全相同，如此它们非常适合 *spring* 应用，但是可以使用在运行任意语言的应用程序。作为一个应用程序经过从 dev 到 test 到 production 的开发流程，你可以管理这些环境之间的配置，然后确保应用程序在迁移后需要运行时有所需要的所有配置。服务存储后端默认实现使用  git，那么就十分容易的支持配置环境的标记版本，并且可以通过各种工具来访问这些内容来管理内容。添加替代实现并将其插入Spring配置很容易。

查找顺序，`label` 对应的是 git 的分支，默认 *master*

```
/{application}/{profile}[/{label}]
/{application}-{profile}.yml
/{label}/{application}-{profile}.yml
/{application}-{profile}.properties
/{label}/{application}-{profile}.properties
```

```yaml
# spring cloud server configuration
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
```

查看配置环境 `curl localhost:8080/env`

#### Config Server

配置文件地址查找配置

```properties
server.port: 8888
spring.cloud.config.server.git.uri: file://${user.home}/config-repo
```

> Windows 上需要配置为 `file:///${user.home}/config-repo`

```bash
	
# The following listing shows a recipe for creating the git repository in the preceding example:
$ mkdir config-repo
$ cd config-repo
$ git init .
$ echo info.foo: bar > application.properties
$ git add -A .
$ git commit -m "Add application.properties"
```

##### Environment Repository

您应该在哪里存储配置服务器的配置数据？控制此行为的策略是为 `Environment` 对象提供服务的`EnvironmentRepository`。

- `{application}`, which maps to `spring.application.name` on the client side.
- `{profile}`, which maps to `spring.profiles.active` on the client (comma-separated list).
- `{label}`, which is a server side feature labelling a "versioned" set of config files.


### spring cloud config

#### 自动刷新生效条件

添加注解 `@EnableDiscoveryClient`

<font color="red">tip</font> 使用配置中心时，部分配置会自动刷新，使用 `@ConfigurationProperties` 注解的会自动刷新配置，`@Value` 的不会自动刷新，需要添加 `@RefreshScope` 注解在自动刷新的 Bean 上才会自动刷新配置。

使用 `@ConfigurationProperties` 或者 `@Value` + `@RefreshScope` 注解。