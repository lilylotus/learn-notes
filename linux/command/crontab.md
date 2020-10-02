#### 定时任务 cron

定时任务文件目录 

- centos7 :  /var/spool/cron 目录中，每个用户定时文件以用户名保存，root 的是 /var/spool/cron/root
- ubunt : /var/spool/cron/crontabs 目录中，每个用户定时文件和 centos 一样

`crontab` 命令管理

```bash
# edit, default root user.
crontab -e [-u luck]
# show list, default root user
crontab -l [-u luck]
# delte
crontab -r [-u luck]
```

配置文件编辑

```
# minute (m), hour (h), day of month (dom), month (mon), day of week (dow)
# use '*' in these fields (for 'any')

# PATH 路径下的命令可以不用写绝对路径
*/10 * * * * /bin/echo "hello crontab" >> /tmp/echo.log 2>&1
```

