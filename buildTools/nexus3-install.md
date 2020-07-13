#### 1. nexus3 安装

##### 1.1 文件说明

`sonatype-work` 目录为 *nexus* 工作的数据文件夹，上传下载的 *jar* 包就在这个下面。
`nexus-3.16.2-01` 是 *nexus* 服务器相关的文件

`nexus3\nexus-3.16.2-01\bin` 执行命令 `nexus /run` - `http://localhost:8081`

默认的用户 `admin`, 密码是 `admin123`

**仓库说明**  有三个数据仓库，*hosted*，*proxy*， *group*
*hosted* 宿主仓库，主要用于部署无法从公共仓库获取的构件以及自己或第三方的项目构件
*proxy* 代理仓库，代理公共的远程仓库
*group* 仓库组，Nexus 通过仓库组统一管理多个仓库，项目中直接请求仓库组即可请求到仓库组管理的多个仓库

Nexus 预定义了2个本地仓库，分别是 maven-releases, maven-snapshots
*maven-releases* 存放了自己项目中发布的构建，通常是 Release 版本。
*maven-snapshots* 这个仓库非常的有用, 它的目的是让我们可以发布那些非 release 版本, 非稳定版本

| 仓库名               | 作用                                                         |
| -------------------- | ------------------------------------------------------------ |
| hosted（宿主仓库库） | 存放本公司开发的 jar 包（正式版本、测试版本）                |
| proxy（代理仓库）    | 代理中央仓库、Apache 下测试版本的 jar 包                     |
| group（组仓库）      | 使用时连接组仓库，包含 Hosted（宿主仓库）和 Proxy（代理仓库） |
| virtual (虚拟仓库)   | 基本用不到，重点关注上面三个仓库的使用                       |

##### 1.2 nexus3 install

<font color="red">不推荐使用 root 用户安装</font>
<font color="blue">nexus-3.9.0-01\bin\nexus.vmoptions</font> 配置文件

执行启动： `./nexus {start|stop|run|run-redirect|status|restart|force-reload}`

```bash
# 创建不登录、-M 不创建用户目录，-m 创建家目录、-r 创建系统账户,-b home 目录的基础，-d 家目录地址
useradd -m -s /bin/bash nexus3
userdel -R nexus4

#/etc/profile
NEXUS_HOME=/usr/local/src/nexus3/nexus-3.24.0-02
PATH=$PATH:$NEXUS_HOME/bin
#修改 jdk 环境
/usr/local/src/nexus3/nexus-3.24.0-02/nexus
INSTALL4J_JAVA_PREFIX="/usr/local/src/jdk1.8.0_202"
# 修改启动用户
/usr/local/src/nexus3/nexus-3.24.0-02/nexus.rc
run_as_user="nexus3"
# 修改端口，默认端口 8081
/usr/local/src/nexus3/nexus-3.24.0-02/etc/nexus-default.properties
application-port=8081

# 初次运行
nexus run
# 访问 http://<server_host>:<port> : http://localhost:8081
# 初始化密码：/usr/local/src/nexus3/sonatype-work/nexus3/admin.password
7922adfc-541c-4c2d-884b-571c0f32d2d8

# 启动 nexus
/usr/local/src/nexus3/nexus-3.24.0-02/bin/nexus start
./nexus status
./nexus stop
```

##### 1.3 maven 中配置私服 setting.xml

```xml
<servers>
    <server>
    <!-- server 的id（注意不是用户登陆的id）
		该 id 与 distributionManagement 中 repository 元素的 id 相匹配
	-->
      <id>nexus</id>
      <username>admin</username>
      <password>admin123</password>
     </server>
</servers>

<!-- 为仓库列表配置的下载镜像列表 -->
<mirrors>
    <mirror>
        <!-- 该镜像的唯一标识符 id 用来区分不同的 mirror 元素  -->
        <id>nexus</id>
        <!-- 此处配置所有的构建均从私有仓库中下载 * 代表所有，也可以写 central -->
        <mirrorOf>*</mirrorOf>
        <name>central repository</name>
        <!-- 该镜像的 URL 构建系统会优先考虑使用该 URL，而非使用默认的服务器 URL  -->
        <url>http://127.0.0.1:8081/repository/maven-public/</url>
    </mirror>
</mirrors>

<profiles>
  <profile>
      <id>nexus</id>
      <!-- 远程仓库列表，它是 Maven 用来填充构建系统本地仓库所使用的一组远程项目。  -->
      <repositories>
          <!--发布版本仓库-->
          <repository>
              <id>nexus</id>      
              <!-- 地址是 nexus 中 repository（Releases/Snapshots）中对应的地址-->
              <url>http://127.0.0.1:8081/repository/maven-public/</url>
          <!-- true 或者 false 表示该仓库是否为下载某种类型构件（发布版，快照版）开启。 -->
          <releases>
              <enabled>true</enabled>
          </releases>
          <snapshots>
              <enabled>true</enabled>
          </snapshots>
      </repository>
      </repositories>
  </profile>     
</profiles>

<!-- 激活配置 -->
<activeProfiles>
    <!-- profile 下的 id -->
    <activeProfile>nexus</activeProfile>
</activeProfiles>
```

##### 1.4 上传 jar 到 nexus

```bash
# 上传到仓库
mvn deploy:deploy-file -Dmaven.test.skip=true 
-DgroupId=com.sgcc.ams -DartifactId=ams-base -Dversion=1.7.0
-Dpackaging=jar -DrepositoryId=nexus
-Dfile=C:\develop\lib\ams-base-1.7.0.jar
-Durl=http://127.0.0.1:8081/repository/maven-releases

# 上传到本地缓存
mvn install:install-file -Dfile=D:/demo/fiber.jar -DgroupId=com.sure -DartifactId=fiber -Dversion=1.0 -Dpackaging=jar
```

```xml
<!-- 上传到nexus仓库中，配合 mvn deploy:deploy -->
<distributionManagement>
    <repository>
        <id>nexus</id>
        <name>Nexus snapshots Repository</name>
        <!-- snapshots仓库 -->
        <url>http://127.0.0.1:8081/repository/maven-snapshots/</url>
    </repository>
</distributionManagement>
```

