Oracle在一个SQL语句的执行，当没有显式游标的语句隐式游标时自动创建。
程序员无法控制隐式游标其中的信息。

每当发出一个DML语句（INSERT，UPDATE和DELETE），隐式游标与此语句关联。
对于INSERT操作时，光标保持一个需要插入的数据。对于UPDATE和DELETE操作，光标标识会受到影响的行。

在PL/SQL，可以参考最近的隐式游标的SQL游标，有％FOUND，％ISOPEN，％NOTFOUND，和％ROWCOUNT属性。
在SQL游标有额外的属性，％BULK_ROWCOUNT和％BULK_EXCEPTIONS，设计用于所有语句中使用。

%FOUND
返回TRUE如果一个INSERT，UPDATE或DELETE语句影响了一行
或多行或SELECT INTO语句返回一行或多行。否则，它将返回FALSE。

%NOTFOUND
逻辑相反%FOUND。
返回TRUE如果一个INSERT，UPDATE或DELETE语句影响没有行或SELECT INTO语句返回任何行。
否则，它将返回FALSE。

%ISOPEN 隐式游标总是返回FALSE，因为Oracle执行其相关的SQL语句之后自动关闭SQL游标。

%ROWCOUNT
返回受INSERT，UPDATE影响的行数，或DELETE语句，或者通过一个SELECT INTO语句返回。

任何SQL游标属性将被访问，SQL％attribute_name如示例图所示

====================================================================
游标的数据量一定不能太大
分类:
    静态游标:
        隐式游标：所有的 DML 语句为隐式游标，回去 SQL 语句信息
        显示游标： 用户显示声明的游标，即指定结果集合。当查询结果超过一行时，就需要一个显示游标
    REF 游标: 动态关联结果集的临时对象

隐式游标: (一直存在, 但常使用)
在 PL/SQL 中所编写的每条 SQL 语句实际上是隐式的游标
通过 DML 操作之后的 SQL%ROWCOUNT 属性,可知道语句所改变的行数
(INSERT UPDATE DELETE 返回更新行数 SELECT 返回查询的行数)
    %FOUND  当用户使用 DML 操作是时返回 TRUE
    %ISOPEN 判断游标是否打开，对于任何隐式游标总是返回 FALSE, 表示已经打开
    %NOTFOUND   执行 DML 操作时候没有返回数据行，返回 TRUE, 否则返回 FALSE
    %ROWCOUNT   返回更新操作的行数或 SELECT 返回的行数
单行隐式游标：SELECT ... INTO ... 一般结果返回一行数据
多行隐式游标: 更新时候，返回多行记录

显示游标: 在声明块中直接定义的游标，在每一个游标中都会保存 SELECT 查询后的结果
创建：
    CURSOR 游标名称 ([参数列表]) [RETURN 返回值类型]
    IS 子查询
    [FOR UPDATE [OF 数据列, 数据列,...][NOWAIT]] ;
声明步骤: (每一次取得一行记录)
    1. 声明游标(CURSOR 游标名称 IS 查询语句), 使用 CURSOR 定义
    2. 为查询打开游标(语法: OPEN 游标名称) 使用 OPEN 操作，
        当游标打开是会首先检查绑定此游标的变量内容，
        之后确定所使用的查询结果集，最后游标将指针指向结果集的第一行
    3. 取得结果放入 PL/SQL 变量中 (FETCH 游标名称 INTO ROWTYPE变量),使用循环和 FETCH .. INTO .. 操作
    4. 关闭游标 (CLOSE 游标名称)
属性:
    %FOUND  光标打开后为执行 FETCH,则值为 NULL，最近一次在该光标上执行 FETCH 返回一行，则值为 TRUE，否则为 FALSE
    %ISOPEN 光标为打开状态 TRUE，否则为 FALSE
    %NOTFOUND   该光标最近一次 FETCH 没有返回行，值为 TRUE，否 FALSE， 光标打开还未执行 FETCH 则值为 NULL
    %ROWCOUNT   目前为止执行 FETCH 语句返回的行数，光标打开时， %ROWCOUNT 初始值为零，每执行一次 FETCH ，如果返回一行则 %ROWCOUNT 增加1

游标如果要操作一定要保证其已经打开
游标关闭后无法再次操作

