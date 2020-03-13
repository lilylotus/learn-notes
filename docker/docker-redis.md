###### docker redis 运行

```bash
docker run -v /redis/conf/redis.conf:/usr/local/etc/redis/redis.conf \
-v /redis/data:/data \
--name redis01 \
redis:alpine redis-server /usr/local/etc/redis/redis.conf
```

