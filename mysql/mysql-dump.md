####  Mysql 数据库脚本备份

1. 备份 db 数据库中的所有表结构和数据，<font color="blue">不包括</font> db 库创建语句。
   `mysqldump -h127.0.0.1 -P3306 -uroot -p db > xxx.sql`
2. 备份 db 数据库中的所有表结构和数据，<font color="blue">包括</font> db 库创建语句。
   `mysqldump -h127.0.0.1 -P3306 -uroot -p --databases db > xxx.sql`
3. 备份 db 数据库中指定表结构和数据，<font color="blue">不包括</font> db 库创建语句。
   `mysqldump -h127.0.0.1 -P3306 -uroot -p db t1 t2 t3 > xxx.sql`
4. 备份 多个 数据库中的所有表结构和数据，<font color="blue">包括</font> db 库创建语句。
   `mysqldump -h127.0.0.1 -P3306 -uroot -p --databases db1 db2 db3 > xxx.sql`
5. 备份 所有 数据库，包括建库语句和所有表的结构和数据
   `mysqldump -h127.0.0.1 -P3306 -uroot -p --all-databases > xxx.sql`
6. 仅备份 db 数据库中所有表结构，只有表结构没有数据，(-d 参数)
   `mysqldump -h127.0.0.1 -P3306 -uroot -p -d db > xxx.sql`
7. 仅备份 db 数据库中 指定表 的表结构，只有表结构没有数据，(-d 参数)
   `mysqldump -h127.0.0.1 -P3306 -uroot -p -d db t1 t2 t3 > xxx.sql`
8. 仅备份 db 数据库中所有表的数据，只有表数据没有表结构，(-t 参数)
   `mysqldump -h127.0.0.1 -P3306 -uroot -p -t db > xxx.sql`
9. 仅备份 db 数据库中 指定表 的表数据，只有表数据没有表结构，(-t 参数)
   `mysqldump -h127.0.0.1 -P3306 -uroot -p -t db t1 t2 t3 > xxx.sql`

##### 小结

* `--databases db db1 db2` 备份指定数据库中所有的表结构/数据，包括建库语句
* `db [table t2 t3]` 备份指定库[指定表] 的表结构/数据，不包括建表语句
* `-d` 仅包含建表数据结构语句
* `-t` 仅包含数据没有结构

#### 数据还原

到指定数据库中还原

```sql
use db;
source D:\db.sql
```

在终端命令行还原

```sql
mysql -h127.0.0.1 -P3306 -uroot -p recover_db < xxx.sql
```

> 备份使用 `mysqldump`，还原使用 `mysql`