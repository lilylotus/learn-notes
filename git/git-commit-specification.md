# Git 提交规范

推荐是的 *AngularJs* 的 *Git* 提交规范。

```
<type>[optional scope]: <description>
# 空行
[optional body]
# 空行
[optional footer]

```

#### type

提交的类型 `type`，每次提交的 *type* 是必须的。

- `feat` 新功能，顾名思义就是新需求的实现。
- `fix` 修复，就是对bug的修复。
- `docs` 文档，主要用来描述文档的变更。
- `style` 主要是代码风格相关的提交，比如格式化等。
- `refactor` 重构代码，对已有功能的重构，但是区别于bugfix。
- `test` 测试相关的提交，不太常用。
- `chore` 构建过程或辅助工具的变动，不太常用，比如之前用Maven，后面换成了Gradle。

#### scope (可选)

用来表明本次提交影响的范围，方便快速定位。你可以写明影响的是哪个模块（通常是模块名称）或者是哪个层（数据层、服务层、还是视图层）。

#### subject (description)

是对本次提交的简短描述概括。就像要起一个标题一样，不要过长。

#### body (可选)

就是比较详细描述本次提交涉及的条目，罗列代码功能，当然 `body` 不是必选的，如果 `subject` 能够描述清楚的话。

#### foot（可选）

描述与本次提交相关联的 **break change** 或 **issue** 。