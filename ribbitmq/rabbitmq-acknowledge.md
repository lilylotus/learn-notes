### Rabbitmq 基础概念

消息队列中间件 (Message Queue Middleware / MQ)
利用高效可靠的消息传递机制进行与平台无关的数据交流，它可以在分布式环境下扩展进程间的数据通信，并基于数据通信来进行分布式系统的集成。

**项目解耦**：不同的项目或模块可以使用消息中间件进行数据的传递，从而可以保证模块的相对独立性，实现解耦。

**流量削峰**：可以将突发的流量 (如秒杀数据) 写入消息中间件，然后由多个消费者进行异步处理。

**弹性伸缩**：可以通过对消息中间件进行横向扩展来提高系统的处理能力和吞吐量。

**发布订阅**：可以用于任意的发布订阅模式中。

**异步处理**：当我们不需要对数据进行立即处理，或者不关心数据的处理结果时，可以使用中间件进行异步处理。

**冗余存储**：消息中间件可以对数据进行持久化存储，直到你消费完成后再进行删除。

#### 1. AMQP 协议

AMQP (Advanced Message Queuing Protocol) 
提供统一消息服务的应用层通讯协议，为消息中间件提供统一的开发规范。
AMQP 协议本身包括以下三层：

**Module Layer**
位于协议最高层，主要定义了一些供客户端调用的命令，客户端可以利用这些命令实现自己的业务逻辑。
例如：可以使用 Queue.Declare 命令声明一个队列或者使用 Basic.Consume 订阅消费一个队列中的消息。

**Session Layer**
位于中间层，主要负责将客户端的命令发送给服务器，再将服务端的应答返回给客户端，主要为客户端与服务器之间的通信提供可靠性同步机制和错误处理。

**Transport Layer**
位于最底层，主要传输二进制数据流 ，提供帧的处理、信道复用、错误检测和数据表示等。

#### 2. 架构模型

![rabbitmq architecture](../images/rabbitmq-architecher.png)

- *Publisher*
  发布者（或称为生产者） 负责生产消息将其投递到指定的交换器上
- *Message*
  消息，消息由消息头和消息体组成。消息头用于存储与消息相关的元数据，如：目标交换机的名字 (exchange_name)、路由键(RoutingKey) 和其它可选配置信息 (properties)。消息体为实际需要传递的数据
- *Exchange*
  交换器，负责接收来自生产者的消息，并将消息路由到一个或多个队列中，如果路由不到，则返回给生产者或直接丢弃，取决于交换器的 mandatory 属性。
  当 mandatory 为 true 时，如果交换器无法根据自身类型和路由键找到一个符合条件的队列，则会将该消息返回给生产者，为 false 时，直接丢弃该数据。
- *BindingKey*
  绑定键，交换器与队列通过 *BindingKey* 建立绑定关系
- *RoutingKey*
  路由键，生产者将消息发给交换器的时候，一般会指定一个 RountingKey，用来指定这个消息的路由规则。
  当 RountingKey 与 BindingKey 基于交换器类型的规则相匹配时，消息被路由到对应的队列中。
- *Queue*
  消息队列，用于存储路由过来的消息。
  多个消费者可以订阅同一个消息队列，队列会将收到的消息轮询 (round-robin) 的方式分发给所有消费者
  即每条消息只会发送给一个消费者，不会出现一条消息被多个消费者重复消费的情况
- *Consumer*
  消费者，订阅感兴趣的队列，并负责消费存储在队列中的消息。
  为了保证消息能够从队列可靠地到达消费者，RabbitMQ 提供了消息确认机制 (message acknowledgement)，并通过 autoAck 参数来进行控制：
  - 当 autoAck 为 true 时
    此时消息发送出去 (写入TCP套接字) 后就认为消费成功，而不管消费者是否真正消费到这些消息。
    当 TCP 连接或 channel 因意外而关闭，或者消费者在消费过程之中意外宕机时，对应的消息就丢失
    因此这种模式可以提高吞吐量，但会存在数据丢失的风险。
  - autoAck 为 false
    需用户在数据处理完成后进行手动确认，只手动确认完成后，RabbitMQ 才认为这条消息被成功处理
    这可以保证数据的可靠性投递，但会降低系统的吞吐量
- *Connection*
  连接，用于传递消息的 TCP 连接
- *Channel*
  信道，RabbitMQ 采用类似 NIO (非阻塞式 IO ) 的设计，通过 Channel 来复用 TCP 连接，并确保每个 Channel 的隔离性，就像是拥有独立的 Connection 连接。
  当数据流量不是很大时，采用连接复用技术可以避免创建过多的 TCP 连接而导致昂贵的性能开销。
