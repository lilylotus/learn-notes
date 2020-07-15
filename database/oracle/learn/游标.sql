处理多行记录的事务经常使用游标来实现。
所有的处理记录都保存在内存中，所以用游标的处理数据量都不能太大。

DML（Data Manipulation Language，数据操作语言）：用于检索或者修改数据。
    SELECT：用于检索数据；
    INSERT：用于增加数据到数据库；
    UPDATE：用于从数据库中修改现存的数据 
    DELETE：用于从数据库中删除数据。
DDL（Data Definition Language，数据定义语言）：定义数据的结构，比如 创建、修改或者删除数据库对象
    CREATE TABLE：创建表
    ALTER TABLE
    DROP TABLE：删除表
    CREATE INDEX
    DROP INDEX
DCL（Data Control Language，数据控制语言）：用于定义数据库用户的权限。
    ALTER PASSWORD 
    GRANT 
    REVOKE 
    CREATE SYNONYM

-----------------------------------------------------------------------------
一. 游标的类型
    静态游标：结果的集合都已经存在
        隐式游标： 所有的DML语句
        显示游标：显示声明的游标
    REF游标：动态关联结果集的临时对象

-----------------------------------------------------------------------------
二. 隐式游标：
SQL%ROWCOUNT 返回操作(修改)的数据行数
SQL> DECLARE
    v_count NUMBER ;
BEGIN
    INSERT INTO dept(deptno, dname, loc) VALUES(99, 'INSDEPT', 'BEIJING') ;
    DBMS_OUTPUT.put_line('SQL%ROWCOUNT counts = ' || SQL%ROWCOUNT ) ;
END ;
/
SQL%ROWCOUNT counts = 1

SQL> DECLARE
BEGIN
    UPDATE emp SET sal=sal+101;
    DBMS_OUTPUT.put_line('SQL%ROWCOUNT counts = ' || SQL%ROWCOUNT ) ;
END ;
/
SQL%ROWCOUNT counts = 15

%FOUND  当用户使用DML操作时，有数据返回或者数据变更，返回true
%ISOPEN 判断游标是否开启，任何隐式的游标总是返回false，表示游标打开
%NOTFOUND   DML操作没有返回数据行，返回TRUE，否则返回FALSE
%ROWCOUNT   返回更新操作或SELECT返回的行数

2.1 单行隐式游标
SQL> DECLARE
    v_empRow emp%ROWTYPE ;
BEGIN
    SELECT * INTO v_empROw FROM emp WHERE empno=7788 ;
    IF SQL%FOUND THEN
        DBMS_OUTPUT.put_line('emp name ' || v_empRow.ename || ' empno : ' || v_empRow.empno ) ;
    END IF ;
END ;
/
emp name SCOTT empno : 7788

2.2 多行隐式游标 - 主要是指更新的时候，返回多行记录。
DECLARE
BEGIN
    UPDATE emp SET sal=sal*1.2 ;
    IF SQL%FOUND THEN
        DBMS_OUTPUT.put_line('update rows : ' || SQL%ROWCOUNT) ;
    ELSE
        DBMS_OUTPUT.put_line('None update') ;
    END IF ;
END ;
/
update rows : 15

-----------------------------------------------------------------------------
三. 显示游标
1. 创建游标
CURSOR 游标名称([参数列表][RETURN 返回值类型])
    IS 子查询
[FOR UPDATE [OF 数据列,数据列,...][NOWAIT]] ;

创建步骤：
    声明游标：(CURSOR  游标名称 IS 查询语句)
    为查询打开游标: (OPEN 游标名称)
    取得的结果放到PL/SQL当中(FETCH 游标名称 INTO ROWTYPE 变量名称)
    关闭游标(CLOSE 游标名称)

FOR UPDATE 字句
如果创建的游标执行更新、删除操作必须带有 FOR UPDATE 字句
FOR UPDATE 会将游标提取出来的数据进行行级锁定，在本会话更新期间，别的用户就不能对当前
游标中更新数据进行操作。
形式1 ：
    FOR UPDATE [ OF 列，列...] 
