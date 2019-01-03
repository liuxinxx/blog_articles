```
tags:rails
source_url:https://ruby-china.org/topics/29562
source_title:ActiveRecord 用 bulk_insert 来批量插入数据，提高效率
```



实际的项目环境中，我们时常会有一次动作写入多条数据的场景，比如导数据，创建通知、Event 给多个人...

简单做法可能大家会直接循环插入

```ruby
receiver_ids.each do |user_id|
  Event.create(user_id: user_id, event_type: 'test')
end
```

或者你可能会在外面包个 transaction 来减少 Commit 次数，从而微微的提速，但还是有 N 次数据库的调用

```ruby
Event.transaction do
 receiver_ids.each do |user_id|
   Event.create(user_id: user_id, event_type: 'test')
 end
end
```

或者你还知道 SQL 批量插入的方法:

```sql
INSERT INTO events (event_type, user_id) VALUES("test", 2),("test", 5),("test", 8) ...;
```

ref: [MySQL](https://dev.mysql.com/doc/refman/5.5/en/optimizing-innodb-bulk-data-loading.html), [PostgreSQL](http://www.postgresql.org/docs/8.4/static/dml-insert.html)

关于第三种方式，有 Gem 帮助我们简单来实现：

<https://github.com/jamis/bulk_insert>

```ruby
# Gemfile
gem 'bulk_insert'
```

然后我们就可以用了：

```ruby
Event.bulk_insert(set_size: 100) do |worker|
  receiver_ids.each do |user_id|
    worker.add({ user_id: user_id, event_type: 'test' })
  end
end
```

### 相关链接

* <https://github.com/jamis/bulk_insert>
* <https://github.com/ruby-china/ruby-china/pull/598> - Ruby China 的通知批量插入，使用 bulk_insert 的例子
* <https://dev.mysql.com/doc/refman/5.5/en/optimizing-innodb-bulk-data-loading.html>
* <http://www.postgresql.org/docs/8.4/static/dml-insert.html>