drop table jdbc_copy ;
create table jdbc_copy as select * from jdbc where 1 = 2 ;

-- PRAGMA  AUTONOMOUS_TRANSACTION;  和 COMMMIT; 语句是必须的。
create or replace trigger recordor
  before insert
  on jdbc 
  for each row
declare
  -- local variables here
  PRAGMA AUTONOMOUS_TRANSACTION ;
begin
  dbms_output.put_line(:new.id || '|' || :new.name) ;
  insert into jdbc_copy (id, name, age, address, create_time, modify_time) 
  values (:new.id, :new.name, :new.age, :new.address, sysdate, sysdate) ;
  commit ;
end recordor;

create or replace trigger recordor_update
before update
on jdbc 
for each row
    declare
    pragma autonomous_transaction ;
begin
    dbms_output.put_line(:old.id || '|' || :new.id) ;
    insert into jdbc_copy (id, name, age, address, create_time, modify_time) 
    values (:new.id, :new.name, :new.age, :new.address, sysdate, sysdate) ;
    commit ;
end recordor_update ;


update jdbc set age = 80 where id = 1 ;
insert into jdbc (id, name, age, address, create_time, modify_time) values (403, 'jdbc_copy', 23, 'copy_address', sysdate, sysdate) ;
commit;

select * from jdbc_copy ;
delete from jdbc_copy ;

declare
    cursor vc is select id, name, age, address, create_time, modify_time from jdbc where age = 80 ;
    row_jdbc jdbc%ROWTYPE ;
begin
    if vc%ISOPEN = false then
        open vc;
        dbms_output.put_line('open cursor') ;
     end if ;
    loop
        fetch vc into row_jdbc ;
        exit when vc%NOTFOUND ;
        dbms_output.put_line('id : ' || row_jdbc.id || ' name : ' || row_jdbc.name) ;
    end loop ;
    
    if vc%Isopen = true then
        close vc ;
        dbms_output.put_line('close cursor') ;
    end if ;
end ;
/


declare
    cursor vc is select id, name, age, address, create_time, modify_time from jdbc where age = 80 ;
    row_jdbc jdbc%ROWTYPE ;
begin
    for v in vc
        loop
            dbms_output.put_line('id : ' || v.id || ' name : ' || v.name) ;
        end loop ;
end ;
/


declare
       var_i NUMBER(4) := 0;
begin
    dbms_output.put_line('var_i : ' || var_i) ;
    
    var_i  := 100 ;
    
    if var_i = 0 then
        dbms_output.put_line('if var_i 1 ' || var_i) ;
     elsif var_i <= 10 then
         dbms_output.put_line('if var_i 2 ' || var_i) ;
     else
         dbms_output.put_line('if var_i 3 ' || var_i) ;
     end if ;
     
     for i in 1..10
         loop
             dbms_output.put_line(i) ;
         end loop ;
    
    loop
      exit when var_i >= 110;
      var_i := var_i + 1;  
      dbms_output.put_line('var_i loop ' || var_i) ;
    end loop ;
    
    while var_i <= 130
        loop
            dbms_output.put_line('var_i while ' || var_i) ;
            var_i := var_i + 2;
        end loop ;
     
end ;
/


create table clob_table
(
       id number(4) not null ,
       name varchar2(50) not null ,
       des clob not null ,
       create_time date not null ,
       modify_time date not null ,
       primary key(id)
) ;
       

insert into clob_table values (1, 'test', '这个号ad森林法', sysdate, sysdate) ;
commit ;

select * from clob_table ;
select dbms_lob.substr(des) as text from clob_table ;
select * from clob_table where dbms_lob.substr(des) like '%a%' ;
