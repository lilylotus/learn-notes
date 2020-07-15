1. 触发器分类
    DML触发器
    INSTEAD-OF(替代)触发器
    DDL触发器
    系统或数据库事件触发器
2. 创建触发器
CREATE [OR REPLACE] TRIGGER trigger_name
{BEFORE | AFTER }
[INSTEAD OF]
{INSERT | DELETE | UPDATE [OF column [, column …]]}
[OR {INSERT | DELETE | UPDATE [OF column [, column …]]}...]
ON [schema.]table_name | [schema.]view_name 
[REFERENCING {OLD [AS] old | NEW [AS] new| PARENT as parent}]
[FOR EACH ROW ]
[WHEN condition]
PL/SQL_BLOCK | CALL procedure_name;

3. 触发器不接受任何参数， 触发器在一张表中不超过12个， 不能使用事务处理或自治事务
    按理来说数据库中尽可能不使用触发器。

--------------------------------------------------------------------------
1. 删除触发器
DROP TRIGGER trigger_name;

2. 禁用或启用触发器
ALTER TIGGER trigger_name [DISABLE | ENABLE ];

3. 触发器和数据字典 [USER_TRIGGERS、ALL_TRIGGERS、DBA_TRIGGERS]
SELECT TRIGGER_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, TABLE_OWNER, 
    REFERENCING_NAMES, STATUS, ACTION_TYPE
FROM user_triggers;
--------------------------------------------------------------------------

--------------------------------------------------------------------------
一. DML触发器 (表级触发器， 行级触发器)
CREATE [OR REPLACE] TRIGGER 触发器名称
{BEFORE | AFTER }
[INSTEAD OF]
{INSERT | DELETE | UPDATE [OF column [, column …]]}
ON 表名称
[FOR EACH ROW]
[WHEN 触发条件]
[DECLARE]
BEGIN
END [触发器名称] ;
/

触发器执行顺序：
    BEFOR表级触发器执行；
    BEFOR行级触发器执行；
    执行更新操作；
    AFTER行级触发器执行；
    AFTER表级触发器执行；


--------------------------------------------------------------------------
二. 表级触发器

CREATE OR REPLACE TRIGGER emp_tax_trigger
AFTER UPDATE OR INSERT OF ename, sal, comm ON emp
DECLARE 
    CURSOR cur_emp IS SELECT * FROM emp ;
    v_empROw emp%ROWTYPE ;
    v_sal emp.sal%TYPE ;
    v_empTax emp_tax.tax%TYPE ;
BEGIN 
    DELETE FROM emp_tax ;
    FOR v_empRow IN cur_emp LOOP 
        v_sal := v_empRow.sal + NVL(v_empRow.comm, 0) ;
        IF v_sal < 2000 THEN
            v_empTax := v_sal * 0.03 ;
        ELSIF v_sal BETWEEN 2000 AND 5000 THEN 
            v_empTax := v_sal * 0.08 ;
        ELSIF v_sal > 5000 THEN 
            v_empTax := v_sal * 0.1 ;
       END IF ;
       
       INSERT INTO emp_tax(empno, ename, sal, tax, comm) 
       VALUES(v_empRow.empno, v_empRow.ename, v_empRow.sal, v_empTax, v_empRow.comm) ; 
    END LOOP ;
END ;
/

3. 启动一个子事务
== [PRAGMA AUTONOMOUS_TRANSACTON ; ]-- 开启子事务

CREATE OR REPLACE TRIGGER emp_tax_trigger
AFTER UPDATE OR INSERT OF ename, sal, comm ON emp
DECLARE 
    PRAGMA AUTONOMOUS_TRANSACTON ; -- 开启子事务
    CURSOR cur_emp IS SELECT * FROM emp ;
    v_empROw emp%ROWTYPE ;
    v_sal emp.sal%TYPE ;
    v_empTax emp_tax.tax%TYPE ;
BEGIN 
    DELETE FROM emp_tax ;
    FOR v_empRow IN cur_emp LOOP 
        v_sal := v_empRow.sal + NVL(v_empRow.comm, 0) ;
        IF v_sal < 2000 THEN
            v_empTax := v_sal * 0.03 ;
        ELSIF v_sal BETWEEN 2000 AND 5000 THEN 
            v_empTax := v_sal * 0.08 ;
        ELSIF v_sal > 5000 THEN 
            v_empTax := v_sal * 0.1 ;
       END IF ;
       
       INSERT INTO emp_tax(empno, ename, sal, tax, comm) 
       VALUES(v_empRow.empno, v_empRow.ename, v_empRow.sal, v_empTax, v_empRow.comm) ; 
    END LOOP ;
    COMMIT ; -- 提交自治事务
END ;
/

--------------------------------------------------------------------------

--------------------------------------------------------------------------
三. 行级触发器 (FOR EACH ROW)
在触发器内部多了两个标识符：(仅在DML触发器中产生)
    :old
    :new
INSERT -> :old 字段内容均为NULL， 操作结束后 :new 为增加的数据值
UPDATE -> :old 更新前的原始值， 更新结束后 :new 为更新后的数据值
DELETE -> :old 删除前的原始值， :new 字段内容均为NULL

