# Nginx 简介
Nginx 是一款面向性能设计的 HTTP 服务器，能反向代理 HTTP，HTTPS 和邮件相关(SMTP，POP3，IMAP)的协议链接。
并且提供了负载均衡以及 HTTP 缓存。它的设计充分使用异步事件模型，削减上下文调度的开销，提高服务器并发能力。采用了模块化设计，提供了丰富模块的第三方模块。  
Nginx 标签：「异步」「事件」「模块化」「高性能」「高并发」「反向代理」「负载均衡」

## Nginx 安装
---
### 安装依赖
> prce [重定向支持] 和 openssl [https 支持]，如果不需要 https 可以不安装
```bash
yum install -y pcre-devel gcc make gcc-c++ wget openssl openssl-devel

./configure \
    --sbin-path=/usr/local/nginx/nginx \
    --conf-path=/usr/local/nginx/nginx.conf \
    --pid-path=/usr/local/nginx/nginx.pid \
    --with-http_ssl_module \
    --with-pcre=../pcre-8.43 \
    --with-zlib=../zlib-1.2.11

make
```

### 服务管理
```bash
# 启动
/usr/local/nginx/sbin/nginx
# 重启
/usr/local/nginx/sbin/nginx -s reload
# 关闭进程
/usr/local/nginx/sbin/nginx -s stop
# 平滑关闭nginx
/usr/local/nginx/sbin/nginx -s quit
# 查看nginx的安装状态
/usr/local/nginx/sbin/nginx -V
```

## Nginx 配置
---
在 Centos 默认配置文件在 **/usr/local/nginx-1.5.1/conf/nginx.conf**，nginx.conf 是主配置文件，由若干个部分组成，每个大括号 `{}` 表示一个部分。每一行指令都由分号结束 `;`，标志着一行的结束。

### **常用正则表达式**
| 正则 | 说明 | 正则 | 说明 |
| ---- | ---- | ---- | ---- |
| `. ` | 匹配除换行符以外的任意字符 | `$ ` | 匹配字符串的结束 |
| `? ` | 重复0次或1次 | `{n} ` | 重复n次 |
| `+ ` | 重复1次或更多次 | `{n,} ` | 重复n次或更多次 |
| `*` | 重复0次或更多次 | `[c] ` | 匹配单个字符c |
| `\d ` |匹配数字 | `[a-z]` | 匹配a-z小写字母的任意一个 |
| `^ ` | 匹配字符串的开始 | - | - |

### 全局变量

| 变量 | 说明 | 变量 | 说明 |
| ---- | ---- | ---- | ---- | 
| `$args` | 这个变量等于请求行中的参数，同 $query_string | `$remote_port` | 客户端的端口 |
| `$content_length` | 请求头中的 Content-length 字段 | `$remote_user` | 已经经过 Auth Basic Module 验证的用户名 |
| `$content_type` | 请求头中的 Content-Type 字段 | `$request_filename` | 当前请求的文件路径，由 root 或 alias 指令与 URI 请求生成 |
| `$document_root` | 当前请求在 root 指令中指定的值 | `$scheme` | HTTP 方法（如http，https） |
| `$host` | 请求主机头字段，否则为服务器名称 | `$server_protocol` | 请求使用的协议，通常是 HTTP/1.0 或 HTTP/1.1 |
| `$http_user_agent` | 客户端 agent 信息 | `$server_addr` | 服务器地址，在完成一次系统调用后可以确定这个值 |
| `$http_cookie` | 客户端 cookie 信息 | `$server_name` | 服务器名称 |
| `$limit_rate` | 这个变量可以限制连接速率 | `$server_port` | 请求到达服务器的端口号 |
| `$request_method` | 客户端请求的动作，通常为GET或POST | `$request_uri` | 包含请求参数的原始 URI，不包含主机名，如：/foo/bar.php?arg=baz |
| `$remote_addr` | 客户端的IP地址 | `$uri` | 不带请求参数的当前URI，$uri 不包含主机名，如 /foo/bar.html |
| `$document_uri` | 与 $uri 相同 | - | - |

例如请求：`http://localhost:3000/test1/test2/test.php`  

`$host`：localhost  
`$server_port`：3000  
`$request_uri`：/test1/test2/test.php  
`$document_uri`：/test1/test2/test.php  
`$document_root`：/var/www/html  
`$request_filename`：/var/www/html/test1/test2/test.php  

### 符号参考
| 符号 | 说明 | 符号 | 说明 | 符号 | 说明 |
| ---- | ---- | ---- | ---- | ---- | ---- |
| k,K | 千字节 | m,M | 兆字节 | ms | 毫秒 |
| s | 秒 | m | 分钟 | h |  小时 |
| d | 日 | w | 周 | M |  一个月, 30天 |

例如，"8k"，"1m" 代表字节数计量。  
例如，"1h 30m"，"1y 6M"。代表 "1小时 30分"，"1年零6个月"。 
