### buildscript 代码块的作用

倘若 *gradle* 构建脚本本身需要使用额外的库依赖，那就可以添加依赖到构建脚本的类路径中。实现这个需要使用 `buildscript()` 方法，传入声明的构建类路径到该块中。

```groovy
buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath group: 'commons-codec', name: 'commons-codec', version: '1.2'
    }
}
```

在 `build.gradle` 中声明了该 `buildscript()` 方法，指定构建是所需要的额外依赖，在下面就可以使用此依赖库。

```groovy
import org.apache.commons.codec.binary.Base64
task encode {
    doLast {
        def byte[] encodedString = new Base64().encode('hello world\n'.getBytes())
        println new String(encodedString)
    }
}
```

### 添加 Spring Boot 依赖管理和插件

```groovy
plugins {
    id 'org.springframework.boot' version '2.3.3.RELEASE'
    id 'io.spring.dependency-management' version '1.0.10.RELEASE'
    id 'java'
    id 'idea'
}
```