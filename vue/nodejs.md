#### 1. 配置 nodeJS 资源仓库

原始资源地址： `https://registry.npmjs.org`

##### 1.1 配置淘宝镜像

```bash
npm install -g cnpm --registry=https://registry.npm.taobao.org

在使用 npm install 使用淘宝镜像，cnpm install 进行安装 node_modules
```

##### 1.2  IDEA 集成有可能出现问题

```bash
# 持久使用
npm config set registry "https://registry.npm.taobao.org"

更改 npm 的 config registry 为淘宝镜像，使用 npm 从淘宝镜像拉取资源
```

##### 1.3 node-sass 中更新资源问题

有时候资源下载不了问题，通常是 git 上的资源无法下载

```bash
淘宝的源
npm config set sass_binary_site=https://npm.taobao.org/mirrors/node-sass/
phantomjs的源
npm config set phantomjs_cdnurl=https://npm.taobao.org/mirrors/phantomjs/
electron源
npm config set electron_mirror=https://npm.taobao.org/mirrors/electron/
```

##### 1.4 指定命令

```bash
node.exe C:\kits\nodejs\node_modules\npm\bin\npm-cli.js install --scripts-prepend-node-path=auto
```

##### 1.5 查看资源配置是否成功

```bash
npm config get registry
npm info express
```

#### 2. nodeJS 安装改变依赖、缓存下载位置

```bash
npm config set prefix "D:\MySoftware\nodejs\node_global"
npm config set cache "D:\MySoftware\nodejs\node_cache"
```

#### 3. nodeJS 打包

```bash
npm run build
```

#### 4. 安装 cnpm

```bash
npm install -g cnpm --registry=http://registry.npm.taobao.org
```

