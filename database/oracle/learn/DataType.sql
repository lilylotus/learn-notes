/* 
    CHAR(n)  n -> 0-2000 字节 定长
    VARCHAR2(n) n -> 0-4000 字节 不定长
    NUMBER(m,n) m -> 1-38 n > -84-127 数字，m为小数部分，m-n为整数部分
    DATE    日期数据，不包含毫秒
    TIMESTAMP   日期类型，包含毫秒
    CLOB    4G  存放海量文字
    BLOB    4G  存放二进制文件，如： 图片等
    
    注意： 不操作200字的选用 VARCHAR2 
        对于数值型 选用NUMBER ： NUMBER(n) 表示整数，也可以INT， NUMBER(m,n) 表示小数，也可以 FLOAT
        CLOB 大量的文本文件
        BLOB 音乐电影等， 但很少有人使用他
        常用类型： VARCHAR2， CHAR， DATE， NUMBER， CLOB
*/

-- 表创建， DDL

CREATE TABLE member (
    mid NUMBER(5) ,
    mname VARCHAR2(50) DEFAULT '无名氏',
    age NUMBER(3), 
    birthday DATE DEFAULT SYSDATE ,
    note CLOB 
);

-- 查看表数据
SELECT * FROM tab ;
DESC member ;

INSERT INTO member(mid, mname, age, note) VALUES(1, '小明', 20, '真大豪爽大方') ;
INSERT INTO member(mid, mname, age, Birthday, note) VALUES(2, '小红', 30, TO_DATE('2000-12-12 12:12:12', 'YYYY-MM-DD HH24:MI:SS'), '真大豪爽大方') ;
COMMIT ;
SELECT * FROM member ;

SELECT * FROM test ORDER BY id ;
INSERT INTO test VALUES(66, '中国') ;
commit ;
select id, var, dump(var, 1016) from test ORDER BY id ;
SELECT LENGTH(var), id FROM test ORDER BY id ;

/*
    ORACLE字符转换的基本原则
    1. 设置客户端的 NLS_LANG 为客户端操作系统的字符集
    2. 如果数据库的字符集等于 NLS_LANG， 数据库和客服端传输字符不做任何转换
    3. 如果他们两个不相等，则需要在不同字符间转换， 只有客户端操作系统字符集是
        数据库字符集子集的基础上才能正确转换，否则会出现乱码
    总结为: 客户端的字符集设置是在 NLS_LANG 环境变量中
        客户端的字符集可以和 ORACLE 客户端设置不一样
        但是客户端字符集一定要和操作系统的字符集相匹配
        NLS_LANG AMERICAN_AMERICA.AL32UTF8 -> 服务器
        NLS_LANG SIMPLIFIED CHINESE_CHINA.ZHS16GBK -> 客户端
*/
-- 推荐设置
-- SET NLS_LANG=SIMPLIFIED CHINESE_CHINA.ZHS16GBK
SELECT * FROM NLS_DATABASE_PARAMETERS ;
SELECT * FROM v$NLS_PARAMETERS WHERE parameter = 'NLS_CHARACTERSET' ;

-- ZHS16GBK: d6,d0,b9,fa
-- AL32UTF8: e4,b8,ad,e5,9b,bd 正确的编码

-- 创建表
-- CREATE TABLE 表名称 AS SELECT 语句
CREATE TABLE department
AS
SELECT d.deptno, d.dname, d.loc, 
    COUNT(e.empno) count, SUM(e.sal + NVL(e.comm, 0)) sum,
    ROUND(AVG(e.sal + NVL(e.comm, 0)), 2) avg, MAX(e.sal) max, MIN(e.sal) min
FROM emp e, dept d
WHERE e.deptno (+)= d.deptno
GROUP BY d.deptno, d.dname, d.loc
ORDER BY d.deptno ;
COMMIT ;

-- ORACLE 数据字典
/*
    静态数据字典： 
        user_* : 当前用户的对象信息
        all_* : 所有当前用户可以访问的信息
        dba_* : 存储了数据库中所有的对象信息
    动态数据字典 :
        v$ 开头
*/
-- 注意： 任何 DDL 都会自动提交事务，不受事务的控制 
SELECT * FROM user_tables u ;
-- 表重命名
RENAME empnew TO empnew1 ;

-- 截断表
-- DELETE 会占用系统资源(表空间),可以通过 ROLLBACK 来会恢复操作
-- TRUNCATE TABLE 表名称; 不会占用表空间和其它的资源，即所有的资源都会被释放
-- DROP TABLE 表名称; 会直接删除表，但是还是会留下残余，可以通过闪回技术恢复

DROP TABLE empnew1 ;
DROP TABLE emp20 ;
-- 闪回技术(FLASH BACK） -> 在删除表的时候不会立即删除表，而是暂存到回收站中
SELECT object_name, original_name, operation, type FROM recyclebin ;
FLASHBACK TABLE empnew1 TO BEFORE DROP ;
-- 彻底删除不经过回收站
DROP TABLE 表名称 PURGE ;
-- 删除回收站中的数据
PURGE　TABLE 在回收站中的表名 ;
-- 清空回收站
PURGE RECYCLEBIN ;

-- 注意： 闪回空间若被占用完了，就是不能在用了