如果创建游标需要执行更新或者删除的操作必须带有 FOR UPDATE 子句
FOR UPDATE 子句会将游标提取出来的数据进行行级锁定
这样在本会话更新期间，其它的用户就不能对当前游标中的数据行进行更新操作
而在使用 FOR UPDATE 语句的时候可以使用如下两种格式:
1. FOR UPDATE [OF 列, 列 ...]
    对游标中的数据列进行行级锁定,在游标更新时其它用户的会话无法更新指定数据
    为游标添加行级锁
    范例：
        CURSOR cur_emp IS SELECT * FROM emp WHERE deptno = 10 FOR UPDATE OF sal, comm ;
2. FOR UPDATE NOWAIT
    在 ORACLE 中所有的事务都具有隔离性，当一个用户会话更新数据且事务未提交时
    其它用户会话是无法对数据进行更新，若此时游标数据进行更新操作，那么就会进入到死锁状态
    为了避免，可以在创建时使用 FOR UPDATE NOWAIT 子句，如果发现所操作的数据行已被锁定，将不会被锁定立即返回
    范例：
        CURSOR cur_emp IS SELECT * FROM emp WHERE deptno = 10 FOR UPDATE NOWAIT ;

注意: FOR UPDATE 和 FOR UPDATE OF 列的区别 ? (多表查询)
    在多表联合操作的时候，只有 FOR UPDATE OF 列的那个列数据就可以更新完成。
    在多表的时候建议加入 OF 列
    FOR emp_row IN cur_emp LOOP
        UPDATE emp SET sal = 9999 WHERE CURRENT OF cur_emp ;
    END LOOP ;

游标变量：   CURSOR 游标变量类型的名称 IS REF CURSOR [RETURN 数据类型] ;
    针对一条固定的 SQL 查询语句而定义，这样的游标称为静态游标
    不绑定的具体查询，而是动态的打开指定类型的查询
    一定需要一个类型的定义，如果写上了 RETURN 那么就表示是一种强类型的定义，不写为若类型定义
    强类型的结果必与声明的一致
    若使用游标变量的时候无法使用 FOR 循环，只能利用 LOOP 循环

    强类型游标
    弱类型游标
    游标变量 ： SYS_REFCURSOR(9i后系统定义的弱类型游标变量)

FOR循环-推荐(不用打开和关闭游标)
    FOR v_empRow IN cur_emp LOOP
        DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
    END LOOP ;
LOOP循环：
    OPEN cur_emp ;
    LOOP
        FETCH cur_emp INTO v_empRow ;
        EXIT WHEN cur_emp%NOTFOUND ;
        DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
    END LOOP ;
    CLOSE cur_emp ; -- 关闭游标
WHILE循环:
    OPEN cur_emp ;
    WHILE cur_emp%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
        FETCH cur_emp INTO v_empRow ;
    END LOOP ;
    CLOSE cur_emp ; -- 关闭游标
