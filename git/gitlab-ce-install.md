`https://about.gitlab.com/install`

#### 1. ubuntu18.04

```bash
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates

sudo apt-get install -y postfix

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash

sudo EXTERNAL_URL="https://gitlab.example.com" apt-get install gitlab-ee
```

#### 2. centeos7

```bash
sudo yum install -y curl policycoreutils-python openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo systemctl reload firewalld

sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

sudo EXTERNAL_URL="https://gitlab.example.com" yum install -y gitlab-ee
```

#### 3. 清华大学开源镜像站

`https://mirrors.tuna.tsinghua.edu.cn/help/gitlab-ce/`

```bash
# GPG 公钥
curl https://packages.gitlab.com/gpg.key 2> /dev/null | sudo apt-key add - &>/dev/null


# ubuntu18.04 -> /etc/apt/sources.list.d/gitlab-ce.list
deb https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu bionic main
sudo apt-get update
sudo apt-get install gitlab-ce

# centos
cat <<EOF > /etc/yum.repos.d/gitlab-ce.repo
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
gpgcheck=0
enabled=1
EOF

# install
sudo yum makecache
sudo yum install gitlab-ce
```

