-- dbms_output��oracle�е�һ���������
-- put_line�����������һ���������������һ���ַ����Զ����� 
-- ������ʾPLSQL�����ִ�н����Ĭ������£�����ʾPLSQL�����ִ�н�����﷨��set serveroutput on/off;
set serveroutput on;

-- ����ʹ��
declare
   nsum NUMBER(3) := 0 ;
   tip VARCHAR(10) := '�����' ;
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
    dbms_output.put_line('��Ա 7369 ������ ' || ename || ' н���� ' || esal) ;
end ;
/

declare
    erow emp%rowtype ;
begin
  select * into erow from emp where empno = 7369 ;
  dbms_output.put_line(erow.ename || ' ' || erow.sal) ;
end ;
/
      
-- �ж����
select to_char(sysdate, 'day') from dual ;

declare
   pday varchar2(10) ;
begin
  select to_char(sysdate, 'day') into pday from dual ;
  dbms_output.put_line('today is ' || pday) ;
  if pday in ('������', '������') then
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
    dbms_output.put_line('δ����') ;
  elsif age < 30 then
    dbms_output.put_line('������') ;
  elsif age < 60 then
    dbms_output.put_line('�ܶ�') ;
  elsif age < 80 then
    dbms_output.put_line('����') ;
  else
    dbms_output.put_line('δ����') ;
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
        insert into plsql_table(id, name) values( i, '����' ) ;
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
        
-- �α�
declare
   cursor curemp
   is
   select e.empno, e.ename, e.mgr, e.sal from emp e ;
   
   ename emp.ename%type ;
   eno emp.empno%type ;
   emgr emp.mgr%type ;
   esal emp.sal%type ;
begin
  -- ���α�
  open curemp ;
  loop
    fetch curemp into eno, ename, emgr, esal ;
    exit when curemp%notfound ;
    dbms_output.put_line(ename || ' | ' || eno || ' | ' || emgr || ' | ' || esal) ;
  end loop ;
  -- �ر��α�
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

--- �쳣
declare
    ret number(2) ;
begin
  ret := 1 / 0 ;
  dbms_output.put_line('ret ' || ret) ;
exception
  when zero_divide then
      dbms_output.put_line('��������Ϊ0');
end ;
/      


-- �洢���̺ʹ洢����

-- �洢����
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

-- ���������Ϊ������д�� VARCHAR2(20) �Ǵ�ģ�Ӧ���� VARCHAR2
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
    ename emp.ename%TYPE := 'û' ;
BEGIN
  dbms_output.put_line('esal ' || esal) ;
  dbms_output.put_line('ename ' || ename) ;
  find(7369, esal, ename) ;
  dbms_output.put_line('find esal ' || esal) ;
  dbms_output.put_line('find ename ' || ename) ; 
END ;
/

-- ����
function test(a NUMBER) return ;

CREATE [OR REPLACE] FUNCTION ������[(�����б�)]
 RETURN  ����ֵ����
AS
PLSQL�ӳ����壻
[begin �� end;/]

create or replace function findEmpSal(eno IN NUMBER)
-- ָ����������
   return NUMBER
AS
   esal NUMBER ;
BEGIN
   SELECT sal into esal
   from emp
   where empno = eno ;
   -- ע�� return
   return esal ;
END ;

create or replace function findEmpNameAndJob(eno IN NUMBER, ejob OUT VARCHAR2, ename OUT VARCHAR2)
       return NUMBER  -- ע�⣬����û�� �� ��
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

-- ������ ,ע�� ������ֻ���ɾ�����޸ġ����������
   CREATE  [or REPLACE] TRIGGER  ��������
   {BEFORE | AFTER}
   { INSERT | DELETE|-----��伶
      UPDATE OF ����}----�м�
   ON  ����
    -- ����ÿһ�м�¼
   [FOR EACH ROW]
   PLSQL �� [declare��begin��end;/]
   
--         :old         :new          ע�⣬��Ϊ�м�����ʹ��
--insert   ��Ϊ null      Ҫ���������
--update   ����ǰ����        ���º�����
--delete   ɾ��ǰ����        null

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
  
  if iday in ('������', '������') or itime not between 7 and 23  then
    raise_application_error('-20000', '�ǹ����¼����빤��ʱ��������') ;
  end if ;
end ;


create or replace trigger checksaltrigger
before update of sal
on emp
for each row
begin
  if :new.sal <= :old.sal then
   RAISE_APPLICATION_ERROR('-20001', '���ǵĹ���Ҳ̫���˰ѣ�������');
  end if ;
end ;

select * from emp where empno = 1 ;
update emp set ename = 'new-name' where empno = 1 ;
