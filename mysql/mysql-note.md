#### 1. 修改密码

```mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'mysql' PASSWORD EXPIRE NEVER;
flush privileges;
```

policy requirements，密码策略。

```mysql
-- 密码策略，0：长度 1: 长度，数字，小写或大写字母，特殊字符 2：长度，数字，小写或大写字母，特殊字符，字典文件
set global validate_password_policy=0;
-- 校验默认长度
set global validate_password_length=1;
```

#### 2. 创建用户授权

```mysql
create user 'remote'@'%' identified by 'mysql';
CREATE DATABASE test DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
grant all privileges on test.* to 'remote'@'%' with grant option;
```

#### 3. 各种字符集的区别

`utf8mb4_bin`、`utf8mb4_unicode_ci` 与 `utf8mb4_general_ci`

> UTF-8 是使用 1~4 个字节，一种变长的编码格式，字符编码。mb4 即 most bytes 4，使用 4 个字节来表示完整的 UTF-8。

`utf8mb4_bin`：将字符串每个字符用二进制数据编译存储，区分大小写，而且可以存二进制的内容。
`utf8mb4_general_ci`：*ci* 即 case insensitive，不区分大小写。没有实现 Unicode 排序规则，在遇到某些特殊语言或者字符集，排序结果可能不一致。但是，在绝大多数情况下，这些特殊字符的顺序并不需要那么精确。
`utf8mb4_unicode_ci`：是基于标准的 Unicode 来排序和比较，能够在各种语言之间精确排序，Unicode 排序规则为了能够处理特殊字符的情况，实现了略微复杂的排序算法。

> `*_bin`: binary case sensitive collation，也就是说是区分大小写的
> `*_cs`: case sensitive collation，区分大小写
> `*_ci`: case insensitive collation，不区分大小写

字符除了需要存储，还需要排序或比较大小，涉及到与编码字符集对应的 排序字符集（collation）。ut8mb4 对应的排序字符集常用的有 `utf8mb4_unicode_ci`、`utf8mb4_general_ci`
总结：`utf8mb4_general_ci` 更快，`utf8mb4_unicode_ci` 更准确。推荐是 `utf8mb4_unicode_ci`