declare
       emprow EMP%ROWTYPE ;
       CURSOR cemp is select * from emp ;
begin
     
    -- for in 不需要打开游标      
    for emprow in cemp
        loop
            dbms_output.put_line(emprow.empno || ' | ' || emprow.ename || ' | ' || emprow.job || ' | ' || emprow.sal);
        end loop;
    
    if cemp%ISOPEN = true
        then
            if cemp%notfound = true
                then
                    dbms_output.put_line('notfound');
             else
                 dbms_output.put_line('have data');
             end if ;
             close cemp ;
                 dbms_output.put_line('close cemp');
    else
        open cemp ;
        dbms_output.put_line('open cemp');
    end if ;
             
    dbms_output.put_line('-----------------------------------------1');
    
    loop
        -- fetch 获取游标的值
        fetch cemp into emprow ;
        exit when cemp%notfound ;
        dbms_output.put_line(emprow.empno || ' | ' || emprow.ename || ' | ' || emprow.job || ' | ' || emprow.sal);
    end loop ;
    
    dbms_output.put_line('-----------------------------------------2');
    if cemp%ISOPEN = true
        then
            if cemp%notfound = true
                then
                    dbms_output.put_line('notfound');
             else
                 dbms_output.put_line('have data');
             end if ;
             close cemp ;
                 dbms_output.put_line('close cemp');
    else
        open cemp ;
        dbms_output.put_line('open cemp');
    end if ;
    
    if cemp%isopen = false
        then
            open cemp ;
    end if ;
    
    fetch cemp into emprow ;
    while cemp%found
        loop
            dbms_output.put_line(emprow.empno || ' | ' || emprow.ename || ' | ' || emprow.job || ' | ' || emprow.sal);
            fetch cemp into emprow ;
        end loop ;
        
    if cemp%isopen = true
        then
            close cemp ;
            dbms_output.put_line('close cemp') ;
    end if ;

end ;       

------------------------------------

loop
  
  exit when ;
end loop;

i := .first;
while i is not null 
loop
    
  i := .next(i);
end loop;

open ;
loop
  fetch  into ;
  exit when %notfound;
  
end loop;
close ;

for c in (select )
loop
  
end loop;

for i in 1..10
loop
  
end loop;

while true
loop
  
end loop;

------------------

declare
begin
    for emprow in (select * from emp )
        loop
            dbms_output.put_line(emprow.empno || ' | ' || emprow.ename || ' | ' || emprow.job || ' | ' || emprow.sal);
        end loop ;
end ;    

------------------

declare
    cursor cemp is select * from emp ;
    emprow emp%rowtype ;
begin
    open cemp;
    loop
      fetch cemp into emprow ;
      exit when cemp%notfound ;
      dbms_output.put_line(emprow.empno || ' | ' || emprow.ename || ' | ' || emprow.job || ' | ' || emprow.sal);
    end loop ;
    close cemp ;
end ;
