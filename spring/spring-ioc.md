### spring IOC 容器初始化

`org.springframework.context.support.AbstractApplicationContext#invokeBeanFactoryPostProcessors` 方法解析和加载所有 *classpath* 下的 `@Component` 注解等需要加载到 *spring* 容器的元数据。

`org.springframework.context.support.AbstractApplicationContext#finishBeanFactoryInitialization` 方法实例化所有需要加载到 *spring* 容器的类。

### spring 加载/解析需要加入 IOC 容器的类

`PostProcessorRegistrationDelegate.invokeBeanFactoryPostProcessors(beanFactory, getBeanFactoryPostProcessors());` 主要是执行这个静态方法。

<font color="red">注意：</font>贯穿变量为 `ConfigurationClass` 和 `beanFactory`

<font color="red">重点：</font>`PostProcessorRegistrationDelegate#invokeBeanDefinitionRegistryPostProcessors` 首次调用使用的是 `ConfigurationClassPostProcessor#postProcessBeanDefinitionRegistry` 来扫描 `@Configuration` 注解配置类。-> `ConfigurationClassUtils#checkConfigurationClassCandidate`

获取配置类 `BeanDefinitionRegistryPostProcessor`

`ConfigurationClassParser#parse()` 来解析所有 `@Configuration` 注解配置类。
`ConfigurationClassParser#doProcessConfigurationClass` 来解析类，解析逻辑顺序：

1. 扫描 `@Component` 注解类中是否有内部类，筛选 `@Import`/`@Component`/`@ImportResource`/`@ComponentScan`/`@Bean` 注解内部类
2. 处理 `@PropertySource` 注解
3. 解析扫描 `@ComponentScans` 和  `@ComponentScan` 注解中配置包中的 `@Component` 注解类，在使用 `ComponentScanAnnotationParser#parse` 解析，生成 `ScannedGenericBeanDefinition`，在把扫描到的配置类在做一遍解析。
4. 处理 `@Import` 注解， 其中 `ImportBeanDefinitionRegistrar`接口实现 是添加到 `importBeanDefinitionRegistrars` 中。其它的递归执行 `ConfigurationClassParser#processConfigurationClass` 扫描类。
5. 引入外部资源 `@ImportResource`
6. 处理内部类的 `@Bean` 注解，添加 `BeanMethod` 类。
7. 处理接口的默认方法中的 `@Bean` 注解
8. 最后在递归处理当前 `@Configuration` 注解类的父级类。

### 实例化所扫描到的配置类

`AbstractApplicationContext#finishBeanFactoryInitialization`

<font color="red">注意：</font> spring 实例化容器时的循环依赖。

`AbstractBeanFactory#doGetBean`

`AbstractAutowireCapableBeanFactory#createBean(String, RootBeanDefinition, Object[])`

`AbstractAutowireCapableBeanFactory#doCreateBean`

`AbstractAutowireCapableBeanFactory#createBeanInstance`

`AbstractAutowireCapableBeanFactory#instantiateBean` (`BeanWrapperImpl` 类)