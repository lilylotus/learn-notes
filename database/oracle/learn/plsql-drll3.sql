declare
  i NUMBER := 0 ;
  k NUMBER := 0 ;
begin
  dbms_output.put_line('i = ' || i) ;
  i := &d ;
  if i < 10 then
    dbms_output.put_line('i less than ten, i = ' || i) ;
  elsif i < 20 then
    dbms_output.put_line('i less than twenty, i = ' || i) ;
  else
    dbms_output.put_line('i less than ' || i) ;
  end if ;
  
  while k <= i 
    loop
      dbms_output.put_line('while k = ' || k) ;
      k := k + 1 ;
    end loop ;
  k := 0 ;
  loop
    dbms_output.put_line('loop k = ' || k) ;
    k := k + 1 ;
    exit when k > i ;
  end loop ;
  
  for v in 0 .. 10 
    loop
      dbms_output.put_line('for v ' || v) ;
    end loop ;
end ;
/

create table customers 
(
 id NUMBER not null ,
 name VARCHAR2(30) not null ,
 age NUMBER(2) not null ,
 address VARCHAR2(60) not null ,
 salary NUMBER(5) not null ,
 constraint PK_customers_id primary key (id)
 ) ;
insert into customers values('1', 'Ramesh', '32', 'Ahmedabad', '2000.00');
insert into customers values('2', 'Khilan', '25', 'Delhi', '1500.00');
insert into customers values('3', 'kaushik', '23', 'Kota', '2000.00');
insert into customers values('4', 'Chaitali', '25', 'Mumbai', '6500.00');
insert into customers values('5', 'Hardik', '27', 'Bhopal', '8500.00');
insert into customers values('6', 'Komal', '22', 'MP', '4500.00');

declare
       total_rows NUMBER(2) ;
begin
  update customers
  set salary = salary + 600 ;
  
  if sql%notfound then
    dbms_output.put_line('no customers selected');
  elsif sql%found then
    total_rows := sql%rowcount ;
    dbms_output.put_line('customers selected total_rows = ' || total_rows);       
  end if ;
  commit ;
end ;
/

declare
    rowcus customers%rowtype ;
    cursor ecur is
    select * from customers;
begin
  -- for
  for rs in ecur
    loop
      dbms_output.put_line('id = ' || rs.id || ' name = ' || rs.name || ' salary = ' || rs.salary) ;
    end loop ;
  dbms_output.put_line('--------------------------1');    
  -- fetch
  open ecur ;
  loop
    fetch ecur into rowcus ;
    -- %notfound
    exit when ecur%notfound ;
    dbms_output.put_line('id = ' || rowcus.id || ' name = ' || rowcus.name || ' salary = ' || rowcus.salary) ;
  end loop ;
  close ecur ;
  dbms_output.put_line('--------------------------2');
  -- while
  open ecur ;
  fetch ecur into rowcus ;
  -- %found
  while ecur%found 
    loop
      dbms_output.put_line('id = ' || rowcus.id || ' name = ' || rowcus.name || ' salary = ' || rowcus.salary) ;
      fetch ecur into rowcus ;
    end loop ;
  close ecur ;
end ;
/

/*
第一种使用For 循环,for循环是比较简单实用的方法。 
首先，它会自动open和close游标。解决了你忘记打开或关闭游标的烦恼。 
其次,自动声明一个记录类型及定义该类型的变量，并自动fetch数据到这个变量。 
注意 RS 这个变量无需要在循环外进行声明，无需为其指定数据类型。它是一个记录类型，具体的结构是由游标决定的。
这个变量的作用域仅仅是在循环体内。
最后，与该游标关联的所有记录都已经被取回后，循环无条件结束，不必判定游标的%NOTFOUND属性为TRUE。
for循环是用来循环游标的最好方法。高效，简洁，安全。


第二种使用Fetch循环
注意，exit when语句一定要紧跟在fetch之后，避免多余的数据处理。 
处理逻辑需要跟在 exit when 之后。循环结束后要记得关闭游标。


第三种使用While循环
使用while 循环时，需要在循环之前进行一次fetch动作，游标的属性才会起作用。
而且数据处理动作必须放在循环体内的fetch方法之前，循环体内的fetch方法要放在最后，否则就会多处理一
*/

create or replace function fun(var1 NUMBER, var2 NUMBER)
       return NUMBER -- 无 ;
as
       varsum NUMBER := 0 ;
begin
  varsum := var1 + var2 ;
  dbms_output.put_line('sum = ' || varsum) ;
  return varsum ;
end ;
/

begin
  dbms_output.put_line('sum = ' || fun(1, 2)) ;
end ;
/


create or replace procedure pro(var1 IN NUMBER)
AS
BEGIN
    dbms_output.put_line('var1 = ' || var1) ;
end ;


declare
    i NUMBER := 2 ;
begin
  pro(i);
end ;
/

create or replace trigger cus_trigger
before insert or update or delete
on customers
declare

begin
  dbms_output.put_line('cus_trigger') ;
end ;

create or replace trigger update_cus_trigger
before update of salary
on customers
for each row
begin
  dbms_output.put_line('update_cus_trigger old value = ' || :old.salary || ' new value ' || :new.salary) ;
end ;


update customers set salary = 1000;
