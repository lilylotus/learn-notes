##### docker redis 运行

```bash
# redis alpine
$ docker run --name redis \
-v `pwd`/conf/redis.conf:/usr/local/etc/redis/redis.conf \
-v `pwd`/data:/data \
-p 6379:6379 \
redis:alpine redis-server /usr/local/etc/redis/redis.conf

# redis debian
$ docker run -d --name redis \
-v `pwd`/data:/data \
-v `pwd`/conf/redis.conf:/etc/redis/redis.conf \
-p 46379:6379 \
redis:5.0.9 \
redis-server /etc/redis/redis.conf

cat <<EOF > /etc/apt/source.list
deb http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb http://mirrors.aliyun.com/debian-security buster/updates main
deb-src http://mirrors.aliyun.com/debian-security buster/updates main
deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
EOF

apt-get update
apt-get install net-tools
apt-get install iputils-ping
```

##### redis 版本

```bash
# 5.x 版本
docker pull redis:5.0.9
docker pull redis:5.0.9-alpine

# 4.x 版本
docker pull redis:4.0.14
docker pull redis:4.0.14-alpine
```

##### redis 数据持久化和自定义配置文件

```bash
docker run --name some-redis -d redis redis-server --appendonly yes

# 如果持久化支持，默认存储在 /data 卷中，可以通过挂载卷方式
-v /docker/host/dir:/data

# 自定义配置文件
# dockerfile
FROM redis
COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]

# 命令
docker run --name myredis redis \
-v /myredis/conf/redis.conf:/usr/local/etc/redis/redis.conf \
redis-server /usr/local/etc/redis/redis.conf
```

