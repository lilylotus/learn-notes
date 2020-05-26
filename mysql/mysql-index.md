#### 1. Mysql 索引管理

##### 1.1 建立索引

```sql
ALTER TABLE 表名 ADD [UNIQUE|FULLTEXT|SPATIAL] INDEX|KEY [索引名] (字段名1[(长度)] [ASC| DESC]) [USING 索引方法]；

CREATE [UNIQUE|FULLTEXT|SPATIAL] INDEX INDEX_NAME ON TABLE_NAME(FIELD_NAME,...) [USAGE];

示例：
ALTER TABLE EXAMPLE_TABLE ADD UNIQUE INDEX (TABLE_FIELD);
ALTER TABLE EXAPMLE_TABLE ADD INDEX (FIELD1, FIELD2);

ALTER TABLE EXAMPLE_TABLE ADD PRIMARY KEY(field);
ALTER TABLE EXAMPLE_TABLE MODIFY field INT AUTO_INCREMENT;
```

##### 1.2 查看索引

```sql
show index from table_name ;
```

##### 1.3 删除索引

```sql
alter table table_name drop index index_name ;
DROP INDEX INDEX_NAME ON TABLE_NAME;
```

##### 1.4 索引效果分析

```sql
EXPLAIN SELECT * FROM TABLE_NAME WHERE .... ;
```

EXPLAIN 指标 - type 联接类型
结果值从好到坏依次是：
system > const > eq_ref > ref > fulltext > ref_or_null > index_merge > unique_subquery > index_subquery > range > index > ALL。
一般来说，得保证查询至少达到range级别。

