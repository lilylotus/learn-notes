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