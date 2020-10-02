###### 目标

> 尽快重用端口和连接。尽可能扩大队列和缓冲区。选择TCP拥塞算法以获得大延迟和高吞吐量。

`/etc/sysctl.conf`

```bash
vm.swappiness = 0
vm.overcommit_memory = 1
vm.panic_on_oom = 0

fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 89100
fs.file-max = 52706963
fs.nr_open = 52706963
fs.may_detach_mounts = 1

net.ipv4.ip_forward = 1
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla

net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 16384
```