形式2 ：
    FOR UPDATE NOWAIT ; 发现所操作的数据已经被锁定，不会等待，立即返回。
    
    DECLARE 
        CURSOR cur_emp IS SELECT * FROM emp WHERE deptno=20 FOR UPDATE NOWAIT ;
    BEGIN
        FOR emp_row IN cur_emp LOOP
            UPDATE emp SET sal=8888 WHERE empno=emp_row.empno ;
        END LOOP ;
    END ;
    /   

-- FOR UPDATE 可以进行行级锁定，可以使用 WHERE CURRENT OF 子句来进行当前的更新或删除操作。
DECLARE 
    CURSOR cur_emp IS SELECT * FROM emp WHERE deptno=20 FOR UPDATE ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        UPDATE emp SET sal=8888 WHERE CURRENT OF cur_emp ;
    END LOOP ;
END ;
/

=== FOR UPDATE 和 FOR UPDATE OF 区别 。(多表)
-- 指定 要更新的列  FOR UPDATE OF 列
-- FOR UPDATE 在多表查询当中是无效的
DECLARE
    CURSOR cur_emp IS 
    SELECT e.empno, e.ename, e.job, e.sal, d.dname, d.loc
    FROM emp e, dept d
    WHERE e.deptno=d.deptno AND e.deptno=20 FOR UPDATE OF sal ;
BEGIN 
    FOR emp_row IN cur_emp LOOP
        UPDATE emp SET sal=7777 WHERE CURRENT OF cur_emp ;
    END LOOP ;
END ; 
/

四. 游标变量
1. 定义游标变量
CURSOR 游标变量类型名称 IS REF CURSOR [RETURN 数据类型] ;

== 注意： 使用游标变量是无法使用 FOR 而使用 WHILE， LOOP
-- 强类型， 类型只能为 emp%ROWTYPE 游标变量
-- 弱类型， 不要写 RETURN 
DECLARE
    TYPE dept_cur IS REF CURSOR RETURN dept%ROWTYPE ;
    cur_dept dept_cur ;
    v_deptRow dept%ROWTYPE ;
BEGIN
    OPEN cur_dept FOR SELECT * FROM dept ;
    LOOP 
        FETCH cur_dept INTO v_deptRow ;
        EXIT WHEN cur_dept%NOTFOUND ;
        DBMS_OUTPUT.put_line('dept name = ' || v_deptRow.dname || ' , dept loc = ' || v_deptRow.loc) ;
    END LOOP ;
    CLOSE cur_dept ;
END ;
/

DECLARE
    TYPE dept_ref IS REF CURSOR ;
    cur_dept dept_ref ;
    v_deptRow dept%ROWTYPE ;
BEGIN
    OPEN cur_dept FOR SELECT * FROM emp ;
    LOOP 
        FETCH cur_dept INTO v_deptRow ;
        EXIT WHEN cur_dept%NOTFOUND ;
        DBMS_OUTPUT.put_line('dept name = ' || v_deptRow.dname || ' , dept loc = ' || v_deptRow.loc) ;
    END LOOP ;
    CLOSE cur_dept ;
EXCEPTION 
    WHEN ROWTYPE_MISMATCH THEN 
        DBMS_OUTPUT.put_line('CURSOR TYPE CAN NOT MATCH ERROR, ERRORCODE = ' || SQLCODE ) ;
END ;
/ 
-----------------------------------------------------

注意：打开的游标默认就在数据的第一行。
SQL> DECLARE
    CURSOR cur_emp IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN
    IF cur_emp%ISOPEN THEN
         NULL ;
    ELSE
         OPEN cur_emp ;
    END IF ;

    FETCH cur_emp INTO v_empRow ;
    DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || ' emp name : ' || v_empRow.ename || ' empjob : ' || v_empRow.job);
    CLOSE cur_emp ;
END ;
/
1 emp name : 倪华 empjob : ANALYST

注意： 游标操作之前必须打开，游标关闭之后不可以在使用
== 游标循环的一种写法 WHILE
DECLARE
    --- CURSOR cur_emp RETURN emp%ROWTYPE IS SELECT * FROM emp ;
    CURSOR cur_emp IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN
    IF cur_emp%ISOPEN THEN
        NULL ;
    ELSE
        OPEN cur_emp ;
    END IF ;
    -- 循环来获取游标的数据 FETCH
    FETCH cur_emp INTO v_empRow ;
    WHILE cur_emp%FOUND LOOP
        DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || ' emp name : ' || v_empRow.ename || ' empjob : ' || v_empRow.job);
        FETCH cur_emp INTO v_empRow ;
    END LOOP ;
    CLOSE cur_emp ;
