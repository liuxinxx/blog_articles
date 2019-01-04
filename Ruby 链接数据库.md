```
tags:pg,ruby
```



Pg是[PostgreSQL RDBMS](https://link.jianshu.com/?t=http://www.postgresql.org/)的Ruby接口

#### 安装pg

`gem install pg`

#### 链接数据库

`conn = PG.connect(dbname: 'crawlers')`

#### 从数据库提取数据

```ruby
require 'pg'
file = File.new('data.csv','ab+')
conn = PG.connect(dbname: 'crawlers')
conn.exec('select * from worldconferencecalendar ;') do |result|
  result.each do |i|
    str = ''
    i.each do |a|
      str+=a[1].gsub(',','，')+',' if a[0]!='source_url'
    end
    file.syswrite(str+"\r\n")
  end
end
```

