```
tags:gem,rails,CarrierWave
```
## gem 'carrierwave'

Carrierwave的主要功能是用于上传文件或者图片的Gem，功能非常强大。我在这里做一个非常简单的使用步骤，并不对Carrierwave做详细的介绍。

------

创建uploader

```ruby 
$ rails g uploader Photo    
  create  app/uploaders/photo_uploader.rb 
```
<!--more-->
uploader这个文件非常重要，carrierwave许多功能都将在photo_uploader.rb里实现。

创建字段存储文件信息

```ruby 
$ rails g migration AddPhotoToUsers photo:string        
  invoke  active_record       
  create  db/migrate/20120816163431_add_photo_to_users.rb 
```

photo字段使用与存储上传文件的地址字段。 然后在User的model中加入调用carrierwave的信息：

```ruby
class User < ActiveRecord::Base
  mount_uploader :photo, PhotoUploader 
```

这样Model和数据库就可以处理好上传上来的文件了。 接下来需要处理一下View，在正常的new下添加上传的按钮。

Views中添加相关设置
```erb
 <%= form_for @user, :html => {:multipart => true} do |f| %>   
  	<p>     
	  <label>My Photo</label>     
  	  <%= f.file_field :photo %>     
  	  <%= f.hidden_field :photo_cache %>   
    </p> 
  <% end %> 
```

关键在form_for中添加:html => {:multipart => true}，就可以使用上传功能了.

使用只需要在需要的地方添加<%= image_tag(@user.photo_url) %>就可以了。 这样，就完成了上传功能了。下面对上传图片的一些特别事项，做一些简单的描述。

------

使用RMagick生成多个图片版本

这里需要使用到另外一个Gem，名字为RMagick。 如果在安装gem 'rmagick'的过程中出现“Can't find Magick-config”的错误，以下链接就有处理这个问题的方法。 <http://stackoverflow.com/questions/5201689/rmagick-gem-install-cant-find-magick-config> 安装完RMagick后，就可以设置版本信息。 打开class PhotoUploader，然后添加RMagick支持：

``` 
include CarrierWave::RMagick 
```

注意：由于RMagick会导致内存泄露，建议使用Mini_Magick，gem "mini_magick"，使用方法基本和RMagick差不多

``` 
include CarrierWave::MiniMagick
```

设置版本信息：
```
  process :resize_to_fit => [800, 800]       #图片大小不超过800*800    version   :thumb do                                 #版本名为thumb   	       process         :resize_to_fill => [200,200]      #想图片处理成200*200大小 end 
```
- 不设置vesrion则为默认版本，既使用方法为<%= image_tag(@user.photo_url) %>
- 而thumb版本的使用方法也很简单，<%= image_tag(@user.photo_url(:thumb)) %>也就是添加thumb参数就可以了，版本号为什么就添加什么。非常方便。 # 限制文件上传格式 # 添加如下代码就可以让用户只上传图片文件了。 ruby class PhotoUploader < CarrierWave::Uploader::Base def extension_white_list %w(jpg jpeg gif png) end end* * * 这是个非常简单的教程，也谈不上是教程，也就是说明书而已，因为在github上，我说写的上面的写的非常清楚。我就是抽出一部分我比较常用的内容写了下来，这样就可以直接按照上面的流程下来，完成需要的部分功能。 如需要了解更加详细的内容，可以登陆：<https://github.com/jnicklas/carrierwave>