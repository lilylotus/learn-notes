### 1. jenkins 安装

#### 1.1 war 包形式安装

```bash
# 会在安装用户家目录生成一个 .jenkins 目录
nohup java -jar jenkins-stable-2.235.1.war --httpPort=9090 > logs/jenkins.log 2>&1 &

# 改变插件的源
.jenkins/hudson.model.UpdateCenter.xml
原始: http://updates.jenkins-ci.org/update-center.json

> https://updates.jenkins-zh.cn/update-center.json
> https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
```



##### 1.2 启动脚本

```bash
#!/bin/bash
export JENKINS_HOME=/data/jenkins
cd $JENKINS_HOME
nohup java -jar jenkins.war --httpPort=9090 > /dev/null 2>&1 &

```

##### 1.3 在后台执行命令

```bash
sh '''
	BUILD_ID:
	java -jar spring.jar > spring.log 2>&1 &
'''

file=$(find build -name "*.jar" -print0 | xargs -0)
```

