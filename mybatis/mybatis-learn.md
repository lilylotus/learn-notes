##### mybatis 开始配置

###### mysql 链接配置：

```properties
driver=com.mysql.cl.jdbc.Driver
url=jdbc:mysql://localhost:50000/test?serverTime=UTC&characterEncoding=utf8&useUnicode=true&useSSL=false
username=
password=
```

###### mybatis 配置：mybatis-config.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

    <properties resource="properties/mysql.properties"></properties>

    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="POOLED">
                <property name="driver" value="${driver}"/>
                <property name="url" value="${url}"/>
                <property name="username" value="${username}"/>
                <property name="password" value="${password}"/>
            </dataSource>
        </environment>
    </environments>

    <databaseIdProvider type="DB_VENDOR">
        <property name="Oracle" value="oracle"/>
        <property name="MySQL" value="mysql"/>
    </databaseIdProvider>

    <mappers>
        <mapper resource="mybatis/mapper/UserMapper.xml"/>
    </mappers>

</configuration>
```



###### mybatis mapper 配置 xxMapper.xml

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="cn.nihility.mybatis.mapper.UserMapper">

</mapper>
```



###### 执行 mybatis 查询

```java
InputStream resource = Resources.getResourceAsStream(MYBATIS_CONFIG);
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(resource);
try (SqlSession sqlSession = sqlSessionFactory.openSession()) {
    final UserMapper mapper = sqlSession.getMapper(UserMapper.class);
    final List<User> allUser = mapper.getAllUser();
    System.out.println(allUser);
}
```



---

##### mybatis config 配置详解：

###### settings

```xml
<settings>
    <setting name="cacheEnabled" value="true"/>
    <setting name="lazyLoadingEnabled" value="true"/>
    <!-- 驼峰命名 -->
    <setting name="mapUnderscoreToCamelCase" value="true"/>
    <setting name="jdbcTypeForNull" value="NULL"/>
</settings>
```

###### typeAliases 类型别名

```xml
<typeAliases>
    <package name="cn.nihility.mybatis.entity"/>
</typeAliases>

注意： 在使用 package 的时候，如果包中类有注解 @Alias("name") 就会以该注解为准。
domain.blog.Author --> author 是这样对应的。

<!-- 或者一个一个的定义 -->
<typeAliases>
    <typeAlias alias="Author" type="domain.blog.Author"/>
</typeAliases>
```

Java 常用数据类型别名

| Alias      | Mapped Type |
| :--------- | :---------- |
| _byte      | byte        |
| _int       | int         |
| _integer   | int         |
| string     | String      |
| int        | Integer     |
| integer    | Integer     |
| date       | Date        |
| decimal    | BigDecimal  |
| bigdecimal | BigDecimal  |
| object     | Object      |
| map        | Map         |
| hashmap    | HashMap     |
| list       | List        |
| arraylist  | ArrayList   |
| collection | Collection  |
| iterator   | Iterator    |

###### mapper 配置

```xml
<mappers>
    <mapper resource="mybatis/mapper/UserMapper.xml"/>
</mappers>
注意： mapper 中仅能配置 resource、url、class 其中一个

<!-- 或这配置 package， 注意 mapper 和 package 不可同时存在 -->
<mappers>
    <package name="cn.nihility.mybatis.mapper"/>
</mappers>
```

