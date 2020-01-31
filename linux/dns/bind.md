#### DNS

> DNS (Domain Name System) 域名系统
> 将对用户友好的域名解析为计算机 IP 地址或将 IP 地址转换为域名
>
> **bind (Berkeley Internet Name Domain)**

#### 安装 bind 软件

```bash
yum install -y bind bind-utils bind-chroot

# 开启 bind 服务
# systemctl start named
# systemctl enable named

======================================
# systemctl start named-chroot -> 使用这个安全

# mount all the DNS configuration files on the chroot environment
/usr/libexec/setup-named-chroot.sh /var/named/chroot on
```

#### 配置 bind 服务

> 配置文件位置 /etc/named.conf
> 域名解析配置文件地址 /var/named

```bash
// listen-on port 53 { 127.0.0.1; any; }; 
// listen-on-v6 port 53 { ::1; };
注释掉这两行，允许监听所有的 IP 地址

allow-query     { localhost; 10.10.37.0/24; 10.10.47.0/24; any; };
配置允许查询的 IP 地址

recursion yes/no # 是否允许递归请求
allow-recursion  {address_match_list; | any; | none; }; # 允许递归的范围
recursive-clients { number; }; # 客户端执行递归请求的数量

# DNS 仅允许转发
forwards { forward_dns_list; }; # 转发的 ip 列表，可配在 options 全局控制或某个具体域局部控制
# 注意 recursion 要改为 yes
```



在 /etc/named.conf 配置正向和反向域名解析

```bash
//forward zone
zone "nihility.cn" IN {
     type master;
     file "nihility.cn.db";
     allow-update { none; };
     allow-query { any; };
};

//backward zone
zone "37.10.10.in-addr.arpa" IN {
     type master;
     file "nihility.cn.rev";
     allow-update { none; };
     allow-query { any; };
};

# 注意： 10.10.37.x 这里要反写， 37.10.10.in-addr.arpa
```

> **type**: Stipulates the role of the server for a particular zone. the attribute ‘master’ implies that this is an authoritative server.
> **file**: Points to the forward / reverse zone file of the domain.
> **allow-update**: This attribute defined the host systems which are permitted to forward Dynamic DNS updates. In this case, we don’t have any.



#### 配置域名正向解析 zone 解析文件

```bash
# vim /var/named/nihility.cn.db
@ 特殊符号，代指操作的域名，这里就是 nihility.cn
TTL (time to live 生命周期)

$TTL 86400
@ IN SOA dns-primary.nihility.cn. lily.nihility.cn. (
                                                2020011800 ;Serial
                                                3600 ;Refresh
                                                1800 ;Retry
                                                604800 ;Expire
                                                86400 ;Minimum TTL
)
; Name Server Information
@ IN NS dns-primary.nihility.cn.
; IP Address for Name Server
dns-primary.nihility.cn IN A 10.10.37.106

; Mail Server MX (mail exchanger) Record
nihility.cn IN MX 10 mail.nihility.cn.

; A Record for the following Host name
www IN A 10.10.37.101
mail IN A 10.10.37.102

; CNAME Record
ftp IN CNAME www.nihility.cn.
```

> **TTL:** This is short for Time-To-Live. TTL is the duration of time (or hops) that a packet exists in a network before finally being discarded by the router.
> **IN:** This implies the Internet.
> **SOA:** This is short for the Start of Authority. Basically, it defines the authoritative name server, in this case, dns-primary.linuxtechi.local and contact information – admin.linuxtechi.local
> **NS:** This is short for Name Server.
> **A:** This is an A record. It points to a domain/subdomain name to the IP Address
> **Serial:** This is the attribute used by the DNS server to ensure that contents of a specific zone file are updated.
> **Refresh:** Defines the number of times that a slave DNS server should transfer a zone from the master.
> **Retry:** Defines the number of times that a slave should retry a non-responsive zone transfer.
> **Expire:** Specifies the duration a slave server should wait before responding to a client query when the Master is unavailable.
> **Minimum:** This is responsible for setting the minimum TTL for a zone.
> **MX:** This is the Mail exchanger record. It specifies the mail server receiving and sending emails
> **CNAME:** This is the Canonical Name. It maps an alias domain name to another domain name.
> **PTR:** Short for Pointer, this attributes resolves an IP address to a domain name, opposite to a domain name.

#### 配置域名 zone 的反向解析文件 (reverse)

```bash
# vim /var/named/nihility.cn.rev

$STTL 86400
@ IN SOA dns-primary.nihility.cn. lily.nihility.cn. (
                                            2020011800 ;Serial
                                            3600 ;Refresh
                                            1800 ;Retry
                                            604800 ;Expire
                                            86400 ;Minimum TTL
)
; name server information
@ IN NS dns-primary.nihility.cn.
dns-primary IN A 10.10.37.106

; Reverse lookup for name server
106 IN PTR dns-primary.nihility.cn.

; PRT record IP address to hostname
101 IN PTR www.nihility.cn
102 IN PTR mail.nihility.cn
```

#### 把配置文件所有人和所属组配置为 named

```bash
# chown named:named /var/named/nihility.cn.db
# chown named:named /var/named/nihility.cn.rev
```

#### 检查配置文件编写是否正确

```bash
# named-checkconf
# named-checkzone nihility.cn /var/named/nihility.cn.db
# named-checkzone 10.10.37.106 /var/named/nihility.cn.rev
```

#### 测试 dns 配置

```bash
vim /etc/resolv.conf
nameserver 10.10.37.106

nsloopup dns-primary.nihility.cn
dig dns-primary.nihility.cn

dig @127.0.0.1 dns-primary.nihility.cn # @指定 dns 服务器
```



