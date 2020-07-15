CREATE TABLE scott.dailytest
(
    DID NUMBER(11) NOT NULL,
    DNAME VARCHAR2(30),
    DAGE NUMBER(3),
    DGENDER CHAR(1),
    CONSTRAINT PK_DID PRIMARY KEY(DID)
);

CREATE SEQUENCE scott.dailytest_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 9999999999
    MINVALUE 0;
    
CREATE OR REPLACE TRIGGER Scott.Dailytest_Seq_Tri
BEFORE INSERT ON scott.dailytest
FOR EACH ROW
BEGIN
    SELECT scott.dailytest_seq.NEXTVAL INTO:NEW.DID FROM DUAL;
END;

COMMIT;

INSERT INTO scott.dailytest(Dname, DAGE, DGENDER) VALUES('first', 20, 'F');

SELECT a.* FROM scott.dailytest a;

----------------------------------------------------------------------------------------
-- 开启输出
SET Serveroutput ON;

-- %TYPE 类型
DECLARE
    var_dname dailytest.DNAME%TYPE;
    var_dage dailytest.DAGE%TYPE;
    var_dgender dailytest.DGENDER%TYPE;
BEGIN
    SELECT A.Dname, a.DAGE, a.DGENDER
    INTO var_dname, var_dage, var_dgender
    FROM scott.dailytest a
    WHERE A.Did = 1;
    dbms_output.put_line(var_dname||' : '||var_dage||' : '||var_dgender);
END;
/

-- record类型
declare
type DAILYTEST_TYPE is record
(
    var_DNAME VARCHAR2(30),
    var_DAGE NUMBER(3),
    var_DGENDER CHAR(1)
);
dinfo DAILYTEST_TYPE;
BEGIN
    SELECT A.Dname, a.DAGE, a.DGENDER
    INTO dinfo
    FROM scott.dailytest a
    WHERE A.Did = 1;
    dbms_output.put_line('record类型');
    dbms_output.put_line(dinfo.var_dname||' : '||dinfo.var_dage||' : '||dinfo.var_dgender);
END;
/

-- if
/*  
if  表达式
then

end if;
*/
declare
var_name1 varchar2(20);
var_name2 varchar2(20);
begin
var_name1 := 'Ease';
var_name2 := 'xaosss';
if length(var_name1) < length(var_name2) 
then
    dbms_output.put_line('字符串"'||var_name1||'"的长度比字符串"'||var_name2||'"的长度小');
end if;
end;
/

-- if elsif
declare
var_age int := 89;
begin
if var_age <= 60 then
    dbms_output.put_line('成绩 : '||var_age||' 不合格');
elsif var_age <= 80 then
    dbms_output.put_line('成绩 : '||var_age||' 良');
elsif var_age <= 90 then
   dbms_output.put_line('成绩 : '||var_age||' 中');
else
    dbms_output.put_line('成绩 : '||var_age||' 优秀');
end if;
end;
/

-- case when then
declare
season int := 3;
info varchar2(50);
begin
case season
when 1 then
    info := season||'季度包括1、2、3 月份';
when 2 then
    info := season||'季度包括4、5、6 月份';
when 3 then
    info := season||'季度包括7、8、9 月份';
when 4 then
    info := season||'季度包括10、11、12 月份';
else 
    info := season||'季度不合法';
end case;
dbms_output.put_line(info);
end;
/

-- loop
declare
sum_i int := 0;
i int := 0;
begin
    loop
        i := i+1;
        sum_i := sum_i + i;
        exit when i = 100;
    end loop;
    dbms_output.put_line('前'||i||'和 : '||sum_i);
end;
/

-- while
declare
sum_i int := 0;
i int := 1;
begin
    while i <= 100 
    loop
        sum_i := sum_i + i;
        i := i+1;
    end loop;
    dbms_output.put_line('前'||i||'和 : '||sum_i);
end;
/

-- for
declare
sum_i int := 0;
i int := 1;
begin
    for i in reverse 1..100
    loop
    sum_i := sum_i + i;
    end loop;
    dbms_output.put_line('前'||i||'和 : '||sum_i);
end;
/

-- 游标
/*
cur_tmp%found 至少影响到一行数据为true;
cur_tmp%notfound 与%found相反
cur_tmp%rowcount 返回受SQL语句影响的行数
cur_tmp%isopen 游标打开时为true
*/
-- cursor
declare
cursor daily_cursor(var_name in varchar2:='notexit')
is select did, dname, dage, dgender
from Dailytest
where Dname like var_name||'%';
type record_type is record
(
    var_did NUMBER(11),
    var_DNAME VARCHAR2(30),
    var_DAGE NUMBER(3),
    var_DGENDER CHAR(1)    
);
test_row record_type;
var_count int := 1;
begin
 DBMS_OUTPUT.enable(buffer_size => null);
 open daily_cursor('fir');
 fetch daily_cursor into test_row;
 while daily_cursor%found loop
    dbms_output.put_line('ID : '||test_row.var_did||' ;NAME : '||test_row.var_DNAME||' ;AGE : '||test_row.var_DAGE||' ;GENDER : '||test_row.var_DGENDER);
     INSERT INTO scott.dailytest(Dname, DAGE, DGENDER) VALUES(test_row.var_DNAME||'NEW'||var_count, 20, 'F');
     Var_Count := Var_Count + 1;
     fetch daily_cursor into test_row;
 end loop;
 commit;
 close daily_cursor;
end;
/


select * from Dailytest;

-- =================================================================
-- procedure
drop procedure daily_insert_pro;
create or replace procedure daily_insert_pro(v_name in varchar2, v_age in INT, v_gender in CHAR(1)) is
begin
    INSERT INTO scott.dailytest(Dname, DAGE, DGENDER) VALUES(v_name,v_age, v_gender);
    commit;
    dbms_output.put_line('通过in参数插入成功！');
end daily_insert_pro;
/
commit;
exec daily_insert_pro('张三', 24, 'M');
