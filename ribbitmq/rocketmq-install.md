# RocketMQ

[RocketMQ 官方网站](https://rocketmq.apache.org/) 

## 环境搭建

[Rocket 下载地址](https://rocketmq.apache.org/download)，[Rocket 4.9.4 版本下载链接](https://archive.apache.org/dist/rocketmq/4.9.4/rocketmq-all-4.9.4-bin-release.zip)

### 启动 NameServer

调整启动 jvm 内存参数

```bash
$ vim bin/runserver.sh
# 调整 jvm 内存大小为
# -server -Xms512m -Xmx512m -Xmn256m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m
```

启动 nameserver

```bash
$ nohup sh bin/runserver.sh > nameserver.log 2>&1 &
```

查看日志确认是否启动成功

```bash
$ tail -f ~/logs/rocketmqlogs/namesrv.log
```

关闭 NameServer

```bash
$ sh bin/mqshutdown namesrv
```

### 启动 Broker

调整 jvm 启动内存参数

```bash
$ vim bin/runbroker.sh
# -server -Xms1g -Xmx1g -Xmn512m
```

修改 broker 配置

```bash
$ vim conf/broker.conf

# 在文件末尾添加
namesrvAddr = 127.0.0.1:9876
# Broker 向 NameServer 注册固定 IP
# broker ip
brokerIP1 = broker_ip
brokerIP2 = 192.168.110.10
# 自动创建 topic
autoCreateTopicEnable = true
```

启动 Broker

```bash
$ nohup sh bin/mqbroker -c conf/broker.conf > broker.log 2>&1 &
# -c 指定配置文件
```

查看日志确认启动状态

```bash
$ tail -f ~/logs/rocketmqlogs/broker.log
```

关闭 broker

```bash
$ sh bin/mqshutdown broker
```

### 搭建可视化操作控制台

[github 地址](https://github.com/apache/rocketmq-dashboard)

下载代码，可以自定义启动端口和参数

```bash
$ git clone https://github.com/apache/rocketmq-dashboard.git
```

编译、打包为可以执行 jar 包

```bash
$ mvn clean package -Dmaven.test.skip=true
```

启动 dashboard

```bash
$ java -Xms200m -Xmx200m -Xmn100m -jar dashboard.jar
```

## spring rocketmq 示例

[spring rocket maven 依赖链接](https://mvnrepository.com/artifact/org.apache.rocketmq/rocketmq-spring-boot-starter)

引入依赖

```
# gradle 依赖
implementation("org.apache.rocketmq:rocketmq-spring-boot-starter:2.2.2")
```

rocket 配置

```yaml
rocketmq:
  name-server: 127.0.0.1:9876
  producer:
    group: RocketGroup
```

### 普通方式发送

发送消息

```java
// 引入 Rocket 发送工具类
@Autowired
private RocketMQTemplate rocketMQTemplate;

// 发送消息 ，若是要加 tag - "topic:tag" 这样的格式
rocketMQTemplate.convertAndSend("topic", "Rocket Hello World!");
```

消费消息

注意：consumerGroup 可以自定义，并不是发送配置的 rocketmq.producer.group，每个 `RocketMQListener` 的 consumerGroup 都不一样，不然会造成消息缺失。

```java
@Component
@RocketMQMessageListener(topic = "topic", consumerGroup = "CG1")
public class RocketConsumerListener implements RocketMQListener<String> {
    
    private static final Logger log = LoggerFactory.getLogger(RocketConsumerListener.class);
    
    @Override
    public void onMessage(String message) {
        log.info("consume message [{}]", message);
    }
}
```

### 消息事务发送

事务方式发送

```java
Message<MessageBaseDto<String>> message = MessageBuilder.withPayload(dto)
                .setHeader(RocketMQHeaders.TRANSACTION_ID, "transactionId")
                .build();
rocketMQTemplate.sendMessageInTransaction("tx-topic", message, null);
```

Rocket 本地事务监听器

- COMMIT：提交事务，允许消费者消费此消息
- ROLLBACK： 回滚事务，消息将被删除，不允许被消费
- UNKNOWN：中间状态，代表需要进行检查来确定状态

```java
@RocketMQTransactionListener
public class RocketLocalTransactionListener implements RocketMQLocalTransactionListener {

    private static final Logger log = LoggerFactory.getLogger(RocketLocalTransactionListener.class);

    @Override
    public RocketMQLocalTransactionState executeLocalTransaction(Message msg, Object arg) {
        log.info("tx local [{}] - [{}]", msg.getHeaders().get(RocketMQHeaders.TRANSACTION_ID), arg);
        return RocketMQLocalTransactionState.COMMIT;
    }

    @Override
    public RocketMQLocalTransactionState checkLocalTransaction(Message msg) {
        log.info("tx local check [{}]", msg.getHeaders().get(RocketMQHeaders.TRANSACTION_ID));
        return RocketMQLocalTransactionState.COMMIT;
    }

}
```

事务方式消息消费，和普通方式一样

```java
@Component
@RocketMQMessageListener(topic = "topic", consumerGroup = "TX-CG1")
public class RocketTxConsumerListener implements RocketMQListener<String> {
    
    private static final Logger log = LoggerFactory.getLogger(RocketTxConsumerListener.class);
    
    @Override
    public void onMessage(String message) {
        log.info("tx consume message [{}]", message);
    }
}
```

## 常见问题

### 发送报错

```
org.apache.rocketmq.spring.core.RocketMQTemplate:565 - syncSend failed. destination:xxxx, message:GenericMessage [payload=byte[355], headers={contentType=application/json, id=db642bc3-de60-e86b-9697-fc953d71a755, timestamp=1672047867866}], detail exception info:
org.apache.rocketmq.client.exception.MQBrokerException: CODE: 2  DESC: [TIMEOUT_CLEAN_QUEUE]broker busy, start flow control for a while, period in queue: 396ms, size of queue: 7 BROKER: 192.168.56.101:10911
For more information, please visit the url, http://rocketmq.apache.org/docs/faq/
```

broker 添加配置

```properties
# 主从异步复制
brokerRole=ASYNC_MASTER
# 异步刷盘
flushDiskType=ASYNC_FLUSH
# 线上关闭自动创建 topic - false
autoCreateTopicEnable=true
# 发送消息的最大线程数，默认 1
sendMessageThreadPoolNums=32
# 使用可重入锁
useReentrantLockWhenPutMessage=true
# 发送消息线程等待时间，默认200ms
waitTimeMillsInSendQueue=1000
# 开启临时存储池
transientStorePoolEnable=true
# 开启 Slave 读权限（分担 master 压力）
slaveReadEnable=true
# 关闭堆内存数据传输
transferMsgByHeap=false
# 开启文件预热
warmMapedFileEnable=true
```

