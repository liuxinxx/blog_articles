#### 创建索引

```sql
CREATE UNIQUE INDEX** name **ON** table (column [, ...]);
```
如果索引声明为唯一索引，那么就不允许出现多个索引值相同的行。我们认为NULL值相互间不相等。



#### 查看索引

```sql
select * from pg_indexes where tablename='log';

或

select * from pg_statio_all_indexes where relname='log';
```

