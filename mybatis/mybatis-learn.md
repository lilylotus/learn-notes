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

---

#### 2. Mybatis 查询方式

##### 2.1 嵌套查询

```xml
<!-- 嵌套查询 -->
<resultMap id="selectTeachingStudentsByTeacherIdUseEmbedQueryMap" type="teacher">
    <id column="teacher_id" property="teacherId" />
    <result property="teacherName" column="teacher_name" />
    <result property="teacherAge" column="teacher_age" />
    <result property="collegeId" column="college_id" />
    <association property="college" column="college_id" javaType="college"
                 select="cn.nihility.mybatis.mapper.TeacherMapper.selectCollegeById" />
    <collection property="students" column="teacher_id" ofType="student"
                select="cn.nihility.mybatis.mapper.TeacherMapper.selectStudentsByTeacherId" />
</resultMap>
```

嵌套查询的弊端：即嵌套查询的N+1问题
尽管嵌套查询大量的简化了存在关联关系的查询
弊端也比较明显：即所谓的 N+1 问题。关联的嵌套查询显示得到一个结果集，然后根据这个结果集的每一条记录进行关联查询。
现在假设嵌套查询就一个（即 resultMap 内部就一个 association 标签），现查询的结果集返回条数为 N，那么关联查询语句将会被执行 N 次，加上自身返回结果集查询 1 次，共需要访问数据库 N+1 次。如果 N 比较大的话，这样的数据库访问消耗是非常大的！所以使用这种嵌套语句查询的使用者一定要考虑慎重考虑，确保 N 值不会很大。

##### 2.2 嵌套结果

```xml
<!-- 嵌套结果  -->
<resultMap id="studentWithTeachers" type="student">
    <id column="teacher_id" property="teacherId" />
    <result property="teacherName" column="teacher_name" />
    <result property="teacherAge" column="teacher_age" />
    <result property="collegeId" column="college_id" />
    <association property="college" javaType="college">
        <id property="collegeId" column="college_id" />
        <result property="collegeName" column="college_name" />
    </association>
    <collection property="teachers" ofType="teacher">
        <id property="studentId" column="student_id" />
        <result property="studentName" column="student_name" />
        <result property="studentAge" column="student_age" />
    </collection>
</resultMap>
```

嵌套语句的查询会导致数据库访问次数不定，进而有可能影响到性能。
Mybatis 还支持一种嵌套结果的查询：即对于一对多，多对多，多对一的情况的查询，Mybatis 通过联合查询，将结果从数据库内一次性查出来，然后根据其一对多，多对一，多对多的关系和 ResultMap 中的配置，进行结果的转换，构建需要的对象。