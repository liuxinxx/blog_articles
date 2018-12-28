```
tags:rails,joins
```
##### 由于模型关联我们可以很快速自然的拿到我们想要的数据

## 联结表

Active Record 提供了 `joins` 和 `left_outer_joins` 这两个查找方法，用于指明生成的 SQL 语句中的 `JOIN` 子句。其中，`joins` 方法用于 `INNER JOIN` 查询或定制查询，`left_outer_joins` 用于 `LEFT OUTER JOIN` 查询。
<!--more-->
#### `joins` 方法

`joins` 方法有多种用法。使用字符串 SQL 片段

在 `joins` 方法中可以直接用 SQL 指明 `JOIN` 子句：

```ruby
Author.joins("INNER JOIN posts ON posts.author_id = authors.id AND posts.published = 't'")
```

上面的代码会生成下面的 SQL 语句：

```ruby
SELECT authors.* FROM authors INNER JOIN posts ON posts.author_id = authors.id AND posts.published = 't'
```

## 使用具名关联数组或散列

使用 `joins` 方法时，Active Record 允许我们使用在模型上定义的关联的名称，作为指明这些关联的 `JOIN` 子句的快捷方式。

例如，假设有 `Category`、`Article`、`Comment`、`Guest` 和 `Tag` 这几个模型：

```ruby
class Category < ApplicationRecord
  has_many :articles
end
 
class Article < ApplicationRecord
  belongs_to :category
  has_many :comments
  has_many :tags
end
 
class Comment < ApplicationRecord
  belongs_to :article
  has_one :guest
end
 
class Guest < ApplicationRecord
  belongs_to :comment
end
 
class Tag < ApplicationRecord
  belongs_to :article
end
```

下面几种用法都会使用 `INNER JOIN` 生成我们想要的关联查询。

### 单个关联的联结

```ruby
Category.joins(:articles)
```

上面的代码会生成下面的 SQL 语句：

```ruby
SELECT categories.* FROM categories
  INNER JOIN articles ON articles.category_id = categories.id
```

这个查询的意思是把所有包含了文章的（非空）分类作为一个 `Category` 对象返回。请注意，如果多篇文章同属于一个分类，那么这个分类会在 `Category` 对象中出现多次。要想让每个分类只出现一次，可以使用 `Category.joins(:articles).distinct`。

###多个关联的联结

```ruby
Article.joins(:category, :comments)
```

上面的代码会生成下面的 SQL 语句：

```sql
SELECT articles.* FROM articles
  INNER JOIN categories ON articles.category_id = categories.id
  INNER JOIN comments ON comments.article_id = articles.id
```

这个查询的意思是把所有属于某个分类并至少拥有一条评论的文章作为一个 `Article` 对象返回。同样请注意，拥有多条评论的文章会在 `Article` 对象中出现多次。

### 单层嵌套关联的联结

```ruby
Article.joins(comments: :guest)
```

上面的代码会生成下面的 SQL 语句：

```sql
SELECT articles.* FROM articles
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
```

这个查询的意思是把所有拥有访客评论的文章作为一个 `Article` 对象返回。

### 多层嵌套关联的联结

```ruby
Category.joins(articles: [{ comments: :guest }, :tags])
```

上面的代码会生成下面的 SQL 语句：

```sql
SELECT categories.* FROM categories
  INNER JOIN articles ON articles.category_id = categories.id
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
  INNER JOIN tags ON tags.article_id = articles.id
```

这个查询的意思是把所有包含文章的分类作为一个 `Category` 对象返回，其中这些文章都拥有访客评论并且带有标签。

### 为联结表指明条件

可以使用普通的数组和字符串条件作为关联数据表的条件。但如果想使用散列条件作为关联数据表的条件，就需要使用特殊语法了：

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where('orders.created_at' => time_range)
```

还有一种更干净的替代语法，即嵌套使用散列条件：

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where(orders: { created_at: time_range })
```

这个查询会查找所有在昨天创建过订单的客户，在生成的 SQL 语句中同样使用了 `BETWEEN` SQL 表达式。

### `left_outer_joins` 方法

如果想要选择一组记录，而不管它们是否具有关联记录，可以使用 `left_outer_joins` 方法。

```ruby
Author.left_outer_joins(:posts).distinct.select('authors.*, COUNT(posts.*) AS posts_count').group('authors.id')
```

上面的代码会生成下面的 SQL 语句：

```sql
SELECT DISTINCT authors.*, COUNT(posts.*) AS posts_count FROM "authors"
LEFT OUTER JOIN posts ON posts.author_id = authors.id GROUP BY authors.id
```

这个查询的意思是返回所有作者和每位作者的帖子数，而不管这些作者是否发过帖子。

## 加载大量数据时

```ruby
User.post.all
# 获取用户的所有post
```

特别方便自然，但是当数据量过大的时候就有有问题

##### N+1查询的问题

假设有如下代码，查找 10 条客户记录并打印这些客户的邮编：

```ruby
clients = Client.limit(10)
 
clients.each do |client|
  puts client.address.postcode
end
```

这段代码看起来没什么问题，但是实际查询次数很高。这段代码总共执行1(查找所有记录)+10(每个post的title) = 11次查询

###### n+1问题的解决办法

Active Record 允许我们提前指明需要加载的所有关联，这是通过在调用 `Model.find` 时指明 `includes` 方法实现的。通过指明 `includes` 方法，Active Record 会使用尽可能少的查询来加载所有已指明的关联。

