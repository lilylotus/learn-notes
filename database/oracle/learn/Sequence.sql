序列: 按照规定自动增长
1. 创建序列
CREATE SEQUENCE 序列名称
    [INCREMENT BY 步长](默认是1)
    [START WITH 开始值]
    [MAXVALUE 最大值| NOMAXVALUE](默认是9999999999999999999999999999)
    [MINVALUE 最小值| NOMINVALUE](默认是0）
    [CYCLE | NOCYCLE](默认是N不是Y)
    [CACHE 缓存大小 | NOCACHE] (默认是20) 指的是缓存的个数
序列中的缓存，是指在序列在使用之前，已经在内存里面为用户提供好的一系列已经生成好的序列，用的时候已经准备好了
若数据库关闭了，那么下次启动后该序列从最后一次使用的值开始重新缓存
最终的目的为生成自动增长列   
CREATE SEQUENCE my_sequence ;

2. 序列字典 user_sequences 
SELECT * FROM user_sequences ;
3. 操作序列
    伪列: 序列名称.currval
        序列名称.nextval
    注意： 必须先使用 nextval 在使用 currval 
SELECT my_sequence.nextval FROM dual ;
SELECT my_sequence.currval FROM dual ;
4. 删除序列
DROP SEQUENCE 序列名称 ;
DROP SEQUENCE my_sequence ;
5. 修改序列
    ALTER SEQUENCE 序列名称 
            [INCREMENT BY 步长](默认是1)
            [START WITH 开始值]
            [MAXVALUE 最大值| NOMAXVALUE](默认是9999999999999999999999999999)
            [MINVALUE 最小值| NOMINVALUE](默认是0）
            [CYCLE | NOCYCLE](默认是N不是Y)
            [CACHE 缓存大小 | NOCACHE] (默认是20) 指的是缓存的个数

CREATE TABLE table_seq (
    sid NUMBER PRIMARY KEY ,
    name VARCHAR2(20) NOT NULL
) ;
INSERT INTO table_seq VALUES(my_sequence.nextval, '你好') ;
SELECT * FROM table_seq ;

-----------------------------------------------------------------------------------
ROWID 伪列
在　ORACLE 中， 数据表中每一行的记录都会默认为每一条分配一个唯一的地址编号， 通过的是 ROWID 来表示
ROWID是个伪列， 所有的数据都利用 ROWID 进行数据定位
SELECT ROWID, empno, ename, deptno FROM emp ;

ROWID ->  AAATO0 AAE AAAACT AAA 
ROWID的组成 和 还原 : 
    数据对象号：AAATO0    DBMS_ROWID.rowid_object(ROWID)
    相对问价号: AAE       DBMS_ROWID.rowid_relative_fno(ROWID)
    数据块号: AAAACT      DBMS_ROWID.rowid_block_number(ROWID)
    数据行号: AAA         DBMS_ROWID.rowid_row_number(ROWID)
    
-----------------------------------------------------------------------------------
ROWNUM 伪列，自动生成行号
SELECT ROWNUM, deptno, dname, loc ;

重点：分页显示
SELECT * FROM (
    SELECT ROWNUM rownumber别名, 列1, 列2....
    FROM 表名 表别名
    WHERE ROWNUM <= (currentPage * pageSize)) tmp
WHERE tmp.rownum别名 > (currentPage - 1) * pageSize ;

SELECT * FROM deptnew WHERE ROWNUM <= 20 ;
SELECT * FROM deptnew WHERE ROWNUM <= 20 AND ROWNUM >= 10; -- 错误

每页显示5条
SELECT * FROM (
    SELECT deptno, dname, loc, ROWNUM nu
    FROM deptnew 
    WHERE ROWNUM <= (1 * 5)
) tmp 
WHERE tmp.nu > (1 - 1) * 5; 
commit ;
还原 ROWID 号码 : 
SELECT ROWID,
    DBMS_ROWID.rowid_object(ROWID), 
    DBMS_ROWID.rowid_relative_fno(ROWID),
    DBMS_ROWID.rowid_block_number(ROWID),
    DBMS_ROWID.rowid_row_number(ROWID),
    empno, ename, deptno
FROM emp ;
    

去除重复数据:
CREATE TABLE deptnew AS SELECT * FROM dept ;
SELECT * FROM deptnew ;
INSERT INTO deptnew VALUES(10, 'aaa', 'bbb1');
INSERT INTO deptnew VALUES(20, 'ddd', 'eee1');
    
最早添加的一定是 ROWID 最小的
SELECT MIN(ROWID), deptno, dname, loc
FROM deptnew 
GROUP BY deptno, dname, loc
ORDER BY deptno, dname, loc ;

desc deptnew ;

DELETE FROM deptnew 
WHERE ROWID NOT IN (
    SELECT MIN(ROWID) FROM deptnew GROUP BY deptno, dname, loc
) ;
COMMIT ;
    