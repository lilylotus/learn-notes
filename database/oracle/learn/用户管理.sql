一. 创建用户
1. 创建用户
CREATE USER 用户名 IDENTIFIED BY 密码 [DEFAULT TABLESPACE 表空间名称]
[TEMPORARY TABLESPACE 临时表空间名称]
[QUOTA 数字[K|M] UNLIMITED ON 表空间名称
QUOTA 数字[K|M] UNLIMITED ON 表空间名称 ..]
[PROFILE 概要文件名称 | DEFAULT]
[PASSWORD EXPIRE]
[ACCOUNT LOCK|UNLOCK]

-- 详细创建用户
CREATE USER c##userdemo IDENTIFIED BY userdemopassword 
DEFAULT TABLESPACE oracle_data
TEMPORARY TABLESPACE oracle_temp
QUOTA 30M ON oracle_data
QUOTA 20M ON users
ACCOUNT UNLOCK
PASSWORD EXPIRE;

-- 注意刚创建的用户无法使用,因为还没有权限

2. 删除用户
DROP USER 用户名 [CASCADE] ;

3. 查看用户
-- 查看用户
SELECT * FROM DBA_USERS ;
-- 查看用户配额
SELECT * FROM dba_ts_quotas ;

----------------------------------------------------------------------------------
二. 概要文件
概要文件，又被称作是资源文件，它是Oracle为了合理的分配和使用系统资源而提出的概念。
当DBA在创建一个用户的时候，Oracle会自动的为该用户创建一个相关联的缺省概要文件。
概要文件中包含一组约束条件和配置项，它可以限制允许用户使用的资源。

注：只有将RESOURCE_LIMIT设置为TRUE，概要文件才能强制执行资源限制。

在指定概要文件之后，DBA可以手工的将概要文件赋予每个用户。
但是概要文件不是立即生效，而是要将初始化参数文件中的参数 RESOURCE_LIMIT 设置为 TRUE 之后，
概要文件才会生效。

概要文件主要可以对数据库系统如下指标进行限制。
1）用户的最大并发会话数（SESSION_PER_USER)
2）每个会话的CPU时钟限制（CPU_PER_SESSION）
3）每次调用的CPU时钟限制，调用包含解析、执行命令和获取数据等等。（CPU_PER_CALL）
4）最长连接时间。一个会话的连接时间超过指定时间之后，Oracle会自动的断开连接（CONNECT_TIME）
5）最长空闲时间。如果一个会话处于空闲状态超过指定时间，Oracle会自动断开连接（IDLE_TIME）
6）每个会话可以读取的最大数据块数量（LOGICAL_READS_PER_SESSION）
7）每次调用可以读取的最大数据块数量（LOGICAL_READS_PER_CALL）
8）SGA私有区域的最大容量（PRIVATE_SGA）
概要文件对口令的定义和限制如下：
1）登录失败的最大尝试次数（FAILED_LOGIN_ATTEMPTS）
2）口令的最长有效期(PASSWORD_LIFE_TIME)
3）口令在可以重用之前必须修改的次数(PASSWORD_REUSE_MAX)
4）口令在可以重用之前必须经过的天数(PASSWORD_REUSE_TIME)
5）超过登录失败的最大允许尝试次数后，账户被锁定的天数
6）指定用于判断口令复杂度的函数名

FAILED_LOGIN_ATTEMPTS      ：当连续登陆失败次数达到该参数指定值时，用户被加锁；
                                DBA解锁(或PASSWORD_LOCK_TIME天)后可继续使用
PASSWORD_LIFE_TIME         ：口令的有效期（天），默认为UNLIMITED
PASSWORD_LOCK_TIME         ：帐户因FAILED_LOGIN_ATTEMPTS锁定时，加锁天数
PASSWORD_GRACE_TIME        ：口令修改的宽限期（天）
PASSWORD_REUSE_TIME        ：口令被修改后原有口令隔多少天被重新使用，默认为UNLIMITED
PASSWORD_REUSE_MAX         ：口令被修改后原有口令被修改多少次才允许被重新使用。
PASSWORD_VERIFY_FUNCTION   ：口令效验函数

1. 创建概要文件
CREATE PROFILE 概要文件名称 LIMIT 
CPU_PER_SESSION 100000 -- 100 秒
LOGICAL_READS_PER_CALL 2000 -- 2000 个数据块
CONNECT_TIME 60 -- 
IDLE_TIME 30 -- 无操作时间 30 分钟
SESSIONS_PER_USER 10 
FAILED_LOGIN_ATTEMPTS 3 
PASSWORD_LOCK_TIME UNLIMITED
PASSWORD_LIFE_TIME 60
PASSWORD_REUSE_TIME 30
PASSWORD_GRACE_TIME 6
PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION ;

