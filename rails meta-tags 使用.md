```
tags:rails,gem
```



　　meta tag 及 data 的设定很重要，通常网站要能快速得被找到，或是透过分享时显示重要(正确)的资讯，我们都得在这个部分下点功夫，本篇笔记一下在专案中所学到的相关知识和方法。<!--more-->

###  1. 什么是 Meta Tags 及 Meta Data

　　Meta Data，在全球资讯网上，是指让机器看得懂的、描述资讯内容的所有相关资讯。

- **Title Tag：**该页标题，英文长度最好是 70 字元内，中文大约 40 字内，关键字尽量往前放，而每一页的 `Title Tag` 不要重复为佳。如：`XXX美食部落格 :: 痞○帮`、`XXX | Facebook`、`征传单小弟 | oPartTime 让打工变得更美好！`等。
- **Description Tag：**该页的叙述，包含标点符号英文约 150 字内，中文 12 字内为佳，此 `Description Tag`会出现在 Google 搜寻结果中，所以关键字的使用很重要，尽量往前摆。
- **Canonical Url：**告诉搜寻引擎关于这个页面的标准网址。
- **Facebook OG：**此标签中的资讯是专门给 Facebook 的，可透过设定 OG (Open Graph) 的内容叙述，调整分享时的**缩图、标题、叙述**等。
- **Twitter Cards：**此标签中的资讯则是专门给 Twitter 的，透过设定 Cards 的内容叙述，调整分享的资讯显示。

#### 2. Gem

　　在 rails 中，除了直接 code html 外，我们可以透过 [**meta-tags**](https://github.com/kpumuk/meta-tags) 这个 gem 来对 Meta Data 作设定。

Gemfile

```
gem 'meta-tags'
```

then, `bundle` it.

#### 3. 设定 Meta Data

　　简单的设定来说，可以透过 `set_meta_tags` 作设定，如下：

page.html.haml

```
= set_meta_tags title: '此页的抬头'
-# <title>此页的抬头</title>
= set_meta_tags site: 'GeorgioWan's Note', title: '此页的抬头'
-# <title>GeorgioWan's Note | 此页的抬头</title>
= set_meta_tags site: 'GeorgioWan's Note', title: '此页的抬头', reverse: true
-# <title>此页的抬头 | GeorgioWan's Note</title> <= 较佳的作法

= set_meta_tags description: '此页的叙述喔！'
-# <meta name="description" content="此页的叙述喔！" />
-# 而这句"此页的叙述喔！"会在 Google 搜寻找到网页时，显时于搜寻结果中。
-# 如下，搜寻 Facebook 时所出现的资讯范例。
```



![img](https://ws1.sinaimg.cn/large/006tNc79ly1fzamlmb8oxj30ex027mx9.jpg)



　　在 Facebook OG 的简单设定如下：

Facebook Open Graph

```
= set_meta_tags og: {
    title: '此页的抬头',
    site_name: 'GeorgioWan's Note'
    type: 'website',
    url: 'http://georgiowan-note.logdown.com/',
    image: 'https://test.jpg',
}
-# <meta property="og:title" content="教你怎么在Rails里做好基本的SEO"/>
-# <meta property="og:type" content="website"/>
-# <meta property="og:site_name" content="好麻烦部落格"/>
-# <meta property="og:url" content="http://georgiowan-note.logdown.com/"/>
-# <meta property="og:image" content="https://test.jpg"/>
```

　　由于目前没有用到 Twitter Cards 所以也不方便多加叙述，详情请至 [**Twitter dev**](https://dev.twitter.com/cards/overview) 欣赏 XDD

#### 4. Rails 设定 meta tags 小技巧

　　如果每一页都要手刻 meta tag 的话，就违背了 DRY 的原则了！为了符合此原则，我们可以透过定义一个设定动作的 Action，而后，在需要设定 meta data 的 Controller 中作 `before_action` 即可，好像在绕口令，详情见下文。

　　(1) 先在 **Application Controller** 中定义一个 Action：

application_controller.rb

```
class ApplicationController < ActionController::Base
　before_action :prepare_meta_tags, if: "request.get?"
 
　protected
  def prepare_meta_tags(options={})
    site_name   = "GeorgioWan's Note"
    title       = "此页的抬头"
    description = "此页的叙述"
    image       = options[:image] || "your-default-image-url"
    current_url = request.url
    
    defaults = {
      site:        site_name,
      title:       title,
      image:       image,
      description: description,
      canonical:   current_url,
      keywords:    %w[这边可以打些关键字],
      og:          {url: current_url,　　# 设定 Facebook OG 预设资讯内容

                    site_name: site_name,
                    title: title,
                    image: image,
                    description: description,
                    type: 'website'}
    }　# 此为预设资讯内容

    options.reverse_merge!(defaults)　
　　# 透过 options.reverse_merge! 让其他 controller 中可作设定（若没有额外设定就是预设）  

    set_meta_tags options
    # 最后透过 set_meta_tags 设定 meta data 资讯

  end
end
```

　　(2) 接着，在 layout 的 head 中使用 `display_meta_tags` 设定每页的 meta data：

application.html.haml

```
%head
  = display_meta_tags
  %meta(http-equiv="X-UA-Compatible" content="IE=edge,chrome=1")
  -# 上面此段 meta 是设定 IE 的兼容性。
```

　　(3) 现在每一页都会有 meta data 了，但内容都是预设的资讯，我们可以在 **Controller** 中作设定：

test_controller.rb

```
class TestsController < ApplicationController
　def index
　　prepare_meta_tags title: "HERE IS TEST　INDEX", description: "TEST INDEX DESCRIPTION."
  　# 透过 prepare_meta_tags 传入想变更的 options

  　@page_title       = "HERE IS TEST INDEX"
  　@page_description = "TEST INDEX DESCRIPTION."
  　# or 我们可以透过 @page_* 作 meta data 设定

　end
 
　def show
　　@page_title       = "HERE IS TEST SHOW"
  　@page_description = "TEST SHOW DESCRIPTION."
　　prepare_meta_tags( og: { title: @page_title,
                             description: @page_description})
    # 也可以对 og 作设定

　end
end
```

　　以上，就简单的 SEO meta data 设定就完成了。

That's it, **DONE!**