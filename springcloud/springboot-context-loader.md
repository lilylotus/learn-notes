### 加载配置中心的配置

在 `META-INF/spring.factories` 中加载自定义配置中心配置类 `org.springframework.cloud.bootstrap.BootstrapConfiguration=`

实现接口 `org.springframework.cloud.bootstrap.config.PropertySourceLocator` 

在 `org.springframework.cloud.bootstrap.config.PropertySourceBootstrapConfiguration#initialize` 加载初始化中调用，在执行具体的配置加载 `org.springframework.cloud.bootstrap.config.PropertySourceLocator#locateCollection(org.springframework.cloud.bootstrap.config.PropertySourceLocator, org.springframework.core.env.Environment)`

<font color="red">注意：</font>这里自定义的仅负责获取配置的数据，具体的数据处理还是 cloud 自己处理的。