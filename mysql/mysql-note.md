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

#### 4. mysql 区分大小写

```properties
[mysqld]
# OFF 文件名区分大小写，ON 不区分大小写
lower_case_file_system=OFF
# 0 大小写敏感， 1 大小写不敏感
lower_case_table_names=0
```

#### 5. 时间操作

查询一小时内的数据

```sql
SELECT now() - INTERVAL 2 HOUR;
SELECT DATE_SUB(NOW(),INTERVAL  1 HOUR) ;

-- 查询 1 小时内的数据
SELECT * FROM tb_log WHERE ADD_TIME > (now() - Interval 1 HOUR);
-- 查询 10 分钟内的数据
SELECT * FROM tb_log WHERE ADD_TIME > (now() - Interval 10 MINUTE);
```

#### mysql 唯一性约束是否可以有多个 null 值

##### 创建唯一性约束

```sql
CREATE TABLE `t_test` (
    `Id` int(11) NOT NULL AUTO_INCREMENT, 
    `username` varchar(18) NOT NULL unique, 
    `password` varchar(18) NOT NULL, 
    UNIQUE KEY(password),
    PRIMARY KEY (`Id`) 
) ENGINE=InnoDB ;
---
ALTER TABLE `t_test` ADD unique(`username`);
或者
create unique index UserNameIndex on 't_test' ('username');
```

<font color="red">注意：</font> `NULL` 在 *mysql* 当中存储是要占用空间的。

清楚理解 **空字符串** 和 **NULL** 的不同。空字符串 `('')` 是不占用空间的。注意：空字符串 `''` 之间是无空格。
`NULL columns require additional space in the row to record whether their values are NULL. For MyISAM tables, each NULL column takes one bit extra, rounded up to the nearest byte.`

唯一性约束下是可以有重复的空值 `NULL`，但是不能有重复的空字符串 `''`。

`主键` 和 `唯一键约束` 是通过参考索引实现的，如果插入的值均为 `NULL`，则根据索引的原理， `NULL` 值不被记录在索引上，所以插入 `NULL` 值时，可以有重复的，而其它的则不能插入重复值。

- `NULL` 其实并不是空值，是要占用空间，所以 MySQL 在进行比较的时候，`NULL` 会参与字段比较，所以对效率有一部分影响。
而对表索引时不会存储 `NULL` 值的，所以如果索引的字段可以为 `NULL`，索引的效率会下降很多。
- 空值不一定为空，对于 MySQL 特殊的注意事项，对于 timestamp 数据类型，如果往这个数据类型插入的列插入 NULL 值，则出现的值是当前系统时间。插入空值，则会出现  `0000-00-00 00:00:00`
