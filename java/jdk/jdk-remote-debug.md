### java JDWP 远程调试

运行时添加参数

```bash
# 本次设置为 8000
-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:8000

# 示例
java -agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=y -jar boot.jar
```