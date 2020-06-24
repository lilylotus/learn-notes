#### 1. 查看 tag

```
git tag # 列出所有
git tag -l "v2*" # 列车匹配
```

#### 2. 添加标签

```
git tag -a v2.0 -m 'tag description' # 在当前分支
git tag -a v2.0 168d8e6 -m 'tag descrption' # 指定分支
```

#### 3. 删除标签

```
git tag -d <tagname>

git push origin --delete <tagname> # 删除远程 tag
```

#### 4. 推送 tag 到服务器

```
git push origin <tagname> # 推送单个指定标签

git push origin --tags # 将会把所有不在远程仓库服务器上的标签全部传送
```

#### 5. 检出标签

```
git checkout <tagname>
git checkout -b <branchName> <tagName>
```

