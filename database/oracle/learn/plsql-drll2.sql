select * 
from user_source
-- where type = 'PROCEDURE'
order by name, line ;

declare
      cursor emp_cursor is
      select ename, sal from emp ; -- 声明游标
      esal emp.sal%TYPE ;
      ename emp.ename%TYPE ;
begin
  open emp_cursor ; -- 打开游标
  loop
    fetch emp_cursor into ename, esal ;
    exit when emp_cursor%notfound ;
    if esal < 2000 then
      dbms_output.put_line(ename || ' 低工资 ' || esal);
    elsif esal < 3000 then
      dbms_output.put_line(ename || ' 低偏高工资 ' || esal);
    elsif esal < 4000 then
      dbms_output.put_line(ename || ' 中工资 ' || esal);
    else
      dbms_output.put_line(ename || ' 高工资 ' || esal);
    end if ;
   end loop ;
  close emp_cursor ;
end ;
/

declare
    num NUMBER := 0 ;
begin
  while num < 100
    loop
        dbms_output.put_line('num ' || num);
        num := num + 1 ;
    end loop ;
end ;
/

declare
    num NUMBER := &d ;
begin
  dbms_output.put_line('num ' || num);
  while ( num <= 100 )
    loop
      dbms_output.put_line('num ' || num);
      num := num + 2 ;
    end loop ;
end ;
/

declare
    num NUMBER(3) := 0 ;
begin
  loop
    exit when num > 99 ;
    dbms_output.put_line('num ' || num);
    num := num + 1 ;
  end loop ;
end ;
/


begin
  for i in 1 .. 100
    loop
      dbms_output.put_line('num ' || i);
    end loop ;
end ;
/
drop table proc_table ;
create table proc_table
(
       proc_id NUMBER NOT NULL ,
       proc_value NUMBER(10) NOT NULL ,
       constraint PK_proc_id primary key (proc_id)
) ;

select * from proc_table ;

declare
       num NUMBER := 0 ;
       value NUMBER := 0 ;
begin
  while num <= 100
    loop
      value := 3 * num ;
      insert into proc_table values(num, value) ;
      dbms_output.put_line('insert ' || num || ' value ' || value) ;
      num := num + 1 ;
    end loop ;
    commit ;
end ;
/


create or replace procedure add_value(v in NUMBER)
as
begin
  update proc_table
  set proc_value = proc_value + v ; 
end ;
/

begin
  add_value(100) ;
end ;
/
commit ;
select * from proc_table ;

create or replace trigger proc_say_trigger
before insert or update or delete
on proc_table
begin
  dbms_output.put_line('deal with proc_table');
end ;
/
rollback ;
delete from proc_table where proc_id = 101 ;
update proc_table set proc_value = proc_value + 1 where proc_id = 2 ;
update proc_table set proc_id = 101 where proc_id = 1 ;
create or replace trigger proc_update_row_trigger
before update of proc_value
on proc_table
for each row
begin
  dbms_output.put_line('update proc_value value is ' || :new.proc_value || ' old value ' || :old.proc_value) ;
end ;
/

create or replace trigger proc_delete_trigger 
before delete
on proc_table
for each row
begin
  dbms_output.put_line('delete proc proc_id ' || :old.proc_id || ' proc_value ' || :old.proc_value);
end ;
/
