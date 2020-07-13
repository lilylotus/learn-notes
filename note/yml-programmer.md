#### YAML 基本语法

>```
>YAML is a human friendly data serialization standard for all programming languages.
>仍是一种标记语言，但为了强调这种语言以数据做为中心，而不是以标记语言为重点
>```

1. 缩进时不允许使用 tab，只允许使用空格
2. 缩进的空格数目不重要，只要相同层级的元素左侧对齐即可
3. *#* 标识注释，从这个字符一直到行尾，都会被解释器忽略

#### YAML 支持的数据结构

- 对象：键值对的集合，又称为映射（mapping）/ 哈希（hashes） / 字典（dictionary）
- 数组：一组按次序排列的值，又称为序列（sequence） / 列表 （list）
- 纯量（scalars）：单个的、不可再分的值



*对象类型：键值对 使用冒号分隔格式*

```yml
name: Steve
age: 18

# 另一种写法
hash: { name: Steve, age: 18 }
```

*数组类型*

```yml
animal:
- Cat
- Dog

# 另一种写法
animal: [Cat, Dog]
```

*复合数据结构：对象和数组可以结合使用，形成复合结构*

```yml
languages:
- Chinese
- Japannese
WebSites:
  ymal: yaml.org
  python: python.org
  perl: perl.org
```

*纯量*

1. 字符串 布尔值 整数 浮点数 Null

2. 时间，日期

   ```yaml
   null 使用 ~ 表示
   时间格式采用 ISO8601 格式 ： 2001-12-12T21:21:21.10
   日期格式： date: 1999-11-11
   ```

*注意：*

1. 字符串默认不使用引号表示 `ThisisaString`

2. 如果字符串之中包含空格或特殊字符，需要放在单引号之中 `'This is a String'`

3. 单引号和双引号都可以使用，双引号不会对特殊字符转义

4. 单引号之中如果还有单引号，必须连续使用两个单引号转义 `str: 'labor''s day'`

5. 字符串可以写成多行，从第二行开始，必须有一个单空格缩进。换行符会被转为空格

   ```yaml
   str: 只是一段
    多行
    字符串
   ```

6. 多行字符串可以使用 **|** 保留换行符，也可以使用 **>** 折叠换行

   ```yaml
   this: |
   Foo
   Bar
   
   that: >
   Foo
   Bar
   ```

7. **+** 表示保留文字块末尾的换行，**-** 表示删除字符串末尾的换行

   ```yaml
   s1: |
   Foo
   s2: |+
   Foo
   s3: |-
   Foo
   ```

   

