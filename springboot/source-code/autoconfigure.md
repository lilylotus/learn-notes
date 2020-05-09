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



