#### 1. LVM 安装

```bash
yum install -y lvm2
```

#### 2. LVM 容量改变

##### 2.1 扩容

```bash
# 扩展命令 lvextend，注意：没有 + 时为绝对值， 有 + 时为当前容量上加
lvextend -L [+]Size(mM|gG|tT) (指定卷的容量)
lvextend -l [+]Number (指定 PE 的数量)

# 缩减 lvreduce
lvreduce -L [-]Size(mM|gT) (指定要缩小的大小)
lvreduce -l [-]Number (指定减少的 PE 数量)

# 容量 lvresize
lvresize -L [+|-](mM|gT) (指定拓展/缩小/特定容量)
lvresize -l [+|-]Number (指定拓展/缩小/特定 PE 数量)
```

<font color="red">注意：缩小容量的时候要先卸载卷</font>

```bash
# xfs 重新格式大小

xfs_info /dev/lvm/lvm01
xfs_growfs /dev/lvm/lvm01

# 以前 resize2fs /dev/lvm/lvm02
```

#### 3. 创建 lvm 流程

```bash
pvcreate /dev/sda2

vgcreate vgName /dev/sdb [/dev/sdc1 ...]
-p Number (最大的物理卷数量) 	-l Number (最大逻辑卷数量) 	-s Size(mM) (指定 PE 大小)

lvcreate -L Size(M|G|T) -l Number -n lvName vgName
```

#### 4. lvm 拓展容量

```bash
vgextend vg2000 /dev/sdb2
```