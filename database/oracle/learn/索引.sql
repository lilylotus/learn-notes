普通的扫描查询默认的是全表的扫描，有就是当你的数据在某一条之后就不满查询条件了，
但是数据库还是后继续查询以后的数据。

------------------
注意：使用 ROWID 查询数据是十分快速的

-- 开启追踪器
set autotrace on

一. 索引
1. 创建索引
CREATE INDEX [用户名].[索引名称] ON [用户名].表名称(列名称 [ASC|DESC], ...);
CREATE [UNIQUE] | [BITMAP] INDEX index_name  --unique表示唯一索引
ON table_name([column1 [ASC|DESC],column2    --bitmap，创建位图索引
[ASC|DESC],…] | [express])
[TABLESPACE tablespace_name]
[PCTFREE n1]                                 --指定索引在数据块中空闲空间
[STORAGE (INITIAL n2)]
[NOLOGGING]                                  --表示创建和重建索引时允许对表做DML操作，默认情况下不应该使用
[NOLINE]
[NOSORT];                                    --表示创建索引时不进行排序，默认不适用，如果数据已经是按照该索引顺序排列的可以使用

-- 创建索引
CREATE INDEX scott.emp_sal_ind ON scott.emp(sal) ;

-- 创建唯一索引
CREATE UNIQUE INDEX scott.emp_sal_ind ON scott.emp(sal) ;

2. 查看索引
-- 查看索引
SELECT * FROM all_indexes;
SELECT * FROM user_indexes ;
SELECT * FROM user_ind_columns ;

SELECT owner, index_name, index_type, table_name, uniqueness 
FROM all_indexes
WHERE table_name='EMP';

3. 删除索引
DROP INDEX INDEX_NAME ;