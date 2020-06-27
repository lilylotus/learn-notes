#### 1. spring boot 缓存使用

##### 1.1 添加依赖

```
implementation 'org.springframework.boot:spring-boot-starter-cache'
implementation 'net.sf.ehcache:ehcache'
```

##### 1.2 配置 cache

```yml
# application.yml
spring:
  cache:
    type: ehcache
    ehcache:
      config: classpath:ehcache/ehcache.xml
```

ehcache.xml 配置

```xml
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="ehcache.xsd">
	<!-- 稍后 @Cacheable 中使用的 name -->
    <cache name="ehcache"
           eternal="false"
           maxEntriesLocalHeap="0"
           timeToIdleSeconds="50" />

    <!-- eternal：true 表示对象永不过期，此时会忽略timeToIdleSeconds和 timeToLiveSeconds属性，默认为false -->
    <!-- maxEntriesLocalHeap：堆内存中最大缓存对象数，0没有限制 -->

    <!-- timeToIdleSeconds： 设定允许对象处于空闲状态的最长时间，以秒为 单位。当对象自从最近一次被访问后，如果处于空闲状态的时间超过了
        timeToIdleSeconds属性值，这个对象就会过期，EHCache将把它从缓存中清空。 只有当eternal属性为false，该属性才有效。如果该属性值为0，则表示对象可以
        无限期地处于空闲状态 -->
</ehcache>
```

##### 1.3 使用 spring boot ehcache

```java
// SpringBootApplication.java
@EnableCaching // 使用 caching
@SpringBootApplication
class SpringBootApplication {}

// 使用
@Service
class ServiceCaching {
    @Cacheable("ehcache") // ehcache.xml 中配置的 cache 名称
    public String cacheMethod() {}
}
```

