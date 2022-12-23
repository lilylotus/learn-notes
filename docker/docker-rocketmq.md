# rocketmq 容器化

## 制作 rocketmq 镜像 - 单机模式

nameserver 和 brokerserver 服务在一起

```dockerfile
FROM openjdk:8u342

# 使用 rocket 版本为 rocketmq-all-4.9.4-bin-release
COPY rocketmq /rocketmq/
COPY docker-entrypoint.sh /
VOLUME ["/root/logs/rocketmqlogs"]

EXPOSE 9876
EXPOSE 10911
EXPOSE 10912
EXPOSE 10909

ENTRYPOINT ["/docker-entrypoint.sh"]
```

docker-entrypoint.sh 启动脚本

```bash
#!/bin/bash

mkdir -p /root/logs/rocketmqlogs/
cd /rocketmq/bin/
nohup bash mqnamesrv > /root/logs/rocketmqlogs/nameserver.log 2>&1 &
sleep 3s
nohup bash mqbroker -c ../conf/broker.conf > /root/logs/rocketmqlogs/broker.log 2>&1 &
sleep 5s

threshold=0

function checkRocketmqRunning() {
    namesrvId=$(ps -ef | grep NamesrvStartup | grep java | awk '{print $2}')
    brokerId=$(ps -ef | grep BrokerStartup | grep java | awk '{print $2}')
    if [[ -z ${namesrvId} || -z ${brokerId} ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') : Namesrv or Broker not running! namesrvId [${namesrvId}] and brokerId [${brokerId}] threshold [${threshold}]" >> /root/logs/rocketmqlogs/running.log
        ((++threshold))
    else
        ((threshold=0))
    fi
}
function logExitStatus() {
    namesrvId=$(ps -ef | grep NamesrvStartup | grep java | awk '{print $2}')
    brokerId=$(ps -ef | grep BrokerStartup | grep java | awk '{print $2}')
    echo "$(date '+%Y-%m-%d %H:%M:%S') : namesrvId [${namesrvId}] and brokerId [${brokerId}] threshold [${threshold}]" >> /root/logs/rocketmqlogs/running.log
    ps -ef >> /root/logs/rocketmqlogs/running.log
}

while [[ "${threshold}" -le "3" ]];
do
    checkRocketmqRunning
    sleep 3s
done

logExitStatus

sleep 1s
```

docker 运行命令

挂载 broker.conf 配置文件，添加网络配置

```properties
# /rocketmq/conf/broker.conf
namesrvAddr=外网ip:9876
brokerIP1=外网ip
```

```bash
docker run --rm --name rocketmq -p 9876:9876 -p 10911:10911 -p 10912:10912 -p 10909:10909 -v /rocketmq/conf/broker.conf:/rocketmq/conf/broker.conf -d rocketmq:4.9.4-v1
```

## rocketmq 镜像 - 集群方式

### nameserver 镜像

```dockerfile
FROM openjdk:8u342
# 使用 rocket 版本为 rocketmq-all-4.9.4-bin-release
COPY rocketmq /rocketmq/
COPY namesrv-entrypoint.sh /
VOLUME ["/root/logs/rocketmqlogs"]
EXPOSE 9876
ENTRYPOINT ["/namesrv-entrypoint.sh"]
```

### nameserver 启动脚本

```bash
#!/bin/bash
# namesrv-entrypoint.sh

mkdir -p /root/logs/rocketmqlogs/
cd /rocketmq/bin/

configPath=$1
echo "namesrv absolute config path [${configPath}]" | tee /root/logs/rocketmqlogs/name.log

if [[ -z "${configPath}" ]]; then
    bash mqnamesrv | tee -a /root/logs/rocketmqlogs/name.log
else
    bash mqnamesrv -c ${configPath} | tee -a /root/logs/rocketmqlogs/name.log
fi
```

构建/启动命令

```bash
$ docker build -t rocketmq-namesrv:4.9.4 .
$ docker run --rm --name rocketmq-namesrv -p 9876:9876 -d rocketmq-namesrv:4.9.4
```

### broker 镜像

```dockerfile
FROM openjdk:8u342
# 使用 rocket 版本为 rocketmq-all-4.9.4-bin-release
COPY rocketmq /rocketmq/
COPY broker-entrypoint.sh /
VOLUME ["/root/logs/rocketmqlogs","/root/store"]
EXPOSE 10911
ENTRYPOINT ["/broker-entrypoint.sh"]
```

### broker 启动脚本

```bash
#!/bin/bash
# broker-entrypoint.sh

mkdir -p /root/logs/rocketmqlogs/
cd /rocketmq/bin/

configPath=$1
echo "broker absolute config path [${configPath}]" | tee /root/logs/rocketmqlogs/broker.log

if [[ -z "${configPath}" ]]; then
    bash mqbroker -c ../conf/broker.conf | tee -a /root/logs/rocketmqlogs/broker.log
else
    bash mqbroker -c ${configPath} | tee -a /root/logs/rocketmqlogs/broker.log
fi
```

构建/启动命令