CREATE OR REPLACE TRIGGER emp_tax_trigger
BEFORE INSERT
ON EMP
FOR EACH ROW
DECLARE
    v_jobCount NUMBER ;
BEGIN
    SELECT COUNT(empno) INTO v_jobCount 
    FROM emp
    WHERE :new.job IN (SELECT DISTINCT job FROM emp) ;
    IF v_jobCount = 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'new add employee has error in job infomation');
    ELSE
        IF :new.sal > 5000 THEN
            RAISE_APPLICATION_ERROR(-20008, 'new add employee has error in sal that can not more than 5000');
        END IF ;
    END IF ;
END ; 
/

CREATE OR REPLACE TRIGGER emp_tax_trigger
BEFORE UPDATE OF sal 
ON EMP
FOR EACH ROW
BEGIN
    IF ABS((:new.sal - :old.sal) / :old.sal) > 0.1 THEN
        RAISE_APPLICATION_ERROR(-20008, 'employee change salary to high');
    END IF ;
END ;
/

2. 触发器谓词
INSERTING : 如果触发的语句为INSERT语句，则为TRUE,否则为FALSE;
UPDATING : 如果触发的语句为UPDATE语句，则为TRUE,否则为FALSE;
DELETING : 如果触发的语句为DELETE语句，则为TRUE,否则为FALSE;

CREATE OR REPLACE TRIGGER tri_test  
BEFORE DELETE OR INSERT OR UPDATE ON mytest  
FOR EACH ROW  
WHEN (OLD.ID = 1)  
BEGIN  
  DBMS_OUTPUT.PUT_LINE('触发器开始执行');  
  CASE WHEN INSERTING THEN  
      DBMS_OUTPUT.PUT_LINE('插入逻辑植入');  
      RAISE_APPLICATION_ERROR(-20001,'id为1的用户不能插入');  
    WHEN UPDATING THEN  
      DBMS_OUTPUT.PUT_LINE('更新逻辑植入');  
      RAISE_APPLICATION_ERROR(-20002,'id为1的用户不能更新');  
    WHEN DELETING THEN  
      DBMS_OUTPUT.PUT_LINE('删除逻辑植入');  
      RAISE_APPLICATION_ERROR(-20003,'id为1的用户不能删除');  
  END CASE;  
END;  


---------------------------------------------------------------------------
四. DDL触发器
1. 创建触发器
CREATE [OR REPLACE] TRIGGER 触发器名称
[BEFORE|AFTER|INSTEAD OF][DDL事件] 
ON[DATABASE | SCHEMA]
[WHEN 触发事件]
[DECLARE]
BEGIN
END [触发器名称] ;
/

2. 可用事件
ALTER       对数据库中的任何一个对象使用SQL的ALTER命令时触发
ANALYZE     对数据库中的任何一个对象使用SQL的ANALYZE命令时触发
ASSOCIATE STATISTICS    统计数据关联到数据库对象时触发
AUDIT       通过SQL的AUDIT命令打开审计时触发
COMMENT     对数据库对象做注释时触发
CREATE      通过SQL的CREATE命令创建数据库对象时触发
DDL         列表中所用的事件都会触发
DISASSOCIATE STATISTICS 去掉统计数据和数据库对象的关联时触发
DROP        通过SQL的DROP命令删除数据库对象时触发
GRANT       通过SQL的GRANT命令赋权时触发
NOAUDIT     通过SQL的NOAUDIT关闭审计时触发
RENAME      通过SQL的RENAME命令对对象重命名时触发
REVOKE      通过SQL的REVOKE语句撤销授权时触发
TRUNCATE    通过SQL的TRUNCATE语句截断表时触发

3. 可用属性
ORA_CLIENT_IP_ADDRESS       客户端IP地址
ORA_DATABASE_NAME           数据库名称
ORA_DES_ENCRYPTED_PASSWORD  当前用户的DES算法加密后的密码
ORA_DICT_OBJ_NAME           触发DDL的数据库对象名称
ORA_DICT_OBJ_NAME_LIST       受影响的对象数量和名称列表
ORA_DICT_OBJ_OWNER          触发DDL的数据库对象属主
ORA_DICT_OBJ_OWNER_LIST     受影响的对象数量和名称列表
ORA_DICT_OBJ_TYPE           触发DDL的数据库对象类型
ORA_GRANTEE                 被授权人数量
ORA_INSTANCE_NUM            数据库实例数量
ORA_IS_ALTER_COLUMN         如果操作的参数column_name指定的列，返回true,否则false
ORA_IS_CREATING_NESTED_TABLE    如果正在创建一个嵌套表则返回true,否则false
ORA_IS_DROP_COLUMN          如果删除的参数column_name指定的列，返回true,否则false
ORA_LOGIN_USER              触发器所在的用户名
ORA_PARTITION_POS           SQL命令中可以正确添加分区子句位置
ORA_PRIVILEGE_LIST          授予或者回收的权限的数量。
ORA_REVOKEE                 被回收者的数量
ORA_SQL_TXT                 触发了触发器的SQL语句的行数。
ORA_SYSEVENT                导致DDL触发器被触发的时间
ORA_WITH_GRANT_OPTION       如果授权带有grant选项，返回true。否则false