#### 获取执行 SHELL 脚本所在目录

```bash
#!/bin/bash
SHELL_DIR=$(cd $(dirname $0) && pwd)

# 软链接版
SOURCE_DIR="$0"
while [ -h "$SOURCE_DIR" ];
do
	DIR="$(cd -P $( dirname "$SOURCE_DIR" ) && pwd)"
	SOURCE_DIR="$(readlink "$SOURCE_DIR")"
	[[ "$SOURCE" != "/*"  ]] && SOURCE="$DIR/$SOURCE_DIR"
done
DIR="$( cd -P $( dirname "$SOURCE_DIR" ) && pwd )"
echo "SHELL DIR [$DIR]"
```

#### 文件测试

```bash
-b filename - Block special file
-c filename - Special character file
-d directoryname - Check for directory Existence
-e filename - Check for file existence, regardless of type (node, directory, socket, etc.)
-f filename - Check for regular file existence not a directory
-G filename - Check if file exists and is owned by effective group ID
-G filename set-group-id - True if file exists and is set-group-id
-k filename - Sticky bit
-L filename - Symbolic link
-O filename - True if file exists and is owned by the effective user id
-r filename - Check if file is a readable
-S filename - Check if file is socket
-s filename - Check if file is nonzero size
-u filename - Check if file set-user-id bit is set
-w filename - Check if file is writable
-x filename - Check if file is executable

#!/bin/bash
file=./file
if [ -e "$file" ]; then
    echo "File exists"
else 
    echo "File does not exist"
fi

# -------------------------
if [ ! -f "$FILE" ]
then
    echo "File $FILE does not exist"
fi
```

#### 2. 字符串处理

```bash
#!/bin/bash
str="truncate-test-script.sh"
line="---------------------------------"

echo "opoeration string = $str"
echo $line

echo "$str len = ${#str}"
echo $line

echo "truncate to left = [${str#*-}]"
echo "truncate to max left = [${str##*-}]"
echo $line

echo "truancate right = [${str%-*}]"
echo "truncate right max = [${str%%-*}]"
echo $line

echo "pattern left = [${str:0:8}]"
echo "pattern left = [${str:9}]"
echo $line

echo "pattern right = [${str:0-10:2}]"
echo "pattern right = [${str:0-10}]"
echo $line
```

```
opoeration string = truncate-test-script.sh
---------------------------------
truncate-test-script.sh len = 23
---------------------------------
truncate to left = [test-script.sh]
truncate to max left = [script.sh]
---------------------------------
truancate right = [truncate-test]
truncate right max = [truncate]
---------------------------------
pattern left = [truncate]
pattern left = [test-script.sh]
---------------------------------
pattern right = [-s]
pattern right = [-script.sh]
---------------------------------
```

