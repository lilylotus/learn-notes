# hexo 博客框架

## hexo 简介

[Hexo](https://hexo.io/zh-cn/) 是一个快速、简洁且高效的博客框架。Hexo 使用 [Markdown](http://daringfireball.net/projects/markdown/)（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页。

## 安装前环境准备

当前是在 [CentOS Linux 7](https://www.centos.org/) 上安装 hexo

- git 安装

```bash
$ sudo yum install -y git
```

- nodejs 安装

[node.js 官网](https://nodejs.org/en/)  [下载地址](https://nodejs.org/dist/v16.18.0/node-v16.18.0-linux-x64.tar.xz)

```bash
$ wget https://nodejs.org/dist/v16.18.0/node-v16.18.0-linux-x64.tar.xz
# 查看安装版本
$ node -v
# npm 配置淘宝镜像站 (https://developer.aliyun.com/mirror/NPM)
$ npm config set registry http://registry.npmmirror.com
$ npm config get registry
```

## hexo 安装

```bash
# 安装 hexo 脚手架
$ npm install hexo-cli -g

# 部署博客
$ hexo init blog
$ cd blog
$ npm install
$ hexo server
```

### hexo 主题安装

[hexo 主题](https://hexo.io/themes/) ， 本次采用简单干净的主题 [Cactus](https://github.com/probberechts/hexo-theme-cactus) 。 cactus -（仙人掌）

```bash
$ git clone https://github.com/probberechts/hexo-theme-cactus.git themes/cactus
```

### cactus 配置

- hexo 主配置 **_config.yml** 配置为新添加的 cactus 主题

```yaml
# hexo/_config.yml
theme: cactus
```

- 设置 cactus 主题颜色， 在 themes/cactus 的 **_config.yml** 中修改配置 

```yaml
# cactus/_config.yml

# 调整颜色模式为 white
colorscheme: white
# 展示页面宽度 rem 为单位
page_width: 60
```

- 修复 cactus 显示右上角导航消失后不在显示，themes/cactus/source/js/main.js

```javascript
// themes/cactus/source/js/main.js

// 修改大概第 60 行界面滚动事件
// hide only the navigation links on desktop
if (menu.is(":visible") && topDistance < 280) {
    nav.show();
} else if (menu.is(":visible") && topDistance > 300) {
    nav.hide();
}
```

- 修改目录样式问题，themes/cactus/source/css\_partial/post/actions_desktop.styl

```css
/* 大概在 121 行，主要是修改右侧的目录显示 */
  #toc
    max-width: 26em
    text-align: right

    // 目录缩进
    ol
      padding-inline-start: 20px

    // 一级标题显示
    .toc-level-1 > .toc-link
      //display: none
	  // 一级标题显示标记
      &:before
        color: $color-accent-1
        content: "#"
```

- 设置 cactus 访问固定地址前缀

```yaml
# cactus/_config.yml
# 指定固定前缀 -> http://127.0.0.1:4000/blog/
root: /blog/
```

