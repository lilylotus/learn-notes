###### windows bash 文件在 linux 使用文件行结尾报错

```bash
查看：
cat -A filename (windows: -> #!/bin/bash^M$ ， unix -> #!/bin/bash$)
od -t x1 filename (0d 0a 表示为 dos 格式，0a 为 unix 格式)
:
sed 命令
sed -i "s/\r//" filename 或者 sed -i "s/^M//" filename
------------------
打开文件，执行，保存
set ff=unix 
```

