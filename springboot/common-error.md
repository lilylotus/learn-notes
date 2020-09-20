*No qualifying bean of type 'javax.sql.DataSource' available: expected single matching bean but found 9: hikariDataSource01,hikariDataSource02*
**解法：**

>1. 在其中一个 DataSource Bean 构造中添加 **@Primary** 注解
>2. 在启动类上注解 **@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})**

```java
1. org.springframework.boot.autoconfigure.jdbc.DataSourceInitializer#init
if (this.applicationContext.getBeanNamesForType(DataSource.class, false, false).length > 0) {
	this.dataSource = this.applicationContext.getBean(DataSource.class);
}
2. org.springframework.beans.factory.support.DefaultListableBeanFactory#resolveNamedBean(java.lang.Class<T>, java.lang.Object...)

		else if (candidateNames.length > 1) {
			Map<String, Object> candidates = new LinkedHashMap<String, Object>(candidateNames.length);
			for (String beanName : candidateNames) {
				if (containsSingleton(beanName)) {
					candidates.put(beanName, getBean(beanName, requiredType, args));
				}
				else {
					candidates.put(beanName, getType(beanName));
				}
			}
	-------->		String candidateName = determinePrimaryCandidate(candidates, requiredType);
			if (candidateName == null) {
				candidateName = determineHighestPriorityCandidate(candidates, requiredType);
			}
			if (candidateName != null) {
				Object beanInstance = candidates.get(candidateName);
				if (beanInstance instanceof Class) {
					beanInstance = getBean(candidateName, requiredType, args);
				}
  -------->	return new NamedBeanHolder<T>(candidateName, (T) beanInstance);
			}
	-------->		throw new NoUniqueBeanDefinitionException(requiredType, candidates.keySet());
		}
```



---

#### Springboot + mybatis

```xml
/* v2.0.1 需要 springboot v2.09， v1.3.4 需要 springboot v1.5.20 */
implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:1.3.4'

-> yml
mybatis:
  mapper-locations: classpath:mybatis/mapper/*.xml
  config-location: classpath:mybatis/mybatis-config.xml
  # 在没有注解的情况下，会使用 Bean 的首字母小写的非限定类名来作为它的别名 Author -> author, 若有注解，则别名为其注解值
  type-aliases-package: cn.nihility.mybatis.dto
```

> *@MapperScan(basePackages = {"cn.nihility.mybatis.dao"})*
> 需要在 *springboot* 启动类上添加此注解来让 *mybatis* 自动扫描 dao 或者在每个 dao 接口上添加 Mybatis 的 *@Mapper*  注解

---

#### tomcat libtcnative-1.so 库

[Apache Tomcat Native Library](http://tomcat.apache.org/native-doc/) 下载库文件，下载地址 http://tomcat.apache.org/download-native.cgi

基于 debian 的 linux `apt-get install libapr1.0-dev libssl-dev`
基于 rpm 的 Linux `yum install apr-devel openssl-devel`

安装 apr，[Apr 网站](http://www.linuxfromscratch.org/blfs/view/svn/general/apr.html)，[下载地址](https://archive.apache.org/dist/apr/apr-1.7.0.tar.bz2)

```
./configure --prefix=/usr --disable-static --with-installbuilddir=/usr/share/apr-1/build
make && make install [make test]

# 文件位置 /usr/bin/apr-1-config
```

安装 native

```bash
./configure
make && make install

# 安装在 /usr/local/apr/lib 目录下
sudo ln -s /usr/local/apr/lib/libtcnative-1.so /usr/lib/libtcnative-1.so
```

##### centos

```
yum install apr-devel openssl-devel

ln -sf /opt/apache-tomcat/lib/libtcnative-1.so /root/ella/bin/libtcnative-1.so
```

