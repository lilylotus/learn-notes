## 基础

```
docker pull alpine:3.18.3
docker pull debian:12.1
docker pull centos:centos7
```


## jdk1.8

```dockerfile
FROM centos:centos7

ADD jdk-8u212-linux-x64.tar.gz /usr/local/

ENV LANG=en_US.UTF-8
ENV JAVA_HOME=/usr/local/jdk1.8.0_212
ENV CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar:${JAVA_HOME}/jre/lib/rt.jar
ENV PATH=${PATH}:${JAVA_HOME}/bin

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /opt/

CMD ["java", "-version"]

```

## jdk11

```dockerfile
FROM centos:centos7

ADD jdk-11.0.20_linux-x64_bin.tar.gz /usr/local/

ENV LANG=en_US.UTF-8
ENV JAVA_HOME=/usr/local/jdk-11.0.20
ENV CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar:${JAVA_HOME}/jre/lib/rt.jar
ENV PATH=${PATH}:${JAVA_HOME}/bin

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /opt/

CMD ["java", "-version"]

```