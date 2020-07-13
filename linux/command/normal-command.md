#### 1. find 命令

```bash
find [path ...] [expression]
# 常用
-type [f|d|b|l(小写L)|p]
-name "*.log" 	-iname 忽略大小写
-perm 755		-empty 空文件
-user root		-group root
-uid 1			-gid 1
-nouser			-nogroup
-size [+2k(大于)|-2k(小于)|2k(等于)] (k|m|g)
-atime -mtime -ctime [+10(十天前)|-10(十天内)|10(十天)] [a(访问)|m(修改)|c(改变文件属性)]
-amin  -cmin  -mmin [在 n 分钟时间范围]

# 逻辑
-or (-o) 	-and (-a)	-not (!EXP)
find / -type d -name "*.log" -or -name "*.zip"

# -exec (执行命令前无确认) / -ok (执行名列前先确认)
find / -type d -name "*.log" -exec rm -rf {} \;

# -xargs
find / -type d -name "*.log" -print0 | xargs -0 rm -f

# 搜索深度
-maxdepth 3
-mindepth 4
```

#### 2. xargs 命令

```bash
somecommand | xargs -item  command
-n num args 的数量， -n2 一次有两个参数让命令执行
-t 先打印命令在执行
-i {} 把一行参数赋值给 {},用 {} 代替
-d delim 分隔符，默认分隔符回车，参数分隔符为空格

find . -maxdepth 3 -type d -name "log" -print0 | xargs -0 -n1 -I {} rm -rf {}
find / -maxdepth 4 -type d -name "log" -o -name "out" -print0 | xargs -0 -n1 -t rm -rf
```

#### 3. ssh-keygen

```bash
ssh-keygen -t rsa -b 4096
ssh-keygen -t dsa
ssh-keygen -t ecdsa -b 521
ssh-keygen -t ed25519

# 指定文件名称
ssh-keygen -f ~/ssh-key-ecdsa -t ecdsa -b 521
ssh-keygen -t rsa -b 4096 -f ./ssh-rsa
```

