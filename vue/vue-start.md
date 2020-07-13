#### 1. 安装 vue

安装 vue cli

```bash
npm install -g @vue/cli[@version]  [默认不加 @3.11.0 安装最新版本]
npm update -g @vue/cli[@version]

# 查看 vue 版本
vue --version

# Instant Prototyping
npm install -g @vue/cli-service-global
serve [options] [entry]

# 安装 vue cli  (脚手架)
npm install -g @vue/cli-init
vue init webpack my-project
```

npm 操作

```
npm install -g npm # 升级 npm
npm list -g --depth 0 | grep vue # 查看是否安装过 vue
npm outdated -g --depth 0 # 查看需要更新的包
npm uninstall -g vue-cli # 卸载已经安装
npm cache clean --force # 清除缓存

npm root -g # npm 全局安装路径， 默认 /node安装目录/lib/node_modules
```

#### 2. 初始化一个 vue 项目

##### 2.1 命令行模式

```
vue create test [项目名称]
cd test
npm run server [启动项目]
```

##### 2.1 UI 创建方式

```
# 采用 ui 的方式创建项目
vue ui
```

#### 3. npm 管理

##### 3.1 配置全局 prefix 和 cache

```
npm config set prefix "location"
npm config set cache "location"
npm config list
```

##### 3.2 全局配置

默认配置在 `/home/user/.npmrc`

获取配置文件路径： `npm config get userconfig`

```
npm config ls -l ## 查看所有配置项
npm config get cache ## 查看缓存配置， get 后可以跟想查看的配置
npm config edit # 直接编辑 config 文件
```

#### 3. npm install 权限问题

> gyp ERR! stack Error: EACCES: permission denied, mkdir

> npm 出于安全考虑不支持以 root 用户运行，即使你用 root 用户身份运行了，npm 会自动转成一个叫 nobody 的用户来运行，而这个用户几乎没有任何权限

```bash
npm i --unsafe-perm # 执行
npm install --unsafe-perm
```