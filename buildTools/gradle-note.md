#### 1. springboot gradle 打包

文件操作：https://docs.gradle.org/current/userguide/working_with_files.html
springboot: https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/gradle-plugin/reference/html/

build.gradle

```groovy
// 执行命令，返回结果
def branchName = "git rev-parse --abbrev-ref HEAD".execute().text.trim()
def branchCommitId = "git rev-parse HEAD".execute().text.trim()

bootJar {
    excludes = ["*.jar", "*.xml", "*.yml"]
    manifest {
        attributes "branchName": "$branchName"
        attributes "commitId": "$branchCommitId"
    }
}

task packageDistribution(type: Zip) {
    archiveFileName = "distribution.zip"
    destinationDirectory = file("$buildDir/dist")

    from "$buildDir/toArchive"
    from("$buildDir/toArchive") {
        exclude "**/*.pdf"
    }
    from("$buildDir/toArchive") {
        include "**/*.pdf"
        into "docs"
    }
}

tasks.withType(JavaCompile) { options.encoding = "UTF-8" }

/* source / doc 包 */
/* sourceSets.main.allJava / sourceSets.main.allSource */
task sourcesJar(type: Jar, dependsOn: classes) {
    classifier = 'sources'
    from sourceSets.main.allJava
}

task javadocJar(type: Jar, dependsOn: javadoc) {
    classifier = 'javadoc'
    from javadoc.destinationDir
}

tasks.withType(Javadoc) {
    options.addStringOption('Xdoclint:none', '-quiet')
    options.addStringOption('encoding', 'UTF-8')
    options.addStringOption('charSet', 'UTF-8')
}

artifacts {
    archives sourcesJar
    archives javadocJar
}
```

build.gradle.kts

```kotlin
configurations {
    all {
        exclude(group = "org.springframework.boot", module = "spring-boot-starter-logging")
        exclude(module = "logback-classic")
        exclude(module = "log4j-over-slf4j")
        exclude(module = "slf4j-log4j12")
    }
}

tasks.named<BootJar>("bootJar") {
    excludes.add("**/*.yml")
}

tasks.create<Zip>("zip") {
    archiveFileName.set("KIAM-DataDistribute.zip")
    destinationDirectory.set(file("$buildDir/distributions"))

    from("$buildDir/libs") {
        into("target")
    }
    from("bin/main") {
        into("conf")
    }
    from("bin") {
        include("*.sh")
        into("bin")
    }
}.dependsOn("bootJar")
```

#### 2. gradle java 插件打包

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

#### 3. gradle 可执行 jar 包

##### 3.1 所有所需依赖放到一个可执行 jar 包中

生成的 jar 包过大，所有的依赖包都打包到了一起。

```groovy
plugins {
    id 'java'
}

group 'cn.nihility.exec'
version '1.0-SNAPSHOT'

[compileJava, compileTestJava, javadoc]*.options*.encoding = 'utf-8'
[compileJava, compileTestJava]*.sourceCompatibility = "1.8"
[compileJava, compileTestJava]*.targetCompatibility = "1.8"
tasks.withType(JavaCompile) { options.encoding = 'UTF-8' }

ext {
    jarName = project.name
    mainClassName = 'cn.nihility.exec.HelloWorld'
    junitVersion = '4.12'
}

repositories {
    mavenLocal()
    maven { url 'http://maven.aliyun.com/nexus/content/groups/public/' }
    mavenCentral()
}

dependencies {
    testImplementation "junit:junit:$junitVersion"
    implementation fileTree(dir: 'D:\\coding\\jars', includes: ["*.jar"])
    implementation 'com.fasterxml.jackson.core:jackson-databind:2.11.2'
}

jar {
    /* configurations.runtime 使用 compile 引入的依赖
    *  implementation 引入的依赖，要使用 configurations.runtimeClasspath
    *  configurations.runtimeClasspath 可以打包 compile/implementation 的依赖
    *  testImplementation 引入的依赖，则使用 configurations.testRuntimeClasspath
    * */
    from {
        configurations.runtimeClasspath.collect { it.isDirectory() ? it : zipTree(it) }
    }
    manifest {
        attributes "Manifest-Version": 1.0
        attributes 'Built-By': System.getProperty("user.name")
        attributes 'Main-Class':"$mainClassName"
    }
    exclude('LICENSE.txt', 'NOTICE.txt', 'rootdoc.txt')
    exclude 'META-INF/*.RSA', 'META-INF/*.SF', 'META-INF/*.DSA'
    exclude 'META-INF/NOTICE', 'META-INF/NOTICE.txt'
    exclude 'META-INF/LICENSE', 'META-INF/LICENSE.txt'
    exclude 'META-INF/DEPENDENCIES'
}

sourceSets {
    main { java { srcDirs = ['src/main/java', 'src/main/resources'] } }
    test { java { srcDirs = ['src/test/java', 'src/test/resources'] } }
}

task mkdirs() {
    sourceSets*.java.srcDirs*.each { it.mkdirs() }
    sourceSets*.resources.srcDirs*.each { it.mkdirs() }
}
```

##### 3.2 所需依赖 jar 放到一个 lib 目录

