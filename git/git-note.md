### 查看提交记录

```bash
# 在 2020-11-24 日期之后提交记录，指定文件的提交记录
git log --after="2020-11-24" --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:"%h - %cn : %cd : %s" -- xxx.file

git log --after="2020-11-24" --date=format:'%Y-%m-%d %H:%M:%S' --pretty=format:"%h - %cn : %cd : %s" --author="xxx" -- xxx.file

a767f218d - xxx : 2020-12-02 14:09:27 : xxxx

# 在 ad4c9ea 与 a22c3c2 提交 id 之间的记录
git log ad4c9ea..a22c3c2
```

### 对比两次提交文件差异

```bash
git diff 63f396f 499983e -- xxx.file

# 对比两次提交之间文件更新
git diff --stat --stat-width=200 93d8eb8 develop
```

