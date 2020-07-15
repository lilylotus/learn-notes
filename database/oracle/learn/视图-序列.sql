CREATE [REPLACE | NOFORCE][OR REPLACE] VIEW 视图名称
AS
子查询
[WITH CHECK OPTION[CONSTRAINT 约束名称]]

FORCE : 表是创建的视图的表不存在也可以创建
NOFORCE ：(默认)创建的视图表必须存在，否则无法创建
OR REPLACE ：视图的替换，不存在创建新的，存在就替换

1. 提供创建视图的权限
GRANT CREATE VIEW TO 用户名称 ;

========================================================================
序列(ORACLE 的对象)
序列(SEQUENCE)是序列号生成器，可以为表中的行自动生成序列号，产生一组等间隔的数值(类型为数字)。
其主要的用途是生成表的主键值，可以在插入语句中引用，也可以通过查询检查当前值，或使序列增至下一个值。
1. 创建序列
CREATE SEQUENCE 序列名
    [INCREMENT BY 步长]
    [START WITH 开始值]
    [{MAXVALUE/ MINVALUE 最大/最小值|NOMAXVALUE}]
    [{CYCLE|NOCYCLE}]
    [{CACHE 缓存大小|NOCACHE}];

默认序列：最小值为0， 最大值为无限大。

2. 查看序列
SELECT * FROM user_sequences ;

3. 使用序列
注意：数据库只会记得一个叫 LAST_NUMBER 的最后一个值，有可能出现跳号的可能。
序列名称.currval : 表示取得当前序列已经增长的结果，重复多次序列内容不会改变
序列名称.nextval : 表示取得下一个序列的下一次增长值，没每调用一次，值增长一次。
SELECT seq1.currval FROM dual ;

4. 删除序列
DROP SEQUENCE 序列名称 ;

5. 修改序列
ALTER SEQUENCE 序列名称
    [INCREMENT BY 步长]
    [START WITH 开始值]
    [{MAXVALUE/ MINVALUE 最大/最小值|NOMAXVALUE}]
    [{CYCLE|NOCYCLE}]
    [{CACHE 缓存大小|NOCACHE}];

=========================================================
视图是从一个或几个实体表中导出的表，但是视图本身不包含任何真实的数据，只是一个虚拟的表
他的数据任然保存在实体表中，所以实体表中的数据更改了视图查询数据也就随之更改了

1. 创建
CREATE [FORCE|NOFORCE][OR REPLACE] VIEW 视图名称 (别名1， 别名2...)
AS
子查询 [WITH CHECK OPTION [CONSTRAINT 约束名称]]
WITH READ ONLY;
FORCE : 表示要创建视图的表不存在也可以创建视图
NOFORCE : (默认) 创建视图的表必须存在，否则无法创建
OR REPLACE : 表示视图替换，视图不存在在创建新的，若存在则替换
WITH CHECK OPTION : 保证创建字段不被修改
WITH READ ONLY : 保证无法执行 DML 操作

2. 视图的数据字典 user_views
SELECT * FROM user_views ;

3. 删除视图
DROP　VIEW 视图名称 ;
DROP VIEW v_myview ;

CREATE VIEW v_myview
AS
SELECT * FROM emp WHERE sal > 2000 ;

CREATE OR REPLACE VIEW v_myview (员工编号, 员工姓名, 工作)
AS
SELECT empno, ename, job FROM emp WHERE sal > 2000 ;

SELECT * FROM v_myview ;