偷懒做法，不符合规范,但是无法使用游标属性：
    FOR v_empRow IN (SELECT * FROM emp) LOOP
        DBMS_OUTPUT.PUT_LINE('雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
    END LOOP ;
保存到索引表中:
    DECLARE
        CURSOR cur_emp IS SELECT * FROM emp ;
        TYPE emp_index IS TABLE OF emp%ROWTYPE INDEX BY PLS_INTEGER ;
        v_emp emp_index ;
    BEGIN
        FOR emp_row IN cur_emp LOOP
            v_emp(emp_row.empno) := emp_row ;
        END LOOP ;
        DBMS_OUTPUT.PUT_LINE('雇员编号: ' || v_emp(7369).empno || ',姓名: ' || v_emp(7369).ename || ',职位: ' || v_emp(7369).job) ;
    END ;
    /
参数游标：
DECLARE
    CURSOR cur_emp(p_dno emp.deptno%TYPE) IS SELECT * FROM emp WHERE deptno = p_dno ;
BEGIN
    FOR emp_row IN cur_emp(&inputdeptno) LOOP
       DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员编号: ' || emp_row.empno || ',姓名: ' || emp_row.ename || ',职位: ' || emp_row.job) ;
    END LOOP ;
END ;
/


-----------------------------------------------------------------------------------
SET SERVEROUTPUT ON ;
DECLARE
    v_count NUMBER ;
BEGIN
    SELECT COUNT(*) INTO v_count FROM dept ;
    DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT = ' || SQL%ROWCOUNT) ;
END ;
/
-- SQL%ROWCOUNT = 1 返回一行的记录
DECLARE
BEGIN
    INSERT INTO dept(deptno, dname, loc) VALUES(90, 'MLDN', '北师大附') ;
    DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT = ' || SQL%ROWCOUNT) ;
END ;
/
-- SQL%ROWCOUNT = 1 返回更新的行数
DECLARE
BEGIN
    UPDATE dept SET dname = 'newDNA' ;
    DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT = ' || SQL%ROWCOUNT) ;
END ;
/
-- SQL%ROWCOUNT = 5

单行游标：
DECLARE
    v_empRow emp%ROWTYPE ;
BEGIN
    SELECT * INTO v_empRow FROM emp WHERE empno = 7369 ;
    IF SQL%FOUND THEN
        Dbms_Output.Put_Line('雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
    END IF ;
END ;
/
-- 雇员姓名 SMITH 职位 CLERK
多行隐式游标：
DECLARE
BEGIN
    UPDATE emp SET sal = sal * 1.2 WHERE 1 = 2 ;
    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('更新记录的行数: ' || SQL%ROWCOUNT) ;
    ELSE
        DBMS_OUTPUT.PUT_LINE('没有更新记录') ;
    END IF ;
END ;
/
-- 更新记录的行数: 14  没有更新记录

显示光标：
DECLARE
    CURSOR cur_emp IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN
    -- 游标如果要操作一定要保证其已经打开
    IF cur_emp%ISOPEN THEN
        NULL ; -- 什么都不做
    ELSE
        OPEN cur_emp ; -- 打开游标
    END IF ;
     -- 默认情况下游标在第一行数据上
    FETCH cur_emp INTO v_empRow ;  -- 取得当前行数据
    DBMS_OUTPUT.PUT_LINE('雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
    CLOSE cur_emp ; -- 关闭游标
END ;
/

DECLARE
    CURSOR cur_emp IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN
    -- 游标如果要操作一定要保证其已经打开
    IF cur_emp%ISOPEN THEN
        NULL ; -- 什么都不做
    ELSE
        OPEN cur_emp ; -- 打开游标
    END IF ;
     -- 默认情况下游标在第一行数据上
    FETCH cur_emp INTO v_empRow ;  -- 取得当前行数据
    DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;

    WHILE cur_emp%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
        FETCH cur_emp INTO v_empRow ;
    END LOOP ;
    CLOSE cur_emp ; -- 关闭游标
END ;
/

出错信息保留：程序出错 SQL CODE =  -1001, SQLERRM = ORA-01001: 无效的游标
DECLARE
    CURSOR cur_emp IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN
    -- 游标如果要操作一定要保证其已经打开
    IF cur_emp%ISOPEN THEN
        NULL ; -- 什么都不做
    ELSE
        OPEN cur_emp ; -- 打开游标
    END IF ;
--     CLOSE cur_emp ;
     -- 默认情况下游标在第一行数据上
    FETCH cur_emp INTO v_empRow ;  -- 取得当前行数据
    DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;

    WHILE cur_emp%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
        FETCH cur_emp INTO v_empRow ;
    END LOOP ;
    CLOSE cur_emp ; -- 关闭游标

    EXCEPTION
        WHEN INVALID_CURSOR THEN
            DBMS_OUTPUT.PUT_LINE('程序出错 SQL CODE =  ' || SQLCODE || ', SQLERRM = ' || SQLERRM) ;
END ;
/

LOOP 循环
DECLARE
    CURSOR cur_emp IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN
    -- 游标如果要操作一定要保证其已经打开
    IF cur_emp%ISOPEN THEN
        NULL ; -- 什么都不做
    ELSE
        OPEN cur_emp ; -- 打开游标
    END IF ;
--     CLOSE cur_emp ;
     -- 默认情况下游标在第一行数据上

    LOOP
        FETCH cur_emp INTO v_empRow ;
        EXIT WHEN cur_emp%NOTFOUND ;
        DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
    END LOOP ;
    CLOSE cur_emp ; -- 关闭游标

    EXCEPTION
        WHEN INVALID_CURSOR THEN
            DBMS_OUTPUT.PUT_LINE('程序出错 SQL CODE =  ' || SQLCODE || ', SQLERRM = ' || SQLERRM) ;
END ;
/

FOR 循环-推荐
DECLARE
    CURSOR cur_emp IS SELECT * FROM emp ;
    v_empRow emp%ROWTYPE ;
BEGIN
    FOR v_empRow IN cur_emp LOOP
        DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
    END LOOP ;

    EXCEPTION
        WHEN INVALID_CURSOR THEN
            DBMS_OUTPUT.PUT_LINE('程序出错 SQL CODE =  ' || SQLCODE || ', SQLERRM = ' || SQLERRM) ;
END ;
/

DECLARE
BEGIN
    FOR v_empRow IN (SELECT * FROM emp) LOOP
        DBMS_OUTPUT.PUT_LINE('雇员姓名 ' || v_empRow.ename || ' 职位 ' || v_empRow.job) ;
    END LOOP ;
END ;
/
将游标保存到索引表中:
DECLARE
    CURSOR cur_emp IS SELECT * FROM emp ;
    TYPE emp_index IS TABLE OF emp%ROWTYPE INDEX BY PLS_INTEGER ;
    v_emp emp_index ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        v_emp(emp_row.empno) := emp_row ;
    END LOOP ;
    DBMS_OUTPUT.PUT_LINE('雇员编号: ' || v_emp(7369).empno || ',姓名: ' || v_emp(7369).ename || ',职位: ' || v_emp(7369).job) ;
END ;
/

动态游标：
DECLARE
    v_lowSal emp.sal%TYPE := &inputlowsal ;
    v_highSal emp.sal%TYPE := & inputhighsal ;
    CURSOR cur_emp IS SELECT * FROM emp WHERE sal BETWEEN v_lowSal AND v_highSal ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员编号: ' || emp_row.empno || ',姓名: ' || emp_row.ename || ',职位: ' || emp_row.job) ;
    END LOOP ;
END ;
/

参数游标：
DECLARE
    CURSOR cur_emp(p_dno emp.deptno%TYPE) IS SELECT * FROM emp WHERE deptno = p_dno ;
BEGIN
    FOR emp_row IN cur_emp(&inputdeptno) LOOP
       DBMS_OUTPUT.PUT_LINE(cur_emp%ROWCOUNT || ' 雇员编号: ' || emp_row.empno || ',姓名: ' || emp_row.ename || ',职位: ' || emp_row.job) ;
    END LOOP ;
END ;
/

SELECT * FROM dept ;

嵌套表
DECLARE
    TYPE dept_nested IS TABLE OF dept%ROWTYPE ;
    v_dept dept_nested ;
    CURSOR cur_dept IS SELECT * FROM dept ;
BEGIN
    IF cur_dept%ISOPEN THEN
        NULL ;
    ELSE
        OPEN cur_dept ;
    END IF ;
    FETCH cur_dept BULK COLLECT INTO v_dept ; -- 保存整个游标
    CLOSE cur_dept ;
    FOR x IN v_dept.FIRST .. v_dept.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('部门编号: ' || v_dept(x).deptno || ',部门: ' || v_dept(x).dname || ',位置: ' || v_dept(x).loc) ;
    END LOOP ;
END ;
/

数据量大保存到可变数组中：
DECLARE
    TYPE dept_array IS VARRAY(2) OF dept%ROWTYPE ; -- 定义嵌套表
    v_dept dept_array ;
    CURSOR cur_dept IS SELECT * FROM dept ;
    v_rows NUMBER := 2 ; -- 每次提取两行数据
    v_count NUMBER := 1 ; -- 每次显示一行数据
BEGIN
    IF cur_dept%ISOPEN THEN
        NULL ;
    ELSE
        OPEN cur_dept ;
    END IF ;
    FETCH cur_dept BULK COLLECT INTO v_dept LIMIT v_rows ; -- 保存指定个数
    CLOSE cur_dept ;
    FOR x IN v_dept.FIRST .. v_dept.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('部门编号: ' || v_dept(x).deptno || ',部门: ' || v_dept(x).dname || ',位置: ' || v_dept(x).loc) ;
    END LOOP ;
END ;
/

DECLARE
    TYPE dept_array IS VARRAY(2) OF dept%ROWTYPE ; -- 定义嵌套表
    v_dept dept_array ;
    CURSOR cur_dept IS SELECT * FROM dept ;
    v_rows NUMBER := 2 ; -- 每次提取两行数据
    v_count NUMBER := 1 ; -- 每次显示一行数据
BEGIN
    IF cur_dept%ISOPEN THEN
        NULL ;
    ELSE
        OPEN cur_dept ;
    END IF ;
    FETCH cur_dept BULK COLLECT INTO v_dept LIMIT v_rows ; -- 保存指定个数
    CLOSE cur_dept ;
    FOR x IN v_dept.FIRST .. (v_dept.LAST - v_count) LOOP
        DBMS_OUTPUT.PUT_LINE('部门编号: ' || v_dept(x).deptno || ',部门: ' || v_dept(x).dname || ',位置: ' || v_dept(x).loc) ;
    END LOOP ;
END ;
/

修改游标数据：
DECLARE
    CURSOR cur_emp IS SELECT * FROM emp ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        IF emp_row.deptno = 10 THEN
            IF emp_row.sal * 1.15 < 5000 THEN
                UPDATE emp SET sal = sal * 1.15 WHERE empno = emp_row.empno ;
            END IF ;
        ELSIF emp_row.deptno = 20 THEN
            IF emp_row.sal * 1.22 < 5000 THEN
                UPDATE emp SET sal = sal * 1.22 WHERE empno = emp_row.empno ;
            END IF ;
        ELSIF emp_row.deptno = 30 THEN
            IF emp_row.sal * 1.39 < 5000 THEN
                UPDATE emp SET sal = sal * 1.39 WHERE empno = emp_row.empno ;
            END IF ;
        ELSE
            NULL ;
        END IF ;
    END LOOP ;

EXCEPTION
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('SQLCODE = ' || SQLCODE ) ;
        DBMS_OUTPUT.PUT_LINE('SQLERRM = ' || SQLERRM ) ;
        ROLLBACK ;
END ;
/

DECLARE
    CURSOR cur_emp IS SELECT * FROM emp WHERE deptno = 10 FOR UPDATE NOWAIT ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        UPDATE emp SET sal = 9999 WHERE empno = emp_row.empno ;
    END LOOP ;
END ;
/
-- ORA-00054: 资源正忙, 但指定以 NOWAIT 方式获取资源, 或者超时失效

DECLARE
    CURSOR cur_emp IS SELECT * FROM emp WHERE deptno = 10 FOR UPDATE NOWAIT ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        UPDATE emp SET sal = 9999 WHERE CURRENT OF cur_emp ; -- 设置的列也表示行级锁定
    END LOOP ;
END ;
/

SELECT * FROM emp ;
DELETE FROM emp ;
ROLLBACK ;
------------------------------------------------------------------------
DECLARE
    CURSOR cur_emp IS
    SELECT e.ename, e.job, e.sal, d.dname, d.loc
    FROM emp e, dept d
    WHERE e.deptno = d.deptno AND e.deptno = 10 FOR UPDATE ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        UPDATE emp SET sal = 9999 WHERE CURRENT OF cur_emp ;
    END LOOP ;
END ;
/
-- 但是数据并没有进行修改
DECLARE
    CURSOR cur_emp IS
    SELECT e.ename, e.job, e.sal, d.dname, d.loc
    FROM emp e, dept d
    WHERE e.deptno = d.deptno AND e.deptno = 10 FOR UPDATE OF sal ;
BEGIN
    FOR emp_row IN cur_emp LOOP
        UPDATE emp SET sal = 9999 WHERE CURRENT OF cur_emp ;
    END LOOP ;
END ;
/
-- 但是数据进行了修改
---------------------------------------------------------------------------

游标变量：
DECLARE
    TYPE dept_ref IS REF CURSOR RETURN dept%ROWTYPE ; -- 强类型
    cur_dept dept_ref ; -- 定义游标变量
    v_deptRow dept%ROWTYPE ;
BEGIN
    OPEN cur_dept FOR SELECT * FROM dept ; -- 打开游标并决定游标类型
    LOOP
        FETCH cur_dept INTO v_deptRow ; -- 取得游标数据
        EXIT WHEN cur_dept%NOTFOUND ; -- 无数据就退出
        DBMS_OUTPUT.PUT_LINE('部门名称: ' || v_deptRow.dname || ' 部门位置: ' || v_deptRow.loc) ;
    END LOOP ;
    CLOSE cur_dept ;
END ;
/

若类型，没有 RETURN, 有限制-操作游标类型要与设置的 SQL 返回类型一致
DECLARE
    TYPE dept_ref IS REF CURSOR ; -- 弱类型
    cur_dept dept_ref ; -- 定义游标变量
    v_deptRow dept%ROWTYPE ;
BEGIN
    OPEN cur_dept FOR SELECT * FROM dept ; -- 打开游标并决定游标类型
    LOOP
        FETCH cur_dept INTO v_deptRow ; -- 取得游标数据
        EXIT WHEN cur_dept%NOTFOUND ; -- 无数据就退出
        DBMS_OUTPUT.PUT_LINE('部门名称: ' || v_deptRow.dname || ' 部门位置: ' || v_deptRow.loc) ;
    END LOOP ;
    CLOSE cur_dept ;
EXCEPTION
    WHEN ROWTYPE_MISMATCH THEN
        DBMS_OUTPUT.PUT_LINE('结果集变量或查询的返回类型不匹配. SQLCODE ' || SQLCODE || ' SQLERRM: ' || SQLERRM) ;
END ;
/
-- ORA-06504: PL/SQL: 结果集变量或查询的返回类型不匹配

DECLARE
    TYPE cursor_ref IS REF CURSOR ; -- 弱类型
    cur_var cursor_ref ; -- 定义游标变量
    v_deptRow dept%ROWTYPE ;
    v_empRow emp%ROWTYPE ;
BEGIN
    OPEN cur_var FOR SELECT * FROM dept ; -- 打开游标并决定游标类型
    LOOP
        FETCH cur_var INTO v_deptRow ; -- 取得游标数据
        EXIT WHEN cur_var%NOTFOUND ; -- 无数据就退出
        DBMS_OUTPUT.PUT_LINE('部门名称: ' || v_deptRow.dname || ' 部门位置: ' || v_deptRow.loc) ;
    END LOOP ;
    CLOSE cur_var ;

    OPEN cur_var FOR SELECT * FROM emp ;
    LOOP
        FETCH cur_var INTO v_empRow ;
        EXIT WHEN cur_var%NOTFOUND ;
        DBMS_OUTPUT.PUT_LINE(cur_var%ROWCOUNT || ' 雇员编号: ' || v_empRow.empno || ',姓名: ' || v_empRow.ename || ',职位: ' || v_empRow.job) ;
    END LOOP ;
    CLOSE cur_var ;
EXCEPTION
    WHEN ROWTYPE_MISMATCH THEN
        DBMS_OUTPUT.PUT_LINE('结果集变量或查询的返回类型不匹配. SQLCODE ' || SQLCODE || ' SQLERRM: ' || SQLERRM) ;
END ;
/

DECLARE
    cur_var SYS_REFCURSOR ; -- 定义游标变量
    v_deptRow dept%ROWTYPE ;
    v_empRow emp%ROWTYPE ;
BEGIN
    OPEN cur_var FOR SELECT * FROM dept ; -- 打开游标并决定游标类型
    LOOP
        FETCH cur_var INTO v_deptRow ; -- 取得游标数据
        EXIT WHEN cur_var%NOTFOUND ; -- 无数据就退出
        DBMS_OUTPUT.PUT_LINE('部门名称: ' || v_deptRow.dname || ' 部门位置: ' || v_deptRow.loc) ;
    END LOOP ;
    CLOSE cur_var ;

    OPEN cur_var FOR SELECT * FROM emp ;
    LOOP
        FETCH cur_var INTO v_empRow ;
        EXIT WHEN cur_var%NOTFOUND ;
        DBMS_OUTPUT.PUT_LINE(cur_var%ROWCOUNT || ' 雇员编号: ' || v_empRow.empno || ',姓名: ' || v_empRow.ename || ',职位: ' || v_empRow.job) ;
    END LOOP ;
    CLOSE cur_var ;
EXCEPTION
    WHEN ROWTYPE_MISMATCH THEN
        DBMS_OUTPUT.PUT_LINE('结果集变量或查询的返回类型不匹配. SQLCODE ' || SQLCODE || ' SQLERRM: ' || SQLERRM) ;
END ;
/