#### 依赖注入

> 基础的 Annotation Bean 注入注解支持 Component/Service/Controller/Repository

**注意：**.properties* 格式的文件不支持中文，必须把中文转换为 ASCII 码， *.yml* 支持中文



统一前缀的注解：*org.springframework.boot.context.properties.ConfigurationProperties*

```java
@Component
@ConfigurationProperties(prefix = "inject")
public class InjectBeanDemo {

--> application-dev.yml
inject:
  name: 小红
  age: 18
  address:
    - 重庆
    - 上海
    - 广州
  address1: [上海, 重庆, 北京]
  grades:
    math: 99
    english: 88
    chinese: 89
    chemistry: 70
  grades1: {math: 99, english: 88, chinese: 77}
  group: {dance: [小米, 小妹], guitar: ~, music: [威威, Steve]}
```

*指定引入的 properties 文件配置：*

```java
@PropertySource() 指定加载配置文件,但是仅仅支持 properties 配置文件
@Component
@PropertySource(encoding = "UTF-8", value = {"classpath:properties/inject.properties"})
public class InjectBeanDemo2 {

--> inject.properties
name = 小米
age = 10
```



*@propertySource + @ConfigurationProperties 指定前缀注入 properties 属性*

```java
@Configuration
@PropertySource(value = {"classpath:properties/inject.properties"}, encoding = "UTF-8")
public class InjectBeanDemo3 {
    @Bean
    @ConfigurationProperties(prefix = "property")
    public InnerClass innerClass() {
        return new InnerClass();
    }
    @Data
    public static class InnerClass {
        private String name;
        private Integer age;
    }
}

-> inject.properties
property.name = Inject小米
property.age = 20
    
--> InjectBeanDemo3.InnerClass(name=Inject小米, age=20)
```



**注意：** *@Bean, @Component, @Service, @Controller, @Property* 放到方法上，放回的 *bean* 的名称为方法的名称

---

#### @Autowired 注入的几种模式说明

> 四种模式 ： byName、byType、constructor、autodectect
> @Qualifier(value = "basicDataSource") 没有作用,不能够按照指定的名称注入 Bean
>
> 执行顺序：
>
> 1. 先查找 Autowired 指定类型的 Bean
> 2. 若没有找到 Bean 则会报异常
> 3. 找到一个指定类型的 Bean 则会自动匹配，并把 Bean 装配到要 Inject 的字段当中
> 4. 若有多个 Bean 则按照注入字段的名称匹配注入 Bean 值，匹配成功后装配到指定字段当中