回到之前 N + 1 查询问题的例子，我们重写其中的 `Client.limit(10)` 来使用及早加载：

```ruby
clients = Client.includes(:address).limit(10)
 
clients.each do |client|
  puts client.address.postcode
end
```

上面的代码只执行 2 次查询，而不是之前的 11 次查询：

```sql
SELECT * FROM clients LIMIT 10
SELECT addresses.* FROM addresses
  WHERE (addresses.client_id IN (1,2,3,4,5,6,7,8,9,10))
```

##### 当然也可以同时加载多个关联

```ruby
Article.includes(:category, :comments)
```

##### 嵌套关联的散列

```ruby
Category.includes(articles: [{ comments: :guest }, :tags]).find(1)
```

上面的代码会查找 ID 为 1 的分类，并及早加载所有关联的文章、这些文章关联的标签和评论，以及这些评论关联的访客。

##### 为关联的及早加载指明条件

尽管 Active Record 允许我们像 `joins` 方法那样为关联的及早加载指明条件，但推荐的方式是使用[联结](https://ruby-china.github.io/rails-guides/active_record_querying.html#joining-tables)。

尽管如此，在必要时仍然可以用 `where` 方法来为关联的及早加载指明条件。

```ruby
Article.includes(:comments).where(comments: { visible: true })
```

上面的代码会生成使用 `LEFT OUTER JOIN` 子句的 SQL 语句，而 `joins` 方法会成生使用 `INNER JOIN` 子句的 SQL 语句。

```sql
SELECT "articles"."id" AS t0_r0, ... "comments"."updated_at" AS t1_r5 FROM "articles" LEFT OUTER JOIN "comments" ON "comments"."article_id" = "articles"."id" WHERE (comments.visible = 1)
```

## 多表联合检索

Active Record 实现[方法链](http://en.wikipedia.org/wiki/Method_chaining)的方式既简单又直接，有了方法链我们就可以同时使用多个 Active Record 方法。

当之前的方法调用返回 `ActiveRecord::Relation` 对象时，例如 `all`、`where` 和 `joins` 方法，我们就可以在语句中把方法连接起来。返回单个对象的方法（请参阅 [检索单个对象](https://ruby-china.github.io/rails-guides/active_record_querying.html#retrieving-a-single-object)）必须位于语句的末尾。

下面给出了一些例子。本文无法涵盖所有的可能性，这里给出的只是很少的一部分例子。在调用 Active Record 方法时，查询不会立即生成并发送到数据库，这些操作只有在实际需要数据时才会执行。下面的每个例子都会生成一次查询。

##### 从多个数据表中检索过滤后的数据

```ruby
Person
  .select('people.id, people.name, comments.text')
  .joins(:comments)
  .where('comments.created_at > ?', 1.week.ago)
```

上面的代码会生成下面的 SQL 语句：

```sql
SELECT people.id, people.name, comments.text
FROM people
INNER JOIN comments
  ON comments.person_id = people.id
WHERE comments.created_at > '2015-01-01'
```

##### 从多个数据表中检索特定的数据

```ruby
Person
  .select('people.id, people.name, companies.name')
  .joins(:company)
  .find_by('people.name' => 'John') # this should be the last
```

上面的代码会生成下面的 SQL 语句：

```sql
SELECT people.id, people.name, companies.name
FROM people
INNER JOIN companies
  ON companies.person_id = people.id
WHERE people.name = 'John'
LIMIT 1
```

### 批量检索多个对象

我们常常需要遍历大量记录，例如向大量用户发送时事通讯、导出数据等。

处理这类问题的方法看起来可能很简单：

```ruby
# 如果表中记录很多，可能消耗大量内存
User.all.each do |user|
  NewsMailer.weekly(user).deliver_now
end
```

但随着数据表越来越大，这种方法越来越行不通，因为 `User.all.each` 会使 Active Record 一次性取回整个数据表，为每条记录创建模型对象，并把整个模型对象数组保存在内存中。事实上，如果我们有大量记录，整个模型对象数组需要占用的空间可能会超过可用的内存容量。

Rails 提供了两种方法来解决这个问题，两种方法都是把整个记录分成多个对内存友好的批处理。第一种方法是通过 `find_each` 方法每次检索一批记录，然后逐一把每条记录作为模型传入块。第二种方法是通过 `find_in_batches` 方法每次检索一批记录，然后把这批记录整个作为模型数组传入块。

> `find_each` 和 `find_in_batches` 方法用于大量记录的批处理，这些记录数量很大以至于不适合一次性保存在内存中。如果只需要循环 1000 条记录，那么应该首选常规的 `find` 方法。



#####  `find_each` 方法

`find_each` 方法批量检索记录，然后逐一把每条记录作为模型传入块。在下面的例子中，`find_each` 方法取回 1000 条记录，然后逐一把每条记录作为模型传入块。

```ruby
User.find_each do |user|
  NewsMailer.weekly(user).deliver_now
end
```

这一过程会不断重复，直到处理完所有记录。

如前所述，`find_each` 能处理模型类，此外它还能处理关系：

```ruby
User.where(weekly_subscriber: true).find_each do |user|
  NewsMailer.weekly(user).deliver_now
end
```

前提是关系不能有顺序，因为这个方法在迭代时有既定的顺序。

如果接收者定义了顺序，具体行为取决于 `config.active_record.error_on_ignored_order`旗标。设为 `true` 时，抛出 `ArgumentError` 异常，否则忽略顺序，发出提醒（这是默认设置）。这一行为可使用 `:error_on_ignore` 选项覆盖。