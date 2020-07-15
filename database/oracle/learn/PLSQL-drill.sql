-- dbms_output是oracle中的一个输出对象
-- put_line是上述对象的一个方法，用于输出一个字符串自动换行 
-- 设置显示PLSQL程序的执行结果，默认情况下，不显示PLSQL程序的执行结果，语法：set serveroutput on/off;
set serveroutput on;

-- 变量使用
declare
   nsum NUMBER(3) := 0 ;
   tip VARCHAR(10) := '结果是' ;
begin
  nsum := 10 + 100;
  dbms_output.put_line(tip || nsum);
end;
/

select * from user_tables ;
select * from emp ;

declare
  ename emp.ename%type ;
  esal emp.sal%type ;
begin
--  select ename, sal from emp where empno = 7369 ;
    select e.ename, e.sal into ename, esal from emp e where e.empno = 7369 ;
    dbms_output.put_line('雇员 7369 姓名是 ' || ename || ' 薪资是 ' || esal) ;
end ;
/

declare
    erow emp%rowtype ;
begin
  select * into erow from emp where empno = 7369 ;
  dbms_output.put_line(erow.ename || ' ' || erow.sal) ;
end ;
/
      
-- 判断语句
select to_char(sysdate, 'day') from dual ;

declare
   pday varchar2(10) ;
begin
  select to_char(sysdate, 'day') into pday from dual ;
  dbms_output.put_line('today is ' || pday) ;
  if pday in ('星期六', '星期日') then
    dbms_output.put_line('rest day') ;
  else
    dbms_output.put_line('work day') ;
  end if ;
end ;
/

declare
    age number(4) := &age;
begin
  if age < 16 then
    dbms_output.put_line('未成年') ;
  elsif age < 30 then
    dbms_output.put_line('青年人') ;
  elsif age < 60 then
    dbms_output.put_line('奋斗') ;
  elsif age < 80 then
    dbms_output.put_line('享受') ;
  else
    dbms_output.put_line('未定义') ;
  end if ;
end ;
/        

declare
    total number(2) := 0 ;
    salary number(1) := 2 ;
begin
while total <= 25
  loop
    total := total + salary ;
    dbms_output.put_line('total ' || total) ;
  end loop ;
end ;
/

declare
    total number(2) := 0 ;
begin
  loop
    exit when total >= 30 ;
    total := total + 4 ;
    dbms_output.put_line('total ' || total) ;
  end loop ;
end ;
/

begin
    for i in 1 .. 10
    loop
      dbms_output.put_line(' i ' || i) ;
    end loop ;
end ;
/

declare
    i number(2) := 1 ;
begin
    loop
      exit when i > 10 ;
      dbms_output.put_line(' i ' || i) ;
      i := i + 1 ;
    end loop ;
end ;
/

create table plsql_table (
       id number(4) not null ,
       name varchar2(10) not null ,
       constraint PK_plsql_table_id primary key(id)
);
select * from user_tables where table_name = 'PLSQL_TABLE' ;
select count(*) from plsql_table ;

declare
    i number(4) := 1 ;
    cnt number(4) := 0 ;
begin
    while ( i < 1000 )
      loop
        insert into plsql_table(id, name) values( i, '嘻嘻' ) ;
        i := i + 1 ;
      end loop ;
     select count(*) into cnt from plsql_table ;
     dbms_output.put_line('cnt ' || cnt) ;
     commit ;
end ;
/

declare
    i number(4) := 1 ;
    cnt number(4) := 0 ;
begin
  loop
    exit when i >= 1000 ;
    delete from plsql_table where id = i ;
    i := i + 1 ;
  end loop ;
  select count(*) into cnt from plsql_table ;
  dbms_output.put_line('cnt ' || cnt) ;
  commit ;
end ;
/
        
-- 游标
declare
   cursor curemp
   is
   select e.empno, e.ename, e.mgr, e.sal from emp e ;
   
   ename emp.ename%type ;
   eno emp.empno%type ;
   emgr emp.mgr%type ;
   esal emp.sal%type ;
begin
  -- 打开游标
  open curemp ;
  loop
    fetch curemp into eno, ename, emgr, esal ;
    exit when curemp%notfound ;
    dbms_output.put_line(ename || ' | ' || eno || ' | ' || emgr || ' | ' || esal) ;
  end loop ;
  -- 关闭游标
  close curemp ;
end ;
/

select * from emp where deptno = 30 ;

declare
    cursor curemp(pdno emp.deptno%type)
    is
    select e.empno, e.ename, e.mgr, e.sal from emp e where e.deptno = pdno ;
    
    ename emp.ename%type ;
    eno emp.empno%type ;
    emgr emp.mgr%type ;
    esal emp.sal%type ;
begin
    open curemp(&d) ;
    loop
      fetch curemp into eno, ename, emgr, esal ;
      exit when curemp%notfound ;
      dbms_output.put_line(ename || ' | ' || eno || ' | ' || emgr || ' | ' || esal) ;  
    end loop ;
    close curemp ;
end ;
/

declare
    cursor curemp
    is
    select e.empno, e.ename, e.job, e.sal from emp e ;
    
    ename emp.ename%type ;
    eno emp.empno%type ;
    ejob emp.job%type ;
    esal emp.sal%type ;  