```groovy
plugins {
    id 'java'
}

group 'cn.nihility.exec'
version '1.0-SNAPSHOT'

[compileJava, compileTestJava, javadoc]*.options*.encoding = 'utf-8'
[compileJava, compileTestJava]*.sourceCompatibility = "1.8"
[compileJava, compileTestJava]*.targetCompatibility = "1.8"
tasks.withType(JavaCompile) { options.encoding = 'UTF-8' }

ext {
    mainClassName = 'cn.nihility.exec.HelloWorld'
    junitVersion = '4.12'
}

repositories {
    mavenLocal()
    maven { url 'http://maven.aliyun.com/nexus/content/groups/public/' }
    mavenCentral()
}

dependencies {
    testImplementation "junit:junit:$junitVersion"
    implementation fileTree(dir: 'D:\\coding\\jars', includes: ["*.jar"])
    implementation 'com.fasterxml.jackson.core:jackson-databind:2.11.2'
}

task clearJar(type: Delete) {
    delete "$buildDir\\libs"
}

task copyJar(type: Copy) {
    from configurations.runtimeClasspath
    into "$buildDir\\libs\\lib"
}

jar {
    /* configurations.runtime 使用 compile 引入的依赖
    *  implementation 引入的依赖，要使用 configurations.runtimeClasspath
    *  configurations.runtimeClasspath 可以打包 compile/implementation 的依赖
    *  testImplementation 引入的依赖，则使用 configurations.testRuntimeClasspath
    * */
    /*from {
        configurations.runtimeClasspath.collect { it.isDirectory() ? it : zipTree(it) }
    }*/
    dependsOn clearJar
    dependsOn copyJar
    def dateStr = new Date().format('yyyyMMdd')
    archiveBaseName = "$project.name-$dateStr"
    if (!configurations.runtimeClasspath.isEmpty()) {
        //manifest.attributes('Class-Path': '. lib/' + configurations.runtimeClasspath.collect { println it.name ; it.name }.join(' lib/'))
        manifest.attributes('Class-Path': '. ' + configurations.runtimeClasspath.files.collect { println it.name; "lib/$it.name" }.join(' '))
    }
    manifest {
        attributes "Manifest-Version": 1.0
        attributes 'Built-By': System.getProperty("user.name")
        attributes 'Main-Class':"$mainClassName"
    }
    exclude('LICENSE.txt', 'NOTICE.txt', 'rootdoc.txt')
    exclude 'META-INF/*.RSA', 'META-INF/*.SF', 'META-INF/*.DSA'
    exclude 'META-INF/NOTICE', 'META-INF/NOTICE.txt'
    exclude 'META-INF/LICENSE', 'META-INF/LICENSE.txt'
    exclude 'META-INF/DEPENDENCIES'
}

task zip(type: Zip, dependsOn: [jar]) {
    archiveFileName = "exec.zip"
    destinationDirectory = file("$buildDir/dist")

    from("$buildDir/libs") {
        /*into("lib")*/
    }

    /*from("$buildDir/libs") {
        into("")
    }*/
}

sourceSets {
    main { java { srcDirs = ['src/main/java', 'src/main/resources'] } }
    test { java { srcDirs = ['src/test/java', 'src/test/resources'] } }
}

task mkdirs() {
    sourceSets*.java.srcDirs*.each { it.mkdirs() }
    sourceSets*.resources.srcDirs*.each { it.mkdirs() }
}

```

##### 3.3 springboot2.x gradle 单独打包

```groovy
def branchName = "git rev-parse --abbrev-ref HEAD".execute().text.trim()
def branchCommitId = "git rev-parse HEAD".execute().text.trim()

task clearJar(type: Delete) {
    delete "$buildDir\\libs\\lib"
}

def branchName = "git rev-parse --abbrev-ref HEAD".execute().text.trim()
def branchCommitId = "git rev-parse HEAD".execute().text.trim()

task clearJar(type: Delete) {
    delete "$buildDir\\libs\\lib"
}

task copyJar(type: Copy, dependsOn: 'clearJar') {
    from configurations.runtimeClasspath
    into "$buildDir\\libs\\lib"
}

jar {
    excludes = ["*.jar"]
    dependsOn clearJar
    dependsOn copyJar

    manifest {
        attributes "branchName": "$branchName"
        attributes "commitId": "$branchCommitId"
        attributes("Main-Class": "cn.nihility.SpringbootStarterApplication")
        /*attributes("branchName": "$branchName",
                "commitId": "$branchCommitId")*/
    }
    if (!configurations.runtimeClasspath.isEmpty()) {
        //manifest.attributes('Class-Path': '. lib/' + configurations.runtimeClasspath.collect { println it.name ; it.name }.join(' lib/'))
        manifest.attributes('Class-Path': '. ' + configurations.runtimeClasspath.files.collect { println it.name; "lib/$it.name" }.join(' '))
    }
}

bootJar {
    excludes = ["*.jar"]
    dependsOn clearJar
    dependsOn copyJar

    manifest {
        attributes "branchName": "$branchName"
        attributes "commitId": "$branchCommitId"
        attributes("Main-Class": "org.springframework.boot.loader.PropertiesLauncher")
        /*attributes("branchName": "$branchName",
                "commitId": "$branchCommitId")*/
    }
    if (!configurations.runtimeClasspath.isEmpty()) {
        //manifest.attributes('Class-Path': '. lib/' + configurations.runtimeClasspath.collect { println it.name ; it.name }.join(' lib/'))
        manifest.attributes('Class-Path': '. ' + configurations.runtimeClasspath.files.collect { println it.name; "lib/$it.name" }.join(' '))
    }
}

task zip(type: Zip, dependsOn: [bootJar]) {
    archiveFileName = "springboot.zip"
    destinationDirectory = file("$buildDir/dist")

    from("$buildDir/libs") {
        /*into("lib")*/
    }

    /*from("$buildDir/libs") {
        into("")
    }*/
}
```

