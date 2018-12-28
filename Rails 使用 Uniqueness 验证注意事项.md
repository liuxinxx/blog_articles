```
tags:rails
```
在 Rails 应用中使用 [uniqueness validations](https://link.jianshu.com?t=http://guides.rubyonrails.org/active_record_validations.html#uniqueness) 比较常见，用以校验字段唯一性。当数据库记录出现重复时，这种校验提供了很好的用户体验，但是单纯地在 Rails 应用层做校验还是不会确保数据完整性

### 会出现什么问题呢

首先开始看一个简单的 User 类

```ruby
class User
  validates :email, presence: true, uniqueness: true
end
```
<!--more-->
当你开始实例化一个用户对象时，Rails 就会通过给定的 `email`,使用执行 `SELECT` 语句查询数据库中是否存在该记录。假设校验通过，Rails 就会执行 `INSERT` 语句把实例化的用户对象持久化到数据库。在开发环境或者使用了单进程单实例的 web 服务器的生产环境中不会出现任何问题。
 但是在生产环境中 WEBrick 跑一个实例很少见。多连接，高并发多进程且一个 Rails 应用部署在多台机器为常态。在例子中，当同一个 email 被两个进程同时处理时会发生什么？

![img](//upload-images.jianshu.io/upload_images/18473-ed1914fd0991ae91.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/500)

unique_without_index

 

原意想校验 email 唯一性，但相同的 email 被不同的进程同时处理时，都会成功保存在数据库中。所以，校验不仅仅要发生在 Rails 应用层，在数据库层也要校验。

### 数据库唯一性索引

Rails 给数据库建唯一性索引有两种方式

- 添加迁移时

```ruby
class AddEmailIndexToUser
  def change
    # If you already have non-unique index on email, you will need
    # to remove it before you're able to add the unique index.
    add_index :users, :email, nul: false, unique: true
  end
end
```

- 添加 model 时

```ruby
rails generate model user email:string:uniq
```

- migration 新建数据库表时

```ruby
class CreateFoos < ActiveRecord::Migration
    def change
      create_table :users do |t|
        t.string :email, :null => false
        t.index :email, unique: true
      end
    end
end
```

有了数据库唯一性索引之后，再次重现上述两个进程同时处理插入相同 email 操作

![img](//upload-images.jianshu.io/upload_images/18473-126fbeedd960daa0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/500)

unique_with_index

 

```ruby
ActiveRecord::RecordNotUnique
```

rescue_from

 

```ruby
rescue_from ActiveRecord::RecordNotUnique do |exception|
  render_404
end
```

### 数据库唯一性索引还能干嘛

对于 [has_one](https://link.jianshu.com?t=http://guides.rubyonrails.org/association_basics.html#the-has-one-association) 关系，只是表明了起只处理一个对象而不是一个集合，本身并不确保数据完整性。
 例如，在一个 Rails 应用中有一个 `Profile` model, 一个用户只有一个 profile 对象。

```ruby
class User
  has_one :profile
  validates :email, presence: true, uniqueness: true
end

class Profile
  belongs_to :user
end
```

我们期望 `profiles`表中的记录，`user_id`的值是唯一的，不能重复，但是 `has_one`做不到。所以我们需要在 profiles 表中给 `user_id` 字段添加唯一性索引。

### 如何在 Rails 应用中找出缺失的唯一性索引

索引有利有弊，利于查询弊于更新且占用存储空间。但是在一些必要的情况下，我们如何快速监测出那里缺失了建立索引呢？
 你可以全局搜索项目中的 `validates_uniqueness_of`, `uniqueness`, `uniqueness`  关键字，这些地方对应的字段都需要在数据库中建立唯一性索引。或者，你可以使用 [Consistency Fail](https://link.jianshu.com?t=https://github.com/trptcolin/consistency_fail)，这个工具帮助监测 Rails 应用中缺失的唯一性索引，其更多使用请查看 README
 使用 `consistency_fail`一个可知的缺点就是其不能识别 `has_one`的多态。
 例如

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_one :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_one :pictures, as: :imageable
end
```

正常来说应建唯一索引：

```ruby
class CreatePictures < ActiveRecord::Migration[5.0]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.integer :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

但是 consistency_fail 的提示却只有

```ruby
add_index :pictures, [:imageable_id]
```

另外，如果迁移数据库的多态是这样写的话

```ruby
class CreatePictures < ActiveRecord::Migration[5.0]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
```

则不要担心唯一性索引没有`imageable_type`的问题。

 

 

 

 

 