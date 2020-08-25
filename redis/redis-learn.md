##### Redis 数据类型 [五种]

`Strings`： 二进制安全的 strings

> *Strings* 是 *redis* 值中最基本的一种。*Redis Strings* 是二进制安全， 意味着一个 *Redis Strings* 可以存储任意类型的数据，如：JPGE 图片格式或者序列化后的对象。
> 一个 *Strings* 值可以保存 512M 长度数据。
>
> - 使用 *INCR* 系列命令操作原子计数：`INCR,DECR,INCRBY`
> - 添加到 strings ：`APPEND`
> - 随机访问字符串向量：`GETRANGE,SETRANGE`
> - 在很小的空间进行编码，`SETBIT，GETBIT`

`Lists` ： string 元素的集合，安装插入顺序排序。使用基本的 `Linked Lists` 数据类型

`Sets` ：唯一、未排序的 string 元素集合

`Hashes`：由字段和其向关联的值映射组成。字段和值都是由 strings 构成。和 Ruby/Python 的 hashes 类似。

`Sorted Sets`：和 sets 类型类似，每个　String 元素都有一个浮点数值，叫做 score。这些元素按照该 score 排序，所以同 set 不同的是可以检索一定范围内的元素。如： top 10，bottom 10

---

###### Keys 命令

`DEL key [key ...]` 删除指定的 key，时间复杂度为 O(N)，N 为要删除元素的个数，单个为 O(M)，M 为 list, set, sorted set, hash 的元素个数，单个的 string key 为 O(1)

```bash
DEL key1 key2 key3
(integer) 2 [成功删除 key 的个数]
```

`EXISTS key [key ...]` : 判断 key 是否存在， 1 -> 存在，0 不存在。

`DUMP key` ： 返回 key 序列化后的值
`DUMP key` -> *\x00\x0etest redis key\b\x00\x1e\xc8\xafp?\x15b\xba*
`EXPIRE key seconds` ： 设置 key 的过期时间
	注意： redis 在 linux 上采用的是 Unix timestamps (milliseconds)保存，若是 RDB 文件在两台主机时间差异很大的机器转移，那么在加载时很多 key 都会被过期。也就是哪怕 redis 实例没有启动，时间也在流逝。
redis key 的过期有两种方式：被动方式、主动方式。
被动：当访问 key 的时候在去判断该 key 是否过期，当然就会有那种不在访问的 key 会永久保留，当时这个 key 无论如何都应该过期，因此，Redis 会定期的对过期集合中的 *key* 进行随机测试，删除已经过期了的 *key*。特定的 *Redis* 每秒执行 10 操作： 随机测试 20 个在过期集合中的 *key*。删除所有过期的 *key*。如果超过 *25%* 的 *key* 都过期了，那么重复在执行第一步骤。

`KEYS pattern` ： 按照 pattern 寻找匹配的 keys，返回 key 的 array
`PRESIST KEY` ： 把设置了过期时间的 key 永久保留，相当于清除过期事件设置。 1 过期时间被消除。
`PEXPRE key milliseconds` ： 设置 key 的过期时间，毫秒为单位。 1 过期事件设置成功。
`PTTL key` ： 查看 key 的剩余过期时间，单位为毫秒。 [-2 : key 不存在，-1 : key 存在，但是没有设置过期时间]
`TTL key`: 看 key 的过期时间，单位为秒。[-2 : key 不存在，-1 : key 存在，但是没有设置过期时间]
`RANDOMKEY` : 随机获取一个 key，nil 没 key
`RENAME key newKey` : 给 key 重命名。当 key 不存在时会报错。当新 key 存在原值会被覆盖，这时会隐式的 *DEL* 操作，当值比较大的时候，也会花费大量时间，可能造成延迟。
`RENAMENX key newkey` ： 重命名一个 key 为 newkey， 若是 *newkey* 不存在，当 key 不存在报错。[1 重命名为 newkey， 0 : newkey 已经存在]
`TYPE key` ： 查询一个 key 的类型，string, list, set, zset, hash, stream, 如果 *key* 不存在返回 none



---

###### Strings 命令

