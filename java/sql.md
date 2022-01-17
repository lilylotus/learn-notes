## SQL 优化

### 利用延迟关联或子查询优化超多分页场景

MySQL 并不会跳过 offset 行，而是取 offset + N 行，然后返回丢掉前 offset 行，返回 N 行，于是当 offset 特别大时，效率就非常底下了。

```sql
-- 优化前
SELECT 多个字段 FROM table_name WHERE 各种条件 LIMIT 0, 10;

-- 优化后
SELECT 多个字段 FROM table_name main_table INNER JOIN (
	SELECT 子查询只查主键
    FROM table_name
    WHERE 各个条件
    LIMIT 0, 10
) temp_table ON temp_table.主键 = main_table.主键;
```

