select * from user_tables;

select * from emp ;

select * from user_tables ;
select count(*) from demo_table ;
select * from demo_table ;
delete from demo_table;
insert into demo_table(name, descript) values();

declare
       vc VARCHAR2(30) := 'hello 你好' ;
begin
       dbms_output.put_line(vc || ' print');
end ;
/

declare
    vi NUMBER := 0;
begin
    vi := &d;
    if vi < 10 then
       dbms_output.put_line('less than 10');
    elsif vi < 20 then
          dbms_output.put_line('less than 20');
    elsif vi < 30 then
          dbms_output.put_line('less than 30');
    else
          dbms_output.put_line('less vi = ' || vi);
    end if ;
    dbms_output.put_line('vi = ' || vi);
end ;
/

declare
    vi NUMBER := 0 ;
begin
    while vi < 100
    loop
          dbms_output.put_line('vi = ' || vi);
          vi := vi + 1 ;
    end loop ;
end ;
/

begin
    for vf in 1 .. 10
        loop
            dbms_output.put_line('vf = ' || vf);
        end loop ;
end ;
/

declare
    vi NUMBER := 0 ;
begin
    loop
        exit when vi >= 10 ;
        dbms_output.put_line('vi = ' || vi);
        vi := vi + 1 ;
    end loop ;
end ;
/

declare
    vno emp.empno%TYPE ;
    vname emp.ename%TYPE ;
    vjob emp.job%TYPE ;
    vsal emp.sal%TYPE ;
begin
    select e.empno, e.ename, e.job, e.sal into vno, vname, vjob, vsal
    from emp e
    where e.empno = 7369 ;
    dbms_output.put_line('no = ' || vno || ' name = ' || vname || ' job = ' || vjob || ' sal = ' || vsal);
end ;
/

-- SQL%ROWCOUNT    整型  代表DML语句成功执行的数据行数
-- SQL%FOUND   布尔型 值为TRUE代表插入、删除、更新或单行查询操作成功
-- SQL%NOTFOUND    布尔型 与SQL%FOUND属性返回值相反
-- SQL%ISOPEN  布尔型 DML执行过程中为真，结束后为假

declare
    vsal emp.sal%TYPE ;
    veno emp.empno%TYPE ;
    cursor ecursor is
    select e.empno, e.sal from emp e;
begin
    open ecursor ;
    loop
        fetch ecursor into veno, vsal ;
        exit when ecursor%NOTFOUND ;
        dbms_output.put_line(veno || ' | ' || vsal);
        if vsal < 2000 then
            update emp set sal = sal * 1.3 where empno = veno;
        end if ;
    end loop ;
    close ecursor ;
    commit ;
end ;
/

declare
    e_row emp%ROWTYPE ;
    cursor cemp is
    select * from emp ;
begin
    if cemp%ISOPEN
        then
            dbms_output.put_line('no');
    else
        dbms_output.put_line('yes');
    end if ;
    if cemp%ISOPEN = false
        then
            open cemp;
    end if ;

    for e_row in cemp
        loop
            dbms_output.put_line(e_row.empno || ' | ' || e_row.ename || ' | ' || e_row.job || ' | ' || e_row.sal);
        end loop ;

    dbms_output.put_line('------------------------------------------1');
    if cemp%ISOPEN = false
        then
            open cemp ;
    end if;
    loop
        fetch cemp into e_row ;
        -- %NOTFOUND
        exit when cemp%NOTFOUND ;
        dbms_output.put_line(e_row.empno || ' | ' || e_row.ename || ' | ' || e_row.job || ' | ' || e_row.sal);
    end loop ;

    close cemp ;

    dbms_output.put_line('------------------------------------------2');
    open cemp ;
    fetch cemp into e_row ;
    -- %FOUND
    while cemp%FOUND
        loop
            dbms_output.put_line(e_row.empno || ' | ' || e_row.ename || ' | ' || e_row.job || ' | ' || e_row.sal);
            fetch cemp into e_row ;
        end loop ;
    close cemp ;
end ;
/