`APPEND key value`： 若 *key* 存在，则把 *value* 添加到 *string* 值后面，没有则新建一个在赋值给 key 的 value。返回的是字符串长度。
`DECR key`：把数值 value 减一，返回值减一后的值。64 位有符号值。若是 *key* 不存在则在操作之前把 key 值置为 0。
`DECRBY key decrement`： 把 key 的值减去指定的值。
`GET key`：获取   *key* 的值， 若是 *key* 不存在，返回 *nil*，若是 *key* 的值不是 *string* 则会报错。
`GETRANGE key start end`： 获取 *key* 指定范围内的值。
`GETSET key value`：获取旧值，保存新值。*nil* 若是 *key* 不存在。
`INCR key`: 增加值 1
`INCRBY key value`： 指定要增加多少值
`MGET key [key ...]`： 获取多个 key 的值， *nil* 为 *key* 值不存在。
`MSET key value [key value ...]`：一次行设置多个 key 和 value 值。
`PSETEX key milliseconds value`：在设定 key 值的同时配置过期时间，毫秒单位
`SET key value [EX seconds | PX milliseconds][NX|XX] [KEEPTTL]`：设置 key 的值和配置。若是 key 有值了，则覆盖其值并且不管现有的是什么类型数据，关于该 *key* 以前的所有配置都不在有用。
*EX seconds* - 配置指定的过期时间，秒。   *PX milliseconds* - 配置指定的The RDB persistence performs point-in-time snapshots of your dataset at specified intervals.过期时间，毫秒
*NX* - 仅当 *key* 不存在的时候才操作             *XX* - 仅当 *key* 存在的时候才操作
*KEEPTTL* - 保持原有的 ttl 配置
`SETEX key seconds value`： 原子操作，设置 key 值和过期时间
`SETNX key value`: *set if not exists* 当 key 不存在时保存 value，当 key 存在，不执行任何操作。
`STRLEN key`：返回 string key 的字符串长度，当 key 的值不是 string 时报错。0 当 key 不存在。

---

###### List 命令

`LPUSH key element [element ..]` ： 添加所有指定的值到 *list* 列表头。若果  *key* 不存在，先创建一个空的 *list*，在执行添加操作。若操作的 *key* 不是一个 *list* 类型，报错。返回 push 完成后 *list* 的长度。
`LPUSHX key element [element ...]`：插入值到存在的 *key* 的 *list*，仅当 *key* 存在才会执行命令。返回 *list* 长度。返回 0 当 *key* 不存在。

`RPUSH key element [element ...]`
`RPUSHX key element [element ...]`
`LRANGE key start stop` ： 获取 list 指定范围内的元素值列表， -1 表示最后一个元素，0 表示第一个元素。
`LPOP key` ： 删除并返回 *list* 存储的第一个值。*nil* key 不存在
`RPOP key` ： 删除并返回 *list* 存储的最后一个值。*nil* key 不存在
`LLEN key` ： 返回 list 的元素长度，当 *key* 不存在的时候放回 0。
`LREM key count element`：删除 *list* 当中和 *element* 匹配数量的值，*count > 0* 从 list head 删除到 tail。*count < 0* 从 list tail 删除到 head，*count = 0* 删除所有匹配的元素。
`LTRIM key start stop`：修剪指定 *key* 的 list，保留指定 start 到 stop 范围的数据。-1 表最后一个数据。0 第一。当 starter 大于list 的末尾，或者 start > end 会导致 list 所有元素删除，key 也会被删除。当 end 大于 list 数据时仅会当做最后一个元素位置。
`LINDEX key index` ： 返回 index 位置的元素值，0 表示开始元素下标。-1 最后一个元素。 *nil* index 超出边界

---

###### HASH 命令

