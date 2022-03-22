#!/bin/bash

host=$1

if [[ "" = "$1" ]]; then
        echo "please entry host ip"
        exit 1
fi

redis_dir=(master slave1 slave2)
for dir in ${redis_dir[@]};
do
        echo "modify file $dir/redis.conf"
        sed -i "s/^replica-announce-ip.*/replica-announce-ip ${host}/" ${dir}/redis.conf
done

sentinel_dir=(sentinel1 sentinel2 sentinel3)
for dir in ${sentinel_dir[@]};
do
        echo "modify file $dir/sentinel.conf"
        sed -i "s/^sentinel announce-ip .*/sentinel announce-ip ${host}/" $dir/sentinel.conf
        sed -i "s/^sentinel monitor .*/sentinel monitor redismaster ${host} 8001 2/" $dir/sentinel.conf
done
