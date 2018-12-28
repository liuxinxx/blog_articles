```
tags:小技巧
```
assets:precompile会把application.js引用的压缩成一个文件，这个对于gem中的js文件用起来很好,但是我们自己写的很多coffee.js不能全部压缩整合到一个文件中，只能是不同的页面引用不同的文件，而引用的话在public中又找不到，请问这个该如何是好？
### 解决办法
将 application 和 controller 对应的 js 分开加载
```ruby
<%= stylesheet_link_tag "application", :media => "all" %>
<%= stylesheet_link_tag params[:controller] %>
<%= javascript_include_tag "application" %>
<%= javascript_include_tag params[:controller] %>
```
<!--more-->
然后在 production.rb 中设置单独编译 scss 和 coffee

```ruby
config.assets.precompile << Proc.new { |path|
  if path =~ /\.(css||scss|js|coffee)\z/
    full_path = Rails.application.assets.resolve(path).to_path
    app_assets_path = Rails.root.join('app', 'assets').to_path
    full_path.starts_with?(app_assets_path)
  else
    false
  end
}
```
这样到了生产环境，一个页面会加载全局的 application.js 和 controller 对应的 js，就不会存在冲突了。

当然了，这样要在 application.js 中把 require_tree 去掉，css 同理。