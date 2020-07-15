1. 创建用户 (具备管理员权限)
CREATE USER 用户名 IDENTIFIED BY 密码 
[DEFAULT TABLESPACE 表空间名称]
[TEMPORARY TABLESPACE 表空间名称]
[QUOTA 数组 [K|M] UNLIMITED ON 表空间名称
QUOTA 数组 [K|M] UNLIMITED ON 表空间名称 ...]
[PROFILE 概要文件名称 | DEFAULT]
[PASSWORD EXPIRE]
[ACCOUNT LOCK | UNLOCK]

CREATE USER testuser IDENTIFIED BY oracle
DEFAULT TABLESPACE mldn_data
TEMPORARY TABLESPACE mldn_tmp
QUOTA 30M ON mldn_data
QUOTA 20M ON USERS
ACCOUNT UNLOCK
PASSWORD EXPIRE ;
此时的用户无法使用，因为没有权限
ORA-01045: user TESTUSER lacks CREATE SESSION privilege; logon denied
SELECT * FROM dba_tablespaces ;

2. 查看用户信息
SELECT * FROM dba_users ;
SELECT * FROM dba_ts_quotas ; -- 用户数据配额
SELECT * FROM user_tab_privs_recd WHERE OWNER = 'TESTUSER' ;
SELECT * FROM user_col_privs_recd ;
COMMIT ;
查询输出格式化显示:
COL 列名称 FOR A长度
COL empno FRO A10

3. 概要文件(管理员限制用户的资源访问量或用户管理等操作)
CREATE PROFILE 概要文件名称 LIMIT 命令(s)
3.1 资源限制命令
    SESSION_PER_USER 数字| UNLIMITED | DEFAULT ;
    CUP_PER_SESSION  数字| UNLIMITED | DEFAULT ;
    CPU_PER_ALL  数字| UNLIMITED | DEFAULT ;
    CONNECT_TIME  数字| UNLIMITED | DEFAULT ;
    IDLE_TIME  数字| UNLIMITED | DEFAULT ;
    LOGICAL_READS_PER_SESSION  数字| UNLIMITED | DEFAULT ;
    LOGICAL_READS_PER_CALL  数字| UNLIMITED | DEFAULT ;
3.2 口令限制命令
    FAILED_LOGIN_ATTEMPTS  数字| UNLIMITED | DEFAULT ;
    PASSWORD_LIFE_TIME  数字| UNLIMITED | DEFAULT ;
    PASSWORD_REUSE_TIME  数字| UNLIMITED | DEFAULT ;
    PASSWORD_REUSE_MAX  数字| UNLIMITED | DEFAULT ;
    PASSWORD_VERIFY_FUNCTION  数字| UNLIMITED | DEFAULT ;
    PASSWORD_LOCK_TIME  数字| UNLIMITED | DEFAULT ;
    PASSWORD_GRACE_TIME  数字| UNLIMITED | DEFAULT ;
SELECT * FROM dba_profiles ;
4. 使用profile
CREATE USER testuser IDENTIFIED BY ORACLE PROFILE test_profile ;
ALTER USER 用户名 PROFILE 概要文件名称 ;
5. 删除profile文件
DROP PROFILE 概要文件名称 ;
6. 维护用户信息
ALTER USER 用户名称 IDENTIFIED BY 新密码 ;
ALTER USER 用户名称 ACCOUNT LOCK ;
ALTER USER 用户名称 ACCOUNT UNLOCK ;
ALTER USER 用户名称 PASSWORD EXPIRE ;
ALTER USER 用户名称 QUOTA 20M ON SYSTEM QUOTA 20M ON USERS ; (dba_ts_quotas)
DROP USER 用户名 [CASCADE] ;
DROP USER 用户名称 ;

ALTER USER testuser PROFILE testuser_profile ;
SELECT * FROM dba_users ;

CREATE PROFILE testuser_profile LIMIT
CPU_PER_SESSION 100000
LOGICAL_READS_PER_SESSION 2000
CONNECT_TIME 60
IDLE_TIME 30
SESSIONS_PER_USER 10
FAILED_LOGIN_ATTEMPTS UNLIMITED
PASSWORD_LIFE_TIME 60
PASSWORD_REUSE_TIME 30
PASSWORD_GRACE_TIME 6 ;


-----------------------------------------------------------------------------------------------
用户权限
DCL : GRANT 或者 REVOKE
分类:
    系统权限： 数据库的资源操作的权限(创建表,索引等),针对的是系统全局用户
    对象权限: 维护数据库中对象的能力，有一个用户操作另一个用户， 指的是一个用户对象下的所有相关操作
        SELECT, INSERT, UPDATE, DELETE, EXECUTE, ALTER, INDEX, REFERENCES 
GRANT 权限
TO [用户名, ...| 角色名称, ....| PUBLIC]
[WITH ADMIN OPTION] ;
权限： 主要指各种系统权限
TO： 授予权限的用户，角色或者使用PUBLIC设置为公共权限
WITH ADMIN OPTION： 将用户授予的权限继续授予给其它用户

-- 仅给了用户进入系统的权限
GRANT CREATE SESSION TO testuser WITH ADMIN OPTION ;
GRANT CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO testuser WITH ADMIN OPTION ;

-- 为 testuser 授予 scott tmp表的相关权限
GRANT SELECT, INSERT ON scott.emp TO TESTUSER ;
GRANT UPDATE(dname) ON scott.dept TO TESTUSER ;

回收对象权限 ： 
REVOKE [权限, ... |ALL]
ON 对象
FROM [用户, ...| 角色, ...| PUBLIC ] ;
REVOKE SELECT, INSERT ON scott.emp FROM TESTUSER ;
权限分配信息表:
SELECT * FROM dba_sys_privs WHERE grantee = 'TESTUSER' ;
撤销权限:
REVOKE CREATE TABLE, CREATE VIEW FROM testuser ;
-----------------------------------------------------------------------------------------------
角色：一组相关权限的集合
创建角色：
    CREATE ROLE 角色名称 [NOT IDENTIFIED | IDENTIFIED BY　密码] ;
    CREATE ROLE testrole ;
    CREATE ROLE testrole1 IDENTIFIED BY testrole1 ;
    
    SELECT * FROM dba_roles ;
    SELECT * FROM role_sys_privs ; -- 角色的权限
    SELECT * FROM session_privs ; -- 当前回话拥有的权限
角色的权限修改：
    ALTER ROLE 角色名称 [NOT IDENTIFIED | IDENTIFIED BY 密码] ;
    REVOKE 权限 FROM 角色名称 ;
系统默认角色:
    重要的： CONNECT, RESOURCE
 
为用户授予角色：
    GRANT 角色1 TO 用户名称 ;
    GRANT 角色1, 角色2, ... TO 用户名称 ;
    
