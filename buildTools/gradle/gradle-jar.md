###### 打包为可执行 jar

build.gradle

```groovy
plugins {
    id 'java'
}

apply plugin: 'idea'
apply plugin: 'java'

sourceCompatibility = 1.8
targetCompatibility = 1.8

repositories {
    maven { url 'http://maven.aliyun.com/nexus/content/groups/public/' }
    mavenLocal()
    mavenCentral()
}

/* 不能有横线 */
project.ext {
    junitVersion = '4.12'
}

/* Gradle 指定编码 */
tasks.withType(JavaCompile) { options.encoding = "UTF-8" }
/* 或者 -Dfile.encoding=UTF-8 */

dependencies {
    testCompile group: 'junit', name: 'junit', version: "$junitVersion"
    /* 依赖 */
    /*方式1： 依赖一个名字为 "common" 的 project
    compile project(":common")
    方式2： 依赖一个本地 jar 包 依赖当前 module/libs/aliyun-vod-croe-android-sdk-1.0.0.jar
    compile files('libs/aliyun-vod-croe-android-sdk-1.0.0.jar')
    方式2 扩展：通过 fileTree 指定 dir 依赖所有的 jar 包
    compile fileTree(dir: 'libs', include: ['*.jar'])*/
}

idea {
    module {
        downloadJavadoc = true  // defaults to false
        downloadSources = true
    }
}

jar {
    /* gradle jar -Pmainclass=cn.nihility.util.LogbackUtil */
    def mainclass = project.hasProperty("mainclass") ? project.property("mainclass") : ""
    manifestContentCharset 'utf-8'
    metadataCharset 'utf-8'

    manifest {
        attributes 'Implementation-Title': 'Project Gradle Quickstart',
                'Implementation-Version': version,
                'Main-Class': "$mainclass"
    }
    /* 这个不可以放到 allprojects 当中，不然会出现 class 重复，应该放到每个独立的 project 当中*/
    from {
        configurations.compile.collect { it.isDirectory() ? it : zipTree(it) }
        /*configurations.runtime.collect { it.isDirectory() ? it : zipTree(it) }*/
    }
    /* 排除无需文件 */
    exclude 'META-INF/NOTICE*', 'META-INF/DEPENDENCIES', 'META-INF/LICENSE*', '*.dtd', '*.xsd', '*.properties', '*.xml'
    exclude('META-INF/maven/', 'META-INF/org/', 'META-INF/services/', 'META-INF/versions/')

    /* gradle jar -PallInOne  根据参数来决定是否将第三方依赖类打入自己的jar包
    if (project.hasProperty("allInOne")) {from {configurations.compile.collect { it.isDirectory() ? it : zipTree(it) }}}
    */
    /* 2. 另一种把依赖放到 lib 里面
     into('lib') { from configurations.runtime }
    * */
}
```

