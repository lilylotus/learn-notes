灰度发布 - Gated Launch，环境 Nginx + lua + Memcache

#### nginx 安装

```bash
# nginx 所需包
yum install -y gcc gcc-c++ make pcre pcre-devel zlib zlib-devel openssl openssl-devel make automake

# 灰度发布所需
yum install -y autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
# lua
yum install -y gd gd-devel lua lua-devel
# Memcache
yum install -y memcached
```

下载所需要的模块

- [ngx_devel_kit](https://github.com/vision5/ngx_devel_kit)
- [lua-nginx-module](https://github.com/openresty/lua-nginx-module)
- [lua-resty-memcached](https://github.com/openresty/lua-resty-memcached)
- [nginx](http://nginx.org/download/)

```bash
# ngx_devel_kit
wget https://github.com/vision5/ngx_devel_kit/archive/v0.3.1.tar.gz
# lua-nginx-module
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.17.tar.gz
# lua-resty-memcached
wget https://github.com/openresty/lua-resty-memcached/archive/v0.15.tar.gz
# nginx
wget http://nginx.org/download/nginx-1.18.0.tar.gz
```

编译安装

```bash
# 解压编译安装
tar xvf nginx-1.18.0.tar.gz
cd nginx-1.18.0

$ ./configure \
--prefix=/usr/local/src/nginx-1.18.0/ \
--with-http_gzip_static_module \
--add-module=/opt/ngx_devel_kit-0.3.1/ \
--add-module=/opt/lua-nginx-module-0.10.17/

$ make && make install
```

拷贝 lua 的 memcached 操作库文件

```bash
cp -r lua-resty-memcached-0.15/lib/resty/ /usr/lib64/lua/5.1/
```

nginx 配置文件 [grated launch nginx configuration](./grated-launch-nginx.conf)

启动 nginx

```bash
$ nginx
```

启动 memcached 服务

```bash
$ memcached -u nobody -m 1024 -c 2048 -p 11211 –d
```