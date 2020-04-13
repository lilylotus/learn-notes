###### 特点

- Distributed/versioned configuration (分布式/版本化 配置)
- Service registration and discovery (服务注册和发现)
- Routing (路由)
- Service-to-service calls (服务间调用)
- Load balancing (负载均衡)
- Circuit Breakers (熔断器)
- Distributed messaging (分布式消息传递)

###### 开发组件

- 服务发现 - Netflix、Eureka
- 客户端负载均衡 - Netflix Ribbon
- 熔断器 - Netflix Hystrix
- 服务网关 - Netflix Zuul
- 分布式配置 - Spring Cloud Config

###### Springone

- Configuration
- Service Discovery
- Circuit Breakers
- Routing and Messaging
- API Gateway
- Tracing
- CI Pipelines and Testing

---

###### spring cloud config 配置

spring cloud config *Http* request.

```xml
/{application}/{profile}[/{label}]
/{application}-{profile}.yml
/{label}/{application}-{profile}.yml
/{application}-{profile}.properties
/{label}/{application}-{profile}.properties
```

`application` 是由 `spring.config.name` 注入到 `SpringApplication` 中的。`profile` 是激活了的 *profile*
`label` 是 *git* 的分支，默认是 *master*

*Spring Cloud Config Server* 配置

```yml
# 配置 git 中的配置文件路径
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          uri: https://github.com/lilylotus/self-springcloud-learn.git # 使用远程 git 地址
          uri: file://${user.home}/dandelion/programming/git/self-springcloud-learn # 本地
          search-paths: config # 查询的文件夹

# 默认的 config server 运行在 8888 端口
```

*Spring Cloud config Client* 配置

```xml
<!-- pom.xml 文件配置 -->
<!-- repositories also needed for snapshots and milestones -->
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>{spring-boot-docs-version}</version>
    <relativePath /> <!-- lookup parent from repository -->
</parent>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>{spring-cloud-version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-config</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

```properties
# 改变默认的 spring cloud config server 端口， 8888
# bootstrap.properties (和 application.properties 类似)
spring.cloud.config.uri: http://myconfigserver.com

# 默认如果没有 application name 配置， application 会被使用
# 改变 name，添加如下属性到 bootstrap.properties 文件中
spring.application.name: myapp
```

展示 *bootstrap.properteis* 配置， `/env -> curl localhost:8080/env`

###### Spring cloud config server 使用

```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServer {
  public static void main(String[] args) {
    SpringApplication.run(ConfigServer.class, args);
  }
}
// 添加 @EnableConfigServer 注解，表示为 Application 配置服务
```

*配置 config server 的两种方式，默认是 8888 端口*

*方式一：*  配置属性 `spring.config.name=configserver` ，然后在添加 `configserver.yml` 到 *jar*。
*方式二*： 使用自定义的 `application.yml` 配置文件

```properties
server.port: 8888
spring.cloud.config.server.git.uri: file://${user.home}/config-repo

# ${user.home}/config-repo 是 git 仓库中 YAML 和 属性 文件
# 注意，在 windows 中，要显示的添加 "/" 前缀，(/${user.home}/config-repo)
```

```bash
# 建立本地的 git 测试仓库
$ cd $HOME
$ mkdir config-repo
$ cd config-repo
$ git init .
$ echo info.foo: bar > application.properties
$ git add -A .
$ git commit -m "Add application.properties"
```

###### config server 环境配置

- `{application}`, which maps to `spring.application.name` on the client side.
- `{profile}`, which maps to `spring.profiles.active` on the client (comma-separated list).
- `{label}`, which is a server side feature labelling a "versioned" set of config files.

loading configuration files from a `spring.config.name` equal to the `{application}` parameter, 
and `spring.profiles.active` equal to the `{profiles}` parameter.
Precedence rules for profiles are also the same as in a regular Spring Boot application: Active profiles take 配置文件的优先规则也与常规 *Spring Boot* 应用程序中的规则相同：活动配置文件的优先级高于默认值，如果有多个配置文件，则最后一个优先（类似于向Map中添加条目）。

示例 *boostrap.yml*

```yaml
spring:
  application:
    name: foo
  profiles:
    active: dev,mysql
```

*GIT 后端仓库配置*
如果 `{label}` 中包含了斜线 `/` 就要换为 `(_)`，例如 `foo/bar` -> `foo(_)bar`

*常用链接配置*

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://example.com/my/repo
          skipSslValidation: true # 跳过 SSL Certificate 校验
          timeout: 4 # HTTP Connection Timeout， git.timeout

# 特殊的 uri ： https://github.com/myorg/{application}
# {application} {profile} {label}
# 注意： 使用 "(_)" 支持多个组织，  organization(_)application
```

*模式匹配多个仓库* `{application}/{profile}`

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          repos:
            simple: https://github.com/simple/config-repo
            special:
              pattern: special*/dev*,*special*/dev*
              uri: https://github.com/special/config-repo
            local:
              pattern: local*
              uri: file:/home/configsvc/config-repo
            development:
              pattern:
                - '*/development'
                - '*/staging'
              uri: https://github.com/development/config-repo
            staging:
              pattern:
                - '*/qa'
                - '*/production'
              uri: https://github.com/staging/config-repo              
```

*扫描文件路径* `searchPaths`

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/spring-cloud-samples/config-repo
          searchPaths: foo,bar*
          searchPaths: '{application}' # 动态改变 {application} {profile} {label}
# 授权
          username: trolley
          password: strongpassword
```

*config server 健康检查*

```yaml
spring:
  cloud:
    config:
      server:
        health:
          repositories:
            myservice:
              label: mylabel
            myservice-dev:
              name: myservice
              profiles: development
# 禁用检查 spring.cloud.config.server.health.enabled=false
```