- *Virtual Host*
  虚拟主机，RabbitMQ 通过虚拟主机来实现逻辑分组和资源隔离，一个虚拟主机就是一个小型的 RabbitMQ 服务器，拥有独立的队列、交换器和绑定关系。
  用户可以按照不同业务场景建立不同的虚拟主机，虚拟主机之间是完全独立的，你无法将 vhost1 上的交换器与 vhost2 上的队列进行绑定，这可以极大的保证业务之间的隔离性和数据安全。
  默认的虚拟主机名为 `/` 
- *Broker*
  真实部署运行的 RabbitMQ 服务

#### 3. 交换器类型

##### 3.1 fanout

最简单的一种交换器模型，此时会把消息路由到与该交换器绑定的所有队列中
任何发送到 X 交换器上的消息，都会被路由到 Q1 和 Q2 两个队列上
![fanout](../images/rabbitmq-exchanger-fanout.png)

##### 3.2 direct

把消息路由到 BindingKey 和 RountingKey 完全一样的队列中
当消息的 RountingKey 为 orange 时，消息会被路由到 Q1 队列
当消息的 RountingKey 为 black 或 green 时，消息会被路由到 Q2 队列。

![direct](../images/rabbitmq-exchanger-direct.png)

需要特别说明的是一个交换器绑定多个队列时，它们的 BindingKey 是可以相同的
当消息的 RountingKey 为 black 时，消息会同时被路由到 Q1 和 Q2 队列

##### 3.3 topic

将消息路由到 BindingKey 和 RountingKey 相匹配的队列中

- RountingKey 和 BindingKey 由多个单词使用逗号 `.` 进行连接
- BindingKey 支持两个特殊符号：`#` 和 `*` 。其中 `*` 用于匹配一个单词， `#` 用于匹配零个或者多个单词。

![topic](../images/rabbitmq-exchanger-topic.png)

路由键为 `lazy.orange.elephant` 的消息会发送给所有队列
路由键为 `quick.orange.fox` 的消息只会发送给 Q1 队列
路由键为 `lazy.brown.fox` 的消息只会发送给 Q2 队列
路由键为 `lazy.pink.rabbit` 的消息只会发送给 Q2 队列
路由键为 `quick.brown.fox` 的消息与任何绑定都不匹配
路由键为 `orange` 或 `quick.orange.male.rabbit` 的消息也与任何绑定都不匹配

##### 3.4 header

在交换器与队列进行绑定时可以指定一组键值对作为 BindingKey 在发送消息的 headers 中的可以指定一组键值对属性，当这些属性与 BindingKey 相匹配时，则将消息路由到该队列。
同时还可以使用 `x-match` 参数指定匹配模式：

- x-match = all  : 所有的键值对都相同才算匹配成功
- x-match = any : 只要有一个键值对相同就算匹配成功

headers 类型的交换器性能比较差，因此其在实际开发中使用得比较少。

#### 4. 死信队列

RabbitMQ 中另外一个比较常见的概念是死信队列。
当消息在一个队列中变成死信 (dead message) 之后，它可以被重新被发送到死信交换器上 (英文为 Dead-Letter-Exchange，简称 DLX )，任何绑定死信交换器的队列都称之为死信队列。
需要特别说明的是死信交换器和死信队列与正常的交换器和队列完全一样，采用同样的方式进行创建，它们的名称表达的是其功能，而不是其类型。
一个正常的消息变成死信一般是由于以下三个原因：

- 消息被拒绝 (Basic.Reject/Basic.Nack) ，井且设置重回队列的参数 requeue 为 false；
- 消息过期；
- 队列达到最大长度。

队列创建的 channel.queueDeclare 方法中设置 x-dead-letter-exchange 参数来为正常队列添加死信交换器，当该队列中存在死信时，死信就会被发送到死信交换器上，进而路由到死信队列上。

```java
// 创建死信交换器
channel.exchangeDeclare("exchange.dlx", "direct");
// 声明死信队列
channel.queueDeclare(" queue.d1x ", true, false, false, null);
// 绑定死信交换器和死信队列
channel.queueBind("queue.dlx ", "exchange.dlx ", "routingkey");

Map<String, Object> args = new HashMap<>();
args.put("x-dead-letter-exchange", "exchange.dlx");
// 为名为 myqueue 的正常队列指定死信交换器
channel.queueDeclare("queue.normal", false, false, false, args);
```

