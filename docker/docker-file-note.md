#### 创建 centos7 JDK 环境

```dockerfile
FROM centos:centos7.7.1908

ADD jdk-8u181-linux-x64.tar.gz /usr/local/src

ENV JAVA_HOME=/usr/local/src/jdk1.8.0_181
ENV CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/jre/rt.jar
ENV PATH=$PATH:$JAVA_HOME/bin

CMD ["java", "-version"]
```

```bash
$ docker build -t centos7-jdk8:v1.0 .
```

