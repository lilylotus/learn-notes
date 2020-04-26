### Consul 笔记

#### 1. Consul 和 Eureka 的区别

##### 1.1 语言区别

consul 使用 GO 语言编写的，安装即可用
eureka 是 servlet 程序，运行在 servlet 容器中

##### 1.2 一致性

Consul 强一致性 (CP)

- 服务注册会比 Eureka 稍慢，因为 Consul 的 raft 协议要求必须通过半数的节点写入成功才认为注册成功
- Leader 挂掉时，重新选取期间整个 Consul 不可用，保证强一致性牺牲掉可用性

Eureka 保证高可用性和最终一致性 (AP)

- Eureka 服务注册相对要快，因为不需要注册信息 replicate 其它节点，也不保证注册信息是否 replicate 成功
- 当数据不一致时，虽然 A,B 注册信息不完全相同，但每个 Eureka 节点依然能够正常对外提供服务，可能出现查询服务信息是如果请求不到 A，但请求 B 就可以。如此保证了可用性牺牲了一致性。

##### 2. 运行 consul

```bash
# 启动程序，开发者模式快速启动
$ consul agent -dev -client=0.0.0.0 # 允许任意客户端访问

# 数据中心成员
$ consul members
Node     Address         Status  Type    Build  Protocol  DC   Segment
lily-pc  127.0.0.1:8301  alive   server  1.7.2  2         dc1  <all>

# 查看节点
$ curl localhost:8500/v1/catalog/nodes
# 查看服务
$ curl localhost:8500/v1/catalog/service

# 关闭
$ consul leave
```

web 界面地址 ： http://localhost:8500/ui/dc1/services

#### 2. Consul 服务注册发送

```json
{"service":{"name":"web","tags":["rails"],"port":80}}

{
	"Datacenter": "dc1",
	"Node": "lily-pc",
	"Address": "127.0.0.1",
	"Service": {
		"ID": "service01",
		"Service": "service",
		"tags": ["master", "v1"],
		"Address": "127.0.0.1",
		"Port": 53003
	}
}
```

```bash
$ echo '{"service":{"name":"web","tags":["rails"],"port":80}}'  | sudo tee /consul.d/web.json
$ consul agent -dev -config-dir=/consul.d
```

#### 3. spring cloud consul 使用

##### 3.1 基础配置

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-consul-discovery</artifactId>
</dependency>
```

```yaml
# application.yaml
spring:
  application:
    name: spring-cloud-consul-service-provider
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        register: true # 是否需要注册
        instance-id: ${spring.application.name}:${server.port} # 注册实例唯一 id
        service-name: ${spring.application.name} # 服务名称
        port: ${server.port} # 服务请求端口
        prefer-ip-address: true
        ip-address: ${spring.cloud.client.ip-address}
```

```java
@SpringBootApplication
@EnableDiscoveryClient
public class Application() {}
```

##### 3.2 spring Cloud Consul 使用

consul 的使用和 eureka，Ribbon 的负载均衡使用一样的。

#### 3. Consul 高可用性

##### 3.1 集群配置

*agent* 启动一个 consul 的守护进程。
*dev* 开发模式
*client* 是 Consul 的代理，Consul Server 交互，一个微服务对应一个 Client，微服务和 Client 部署到一个机器上
*server* 真正干活的 Consul 服务， 官方推荐配置 3-5 个节点
<font color="blue">推荐一个微服务绑定一个 Consul 集群 client</font>

Gossip 协议，流言协议
所有 Consul 都会参与到 Gossip 协议中 (多节点数据赋值)，一传二，二传四

Raft 协议：
保证 Server 集群数据一致性，Leader：是 Server 集群的位置处理客户端的请求
Follower：选民，可以被动接收数据，候选人：可以被选举为 leader。选主，数据同步。

##### 3.2 consul server 启动配置

启动 server

```bash
$ consul agent -server -bootstrap-expect 3 -data-dir /etc/consul.d -node=server-1 -bind=192.168.1.12 -ui -client 0.0.0.0
# 以 server 的形式运行
-bootstrap-expect 集群要求最少的 Server  数量，当低于该数量，集群即失效
-data-dir data 数据存放的目录
-node 节点 id，同一集群节点 id 不能重复
-bind 绑定 ip 地址
-client 客户端 ip 地址
-ui 允许远程访问
```

启动 Client

```bash
$ consul agent -client=0.0.0.0 -data-dir /etc/consul.d -node=client-node-1
```

节点加入集群，选取一个为 leader，在其他节点加入主节点

```bash
$ consul join 192.168.1.12
```

查询集群信息

```bash
$ consul members
```

<font color="blue">微服务使用/绑定 client 就可以了</font>

#### 4. Consul 存在的问题

##### 4.1 节点服务的注销

当服务节点失效时 Consul 不会自动的对注册信息进行剔除处理，仅仅标记为已标记进行状态（并且不可使用）。如果担心节点失效和失效服务过多影响监控，可以调用 HTTP API 进行处理。

- 注销任意节点： /catalog/deregister
- 注销节点服务：/agent/service/deregister/:service_id

##### 4.2 健康检查与故障转移

在集群环境下，健康检查是由服务注册到的 Agent 来处理的，那么如果 agent 挂掉了，那么此节点的健康检查将无人管理。