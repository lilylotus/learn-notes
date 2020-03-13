#### 网站开发优化

1. 尽可能减少 *HTTP* 请求次数
2. 使用 *CND (Content Delivery Network)*  内容分发网络
3. 添加 *Expire/Cache-Control* 头
4. 启用 *gzip* 压缩，文本内容 (html, php, js, css, xml, txt)
5. 将 *CSS (Cascading Style Sheets) 层叠样式表* 放到页面最上面
6. 将 *script* 放到页面最下面，代码式顺序执行，先将内容呈现出来
7. 避免在 *CSS* 中使用 *Expressions*， *css expressions* 的计算频率比我们想象的要多得多，严重影响浏览器性能
8. 把 *JavaScript 和 CSS* 放到外部文件中，**合理计划**
9. 减少 *DNS* 查询
10. 压缩 *JavaScript* 和 *CSS* 体积，去除不必要的空白符，格式符，注释符
11. 避免重定向
12. 移除重复脚本
13. 配置实体标签 *ETag (被请求变量的实体值)*
14. 使用 *AJAX (Asynchronous Javascript And XML) 异步 JavaScript 和 XML* 局部更新，缓存