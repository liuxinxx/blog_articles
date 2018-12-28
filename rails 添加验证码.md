```
tags:验证码
```
## 1.安装包
```ruby
gem 'rucaptcha'
gem 'dalli'
```
## 2.配置路由 （最新版本的不用配置路由）
```ruby
mount RuCaptcha::Engine => "/rucaptcha"
```
<!--more-->
### 3.controller部分
```ruby
def create
    @user = User.new(user_params)
    if  verify_rucaptcha?(@user)&&@user.save
    ......
```

### 4.view部分
```erb
<div class="form-group " >
     <%=  rucaptcha_input_tag( class:'form-control rucaptcha-text') %>
     <a href="#" class='rucaptcha-image-box'><%= rucaptcha_image_tag(class:'rucaptcha-image', alt: 'Captcha') %></a>
  </div>
```

### 5.实现点击图片刷新验证码

```js
//点击验证码刷新
  $(".rucaptcha-image").click ->
    img = $(this)
    currentSrc = img.attr('src');
    img.attr('src', currentSrc.split('?')[0] + '?' + (new Date()).getTime());
    return false
```