#### 1. 自动配置源码阅读

##### 1.1 自动配置的实现

```java
@SpringBootTest
public class SpringTest {
    @Autowired
	private ApplicationContext context;

	@Value("${foo:spam}")
	private String foo = "bar";
    
	@Test
	public void testContextCreated() {
		assertThat(this.context).isNotNull();
	}

	@Test
	public void testContextInitialized() {
		assertThat(this.foo).isEqualTo("bucket");
	}

	@Configuration
	@Import({ PropertyPlaceholderAutoConfiguration.class })
	public static class TestConfiguration {

	}
}
```

要实现 *spring boot* 自动配置，需要引入 `org.springframework.boot.autoconfigure.context.PropertyPlaceholderAutoConfiguration` 配置类。其实是配置了一个 `org.springframework.context.support.PropertySourcesPlaceholderConfigurer` 的资源配置类 *Bean*。

```java
@Configuration
static class PlaceholdersOverride {
    @Bean
    public static PropertySourcesPlaceholderConfigurer morePlaceholders() {
        PropertySourcesPlaceholderConfigurer configurer = new PropertySourcesPlaceholderConfigurer();
        configurer.setProperties(StringUtils.splitArrayElementsIntoProperties(new String[] { "foo=spam" }, "="));
        configurer.setLocalOverride(true);
        configurer.setOrder(0);
        return configurer;
    }
}
```



#### 1. spring boot 自动配置

##### 1.1 配置文件

`resources/META-INF/spring.factories`

```
cn.nihility.suports.IAutoImportFactory= \
  cn.nihility.suports.AutoImportImpl01, \
  cn.nihility.suports.AutoImportImpl02

指定要自动配置的接口=实现该接口的类
```

类实现示例

```java
# 要指定配置的类接口
public interface IAutoImportFactory { String getString(); }

# 该接口的实现类
public class AutoImportImpl01 implements IAutoImportFactory {
    @Override
    public String getString() { return "factory01"; }
}
# 那么 spring boot 就会自动装载该实现类
```

##### 1.2 采用 `@Enablexxx` 注解自动注入

实现 `@Enablexxx` 注解

```java
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Target(ElementType.TYPE)
// 帮助导入要的配置类
@Import(UserImportSelector.class)
public @interface EnableUserBean {}

// 这里的重点是 @Import 注解引用一个实现了 ImportSelector 接口的类型
// 最后在启动类上添加该 @Enablexx 注解
```

实现了 `ImportSelector` 接口的类，自动装载该类

```java
public class UserImportSelector implements ImportSelector {
    /* 根据获取配置类的名称 */
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        return new String[] {UserConfiguration.class.getName()};
    }
}
// 这里的重点是获取要自动导入 Bean 的配置类名称， spring boot 会当做 @Configuration 注解类处理
// 注解该处并没有 @Configuration 注解配置
public class UserConfiguration {
    @Bean
    public User getUser() { return new User("自动装载机制", 20); }
}
```

