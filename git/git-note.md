### 1. git 追踪远程分支
- 当还未推送到远程  
`git push --set-upstream origin remote_branch_name`  
示例: `git push --set-upstream origin spring-web-mvn:spring-web-mvn`
- 当已经推送,但是本地未追踪  
`git branch --set-upstream-to=origin/spring-web-mvn`
- 当本地还未 pull 时候  
`git checkout -b spring-web-mvn --track origin/spring-web-mvn`



### 克隆远程分支
`git clone --branch collections git@github.com:lilylotus/codinghappy.git C:\programming\`