---

#### DNS 主从配置

**Master DNS 配置**

```bash
# /etc/named.conf

listen-on port 53 { 127.0.0.1; 10.0.2.32; };
allow-query     { localhost; any; };
allow-query-cache { localhost; any; };

# additional configuration, 主服务器有变化会同步到从节点 DNS
allow-transfer  { 10.0.2.31; }; -> 添加从服务器 IP
notify yes;
also-notify { 10.0.2.31; }; -> 提示从服务器 IP

# masater
# 1. forward zone config
zone "example.com" IN {
        type master;
        file "example.com.zone";
        allow-update { none; };
};

zone "2.0.10.in-addr.arpa" IN {
        type master;
        file "example.com.rzone";
        allow-update { none; };
};
# 2. forward zone
$TTL 1D
@       IN SOA  example.com       root (
                                        6       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
                IN NS   master
master          IN A    10.0.2.32
localhost       IN A    127.0.0.1
client          IN A    10.0.2.30
slave           IN A    10.0.2.31
# 3. reverse zone
$TTL 1D
@       IN SOA  example.com.    root (
                                        2       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        IN NS   master.
30      IN PTR  client.example.com.
31      IN PTR  slave.example.com.
32      IN PTR  master.example.com.
```

`serial`

**Slave DNS Configuration**

```bash
# /etc/named.conf

listen-on port 53 { 127.0.0.1; 10.0.2.31; };
allow-query     { localhost; any; };

# configuration zone config

zone "example.com" IN {
        type slave;
        masters { 10.0.2.32; }; -> 主节点 DNS 服务器
        file "slaves/example.com.zone";
};

zone "2.0.10.in-addr.arpa" IN {
        type slave;
        masters { 10.0.2.32; };
        file "slaves/example.com.rzone";
};

# start dns server
/usr/libexec/setup-named-chroot.sh /var/named/chroot on
named-checkconf -t /var/named/chroot/ /etc/named.conf

systemctl restart named-chroot

/var/named/data/named.run -> 这是 dns 解析记录
```

>  **注意：**主服务器的 dns 变更后要把 serial id 递增，让从服务好同步数据。



---

#### 信息安全，区域传输限制

```bash
dig @127.0.0.1 nihility.cn axfr # axfr 全量数据会返回, ixfr 增量数据
-->
; <<>> DiG 9.11.4-P2-RedHat-9.11.4-9.P2.el7 <<>> @127.0.0.1 nihility.cn axfr
; (1 server found)
;; global options: +cmd
nihility.cn.            86400   IN      SOA     dns-primary.nihility.cn. lily.nihility.cn. 2020011800 3600 1800 604800 86400
nihility.cn.            86400   IN      NS      dns-primary.nihility.cn.
nihility.cn.            86400   IN      MX      10 mail.nihility.cn.
dns-primary.nihility.cn. 86400  IN      A       10.10.37.106
ftp.nihility.cn.        86400   IN      CNAME   www.nihility.cn.
mail.nihility.cn.       86400   IN      A       10.10.37.102
www.nihility.cn.        86400   IN      A       10.10.37.101
nihility.cn.            86400   IN      SOA     dns-primary.nihility.cn. lily.nihility.cn. 2020011800 3600 1800 604800 86400
;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Tue Jan 07 13:49:10 CST 2020
;; XFR size: 8 records (messages 1, bytes 234)
```

区域传输限制：

1. 基于主机的访问控制

   ```bash
   /etc/named.conf
   # 在具体的 zone 标签下配置
   allow-transfer { none; | ip_list; }; 允许传输的 IP 限制，如从服务的 IP 地址
   ```

2. 基于事务签名的访问控制

   1. DES 对称加密：加密和解密使用相同的密钥，简单快捷
   2. IDEA 非对称加密：密钥(公钥和私钥)，安全性高于 DES，公钥加密私钥解密

   DNS 事务签名方式：

   1. TSIG 对称方式

   2. SIG0 非对称方式

      ```bash
      allow-transfer { key keyfile; }; 事务签名的 key
      
      # 生成 key, TSIG 方式
      # dnssec-keygen -a HMAC-MD5 -b 128 -n HOST nihility-key
      	-a 算法
      	-b 加密位数
      	-n HOST 基于主机， ZONE 基于域 ， ZONE | HOST | ENTITY | USER | OTHER
      	key 的名称
      -> 生成文件 Knihility-key.+157+32131.key  Knihility-key.+157+32131.private
      private:
      Private-key-format: v1.3
      Algorithm: 157 (HMAC_MD5)
      Key: 4aK7M8zA0odD2/X/c12Ojg==
      Bits: AAA=
      Created: 20200107060132
      Publish: 20200107060132
      Activate: 20200107060132
      
      public:
      nihility-key. IN KEY 512 3 157 4aK7M8zA0odD2/X/c12Ojg==
      
      # 新建文件
      /var/named/chroot/etc/nihility-key
      key "nihility-key" {
      	algorithm hmac-md5;
      	secret "4aK7M8zA0odD2/X/c12Ojg==";
      }
      
      # 在 master dns -> /etc/named.conf 导入文件
      添加： include "/var/named/chroot/etc/nihility-key";
      allow-transfer { key "nihility-key"; }; # 事务签名认证
      
      # 配置从服务器 dns，使用上面生成的 key
      # 主 dns IP 地址
      include "/var/named/chroot/etc/nihility-key";
      server 10.10.37.106 {
      	keys { "nihility-key"; };
      }
      masters { 10.10.37.106; };
      ```



---

#### 获取 IP 库

`http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest`

