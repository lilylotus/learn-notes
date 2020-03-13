#### 1. 安装脚本

```bash
yum install -y python-setuptools m2crypto supervisor
yum install -y net-tools vim epel-release gcc automake make
yum -y install python-pip
easy_install pip && pip install shadowsocks


cat <<EOF > /etc/shadowsocks.json
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
        "19091":"ShadowSocks#1000Yuan"
    },
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": true
}
EOF

ssserver -c /etc/shadowsocks.json -d start
```