```bash
$ docker build -t rocketmq-broker:4.9.4 .
$ docker run --rm --name rocketmq-broker -p 10911:10911 -p 10909:10909 -v /rocketmq/conf/broker.conf:/rocketmq/conf/broker.conf -d rocketmq-broker:4.9.4
```

### docker-compose 脚本

```yaml
version: "3.9"
services:
  namesrv1:
    image: rocketmq-namesrv:4.9.4
    container_name: namesrv1
    restart: always
    ports:
      - ${SRV1_PORT}:9876
    volumes:
      - srv1:/root/logs/rocketmqlogs/
    networks:
      - servera
  namesrv2:
    image: rocketmq-namesrv:4.9.4
    container_name: namesrv2
    restart: always
    ports:
      - ${SRV2_PORT}:9876
    volumes:
      - srv2:/root/logs/rocketmqlogs/
    networks:
      - serverb
  broker-master1:
    image: rocketmq-broker:4.9.4
    container_name: broker-master1
    restart: always
    command: ["../conf/2m-2s-sync/broker-a.properties"]
    ports:
      - ${BROKER_MASTER1_PORT}:10911
      - ${BROKER_MASTER1_PORT2}:10909
    depends_on:
      - namesrv1
      - namesrv2
    volumes:
      - bm1:/root/logs/rocketmqlogs/
      - bm1:/root/store
      - /rocketmq/conf/2m-2s-sync:/rocketmq/conf/2m-2s-sync
    networks:
      - servera
  broker-master2:
    image: rocketmq-broker:4.9.4
    container_name: broker-master2
    restart: always
    command: ["../conf/2m-2s-sync/broker-b.properties"]
    ports:
      - ${BROKER_MASTER2_PORT}:20911
      - ${BROKER_MASTER2_PORT2}:20909
    depends_on:
      - namesrv1
      - namesrv2
    volumes:
      - bm2:/root/logs/rocketmqlogs/
      - bm2:/root/store
      - /rocketmq/conf/2m-2s-sync:/rocketmq/conf/2m-2s-sync
    networks:
      - serverb
  broker-slave1:
    image: rocketmq-broker:4.9.4
    container_name: broker-slave1
    restart: always
    command: ["../conf/2m-2s-sync/broker-a-s.properties"]
    ports:
      - ${BROKER_SLAVE1_PORT}:11011
      - ${BROKER_SLAVE1_PORT2}:11009
    depends_on:
      - namesrv1
      - namesrv2
      - broker-master1
      - broker-master2
    volumes:
      - bs1:/root/logs/rocketmqlogs/
      - bs1:/root/store
      - /rocketmq/conf/2m-2s-sync:/rocketmq/conf/2m-2s-sync
    networks:
      - serverb
  broker-slave2:
    image: rocketmq-broker:4.9.4
    container_name: broker-slave2
    restart: always
    command: ["../conf/2m-2s-sync/broker-b-s.properties"]
    ports:
      - ${BROKER_SLAVE2_PORT}:21011
      - ${BROKER_SLAVE2_PORT2}:21009
    depends_on:
      - namesrv1
      - namesrv2
      - broker-master1
      - broker-master2
    volumes:
      - bs2:/root/logs/rocketmqlogs/
      - bs2:/root/store
      - /rocketmq/conf/2m-2s-sync:/rocketmq/conf/2m-2s-sync
    networks:
      - servera

networks:
  servera:
  serverb:

# mkdir -p /volumes/{srv1,srv2,bm1,bm2,bs1,bs2}
volumes:
  srv1:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /volumes/srv1
  srv2:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /volumes/srv2
  bm1:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /volumes/bm1
  bm2:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /volumes/bm2
  bs1:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /volumes/bs1
  bs2:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /volumes/bs2
```

### .env 配置文件

```properties
# .env
SRV1_PORT=19876
SRV2_PORT=29876

BROKER_MASTER1_PORT=10911
BROKER_MASTER1_PORT2=10909

BROKER_MASTER2_PORT=20911
BROKER_MASTER2_PORT2=20909

BROKER_SLAVE1_PORT=11011
BROKER_SLAVE1_PORT2=11009

BROKER_SLAVE2_PORT=21011
BROKER_SLAVE2_PORT2=21009
```

### rocket cluster 配置文件

```properties
# conf/2m-2s-sync/broker-a.properties
brokerClusterName=RocketmqCluster
brokerName=broker-a
brokerId=0
deleteWhen=04
fileReservedTime=48
brokerRole=SYNC_MASTER
flushDiskType=ASYNC_FLUSH

namesrvAddr=192.168.56.101:19876;192.168.56.101:29876
brokerIP1=192.168.56.101
# master 默认监听端口 10911, 10909 (10911-2), slave 为 20911，20909
listenPort=10911

# conf/2m-2s-sync/broker-a-s.properties
brokerClusterName=RocketmqCluster
brokerName=broker-a
brokerId=1
deleteWhen=04
fileReservedTime=48
brokerRole=SLAVE
flushDiskType=ASYNC_FLUSH

namesrvAddr=192.168.56.101:19876;192.168.56.101:29876
brokerIP1=192.168.56.101
# 默认端口 11011, 11009 (11011-2),slave 为 21011，21009
listenPort=11011
```

