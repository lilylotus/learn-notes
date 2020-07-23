#### 配置匿名用户

```
anonymous_enable=YES　　　　　　　　　   # 打开匿名用户模式
write_enable=YES　　 　　　　　　　　　　 # 打开全局写权限
anon_upload_enable=YES　　　　　　　　　 # 开启匿名用户上传权限
anon_mkdir_write_enable=YES　　　　　 　# 开启匿名用户创建目录的权限
anon_other_write_enable=YES　　　　　 　# 开启匿名用户可以删除目录和文件
anon_world_readable_only=YES　　　　　  # 开启匿名用户下载权限
anon_umask=022　　　　　　　　    　　    # 设置匿名用户可以下载自己上传的文件
```

