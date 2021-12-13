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

### 2. 安装

```bash

pip install https://github.com/shadowsocks/shadowsocks/archive/master.zip -U
# aes-256-gcm 算法支持
yum install -y libsodium

mkdir -p /etc/shadowsocks
cat <<EOF > /etc/shadowsocks/shadowsocks.json
{
    "server": "0.0.0.0",
    "server_port": 13689,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "12345678",
    "timeout": 300,
    "method": "aes-256-gcm"
}
EOF

cat <<EOF > /etc/systemd/system/shadowsocks.service 
[Unit]
Description=Shadowsocks
[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/ssserver -c /etc/shadowsocks/shadowsocks.json
[Install]
WantedBy=multi-user.target
EOF

```

