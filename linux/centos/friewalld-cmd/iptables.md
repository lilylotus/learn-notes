## iptables 使用
| 主机： c01(104) c02(105) c03(106)  
| 构建： c01 不可直接访问 co3[web 40000 端口]，c02 转发 c01 的请求到 c03

1. c03 拦截 c01 的请求
```bash
iptables -t filter -p tcp --dport 4000 -s 10.10.27.104 -j REJECT
```