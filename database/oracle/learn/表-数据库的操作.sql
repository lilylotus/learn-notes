-- 创建相同表结构但是没有复制数据
CREATE TABLE smembercopy 
AS
SELECT * FROM smember WHERE 1 = 2;

SELECT * FROM tab ;
DESC smember ;
-- 表更名
ALTER TABLE semember RENAME TO smember ; 
RENAME semember TO smemeber ;
-- 添加字段的语法：alter table tablename add (column datatype [default value][null/not null],….);
-- 如果表中有数据，添加字段有默认值的表中数据添加字段会添加默认值
ALTER TABLE smember ADD (age NUMBER(3) DEFAULT 1) ;
-- 修改字段数据类型的语法：alter table tablename modify (column datatype [default value][null/not null],….);
ALTER TABLE smember MODIFY (mage NUMBER(4) DEFAULT 2) ;
-- 改变字段名称正规写法
ALTER TABLE smember RENAME COLUMN age TO mage ;
-- 删除字段的语法：alter table tablename drop column (column_name);
ALTER TABLE smember DROP COLUMN mage ;
-- 设置无用的列，把表的该字段置为无用
ALTER TABLE smember SET UNUSED(MID) ;
ALTER TABLE smember SET UNUSED COLUMN MID ;
--  添加注释
COMMENT ON TABLE 表名称 | COLUMN 表名称.列名称 IS '注释内容' ;
COMMENT ON TABLE smember IS '这是我的ORACLE练习表' ;
COMMENT ON COLUMN smember.mid IS 'smember的主键列' ;
-- user_tab_comments 数据字典查询注释
SELECT * FROM user_tab_comments ;
-- user_col_comments 数据字典查询列的注释
SELECT * FROM user_col_comments WHERE TABLE_NAME='SMEMBER';
-- 添加主键
ALTER TABLE SMEMBER ADD CONSTRAINT PK_SID PRIMARY KEY(MID) ;
-- 添加、修改、删除多列的话，用逗号隔开。
-- 删除表，但是删除后会保留一些表数据(类似与回收站功能),防止误删除
DROP TABLE smember ;
-- 彻底删除表，不经过回收站
DROP TABLE smember PURGE ;
-- 删除回收站中的表
PURGE TABLE smember ;
-- 清空回收站
PURGE RECYCLEBIN ;
-- 闪回，删除表恢复
SELECT * FROm Recyclebin;
FLASHBACK TABLE smember TO BEFORE DROP ;
-- 截断表, 不可以恢复，立即释放该表的所有资源。
TRUNCATE TABLE smembercoyp ;
-- 查看表的约束
SELECT * FROM user_cons_columns WHERE table_name like 'SMEMBER%' ;

-------------------------------------------------------------------------------
表空间
-- ORACLE 数据库也叫做是实例
-- 数据表的空间(管理员创建)
CREATE TABLESPACE oracl_spacedata
DATAFILE 'D:\logs\oracle_space01.dbf' SIZE 50M,
        'E:\document\oracle_space02.dbf' SIZE 50M
AUTOEXTEND ON NEXT 2M LOGGING ;
-- 临时的表空间
CREATE TEMPORARY TABLESPACE oracl_tempspace
TEMPFILE 'D:\logs\oracle_tmpspace01.dbf' SIZE 50M,
        'E:\document\oracle_tmpspace02.dbf' SIZE 50M
AUTOEXTEND ON NEXT 2M ;
-- 查看表空间信息
SELECT tablespace_name, block_size, extent_management, status, contents 
FROM dba_tablespaces ;
-- 使用表空间
CREATE TABLE 用户名.表名 (
) TABLESPACE 表空间 ;
-- 删除表空间包含物理文件和内容
DROP TABLESPACE ORACL_SPACEDATA INCLUDING CONTENTS AND DATAFILES ;
DROP TABLESPACE ORACL_TEMPSPACE INCLUDING CONTENTS AND DATAFILES ;

数据库 ->
    表空间1，表空间2，表空间3 ...
        数据文件1，数据文件2 ....
            物理存储

系统表空间
非系统表空间

CREATE [TEMPORARY] TABLESPACE 表空间名称
[DATAFILE | TEMPFILE 表空间的文件保存路径 ...][SIZE 数字[K|M]] 
[AUTOEXTEND ON|OFF][NEXT 数字[K|M]]
[LOGGING | NOLOGGING]

DATAFILE : 保存表空间的磁盘的路径，可以设置多个保存路径
TEMPFILE ：保存临时表空间的磁盘路径
SIZE : 开辟的空间大小
AUTOEXTEND : 是否自动扩展表空间
NEXT : 可以定义表空间的增长量
LOGGING|NOLOGGING : 是否需要对DML进行日志记录

CREATE TABLESPACE mldn_data
DATAFILE 'd:\mldn_data.dbf' SIZE 50M,
        'd:\mldn_data1.dbf' SIZE 50M
AUTOEXTEND ON 
NEXT 2M
LOGGING ;

CREATE Temporary Tablespace mldn_tmp
TEMPFILE 'd:\mldn_tmp.dbf' SIZE 50M
AUTOEXTEND ON
NEXT 2M;

-- 使用表空间，在创建表的时候
CREATE TABLE mldn_table (
    id NUMBER(3) ,
    var VARCHAR2(20) 
) TABLESPACE mldn_data ;