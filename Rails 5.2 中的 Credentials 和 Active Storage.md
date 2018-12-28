```
tags:rails
```

看到很多朋友们对Rails 5.2里的新东西，感觉云里雾里的，不太清楚它们究竟为我们提供了什么便利，所以我这里主要讲讲新版本中的Credentials和Active Storage。

## 为什么使用credentials？

先回顾在5.2版本以前，我们为了处理很多私密的信息，需要在`.gitignore`里加入多少的yml文件，有`secrets.yml`、`database.yml`、`cable.yml`，甚至会加入一些自定义的配置文件，如：`application.yml`。
<!--more-->
然后在部署配置中：

```ruby
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/cable.yml'...)
```

而我们升级到Rails 5.2后，很可能，只需要在`.gitignore`加入`master.key`一个文件，就可以处理所有的私密信息了。究竟`credentials.yml.enc`和`master.key`是怎么办到的呢？

## 把私密信息放入credentials中

因为我们在使用`credentials.yml.enc`后，可以把所有私密的信息都放到里面，然后通过`master.key`进行解密。所以当我们团队在一起完成一个项目时，需要分享`master.key`文件，但是考虑到安全的问题，不要把`master.key`上传到git的仓库中。

当我们打开`credentials.yml.enc`发现内容是一串随机串，如下：

```sh
qEbH/+fadmlPVeMVgFvpwk4ADadW2LbMkzMKJKkHrZeFNooiKKJvOoe5YJlbab1wJLHL77nSohvEm6MYnl9krXLFnDG0iSWm/svtipruMCc1FVfhSpmXSvLNJI1RUk2VeZCFjYkT8/PG4N7oj1OLrSq4yeRsbKTrS/3izcMm9ndJkcd4/wR7WAMReQSRGt5YGNZ4E3Jt9Wgg7ls2okZcwxEv/3brdgIyHrmfyEWb50YSe5oDDyscfRNX70uwZieSVGn99fFcexYUL8F0dxSrVNaix/h/UAeApq6Ifhs0/p9eXk0349f8dEMFkp5A3I4j0ubgjZ/ncdLTct37OxxhfucWukCtP6oSFvpC+5ma2epjjTSJM25+Vv3GQy7xfSdwbsEq8jm3tqT/zGr2M9iRuEX+LJrxzhDHnHC0--jQ+G6M9HWGe7zlFb--ltdsqYuI+4O8cqw/bcJRJw==
```

非常棒，`secret_key_base`之类的信息都在里面安全的保护着，可是如果我要修改里面的内容，怎么办？我们不可能直接修改加密后的内容啊。

不要着急，Rails这里给我们提供了一个方便的方法：`EDITOR="mate --wait" bin/rails credentials:edit`。当然，EDITOR的信息需要根据我们使用的工具进行调整。

```
EDITOR=vim bin/rails credentials:edit  # 使用VIM编辑
EDITOR="subl --wait" bin/rails credentials:edit  # 使用Sublime编辑
```

输入命令后，我们可以清楚的看到里面的内容：

```ruby
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: 0b4d8892f41d7b89127b3ad997ca9ca581fe7f84bf890c85095b635c651a9de00edd1032aeb377a5753f0236e526cb61d995d01fc3d52bb5644a33dbfbc69335
```

所以我们就可以在里面输入需要加密的信息，例如输入在生产环境里，数据库的密码：

```ruby
...
production:
  database:
    database: project
    password: 9f797275f3f
...
```

然后在我们需要用到这些加密信息的地方，调用：

```ruby
Rails.application.credentials[Rails.env][:database][:database]
Rails.application.credentials[Rails.env][:database][:password]
```

剩下部署的时候，就记得把`master.key`放到服务器里，不要弄丢了。

## 如何使用Active Storage

因为Active Storage和Rails结合紧密，所以使用起来很方便。在项目中运行`rails active_storage:install`，就会发现生成了一个数据迁移的文件，里面会给我们加入两个表，分别是`active_storage_blobs（储存文件信息）`和`active_storage_attachments（与业务表的多对多关系）`。

如果我们需要在`Project`模型中，保存`image`信息时，就不需要像使用`CarrierWave`时，在`Project`中另外添加字段，因为`Active Storage`会把文件信息直接保存到`active_storage_blobs`和`active_storage_attachments`中，我们只需要在`Project`的模型中加入：

```ruby
has_one_attached :image  ## 一对一关系 或
has_many_attached :images  ## 一对多关系
```

在控制器里的参数保护也不需要做特殊的处理，只需要保持正常的设置就可以了。

```ruby
params.require(:project).permit(..., :image)   # 一对一关系 或
params.require(:project).permit(..., images: [])   # 一对多关系
```

\##通过Active Storage上传的文件会保存在哪里？ 通过`config/storage.yml`，我们可以看到：

```ruby
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

默认的`test`和`local`是保存在本地的Disk中的，`local`默认把文件保存在`storage`文件夹中，所如果我们想要把文件保存在public内，可以修改成：

```erb
root: <%= Rails.root.join("public/storage") %>
```

当然无论我们保存在什么位置，记得把该目录加入到`.gitignore`中。

那么在开发环境中，它是如何知道使用`local`配置的呢？在`config/environments/development.rb`中，我们可以看到：

```ruby
# Store files locally.
config.active_storage.service = :local
```

所以，如果我们生产环境也希望保存在`Disk`的话，只需要修改`config/environments/production.rb`即可，当然我们会建议使用云服务，因为结合`Active Storage`可以让一切变得很简单，例如保存在`aws`，只需要：

```ruby
# config/environments/production.rb
# Store files on Amazon S3.
config.active_storage.service = :amazon

# config/storage.yml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

在前端，可以看到`application.js`里加入了`//= require activestorage`，通过`activestorage`可以使用`<%= form.file_field :image, direct_upload: true %>`，全交给客户端直接往云服务器上传文件，避免经过服务器。

同时，如果需要调整图片尺寸大小时，我们加入`gem 'mini_magick'`后，直接在页面就可以对图片尺寸进行处理：

```erb
<%= image_tag project.image.variant(resize: "100x100") %>
```

国内云服务的`Active Storage`相关gem：
> <https://github.com/mycolorway/activestorage_qiniu>
> <https://github.com/doabit/activestorage_upyun>
> <https://github.com/huacnlee/activestorage-aliyun>

参考：
* [Rails 5.2: Active Storage and beyond](https://evilmartians.com/chronicles/rails-5-2-active-storage-and-beyond)
* [Active Storage Environment-Specific Credentials](https://joey.io/active-storage-environment-specific-credentials/)
* [Encrypted Credentials — A new way to use Secrets in Rails 5.2](https://blog.botreetechnologies.com/encrypted-credentials-a-new-way-to-use-secrets-in-rails-5-2-eca929629bb4)
* [Rails 5.2 credentials](https://medium.com/cedarcode/rails-5-2-credentials-9b3324851336)