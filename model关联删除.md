```
tags:rails
```
#### 示例

```ruby
has_many :user_red_bag_relationships,dependent: :destroy
```
<!--more-->
这是 has_one 和 has_many 上的用法：

| 参数                     | 含义                                                         |
| ------------------------ | ------------------------------------------------------------ |
| :destroy                 | 删除拥有的资源                                               |
| :delete                  | 直接发送删除命令，不会执行回调                               |
| :nullify                 | 将拥有的资源外键设为 null                                    |
| :restrict_with_exception | 如果拥有资源，会抛出异常，也就是说，当它 has_one 为 nil 或 has_many 为 [] 的时候，才能正常删除它自己 |
| :restrict_with_error     | 如有拥有资源，会增加一个 errors 信息。                       |

我用 `restrict_with_error`，先删子资源，再删上一级。

在 belongs_to 上，也可以设置 dependent，但它只有两个参数：

| 参数     | 含义                                             |
| -------- | ------------------------------------------------ |
| :destroy | 删除它所属的资源                                 |
| :delete  | 删除它所属的资源，直接发送删除命令，不会执行回调 |