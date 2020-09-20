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
`git push --set-upstream origin collections:collections`

#### 删除分支

```bash
git branch -d branchName
git branch -D branchName

git branch -d -r origin/origin/dev
git push -v origin :refs/heads/origin/dev
```

#### 创建一个空分支

空分支该分支没有父亲节点，不继承任何提交，是一个完全干净的节点。

```bash
git checkout --orphan <new-branch-name>

$ git checkout --orphan all-new-branch
$ git rm -rf .
$ git commit -m "new branch for learn"
```

#### git rebase

`log --pretty=format:'%Cred%h %C(yellow)%ad%Creset %Cred%s%Creset %Cblue[%an] %C(yellow)%d' --graph --date=short --topo-order`

`rebase`最强大的地方在于可以按需移动提交并对其进行编辑更改，当然前提是在**个人分支**上
**`git rebase`相关命令只允许在个人分支上使用**

- 用法一：将当前分支的提交变基到目标分支
  `git rebase <upstream> [<branch>]`
  *<upstream>* 目标分支或新基点
  如果提供`<branch>`，则会执行`git checkout <branch>`，默认为`HEAD`
  `git rebase master test` 或者 `git rebase master` -> 是在 *test* 分支上操作

  场景：将当前分支合并到主分支前执行变基操作，然后再合并到主分支，可以实现`fast-forward`

- 用法二：将当前分支变基到之前的提交, 重写其后的提交
  将当前分支变基到之前的某一提交, 重写其后的提交：`git rebase -i <upstream> [<branch>]`

- 用法三：将当前分支某一段提交变基到目标分支

- 用法四：变基时保留合并提交