`HDEL key field [field ...]`：删除指定的字段，当指定字段不存在会被忽略。当 key 不存在，会被当做一个空的 hash，返回 0。
`HEXISTS key field`：判断 key 中指定 field 是否存在。1 存在，0 不存在或者 key 不存在。
`HGET key field`：返回存在在 key 当中相关联的 field 值。nil 当 field 不存在或者 key 不存在。
`HGETALL key`： 返回该 key 包含的 hash 所有 field 和值。一个 field 跟着一个 value。
`HKEYS key`：返回 key 包含的所有 field 名称。空的 list 当 key 不存在。
`HLEN key`：返回 key 中 field 的数量。0 当 key 不存在。
`HMGET key field [field ...]`： 批量获取 key 中 field 的值。
`HMSET key field value [field value ...] `： 批量设置 key 的 field 和 value
`HSET key field value [field value ...]`： 设置 hash 的 field 和 value 值。当 field 存在会被覆盖。<font color="red">推荐使用 *HSET*</font>
`HSETNX key filed value`：设置 field 的 hash 值，仅当 field 不存在的时候。当 key 不存在，新的 key 创建。1 操作成功。
`HVALS key` ： 返回该 hash key 当中所有的 value 值。

---

###### SET 命令

`SADD key member [memeber ...]`：添加指定的 member 到 set 存储的 key。存在的 member 会被忽略。
`SMEMBERS key`： 获取 set key 中的所有值。
`SCARD key` ： 返回 set key 中元素的个数。0 key 不存在。
`SDIFF key [key ...]`： 返回第一个 key 和其余的差别。key 不存在的当做空。
`SDIFFSTORE destionation key [key ...]`： 比较与第一个 key 的差别，保存到 destination。
`SINTER key [key ...]`：返回所有 key 都包含的 member，仅有一个 空的 set 那么返回值就是空的 set。
`SINTERSTORE destination key [key ...]`： 当 destination 存在会被覆盖。
`SISMEMBER key memeber`：返回当 member 是存储 set 的 key 中的一个。 1 元素在 set 中存在。0 不存在或 key 不存在。
`SMOVE source destination memebr`：把一个 set 中的 member 移动到另一个 set。1 移动成功。
`SPOP key [count]`： 弹出指定数量的元素并删除。
`SREM key member [member ...]`：删除指定 member。返回删除的元素数量，不包括没存在的元素。
`SUNION key [key ...]`：取所有 key 的合集。
`SUNIONSTORE destination key [key ...]`：把合集放到指定位置

---

###### SORTED SET 命令

`ZADD key [NX|XX] [CH] [INCR] score member [score member]`： 添加值
*XX*  仅更新已经存在的元素，不添加元素                       *NX*  不更新存在的元素，仅添加新的元素
*CN* 更改返回值为所有修改过的元素数量                       *INCR* 
*Redis Sorted set* 采用 64-bit 浮点数来表示 score。可以添加相同分数的不同元素。每个元素都是唯一。当多个元素有相同的 score 后就按字典顺序排序。
`ZCARD key`： 返回 set 的元素个数
`ZCOUNT key min max`：返回 score 在 min 和 max 中间的元素个数
`ZRANGE key start stop [WITHSCORES]`：获取指定 index 范围的元素
`ZRANK key member`：获取指定 key 中 member 的 score，没有的 member 返回 nil
`ZREM key member [member]`： 删除指定 key 中的指定 member 元素。

---

Transaction 事务处理

`MULTI` 开始事务
`EXEC` 原子执行队列操作 <font color="blue">MULTI 和 EXEC 中间不能有错误出现</font>



---

#### redis 持久化

`redis` 支持两种方式的持久化：**快照持久化（RDB）** 和 **AOF持久化**

##### 快照方式（RDB）

快照持久化，是将某一时刻的所有数据写入到硬盘中持久化。显然，这存在一个“何时”写入硬盘的问题。如果相隔时间过长，那么恰好在没有持久化前宕机，这部分数据就会丢失。也就是说，无论如何配置持久化的时机，都有可能存在丢失数据的风险。所以，**快照持久化适用于即使丢失一部分数据也不会造成问题的场景**。
配置快照持久化，既可以直接通过**命令**，也可以通过**配置文件**的方式。

