**Headings** - To create a heading, add number signs (#) in front of a word or phrase.

# Heading level 1 -- <h1>Heading level 1</h1>

## Heading level 2 -- <h2>Heading level 2</h2>

###### Heading level 6 -- <h6>Heading level 6</h6>

**Alternate Syntax** add any number of == characters for heading level 1 or --- characters for heading level2



**Paragraphs**  To create paragraphs, use a blank line to separate one or more lines of text. You should not indent paragraphs with spaces or tabs.

I really like using Markdown.

I think I'll use it to format all of my documents from now on.



---

**一. 标题**

# # 这是一级表题
## ## 这是二级标题

### ### 这个三级标题

#### #### 这是四级标题

###### ###### 这是六级标题

**二. 字体**

1. 加粗, 左右两边用两个 * 号包起来. \*\*加粗\*\* **加粗**
2. 斜体, 左右两边使用一个 * 好包起来. \*斜体\* *斜体*
3. 斜体加粗, 文字左右分别用三个*号包起来 \*\*\*斜体加粗\*\*\* ***斜体加粗***
4. 删除线, 用两个 ~ 号包起来, ~~删除~~

**三.引用**

在引用文字前加 > 即可,引用可以嵌套,如加两个 >> 三个 >>>

> \> 这个是引用 1
>
> > \> 这个是引用 2
> >
> > > \> 这个是引用 3

**四.分隔线**

三个或者三个以上的 - 或者 * 都可以

---

**五.列表**

**1. 无序列表** 语法: 无序列表用  - + *  任何一种都可以

- \- 列表内容
+ \+ 列表内容
* \* 列表内容

**2. 有序列表** 语法: 数字加点 1.

1. 列表内容1
2. 列表内容2
3. 列表内容3

**3. 列表嵌套** 语法: 上一级和下一级之间敲三个空格即可

* 无序列表1
   * 无序子列表1
   * 无序子列表2
* 无序列表2
   1. 有序列表1
   2. 有序列表2
   3. 有序列表3

**六.图片**

语法: \![picture alt]\(picture address ''picture title'')
图片alt就是显示在图片下面的文字，相当于对图片内容的解释。
图片title是图片的标题，当鼠标移到图片上时显示的内容。title可加可不加

![beauty61-alt](./beauty61.jpg "beauty61.jpg")

**七. 表格**

语法: 

表头1| 表头2|表头3

---|:---:|---:

内容|内容|内容

```
第二行分割表头和内容。
- 有一个就行，为了对齐，多加了几个
文字默认居左
-两边加：表示文字居中
-右边加：表示文字居右
注：原生的语法两边都要用 | 包起来。此处省略
```

| 姓名 | 技能 | 排行 |
| :--: | :--- | ---: |
| 刘备 | 哭   | 大哥 |



**九. 代码**

语法: 单行代码: 代码之间分别用一个反引号包起来 (``)

\``单行代码`\`

代码块: 三个 \`\`\`代码快\`\`\`

```
这个是代码块
```