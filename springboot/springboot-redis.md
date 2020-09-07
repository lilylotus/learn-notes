#### spring boot 添加 redis 依赖

```groovy
/* spring boot redis 操作 */
implementation "org.springframework.boot:spring-boot-starter-data-redis"
/* spring-boot-starter-data-redis 依赖 commons-pool2 连接池 */
implementation 'org.apache.commons:commons-pool2:2.8.1'
/* redis 分布式锁 */
implementation 'org.redisson:redisson:3.13.4'
```

#### redis 配置

##### application.yml 配置

```yaml
spring:
  redis:
    host: localhost
    port: 6379
    database: 12
    password: redis
    timeout: 3000
    lettuce:
      pool:
        # lettuce 采用多路复用原理，真正工作的连接受制于 CPU 核数，增大连接数反而增加了线程上下文切换时间
        # 连接池最大连接数（使用负值表示没有限制） (CPU cores + 1)
        max-active: 5
        # 连接池中的最大空闲连接
        max-idle: 4
        # 连接池中的最小空闲连接
        min-idle: 0
        # 连接池最大阻塞等待时间（使用负值表示没有限制）
        max-wait: 1000
      # 关闭超时时间
      shutdown-timeout: 100
```

##### Redis 配置

```java
@Configuration
public class RedisConfiguration extends CachingConfigurerSupport {

    private static final Logger log = LoggerFactory.getLogger(RedisConfiguration.class);

    /**
     * 自定义缓存 key 的生成策略，默认的生成策略是看不懂的(乱码内容)
     * 通过 Spring 的依赖注入特性进行自定义的配置注入并且此类是一个配置类可以更多程度的自定义配置
     */
    @Override
    public KeyGenerator keyGenerator() {
        log.info("RedisConfiguration : configuration keyGenerator");
        return (target, method, params) -> {
            StringBuilder sb = new StringBuilder();
            sb.append(target.getClass().getName()).append(":");
            sb.append(method.getName()).append(":");
            for (Object obj : params) {
                sb.append(obj.toString()).append(":");
            }
            return sb.toString();
        };
    }

    /**
     * 缓存配置管理器
     */
    @Bean
    public CacheManager cacheManager(LettuceConnectionFactory factory) {
        log.info("RedisConfiguration : Generate CacheManager");
        // 以锁写入的方式创建 RedisCacheWriter 对象
        RedisCacheWriter writer = RedisCacheWriter.lockingRedisCacheWriter(factory);
        // 创建默认缓存配置对象
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig();
        return new RedisCacheManager(writer, config);
    }

    @Bean
    @ConditionalOnMissingBean(name = "redisTemplate")
    public RedisTemplate<String, Object> redisTemplate(LettuceConnectionFactory connectionFactory) {
        log.info("RedisConfiguration : Generate RedisTemplate");
        RedisTemplate<String, Object> redisTemplate = new RedisTemplate<>();
        redisTemplate.setConnectionFactory(connectionFactory);

        ObjectMapper om = new ObjectMapper();
        om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);

        Jackson2JsonRedisSerializer<Object> jackson2JsonRedisSerializer = new Jackson2JsonRedisSerializer<>(Object.class);
        jackson2JsonRedisSerializer.setObjectMapper(om);
        StringRedisSerializer stringRedisSerializer = new StringRedisSerializer();
        // 在使用注解 @Bean 返回 RedisTemplate 的时候，同时配置 hashKey 与 hashValue 的序列化方式。
        /* Key 值序列化 */
        // key 采用 String 的序列化方式
        redisTemplate.setKeySerializer(stringRedisSerializer);
        // hash 的 key 也采用 String 的序列化方式
        redisTemplate.setHashKeySerializer(jackson2JsonRedisSerializer);
        /* Value 值序列化 */
        // value 序列化方式采用 jackson
        // 使用它操作普通字符串，会出现 Could not read JSON template.setValueSerializer(jackson2JsonRedisSerializer);
        redisTemplate.setValueSerializer(stringRedisSerializer);
        // hash 的 value 序列化方式采用 jackson
        redisTemplate.setHashValueSerializer(jackson2JsonRedisSerializer);

        redisTemplate.afterPropertiesSet();
        return redisTemplate;
    }

}

```

#### Spring 提供操作 redis 的 API

##### 类型一

```java
// ===== 类型一
ValueOperations： 字符串类型操作
ListOperations：  列表类型操作
SetOperations：   集合类型操作
ZSetOperations：  有序集合类型操作
HashOperations：  散列操作

ValueOperations<String, String> valueOperations = stringRedisTemplate.opsForValue();
ListOperations<String, String> listOperations = stringRedisTemplate.opsForList();
SetOperations<String, String> setOperations = stringRedisTemplate.opsForSet();
ZSetOperations<String, String> zSetOperations = stringRedisTemplate.opsForZSet();
HashOperations<String, Object, Object> hashOperations = stringRedisTemplate.opsForHash();
```

##### 类型二

```java
// ===== 类型二
BoundValueOperations：   字符串类型操作
BoundListOperations：    列表类型操作
BoundSetOperations：     集合类型操作
BoundZSetOperations：    有序集合类型操作
BoundHashOperations：	散列操作

BoundValueOperations<String, String> valueOperations = stringRedisTemplate.boundValueOps("key");
BoundListOperations<String, String> listOperations = stringRedisTemplate.boundListOps("key");
BoundSetOperations<String, String> setOperations = stringRedisTemplate.boundSetOps("key");
BoundZSetOperations<String, String> zSetOperations = stringRedisTemplate.boundZSetOps("key");
BoundHashOperations<String, Object, Object> hashOperations = stringRedisTemplate.boundHashOps("key");
```

>从上面两组实现可以发现，类型二 API 只是在类型一 API 的上面将 key 值的绑定放在获得接口时了，此举方便了每次操作基本数据类型的时候不用反复的去填写 key 值，只需要操作具体的 value 就行了。