END ;
/

=== SQL CURSOR 出错
DECLARE
    CURSOR cur_emp RETURN emp%ROWTYPE IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN

    FETCH cur_emp INTO v_empRow ;
    WHILE cur_emp%FOUND LOOP
        DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || ' emp name : ' || v_empRow.ename || ' empjob : ' || v_empRow.job);
        FETCH cur_emp INTO v_empRow ;
    END LOOP ;
    CLOSE cur_emp ;
EXCEPTION 
    WHEN INVALID_CURSOR THEN
        DBMS_OUTPUT.put_line('Run error SQL CODE = ' || SQLCODE || ' , SQL ERRM = ' || SQLERRM) ;
END ;
/
Run error SQL CODE = -1001 , SQL ERRM = ORA-01001: invalid cursor

== 游标循环的另一种写法 LOOP
DECLARE
    CURSOR cur_emp RETURN emp%ROWTYPE IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN
    IF cur_emp%ISOPEN THEN
        NULL ;
    ELSE
        OPEN cur_emp ;
    END IF ;
    
    LOOP 
        FETCH cur_emp INTO v_empRow ;
        EXIT WHEN cur_emp%NOTFOUND ;
            DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || ' emp name : ' || v_empRow.ename || ' empjob : ' || v_empRow.job);
    END LOOP ;
    CLOSE cur_emp ;
END ;
/

-- 游标循环的一种写法 FOR ， 推荐使用，不再处理打开和关闭，最为方便的
DECLARE
    CURSOR cur_emp RETURN emp%ROWTYPE IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN
    FOR v_empRow IN cur_emp LOOP
        EXIT WHEN cur_emp%NOTFOUND ;
        DBMS_OUTPUT.put_line(cur_emp%ROWCOUNT || ' emp name : ' || v_empRow.ename || ' empjob : ' || v_empRow.job);
    END LOOP ;
END ;
/

-- 最简便的写法，但是不推荐
DECLARE
BEGIN
    FOR v_empRow IN (SELECT * FROM emp) LOOP
        DBMS_OUTPUT.put_line('emp name : ' || v_empRow.ename || ' empjob : ' || v_empRow.job);
    END LOOP ;
END ;
/

-- 索引保存在游标当中
DECLARE
    CURSOR cur_emp IS SELECT * FROM emp ;
    TYPE emp_index IS TABLE OF emp%ROWTYPE INDEX BY PLS_INTEGER ;
    v_emp emp_index ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        v_emp(emp_row.empno) := emp_row ;
    END LOOP ;
    DBMS_OUTPUT.put_line('empno = ' || v_emp(7369).empno || ' emp name = ' || v_emp(7369).ename || ' , job = ' || v_emp(7369).job) ;
END ;
/

== 复杂
DECLARE 
    CURSOR cur_emp IS SELECT * FROM emp ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        IF emp_row.deptno = 10 THEN
            IF emp_row.sal*1.15 < 5000 THEN
                UPDATE emp SET sal=sal*1.15
                WHERE empno=emp_row.empno ;
            ELSE
                UPDATE emp SET sal=5000 
                WHERE empno=emp_row.empno ;
            END IF ;
        ELSIF emp_row.deptno = 20 THEN
            IF emp_row.sal*1.20 < 5000 THEN
                UPDATE emp SET sal=sal*1.20
                WHERE empno=emp_row.empno ;
            ELSE
                UPDATE emp SET sal=5000 
                WHERE empno=emp_row.empno ;
            END IF ;        
        ELSIF emp_row.deptno = 30 THEN
            IF emp_row.sal*1.39 < 5000 THEN
                UPDATE emp SET sal=sal*1.39
                WHERE empno=emp_row.empno ;
            ELSE
                UPDATE emp SET sal=5000 
                WHERE empno=emp_row.empno ;
            END IF ;
        ELSE
            NULL ;
        END IF ;
    END LOOP ;
EXCEPTION
    WHEN others THEN
        DBMS_OUTPUT.put_line('SQLCODE = ' || SQLCODE);
        DBMS_OUTPUT.put_line('SQLERRM = ' || SQLERRM);
        ROLLBACK ;
END ;
/