begin
    open curemp ;
    loop
      fetch curemp into eno, ename, ejob, esal ;
      exit when curemp%notfound ;
      dbms_output.put_line(ename || ' | ' || eno || ' | ' || ejob || ' | ' || esal) ;
      
      if ejob = 'MANAGER' then
        update emp set sal = sal + 5000 where empno = eno ;
      elsif ejob = 'SALESMAN' then
        update emp set sal = sal + 3000 where empno = eno ;
      else
        update emp set sal = sal + 1000 where empno = eno ;
      end if ;
     end loop ;
     close curemp ;
     commit ;
end ;
/  
    
select * from emp ;

--- 异常
declare
    ret number(2) ;
begin
  ret := 1 / 0 ;
  dbms_output.put_line('ret ' || ret) ;
exception
  when zero_divide then
      dbms_output.put_line('除数不能为0');
end ;
/      


-- 存储过程和存储函数

-- 存储过程
-- Author  : SAKURA
-- Created : 2018/6/3 23:15:06
-- Purpose : a
CREATE OR REPLACE PROCEDURE demo(Name in out type, Name in out type, ...) 
IS
BEGIN
  
END;

create or replace procedure hello
AS
BEGIN
  dbms_output.put_line('hello procedure') ;
END ;

create or replace procedure improveEmpSal(eno in NUMBER)
as
begin
  update emp e
  set e.sal = e.sal * 1.2 
  where e.empno = eno ;
  commit ;
end ;

-- 这里的类型为概述的写， VARCHAR2(20) 是错的，应该是 VARCHAR2
create or replace procedure find(eno IN NUMBER, esal OUT NUMBER, ename OUT VARCHAR2)
as
begin
  select e.sal, e.ename into esal, ename
  from emp e
  where e.empno = eno ;
end ;

begin
  hello() ; -- hello procedure
end ;

select * from emp where empno = 7369 ;

begin
  improveEmpSal(7369) ;
end ;
/

DECLARE
    esal emp.sal%TYPE := 0 ;
    ename emp.ename%TYPE := '没' ;
BEGIN
  dbms_output.put_line('esal ' || esal) ;
  dbms_output.put_line('ename ' || ename) ;
  find(7369, esal, ename) ;
  dbms_output.put_line('find esal ' || esal) ;
  dbms_output.put_line('find ename ' || ename) ; 
END ;
/

-- 函数
function test(a NUMBER) return ;

CREATE [OR REPLACE] FUNCTION 函数名[(参数列表)]
 RETURN  返回值类型
AS
PLSQL子程序体；
[begin … end;/]

create or replace function findEmpSal(eno IN NUMBER)
-- 指定返回类型
   return NUMBER
AS
   esal NUMBER ;
BEGIN
   SELECT sal into esal
   from emp
   where empno = eno ;
   -- 注意 return
   return esal ;
END ;

create or replace function findEmpNameAndJob(eno IN NUMBER, ejob OUT VARCHAR2, ename OUT VARCHAR2)
       return NUMBER  -- 注意，这里没有 ； 号
as
       emajor emp.mgr%TYPE ;
begin
  select e.job, e.ename, e.mgr into ejob, ename, emajor 
  from emp e
  where e.empno = eno ;
  return emajor ;
end ;

declare
       ejob emp.job%TYPE ;
       ename emp.ename%TYPE ;
       emajor emp.mgr%TYPE ;
begin
      dbms_output.put_line('ejob ' || ejob) ;
      dbms_output.put_line('ename ' || ename) ;
      dbms_output.put_line('emajor ' || emajor) ;
      emajor := findEmpNameAndJob(7369, ejob, ename) ;
      dbms_output.put_line('find ejob ' || ejob) ;
      dbms_output.put_line('find ename ' || ename) ;
      dbms_output.put_line('find emajor ' || emajor) ;
end ;
/

declare
    esal NUMBER := 0 ;
begin
    dbms_output.put_line('esal ' || esal) ;
    esal := findEmpSal(7369) ;
    dbms_output.put_line('find esal ' || esal) ;
end ;
/

-- 触发器 ,注意 触发器只针对删除、修改、插入操作！
   CREATE  [or REPLACE] TRIGGER  触发器名
   {BEFORE | AFTER}
   { INSERT | DELETE|-----语句级
      UPDATE OF 列名}----行级
   ON  表名
    -- 遍历每一行记录
   [FOR EACH ROW]
   PLSQL 块 [declare…begin…end;/]
   
--         :old         :new          注意，都为行级触发使用
--insert   都为 null      要插入的数据
--update   更新前数据        更新后数据
--delete   删除前数据        null

create or replace trigger insertEmpTrigger
before insert
on emp
for each row
begin
  dbms_output.put_line('update emp new id ' || :new.empno) ;
end ;

select * from emp order by empno ;
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (2, '2', '3', 4, NULL, NULL, NULL, 10);

 
create or replace trigger securityTrigger
before insert
on emp
declare
   iday VARCHAR2(10) ;
   itime NUMBER ;
begin
  select to_char(sysdate, 'day') into iday 
  from dual ;
  
  select to_char(sysdate, 'hh24') into itime
  from dual ;
  
  dbms_output.put_line('day ' || iday || ' time ' || itime) ;
  
  if iday in ('星期六', '星期日') or itime not between 7 and 23  then
    raise_application_error('-20000', '非工作事件，请工作时间再来！') ;
  end if ;
end ;


create or replace trigger checksaltrigger
before update of sal
on emp
for each row
begin
  if :new.sal <= :old.sal then
   RAISE_APPLICATION_ERROR('-20001', '你涨的工资也太少了把！！！！');
  end if ;
end ;

select * from emp where empno = 1 ;
update emp set ename = 'new-name' where empno = 1 ;
