DECLARE

BEGIN

END ;
/

1. 变量的声明
变量名称 [CONSTANT] 类型 [NOT NULL] [:=value] ;
CONSTANT : 常量
NOT NULL : 变量不可为空
:=value ：设置好初始化类容

２. %TYPE 指定的变量与一指定的数据表的某一列类型一样
变量定义 表名称.字段名称%TYPE

DECLARE
    v_eno emp.empno%TYPE ;
    v_ename emp.ename%TYPE ;
BEGIN
    DBMS_OUTPUT.put_line('Please Enter number : ') ;
    v_eno := &empno ;
    SELECT ename INTO v_ename FROM emp WHERE empno = v_eno ;
    Dbms_Output.Put_Line('Emp num is : ' || v_eno || ' emp name is : ' || v_ename) ;
END ;
/

3. %ROWTYPE 标记定义表中的一行记录的类型
当使用个 SELECT ... INTO .. 就将一行记录设置到了ROWTYPE中
在使用 rowtype变量.表字段 方式使用数据

二. 运算符
1. 赋值
变量 := 表达式 ;

2. 关系运算符
关系运算符 : > >= < <= = != <>
判断null : IS NULL , IS NOT NULL
逻辑 : AND , OR , NOT
范围 : BETWEEN mix AND max
范围 : IN
模糊 : LIKE


三. 批处理
1. 常见方法
DECLARE
    TYPE emp_varray IS VARRAY(8) OF emp.empno%TYPE ;
    v_empno emp_varray := emp_varray(7369, 7566, 7788, 7839, 7902) ;
BEGIN
    FOR x IN v_empno.FIRST .. v_empno.LAST LOOP
        UPDATE emp SET sal=9000 WHERE empno=v_empno(x) ;
    END LOOP ;
END ;
/
进行多次更新

2. 批量进行 - FORALL
FORALL 变量 IN 集合初值 .. 集合最高值 SQL语句 ;

DECLARE
    TYPE emp_varray IS VARRAY(8) OF emp.empno%TYPE ;
    v_empno emp_varray := emp_varray(7369, 7566, 7788, 7839, 7902) ;
BEGIN
    FORALL x IN v_empno.FIRST .. v_empno.LAST
        UPDATE emp SET sal=9000 WHERE empno=v_empno(x) ;
    FOR x IN v_empno.FIRST .. v_empno.LAST LOOP
        Dbms_Output.Put_Line('emp no : ' || v_empno(x) || ' Update rows : ' || SQL%BULK_ROWCOUNT(x) );
    END LOOP ;
END ;
/

3. 批量接收数据

DECLARE
    TYPE ename_array IS VARRAY(8) OF emp.ename%TYPE ;
    v_ename ename_array ;
BEGIN
    SELECT ename BULK COLLECT INTO v_ename
    FROM emp
    WHERE deptno=10 ;
    FOR x IN v_ename.FIRST .. v_ename.LAST LOOP
        DBMS_OUTPUT.put_line('emp name : ' || v_ename(x)) ;
    END LOOP ;
END ;
/

DECLARE
    TYPE dept_nested IS TABLE OF dept%ROWTYPE ;
    v_dept dept_nested ;
BEGIN
    SELECT * BULK COLLECT INTO v_dept
    FROM dept ;
    FOR x IN v_dept.FIRST .. v_dept.LAST LOOP
        DBMS_OUTPUT.put_line('detp no : ' || v_dept(x).deptno || ' dept name : ' || v_dept(x).dname || ' dept loc : ' || v_dept(x).loc) ;
    END LOOP ;
END ;
/

===================================================================
https://blog.csdn.net/hon_3y/article/details/74972555
PLSQL是Oracle对SQL99的一种扩展
SQL99是什么
1. 是操作所有关系型数据库的规则
2. 是第四代语言
3. 是一种结构化查询语言
4. 只需发出合法合理的命令，就有对应的结果显示

因为SQL是第四代命令式语言，无法显示处理过程化的业务，
所以得用一个过程化程序设计语言来弥补SQL的不足之处，SQL和PLSQL不是替代关系，是弥补关系

------------------------------------------
PLSQL语法
declare和exception都是可以省略的，
begin 和 end;/ 是不能省略的。( ;号表示每条语句的结束，/表示整个PLSQL程序结束)

[declare]
    变量声明;
    变量声明;
begin
    DML/TCL操作;
    DML/TCL操作;
    [exception]
        例外处理;
    例外处理;
end;
/

PLSQL与SQL执行有什么不同：
1. SQL是单条执行的
2. PLSQL是整体执行的，不能单条执行，整个PLSQL结束用/，其中每条语句结束用 ; 号

-------------------------------------------
PLSQL变量
PLSQL的变量有4种
number      [i NUMBER(2); | sum NUMBER(2):=100;]
varchar2    [v VARCHAR2(10):='结果是';]
与列名类型相同 [pname emp.name%type;]
与整个表的列类型相同 [emprow emp%rowtype;]

何时使用%type，何时使用%rowtype？
当定义变量时，该变量的类型与表中某字段的类型相同时，可以使用%type
当定义变量时，该变量与整个表结构完全相同时，可以使用%rowtype，
此时通过变量名.字段名，可以取值变量中对应的值
项目中，常用%type

----------------------------------------
判断
IF 条件 THEN 语句1 ;
    语句2 ;
END IF ;

IF 条件 THEN 语句1 ;
    ELSE 语句2 ;
END IF ;

IF 条件 THEN 语句 ;
    ELSIF 条件 THEN 语句 ;
    ELSE 语句 ;
END IF ;

eslif并没有写错的，它是少了一个e的

循环

loop
    exit when i >= 10 ;
    i := i + 1 ;
end loop ;

when ( i < 100 )
    loop
        i := i + 1 ;
    end loop ;

for i in 1 .. 100
    loop
        dbms_output.print_line(i) ;
    end loop ;

--------------------------------------------
游标
类似JDBC中的resultSet，就是一个指针的概念。
游标仅仅是在查询的时候有效的

CURSOR  光标名  [ (参数名  数据类型[,参数名 数据类型]...)]
IS  SELECT   语句；

异常
在declare节中定义例外
out_of   exception ;

 在begin节中可行语句中抛出例外
raise out_of ；

 在exception节处理例外
when out_of then …


---------------------------
存储过程
注意： 类型为 NUMBER, VARCHAR2, 不能写为 VARCHAR2(20)
create or replace procedure 存储过程名称[(参数名称 IN/OUT 类型)]
as
begin

end ;

函数
create or replace function 函数名称(参数名称 IN/OUT 类型)
    return 类型 -- 注意，这里没有 ； 号
as
    参数名称 类型 ;
begin

    return 参数名称 ;
end ;

-----------------------------
触发器

create or replace trigger 触发器的名称
[before | after]
[insert | update [of 列] | delete]
on 表名称
[of each row]
    变量声明
begin

end ;