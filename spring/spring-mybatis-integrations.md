#### 1. Spring 和 Mybatis 的集成

*Mybatis* 的 *SqlSessionFactoryBean* 定义 ， 和 DataSource Bean 定义

```java
@Configuration
@PropertySource(value = "classpath:properties/db.properties", encoding = "UTF-8")
@ComponentScan("cn.nihility")
@MapperScan("cn.nihility.mybatis.mapper")
public class MybatisConfig {}

@Bean
public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception {
    SqlSessionFactoryBean factoryBean = new SqlSessionFactoryBean();
    factoryBean.setDataSource(dataSource);
    return factoryBean.getObject();
}

@Bean
public DataSource dataSource(@Value("${driverClassName}") String driverClassName,
                             @Value("${url}") String url,
                             @Value("${mysqlUser}") String userName,
                             @Value("${password}") String password) {
    DriverManagerDataSource dataSource = new DriverManagerDataSource();
    dataSource.setDriverClassName(driverClassName);
    dataSource.setUrl(url);
    dataSource.setUsername(userName);
    dataSource.setPassword(password);
    return dataSource;
}
```

*注意：*
`@MapperScan` 注解，扫描 Mybatis 的 Mapper 接口

#### 2. 整合笔记

##### 2.1 问题1

如何把自己产生的对象交给 spring 容器管理？
就是把第三方的对象或者自己生产的对象交给 Spring 管理？

不是使用注解 `@Component`，`@Service`，这是指把类交给 spring 管理，由 spring 容器自己生产对象，如 new。
把一个类交给 spring 管理。

- `@Bean` 注解生成 Bean。
- `FactoryBean` 接口，如果 Bean 实现了该接口，不是直接作为一个 bean 的实例暴露
- `ConfigurableListableBeanFactory beanFactory.registerSingleton` ， `SingletonBeanRegistry` 接口

```java
AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();
ctx.register(ApplicationConfig.class);

final ConfigurableListableBeanFactory beanFactory = ctx.getBeanFactory();
beanFactory.registerSingleton("BeanName", "self generate object instance.");

ctx.refresh();
```

- `BeanDefinition` -> 接口 `ImportBeanDefinitionRegistrar`
  类似的是 mybatis 的 MapperScan

```java
// 自定义 FactoryBean 类，实现 interface 接口的代理，类似于 mybatis 的 mapper
public class ImportBeanDefinitionRegistrarFactoryBean implements FactoryBean {
    private Class<?> mapperInterface;
	// getter, setter
    
    @Override
    public Object getObject() throws Exception {
        return SpringExtensionProxy.getAnnotationValue(mapperInterface);
    }

    @Override
    public Class<?> getObjectType() { return mapperInterface; }
}

// spring 拓展点 ImportBeanDefinitionRegistrar 引入 BeanDefinition
public class MyImportBeanDefinitionRegistrar implements ImportBeanDefinitionRegistrar {
    // importingClassMetadata 携带了配置类上的所有注解元数据信息
    @Override
    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
                AnnotationAttributes annotationAttributes =
                AnnotationAttributes.fromMap(importingClassMetadata.
                        getAnnotationAttributes(SpringExtensionImportScan.class.getName()));
        if (null != annotationAttributes) {
            String value = annotationAttributes.getString("value");
            System.out.println("Annotation Value " + value);
        }

		BeanDefinitionBuilder beanDefinitionBuilder = BeanDefinitionBuilder.
                genericBeanDefinition(ImportBeanDefinitionRegistrarFactoryBean.class);

        AbstractBeanDefinition beanDefinition = 
            beanDefinitionBuilder.getBeanDefinition();
        // 添加 BeanFactory 中 mapperInterface 属性值
        beanDefinition.getPropertyValues().
                add("mapperInterface", "SpringExtensionEntity");

        registry.registerBeanDefinition("defineName", beanDefinition);

    }
}

// 定义 spring @Import 注解
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Import(MyImportBeanDefinitionRegistrar.class)
public @interface SpringExtensionImportScan {
    String value() default "";
}

// 在启动类上配置
@Configuration
@SpringExtensionImportScan
public class App {}
```



##### 2.2 问题2

Spring 中 `BeanFactory` 和 `FactoryBean` 的区别？

BeanFactory 是 spring 中的 bean 工厂，可以产生 Bean 和获取 Bean，可以访问 spring bean 容器。

FactoryBean 是一个特殊的 Bean，首先 FactoryBean 自己本身也是一个 Bean，它的接口 getObject 返回的实例也在 spring 容器中。一共有两个 Bean。自定义 Bean 实例初始化的逻辑。
ctx.getBean("myBeanFactory") | ctx.getBean("&myBeanFactory")

`BeanFactory` 和一般的 `Bean` 有什么区别？

