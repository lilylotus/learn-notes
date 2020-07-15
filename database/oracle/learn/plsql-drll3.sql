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
��һ��ʹ��For ѭ��,forѭ���ǱȽϼ�ʵ�õķ����� 
���ȣ������Զ�open��close�αꡣ����������Ǵ򿪻�ر��α�ķ��ա� 
���,�Զ�����һ����¼���ͼ���������͵ı��������Զ�fetch���ݵ���������� 
ע�� RS �����������Ҫ��ѭ�����������������Ϊ��ָ���������͡�����һ����¼���ͣ�����Ľṹ�����α�����ġ�
����������������������ѭ�����ڡ�
�������α���������м�¼���Ѿ���ȡ�غ�ѭ�������������������ж��α��%NOTFOUND����ΪTRUE��
forѭ��������ѭ���α����÷�������Ч����࣬��ȫ��


�ڶ���ʹ��Fetchѭ��
ע�⣬exit when���һ��Ҫ������fetch֮�󣬱����������ݴ��� 
�����߼���Ҫ���� exit when ֮��ѭ��������Ҫ�ǵùر��αꡣ


������ʹ��Whileѭ��
ʹ��while ѭ��ʱ����Ҫ��ѭ��֮ǰ����һ��fetch�������α�����ԲŻ������á�
�������ݴ������������ѭ�����ڵ�fetch����֮ǰ��ѭ�����ڵ�fetch����Ҫ������󣬷���ͻ�ദ��һ
*/

create or replace function fun(var1 NUMBER, var2 NUMBER)
       return NUMBER -- �� ;
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