```properties
######## SNAPSHOTTING ########
# save [seconds] [changes] 表示在 [seconds] 秒内有 [changes] 个键值的变化则进行持久化
# 可同时配置多个，满足一个条件则触发
save 10 1               # 在 10 秒内有 1 次键值改变
save 900 1				# 在 900 秒内有 1 次键值变化则进行持久化。
save 300 10				# 在 300 秒内有 10 次键值变化则进行持久化。
save 60 10000			# 在 60  秒内有 10000 次键值变化则进行持久化。

# 当持久化出现错误时，是否停止数据写入，默认停止数据写入
# 可配置为 no，当持久化出现错误时，仍然能继续写入缓存数据。
stop-writes-on-bgsave-error yes
# 是否压缩数据，默认压缩,no 不压缩
rdbcompression yes
#对持久化rdb文件是否进行校验，默认校验。no 不校验
rdbchecksum yes
# 指定 rdb 保存到本地的文件名
dbfilename dump.rdb
# 指定 rdb 保存的目录，默认在本目录下，即 redis 的安装目录。
dir ./
```

`redis` 持久化默认使用**快照持久化**方式，如果想要开启 `AOF` 持久化 `appendonly yes`
通过命令方式快照持久化，有两个命令可供使用：`bgsave` 和 `save`。`bgsave`，redis 会创建一个子进程，通过子进程将快照写入硬盘，父进程则继续处理命令请求。`save` 则是 redis 在快照创建完成前不会响应其他命令，也就是阻塞式的，并不常用。

命令 `save` 或 `bgsave` 可以生成 dump.rdb 文件。
每次执行命令都会将所有 redis 内存快照保存到一个 rdb 文件里，并覆盖原有的 rdb 快照文件。
save 是同步命令，bgsave 是异步命令，bgsave 会从 redis 主进程 fork 出一个子进程专门生成 rdb 二进制文件

```bash
> bgsave
1201:C 25 Aug 2020 10:25:35.668 * RDB: 0 MB of memory used by copy-on-write
1172:M 25 Aug 2020 10:25:35.684 * Background saving terminated with success

> save
1172:M 25 Aug 2020 10:25:57.423 # User requested shutdown...
1172:M 25 Aug 2020 10:25:57.423 * Saving the final RDB snapshot before exiting.
1172:M 25 Aug 2020 10:25:57.424 * DB saved on disk
1172:M 25 Aug 2020 10:25:57.424 * Removing the pid file.
1172:M 25 Aug 2020 10:25:57.424 # Redis is now ready to exit, bye bye...
```

注意：配置文件中的 save 配置底层调用的是 `bgsave` 命令，在调用 `shutdown` 命令时，会调用 `save` 命令阻塞其它命令，将数据写入磁盘。

##### AOF 持久化

记录的是**执行的命令**，将被执行的写命令写入到 AOF 文件的末尾。它同样有持久化时机的问题，通常我们会配置“每秒执行一次同步”。

```properties
############################## APPEND ONLY MODE ###############################
# 是否开起 AOF 持久化，默认关闭，yes 打开。
# 在 redis4.0 以前不允许混合使用 RDB 和 AOF，但此后允许使用混合模式，通过最后两个参数配置。
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec

# 默认不重写 AOF 文件。
no-appendfsync-on-rewrite no
# 下面这两个配置是用于AOF“重写”触发条件。
# 当AOF文件的体积大于 64m，且 AOF 文件的体积比上一次重写之后的体积至少大了一倍（100%）则执行重新命令。
auto-aof-rewrite-percentage 100		
auto-aof-rewrite-min-size 64mb	
# 指 redis 在恢复时，会忽略最后一条可能存在问题的指令，默认值yes。
aof-load-truncated yes
# 是否打开 RDB 和 AOF 混合模式，默认yes打开。
aof-use-rdb-preamble yes
```

##### 混合持久化

```properties
aof-use-rdb-preamble yes
```

如果开启了混合持久化，aof 在重写时，不再是单纯将内存数据转换为 RESP 命令写入 aof 文件，而是将重写这一刻之前的内存做 rdb 快照处理，并且将 rdb 快照内容和增量的 aof 修改内存数据的命令存在一起，都写入新的 aof 文件，新的 aof 文件一开始不叫 appendonly.aof，等到重写完成后，新的 aof 文件才会进行改名，原子的覆盖原有的 aof 文件，完成新旧两个 aof 文件的替换。
于是在 redis 重启的时候，可以先加载 rdb 文件，然后再重放增量的 aof 日志就可以完全替代之前的 aof 全量文件重放，因此重启效率大幅得到提高。