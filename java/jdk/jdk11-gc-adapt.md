

由于 G1 的自适应算法不足，导致 GC 频繁，进而导致了业务的性能衰减，调整 GC 参数：

```bash

export G1_ENABLE=false
if [ -f /home/admin/logs/g1.enable ]; then
    export G1_ENABLE=true
    echo "enable g1"
fi
if [ "$G1_ENABLE" == "true" ]; then
  CATALINA_OPTS="${CATALINA_OPTS} -Xms9500m -Xmx9500m"
  CATALINA_OPTS="${CATALINA_OPTS} -XX:+UseG1GC"
  CATALINA_OPTS="${CATALINA_OPTS} -XX:G1HeapRegionSize=32m"
  CATALINA_OPTS="${CATALINA_OPTS} -XX:+G1BarrierSkipDCQ"
  CATALINA_OPTS="${CATALINA_OPTS} -XX:InitiatingHeapOccupancyPercent=40"
  CATALINA_OPTS="${CATALINA_OPTS} -XX:-G1UseAdaptiveIHOP"
  CATALINA_OPTS="${CATALINA_OPTS} -XX:G1HeapWastePercent=2"
else
  CATALINA_OPTS="${CATALINA_OPTS} -Xms10g -Xmx10g"
  CATALINA_OPTS="${CATALINA_OPTS} -Xmn5632m"
  CATALINA_OPTS="${CATALINA_OPTS} -XX:+CMSScavengeBeforeRemark"
  CATALINA_OPTS="${CATALINA_OPTS} -XX:+UseConcMarkSweepGC -XX:CMSMaxAbortablePrecleanTime=5000"
  CATALINA_OPTS="${CATALINA_OPTS} -XX:+CMSClassUnloadingEnabled -XX:CMSInitiatingOccupancyFraction=80 -XX:+UseCMSInitiatingOccupancyOnly"
fi

```

JDK8 切换到 JDK11 ，同时充分 JDK11 本身的新的特性

```bash
if [ -f /home/admin/logs/jdk11.enable ]; then     
    export JAVA_HOME=/opt/taobao/install/ajdk11_11.0.14.13/     
    export JDK11_ENABLE=true     
    echo "enable jdk11 , use new JAVA_HOME : ${JAVA_HOME}" 
fi 
    
if [ "$JDK11_ENABLE" == "true" ]; then     
    CATALINA_OPTS="${CATALINA_OPTS} -Xlog:gc*:${MIDDLEWARE_LOGS}/gc.log:time"     
    CATALINA_OPTS="${CATALINA_OPTS} --add-exports=java.base/jdk.internal.loader=ALL-UNNAMED --add-exports=java.base/jdk.internal.loader=jdk.unsupported --patch-module jdk.unsupported=/home/admin/buy2/bin/java9-migration-helper-0.1.jar"     
    CATALINA_OPTS="${CATALINA_OPTS} -Dio.netty.tryReflectionSetAccessible=true --add-opens=java.base/jdk.internal.misc=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED"     CATALINA_OPTS="${CATALINA_OPTS} --add-exports=java.base/jdk.internal.util.jar=ALL-UNNAMED --add-exports=java.base/jdk.internal.util.jar=jdk.unsupported"     
    CATALINA_OPTS="${CATALINA_OPTS} --add-opens=java.base/com.alibaba.wisp.engine=ALL-UNNAMED"     CATALINA_OPTS="${CATALINA_OPTS} -XX:CompileCommand=stableif,*::*"     test -z "$JPDA_ADDRESS" && export JPDA_ADDRESS=*:8000     #gson兼容     CATALINA_OPTS="${CATALINA_OPTS} -Djava.locale.providers=COMPAT,SPI" else     
    CATALINA_OPTS="${CATALINA_OPTS} -Xloggc:${MIDDLEWARE_LOGS}/gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps"     
    CATALINA_OPTS="${CATALINA_OPTS} -XX:-UncommonNullCast -XX:CompileCommand=stableif,*::*"     test -z "$JPDA_ADDRESS" && export JPDA_ADDRESS=8000 fiexport G1_ENABLE=false if [ -f /home/admin/logs/g1.enable ]; then     export G1_ENABLE=true     echo "enable g1" fi if [ "$G1_ENABLE" == "true" ]; then   
    CATALINA_OPTS="${CATALINA_OPTS} -Xms9500m -Xmx9500m"   CATALINA_OPTS="${CATALINA_OPTS} -XX:+UseG1GC"   
    CATALINA_OPTS="${CATALINA_OPTS} -XX:G1HeapRegionSize=32m"   CATALINA_OPTS="${CATALINA_OPTS} -XX:+G1BarrierSkipDCQ"   
    CATALINA_OPTS="${CATALINA_OPTS} -XX:InitiatingHeapOccupancyPercent=40"   CATALINA_OPTS="${CATALINA_OPTS} -XX:-G1UseAdaptiveIHOP"   
    CATALINA_OPTS="${CATALINA_OPTS} -XX:G1HeapWastePercent=2" else   CATALINA_OPTS="${CATALINA_OPTS} -Xms10g -Xmx10g"   
    CATALINA_OPTS="${CATALINA_OPTS} -Xmn5632m"   CATALINA_OPTS="${CATALINA_OPTS} -XX:+CMSScavengeBeforeRemark"   
    CATALINA_OPTS="${CATALINA_OPTS} -XX:+UseConcMarkSweepGC -XX:CMSMaxAbortablePrecleanTime=5000"   
    CATALINA_OPTS="${CATALINA_OPTS} -XX:+CMSClassUnloadingEnabled -XX:CMSInitiatingOccupancyFraction=80 -XX:+UseCMSInitiatingOccupancyOnly" 
fi
```

本地化的问题

```bash
-Djava.locale.providers=COMPAT,SPI
```

