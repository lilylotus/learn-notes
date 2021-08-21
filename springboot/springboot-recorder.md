## Springboot 关于日期时间格式化处理方式

- 请求入参为 String（指定格式）转 Date，支持get、post（content-type=application/json）
- 返回数据为Date类型转为指定的日期时间格式字符创
- 支持 Java8 日期 API，如：`LocalTime`、`localDate` 和 `LocalDateTime`

### GET 请求及 POST 表单日期时间字符串格式转换

这种情况要和时间作为 Json 字符串时区别对待，因为前端 json 转后端 pojo 底层使用的是 Json 序列化 Jackson 工具（`HttpMessgeConverter`）；而时间字符串作为普通请求参数传入时，转换用的是 `Converter`，两者在处理方式上是有区别。

#### 使用自定义参数转换器（Converter）

实现 `org.springframework.core.convert.converter.Converter`，自定义参数转换器

```java
@Configuration
public class DateConverterConfig {
    @Bean
    public Converter<String, LocalDate> localDateConverter() {
      	return new Converter<String, LocalDate>() {
            @Override
            public LocalDate convert(String source) {
                return LocalDate.parse(source, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }
        };
    }

    @Bean
    public Converter<String, LocalDateTime> localDateTimeConverter() {
        return new Converter<String, LocalDateTime>() {
            @Override
            public LocalDateTime convert(String source) {
                return LocalDateTime.parse(source, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            }
        };
    }
}
```

还可以对前端传递的 string 进行正则匹配，如 yyyy-MM-dd HH:mm:ss、yyyy-MM-dd、 HH:mm:ss 等，进行匹配。以适应多种场景。

```java
@Component
public class DateConverter implements Converter<String, Date> {
    @Override
    public Date convert(String value) {
        /**
         * 可对value进行正则匹配，支持日期、时间等多种类型转换
         * @param value
         * @return
         */
        return DateUtil.parse(value.trim());
    }
}
```

#### 使用 Spring 注解

使用 spring 自带注解 `@DateTimeFormat(pattern = "yyyy-MM-dd")`，如下：

```java
@DateTimeFormat(pattern = "yyyy-MM-dd")
private Date startDate;
```

如果使用了自定义参数转化器，Spring 会优先使用该方式进行处理，即 Spring 注解不生效。