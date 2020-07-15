desc dba_users
select username from dba_users
connect scott/tigger
-------------------------------
create temporary tablespace ORCL_TMP tempfile 'D:\app\dump\ORCL_TMP.DBF' size 100M autoextend on next 50M maxsize unlimited extent management local ;
create tablespace ORCL_DATA logging datafile 'D:\app\dump\ORCL_DATA.DBF' size 100M autoextend on next 50M maxsize unlimited extent management local ;
create user scott_lily identified by lily account unlock default tablespace ORCL_DATA temporary tablespace ORCL_TMP;

创建用户之前要创建"临时表空间"，若不创建则默认的临时表空间为temp
CREATE TEMPORARY TABLESPACE DB_TEMP TEMPFILE 'D:\app\dump\NewDBDB_TEMP.DBF'
SIZE 32M AUTOEXTEND ON NEXT 32M MAXSIZE 10240M [UNLIMITED] EXTENT MANAGEMENT LOCAL;

创建用户之前先要创建数据表空间，若没有创建则默认永久性表空间是system。
CREATE TABLESPACE DB_DATA LOGGING DATAFILE 'D:\app\dump\DBDB_DATA.DBF'
SIZE 32M AUTOEXTEND ON NEXT 32M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;

其中'DB_DATA'和'DB_TEMP'是你自定义的数据表空间名称和临时表空间名称，可以任意取名；
是数据文件的存放位置，'DB_DATA.DBF'文件名也是任意取；'size 32M'是指定该数据文件的大小，也就是表空间的大小。


现在建好了名为'DB_DATA'的表空间，下面就可以创建用户了：
CREATE USER NEWUSER IDENTIFIED BY BD123 ACCOUNT UNLOCK
DEFAULT TABLESPACE DB_DATA TEMPORARY TABLESPACE DB_TEMP;

默认表空间'DEFAULT TABLESPACE'使用上面创建的表空间名：DB_DATA。
临时表空间'TEMPORARY TABLESPACE'使用上面创建的临时表空间名:DB_TEMP。

接着授权给新建的用户：
GRANT CONNECT,RESOURCE TO NEWUSER;  --表示把 connect,resource权限授予news用户
GRANT DBA TO NEWUSER;  --表示把 dba权限授予给NEWUSER用户,授权成功。

-------------------------------
表空间：数据库的逻辑存储空间，可以理解为在数据库中开辟的空间用来存储数据库对象;
表空间和数据文件的关系：表空间由一个或多个数据文件组成;数据文件的大小和位置可以自己定义;
表空间的分类：
    永久表空间：数据库中要永久化存储的一些对象，如：表、视图、存储过程
    临时表空间：数据库操作当中中间执行的过程，执行结束后，存放的内容会被自动释放
    UNDO表空间：用于保存事务所修改数据的旧值，可以进行数据的回滚

查看用户的表空间：
数据字典
dba_tablespaces (系统管理员级别查看的数据字典)
user_tablespaces (普通用户查看的数据字典)

查看表空间的字段    desc dba_tablespaces
查看有几个表空间    select tablespace_name from dba_tablespaces;
查看用户的字段信息   desc dba_users
查看用户的默认表空间、临时表空间等等  select default_tablespace from dba_users where username=’SYS’;

设置用户的默认或临时表空间   alter user username default|tempporart tablespace tablespace_name;
备注：普通用户没有设置表空间的权限

创建、修改、删除表空间
创建表空间
create [temporary] tablespace tablespace_name tempfile|datafile ‘xx.dbf’ size xx;

备注：如果创建的是临时表空间，需要加上temporary关键字;
查看表空间的具体路径：(通过dba_data_files 和 dba_temp_files这个数据字典)
desc dba_data_files
select file_name from dba_data_files where tablespace_name=”;(条件是表空间的名字,需要大写)

修改表空间的状态
设置联机或脱机的状态(表空间是脱机时不可用，默认是联机的)
alter tablespace tablespace_name online|offline;
如何知道表空间所处的状态？(通过这个dba_tablespaces数据字典)
desc dba_tablespaces
select status from dba_tablespaces where tablespace_name=”;(条件是表空间的名字,需要大写)
设置只读或可读写的状态(只有在联机状态才可以更改,默认的联机状态就是读写状态)
alter tablespace tablespace_name read only | read write;

修改数据文件
增加数据文件
alter tablespace tablespace_name add datafile ‘xx.dbf’ size xx;
select file_name from dba_data_files where tablespace_name=”;(条件是表空间的名字,需要大写)
备注：通过这条select语句就查询到当前表空间中的数据文件

删除数据文件(不能删除表空间当中第一个数据文件，如果要删除就需要删除整个表空间)
alter tablespace tablespace_name drop datafile ‘xx.dbf’;
删除表空间
drop tablespace tablespace_name[including contents];
备注：如果只是删除表空间不删除该表空间下的数据文件，则不加including contents;
