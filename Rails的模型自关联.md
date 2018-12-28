```
tags:rails
```
关于Rails的模型自关联有一个非常有意思的题目，大概是这样的：

```ruby
lisa = Person.create(name:'Lisa')
tom = Person.create(name:'Tom',parent_id:lisa.id)
andy = Person.create(name:'Andy',parent_id:lisa.id)
tom.parent.name => 'Lisa'
lisa.children.map(&:name) => ['Tom','Andy']

thomas = Person.create(name: 'Thomas',parent_id: tom.id)
peter = Person.create(name:'Peter',parent_id:tom.id)
gavin = Person.create(name:'Gavin', parent_id: andy.id)
lisa.grandchildren.map(&:name) => ['Thomas','Peter','Gavin']
```
<!--more-->
问如何定义Person模型来满足以上需求？

题目考察了对模型自关联的理解，通过审题我们可以得出以下几点：

- Person对象的Parent同样是Person对象（自关联）
- Person对象对Parent是多对一关系
- Person对象对Children是一对多关系
- Person对象通过Children与GrandChildren建立了一对多关系

在不考虑GrandChildren时，不难得出模型定义如下：

```ruby
class Person < ActiveRecord::Base 
  belongs_to :parent, class_name: 'Person', foreign_key: 'parent_id' 
  has_many :children, class_name: 'Person', foreign_key: 'parent_id' 
end
```

其中Person包含两个自关联关系：

- 第一个就是非常常见的从子到父的关系，在Person对象创建时指定parent_id来指向父对象；
- 第二个关系用来指定Person对象对应的所有子对象

接下来更近一步，我们要找到Person对象子对象的子对象，换句话说：孙子对象。
 如我们上面的分析，Person对象通过Children与GrandChildren建立了一对多关系，其代码表现为：

```ruby
has_many :grandchildren, :through => :children, :source => :children
```

`:source`选项的官方文档说明如下：

> The :source option specifies the source association name for a has_many :through association. You only need to use this option if the name of the source association cannot be automatically inferred from the association name.  —— rails guide

在这里我们通过`:source`选项告诉Rails在children对象上查找children关联关系。
 于是该题目完整的模型定义如下：

```ruby
class Person < ActiveRecord::Base
  belongs_to :parent, class_name: 'Person', foreign_key: 'parent_id'
  has_many :children, class_name: 'Person', foreign_key: 'parent_id'
  has_many :grandchildren, :through => :children, :source => :children
end
```

![4269060-a288206187bfe563](http://pd8738g5p.bkt.clouddn.com/2018-08-15-035939.png)

 

 

 

 

 