2. 查看概要文件
SELECT * FROM dba_profiles WHERE PROFILE='PROFILE_NAME' ;

3. 为用户分配 概要文件
CREATE USER 用户名 INDENTIFIED BY 密码
PROFILE 概要文件名称 ;
4. 修改用户概要文件
ALTER USER 用户名 PROFILE 概要文件名称 ;

5. 删除概要文件
DROP PROFILE 概要文件名称 [CASCADE];

----------------------------------------------------------------------------------
三. 维护用户
1. 修改密码
ALTER USER 用户名 IDENTIFIED BY 密码 ;
2. 锁定状态
ALTER USER 用户名 ACCOUNT LOCK | UNLOCK;
3. 密码失效
ALTER USER 用户名 PASSWORD EXPIRE ;
4. 表空间配额
ALTER USER 用户名
QUOTA 20M ON system 
QUOTA 40M ON users ;

----------------------------------------------------------------------------------
四. 权限管理

1. 为用户授权
1.1 系统权限授权
GRANT 权限, ....
    TO [用户名,... | 角色名,.. | PUBLIC]
    [WITH ADMIN OPTION] ;
PUBLIC     所有用户
WITH ADMIN OPTION 使用户同样具有分配权限的权利，可将此权限授予别人
1.2 对象权限授权
对象授权
GRANT object_priv｜ALL [columns]
ON object
TO {user|role|PUBLIC}
[WITH GRANT OPTION]
ALL：所有对象权
PUBLIC：授给所有的用
WITH GRANT OPTION：允许用户再次给其它用户授
--- 示例
GRANT SELECT ON emp TO robinson;
-- 为user2 授权 user1 的 table1 表的查询、添加权限
GRANT SELECT, INSERT ON user1.table1 TO user2 ;
-- 为user2 授权 user1 的 table1 表的更新字段 fiel1 权限
GRANT update(fiel1) ON user1.table1 TO user2 ;

2. 回收权限
REVOKE 权限 FROM 用户名 ;

3. 查看权限
查看系统权限
dba_sys_privs  --针对所有用户被授予的系统权
user_sys_privs --针对当前登陆用户被授予的系统权

4. 系统权限
常用的系统权限：
CREATE SESSION          创建会话
CREATE SEQUENCE         创建序列
CREATE SYNONYM          创建同名对象
CREATE TABLE            在用户模式中创建表
CREATE ANY TABLE        在任何模式中创建表
DROP TABLE              在用户模式中删除表
DROP ANY TABLE          在任何模式中删除表
CREATE PROCEDURE        创建存储过程
EXECUTE ANY PROCEDURE   执行任何模式的存储过程
CREATE USER             创建用户
DROP USER               删除用户
CREATE VIEW             创建视图

5. 对象权限
修改(alter)      
删除(delete)
执行(execute)            
索引(index)
插入(insert)
关联(references)
选择(select)
更新(update)

6. 权限管理数据字典
ROLE_SYS_PRIVS           角色拥有的系统权限
ROLE_TAB_PRIVS           角色拥有的对象权限 
USER_TAB_PRIVS_MADE      查询授出去的对象权限(通常是属主自己查）
USER_TAB_PRIVS_RECD      用户拥有的对象权限 
USER_COL_PRIVS_MADE      用户分配出去的列的对象权限
USER_COL_PRIVS_RECD      用户拥有的关于列的对象权限 
USER_SYS_PRIVS           用户拥有的系统权限
USER_TAB_PRIVS           用户拥有的对象权限
USER_ROLE_PRIVS          用户拥有的角色  

-----------------------------------------------------------------------
五. 角色管理
1. 创建角色
CREATE ROLE 角色名称 [NOT IDENTIFIED | INDENTIFIED BY 密码] ; 

2. 角色的授权
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE TO 角色名称 ;

3. 为用户授予角色
GRANT 角色名称[, 多个角色...] TO 用户名称 ;

4. 角色回收权限
REVOKE 权限 FROM 角色名称 ;

5. 删除角色
DROP ROLE 角色名称 ;

6. 默认的角色
CONNECT自动建立，包含以下权限：ALTER SESSION、CREATE CLUSTER、CREATE DATABASELINK、CREATE SEQUENCE、CREATE SESSION、CREATE SYNONYM、CREATE TABLE、CREATEVIEW。
RESOURCE自动建立，包含以下权限：CREATE CLUSTER、CREATE PROCEDURE、CREATE SEQUENCE、CREATE TABLE、CREATE TRIGGR。

7. 角色管理的数据字典
ROLE_SYS_PRIVS
ROLE_TAB_PRIVS
ROLE_ROLE_PRIVS
SESSION_ROLES
USER_ROLE_PRIVS
DBA_ROLES