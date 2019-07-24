```
tags:mysql
```

* 检查“数据库日志”是否开启：
  ```sql
  SHOW VARIABLES LIKE 'general%';
  ```
* 开启日志
  ```sql
  SET GLOBAL general_log='ON';
  ```
* 慢查询日志”，检查是否开启：
  ```sql
  SHOW VARIABLES LIKE '%slow_query_log%';
  ```
* 开启慢查询日志
  ```
  SET GLOBAL slow_query_log='ON';
  ```
> 日志位置
> linux : `/var/lib/mysql/`
> win: `C:\ProgramData\MySQL\MySQL Server 5.7\Data`
* 查看当前数据库的事务隔离级别：
```sql
show variables like 'tx_isolation';
```

