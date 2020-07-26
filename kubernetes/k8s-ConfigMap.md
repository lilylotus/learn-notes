# 介绍

`ConfigMap` 功能在 Kubernetes 1.2 版本中引入，许多应用程序会从配置文件、命令行参数或环境变量中读取配置信息。ConfigMap API 提供了向容器中注入配置信息的机制，`ConfigMap` 可以被用来保存单个属性，也可以用来保存整个配置文件或者 JSON 二进制大对象

# ConfigMap 创建

## I、使用目录创建

```bash
mkdir -p configmap/properties

$ cat <<EOF > game.properties
enemies=aliens
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten
secret.code.passphrase=UUDDLRLRBABAS
secret.code.allowed=true
secret.code.lives=30
EOF

$ cat <<EOF > ui.properties
color.good=purple
color.bad=yellow
allow.textmode=true
how.nice.to.look=fairlyNice
EOF

$ kubectl create configmap properties-config --from-file=./properties
# --from-file 指定目录下所有的文件都会配置在 configmap 创建键值对
# 键名：文件名， 键值：文件内容

$ kubectl get configmap[cm]
$ kubectl get cm property-config -o yaml
$ kubectl describe cm property-config
```

## II、使用文件创建

```bash
$ kubectl create configmap learn-config --from-file=./learn.properties
# --from-file 可以使用多次，和使用目录效果一样
$ kubectl get cm learn-config -o yaml
```

## III、使用字面值创建

```bash
$ kubectl create configmap special-config --from-literal=special.how=very --from-literal=special.type=charm

$ kubectl get configmaps special-config -o yaml
```

# comfigmap 使用

## I、用 ConfigMap 来替代环境变量

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: comfigmap-pod
spec:
  containers:
  - name: test-container
    image: hub.atguigu.com/library/myapp:v1
    command: [ "/bin/sh", "-c", "env" ]
    env:
      - name: SPECIAL_LEVEL_KEY
        valueFrom:
          configMapKeyRef:
            name: special-config
            key: special.how
      - name: SPECIAL_TYPE_KEY
        valueFrom:
          configMapKeyRef:
            name: special-config
            key: special.type
    envFrom:
      - configMapRef:
          name: env-config
restartPolicy: Never
```

