#### 1. mvn 打包

##### 1.1 gbk 字符问题

```xml
<!-- pom.xml -->
<properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>

<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.1</version>
    <configuration>
        <source>${java.version}</source>
        <target>${java.version}</target>
        <encoding>utf-8</encoding>
    </configuration>
</plugin>
```

```bash
mvn package -Dmaven.test.skip=true
```

#### 2. nginx 启动指定配置文件

```bash
nginx -c /nginx/nginx.conf
```

#### 3. maven 私服使用

##### 3.1 setting.xml 配置

```xml
<servers>
    <server> 
        <id>releases</id> 
        <username>admin</username> 
        <password>admin123</password> 
    </server> 
    <server> 
        <id>snapshots</id> 
        <username>admin</username> 
        <password>admin123</password> 
    </server>
</servers>

<mirrors>
    <mirror>
        <id>local_mirror</id>
        <mirrorOf>*</mirrorOf>
        <name>local_mirror</name>
        <url>http://localhost:8081/nexus/content/groups/public/</url>
    </mirror>
</mirrors>

<profiles>
    <profile>
        <!--ID用来确定该profile的唯一标识-->
        <id>jdk-1.8</id>
        <activation>
            <activeByDefault>true</activeByDefault>
            <jdk>1.8</jdk>
        </activation>
        <properties>
            <maven.compiler.source>1.8</maven.compiler.source>
            <maven.compiler.target>1.8</maven.compiler.target>
            <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
        </properties>
    </profile>

    <profile>
        <id>dev</id>
        <!-- jar 包拉取的地址 -->
        <repositories>
            <repository>
                <!-- 仓库 id，repositories 可以配置多个仓库，保证 id 不重复 --> 
                <id>maven-public</id>
                <name>maven-public</name>
                <url>http://192.168.134.131:8081/repository/maven-public/</url>
                <releases>
                    <!-- never,always,interval n -->
                    <updatePolicy>daily</updatePolicy>
                    <enabled>true</enabled>
                    <!-- fail,ignore -->
                    <checksumPolicy>warn</checksumPolicy>
                </releases>
                <!-- 是否下载 release 构件 --> 
                <releases>
                    <enabled>true</enabled>
                </releases>
                <!-- 是否下载 snapshots 构件 --> 
                <snapshots>
                    <enabled>false</enabled>  
                </snapshots>  
                <layout>default</layout>
            </repository>
        </repositories>
        <!-- 插件仓库 -->
        <pluginRepositories>
            <!-- 插件仓库，maven 的运行依赖插件，也需要从私服下载插件 --> 
            <pluginRepository>
                <!-- 插件仓库的 id 不允许重复，如果重复后边配置会覆盖前边 --> 
                <id>nexus</id>
                <name>private-nexus</name>
                <url>http://192.168.125.11/nexue/content/groups/pulic/</url>
                <layout>default</layout>
                <releases>
                    <enabled>true</enabled>
                </releases>
                <snapshots>
                    <enabled>false</enabled>
                </snapshots>
            </pluginRepository>
        </pluginRepositories>
    </profile>
</profiles>

<!-- 激活 -->
<activeProfiles> 
    <activeProfile>jdk-1.8</activeProfile>
	<activeProfile>dev</activeProfile> 
</activeProfiles> 
```

##### 3.2 项目使用 pom.xml

```xml
<repositories>
    <!-- 仓库地址，注意和 setting.xml 配置中 mirror 的冲突 -->
    <repository>
        <id>nexus</id>
        <name>local nexus repository</name>
        <url>http://10.10.100.6:8081/repository/maven-public/</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
    </repository>
</repositories>
<!-- 插件仓库 -->
<pluginRepositories>
    <!-- 插件仓库，maven 的运行依赖插件，也需要从私服下载插件 -->
    <pluginRepository>
        <!-- 插件仓库的 id 不允许重复，如果重复后边配置会覆盖前边 -->
        <id>nexus</id>
        <name>private-nexus</name>
        <url>http://10.10.100.6:8081/nexue/content/groups/pulic/</url>
        <layout>default</layout>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
    </pluginRepository>
</pluginRepositories>
<!-- jar 包上传的地址 -->
<distributionManagement>
<!-- pom.xml 中 repository 里的 id 需要和 .m2 中 setting.xml 里的 server id 名称保持一致 -->
    <repository>
        <id>releases</id>
        <name>maven-releases</name>
        <url>http://10.10.100.6:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
        <id>snapshots</id>
        <name>maven-snapshots</name>
        <url>http://10.10.100.6:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>
```

##### 3.3 mvn 本地安装

```bash
mvn install:install-file 
-Dfile=common-util-0.0.1-SNAPSHOT.jar 
-DgroupId=com.kite 
-DartifactId=common-util
-Dversion=0.0.1-SNAPSHOT 
-Dpackaging=jar

mvn clean deploy -Dmaven.test.skip=true

mvn deploy:deploy-file 
-Dfile=D:\coding\jars\kl_wof-2.0.0-SNAPSHOT.jar 
-DgroupId=kl.kiam.pms 
-DartifactId=kl_wof 
-Dversion=2.0.0-SNAPSHOT 
-Dpackaging=jar 
-DrepositoryId=nexus-repository 
-Durl=http://nexus3.koal.com:8081/repository/maven-public/

repositoryId 对应的是 setting.xml 中配置的 server id
```

