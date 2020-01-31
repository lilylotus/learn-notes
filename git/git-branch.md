#### clone 远程分支

```
git clone --branch branch-name git_address clone_location

git clone --branch spring-gradle git@github.com:lilylotus/codinghappy.git C:/programming/idea/spring-gradle
```

#### 设置跟踪远程分支

`git branch --set-upstream-to=origin/dev`

```
git checkout -b spring-web-mvn --track origin/spring-web-mvn
git update --init
```

#### 取消跟踪远程分支

`git branch --unset-upstream [分支名称]`

#### 推送同时设置 upstream

`git push -u origin master`

#### 删除分支

```
git branch -d branchName
git branch -D branchName
```

