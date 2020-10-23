### nginx WebScoket 配置支持

在 server 标签下配置匹配路径，`~` 表示使用正则表达式

```
location ~ ^/(uri|uri2|uri3)/ {
    // 转发代理地址
    proxy_pass           http://127.0.0.1:8080/;
    // 使用 http 版本为 1.1 
    proxy_http_version   1.1;
    // 超时设置，表明连接成功以后等待服务器响应的时候，如果不配置默认为 60s
    proxy_read_timeout   3600s;
    proxy_set_header Host $host:$server_port;
    // 启用支持 websocket 连接
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```