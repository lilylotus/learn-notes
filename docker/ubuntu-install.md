#### 1. ubuntu18.04 安装

```bash
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

# Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# ali GPG key
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

# install Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# ali repository
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

# install docker
sudo apt-get install docker-ce docker-ce-cli containerd.io

# 安装指定版本
sudo apt-cache madison docker-ce
sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io

# 5:18.09.9~3-0~ubuntu-bionic
sudo apt-get install docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic containerd.io

sudo apt-get install docker-ce=5:19.03.12~3-0~ubuntu-focal docker-ce-cli=5:19.03.12~3-0~ubuntu-focal containerd.io
```

/etc/docker/daemon.json

```json
{
    "registry-mirrors": ["https://9ebf40sv.mirror.aliyuncs.com"],
    "graph": "/home/sharespace/docker",
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {"max-size": "100m"}
}
```

