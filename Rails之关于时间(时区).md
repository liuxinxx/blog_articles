```
tags:rails
```
[It’s About Time (Zones)](https://robots.thoughtbot.com/its-about-time-zones)

这是时间系列的第一篇文章。第二篇的主题是 [a case study in multiple time zones](http://robots.thoughtbot.com/a-case-study-in-multiple-time-zones)。

Ruby提供了两个类来管理时间：[`Time`](http://ruby-doc.org/core-2.2.2/Time.html)和[`DateTime`](http://ruby-doc.org/stdlib-2.0.0/libdoc/date/rdoc/DateTime.html)。Ruby1.9.3之后两者之间的区别越来越小。鉴于`Time`包含闰秒和夏令时的概念。本文中，我们将使用`Time`来举例。 
[TZInfo](https://tzinfo.github.io/)是一个时区库，提供不同时区的夏令时转换。它被封装成了gem并且包含582个不同时区的数据。
<!--more-->
### Rails中的时区

Rails中的[ActiveSupport::TimeZone](http://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html)封装了TZInfo，并提供其中146个时区的数据以及更好的时区格式（例如：用`Eastern Time (US & Canada)`替换`America/New_York`）。另外配合 [ActiveSupport::TimeWithZone](http://api.rubyonrails.org/classes/ActiveSupport/TimeWithZone.html)，Rails提供和Ruby中`Time`类一样的API，所以`Time`和`ActiveSupport::TimeWithZone`是可以互换的，你永远都不需要直接创建一个`TimeWithZone`实例（new） 
执行以下命令查看Rails中所有可用的时区：

```ruby
$ rake time:zones:all
* UTC -11:00 *
American Samoa
International Date Line West
Midway Island
Samoa

* UTC -10:00 *
Hawaii

* UTC -09:00 *
Alaska
...12345678910111213
```

在console中查看当前时区：

```ruby
> Time.zone
=> #<ActiveSupport::TimeZone:0x007fbf46947b38
 @current_period=#<TZInfo::TimezonePeriod: nil,nil,#<TZInfo::TimezoneOffset: 0,0,UTC>>>,
 @name="UTC",
 @tzinfo=#<TZInfo::TimezoneProxy: Etc/UTC>,
 @utc_offset=nil>123456
```

或临时设置时区：

```ruby
# in console
> Time.zone = "Perth"12
```

或在配置文件`config/application.rb`中永久修改项目时区：

```ruby
# config/application.rb
config.time_zone = "Perth"12
```

Rails的默认时区是UTC。最好就保留项目时区为UTC，让用户自己去设置他们各种的时区，下一篇文章[a case study in multiple time zones](http://robots.thoughtbot.com/a-case-study-in-multiple-time-zones) 详述了这么做的原因。

### 用户的时区

假设每个用户都拥有自己的时区。这个可以通过向User表添加time_zone属性实现：

```ruby
create_table :users do |t|
  t.string :time_zone, default: "UTC"
  ...
end1234
```

将时区保存为字符串形式是因为Rails中大多数时区相关方法都接受字符串。因此，应该避免将时区保存为`:enums` 格式。 
用户可以设置自己想要的时区。[SimpleForm](https://github.com/plataformatec/simple_form#priority)支持`:time_zone`，并且提供了一个help方法让用户可以在下拉框中选择时区。

```ruby
<%= f.input :time_zone %>1
```

可以在`ApplicationController`中使用`around_action`来应用用户设置的时区。

```ruby
# app/controllers/application_controller.rb
around_action :set_time_zone, if: :current_user

private

def set_time_zone(&block)
  Time.use_zone(current_user.time_zone, &block)
end12345678
```

我们将用户的时区信息传递给`Time.use_zone`（ActiveSupport提供的方法）。该方法需要传递一个块，在块的范围内设置时区。所以它只影响一次请求，请求结束之后使用的还是原始时区（应用默认时区）。 
在Rails 3.2.13及更低版本中，需要使用`around_filter`替代`around_action`。 
最后，在展示时区时，可以使用`in_time_zone`方法：

```ruby
<%= time.in_time_zone(current_user.time_zone) %>1
```

### 相关API

操作API时最好使用ISO8601标准，该标准用字符串表示日期时间。ISO8601的优点是清晰，可读，广泛支持并且是按规则排序的。示例：

```ruby
> timestamp = Time.now.utc.iso8601
=> "2015-07-04T21:53:23Z"12
```

结尾处的Z代表UTC时间，可以使用以下方法将字符串转为时间对象：

```ruby
> Time.iso8601(timestamp)
=> 2015-07-04 21:53:23 UTC12
```

### 三个时区

在一个Rails应用中，存在三个不同的时区：

- 系统时间
- 应用时间
- 数据库时间

假设我们将时区设为Fiji，来看下结果：

```ruby
# This is the time on my machine, also commonly described as "system time"
> Time.now
=> 2015-07-04 17:53:23 -0400

# Let's set the time zone to be Fiji
> Time.zone = "Fiji"
=> "Fiji"

# But we still get my system time
> Time.now
=> 2015-07-04 17:53:37 -0400

# However, if we use `zone` first, we finally get the current time in Fiji
> Time.zone.now
=> Sun, 05 Jul 2015 09:53:42 FJT +12:00

# We can also use `current` to get the same
> Time.current
=> Sun, 05 Jul 2015 09:54:17 FJT +12:00

# Or even translate the system time to application time with `in_time_zone`
> Time.now.in_time_zone
=> Sun, 05 Jul 2015 09:56:57 FJT +12:00

# Let's do the same with Date (we are still in Fiji time, remember?)
# This again is the date on my machine, system date
> Date.today
=> Sat, 04 Jul 2015

# But going through `zone` again, and we are back to application time
> Time.zone.today
=> Sun, 05 Jul 2015

# And gives us the correct tomorrow according to our application's time zone
> Time.zone.tomorrow
=> Mon, 06 Jul 2015

# Going through Rails' helpers, we get the correct tomorrow as well
> 1.day.from_now
=> Mon, 06 Jul 2015 10:00:56 FJT +12:0012345678910111213141516171819202122232425262728293031323334353637383940
```

### 时区相关查询

Rails使用UTC时区将时间戳存入数据库。在数据库查询中应该始终使用`Time.current`，Rails会帮我们转换成正确的时间进行对比。

```ruby
Post.where("published_at > ?", Time.current)
# SELECT "posts".* FROM "posts" WHERE (published_at > '2015-07-04 17:45:01.452465')12
```

### 总结

*不要使用*

```ruby
* Time.now
* Date.today
* Date.today.to_time
* Time.parse("2015-07-04 17:05:37")
* Time.strptime(string, "%Y-%m-%dT%H:%M:%S%z")12345
```

*推荐使用*

```ruby
* Time.current
* 2.hours.ago
* Time.zone.today
* Date.current
* 1.day.from_now
* Time.zone.parse("2015-07-04 17:05:37")
* Time.strptime(string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone1234567
```

- 始终使用UTC
- 用`Time.current`或者`Time.zone.today`