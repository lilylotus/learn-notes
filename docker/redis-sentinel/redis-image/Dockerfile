FROM redis:5.0.14-bullseye

RUN cat <<EOF > /etc/apt/sources.list \
deb http://mirrors.aliyun.com/debian/ bullseye main non-free contrib \
deb http://mirrors.aliyun.com/debian-security/ bullseye-security main \
EOF

RUN apt-get update && apt-get install -y iputils-ping

CMD ["which", "ping"]