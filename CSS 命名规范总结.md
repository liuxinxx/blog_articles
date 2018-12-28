```
tags:css
```
> BEM 命名给 CSS 以及 html 提供清晰结构，命名空间提供更多信息，模块化提高代码的重用，以达到 CSS 命名语义化、可重用性高、后期维护容易、加载渲染快的要求。

首先，这是一篇仅对 CSS 命名的总结，更多 CSS 规范请参考规范文档。其次 CSS 命名并无对错之分，只是不同的命名方式和代码的优雅程度与后期维护有着密切关系。
<!--more-->
> [@iamdevloper](https://twitter.com/iamdevloper) [pic.twitter.com/4SRgVDDaiC](https://t.co/4SRgVDDaiC)
>
> — Saeed Prez (@SaeedPrez) 2016年7月14日

CSS 很容易写，但是维护它却很难，因为 CSS 声明属性的性质不具备编程语言流程控制的特点，CSS(Cascading Style Sheets)也可以层叠生效，不同地方的 classes 相互影响。CSS 命名是规范中最重要的部分，它几乎就是 CSS 规范的全部，我们也就是依赖它完成对 CSS 的控制。

## 分离

曾经我们这样定义选择器：

```
.fl
  float: left

.fr
  float: right

.mr10
  margin-right: 10px

.pb10
  padding-bottom: 10px

.hidden
  overflow: hidden

.highlight
  color: $green
```

在 html 中添加选择器：

```
.fl.pb10.highlight
```

这就是规则分离的做法，将一些确定值的 CSS 规则单独定义选择器，这样做的目的是提高代码的重用，但是也有很多缺点：

- 可供分离的属性有限，还有很多不确定值的属性，比如 width、color，而且现实布局的多样性使 mr10 这样的分离也很少用到，因此无法做到彻底分离；
- 分离之后导致 html 中 class 特别多，而且不具有语义化；

既然还是需要添加语义化的 class 来定义一部分样式，那么分离一部分出去也没有意义，操作上缺点远远大于优点。吸取这种命名的优点，现在依然会使用它，但是只保留了少数语义化且常用的，例如：`.hidden`、`.highlight`。

## 不好的写法

html：

```
.container
  .actions
    .card_wrapper
      .card
        .title.light
        .content
          .list
            i.fa.fa-cog
```

CSS：

```
body.events,
body.aaa,
body.bbb

  .actions

    .card_wrapper

      .card

        .title

        .content

          .list

            .fa

    .another
```

以上是我们现在常见的写法，但是是需要绝对避免的，虽然 class 有一定语义了，但是并不能真正的重用。class 命名太通用了，我们不知道还有什么地方用到 `.title` `.content` 这样的命名，就不敢直接使用，一方面层层嵌套防止冲突，一方面想要重用时就在顶层添加 `body.aaa` 这样的东西，导致很多样式用不到，写的乱七八糟。

这样一直写下去，旧的 CSS 我们永远不会删，只敷衍写出效果，如此往复循环，最终就会像上面的窗帘，让人忍无可忍。每个页面都有 `.content` 甚至每个模块都有 `.content`，`.content` 就毫无意义（.content 不是抽象化的全局共用模块）。深层次的嵌套也会降低渲染效率。

另一种常见的：

html：

```
.main-news-box
  h2.news-title
  ul.main-news-list
    li
      a
        span
        span
```

CSS：

```
.main-news-box

.main-news-box .news-title

.main-news-list

.main-news-list li

.main-news-list a

.main-news-list span
```

这种写法的问题：

- `.news-title` 在别的地方有没有定义？能不能单独使用？其他地方定义的 `.news-title` 会相互影响，父级更深层次的 `li`、`a` 也会覆盖现有的定义。
- 这种命名也有性能问题，CSS 从右向左渲染，例如 `.main-news-list a`，先渲染页面所有的 a，再渲染 .main-news-list。

## BEM 命名

BEM 是一种真正消除不确定性的命名方式，它使得结构样式更加清晰，我们有足够的信心做任何修改。

- block：模块，名字单词间用 `-` 连接
- element：元素，模块的子元素，以 `__` 与 block 连接
- modifier：修饰，模块的变体，定义特殊模块，以 `--` 与 block 连接

例如：

```
.user-home-nav
  .user-home-nav-item.user-home-nav-item--small
    .user-home-nav-item__icon
    .user-home-nav-item__text
```

CSS 中这样写：

```
.user-home-nav

  &-item

    &--small

    &__icon

    &__text
```

这样命名的好处：

- 语义化，此处的语义化不是指 html 标签的语义化，对 SEO 可能也没有任何意义，但是这是一种人阅读的语义化。语义化的重要意义：宁可增加 html 大小，力图使维护变得轻松。
- 减少层层嵌套，有利于渲染效率。以上 sass 解析之后就是：

```
.user-home-nav

.user-home-nav-item

.user-home-nav-item__icon

.user-home-nav-item__text

.user-home-nav-item--small
```

缺点？

- 有人说又是 `__` 又是 `--`，什么乱七八糟的符号，我并不觉得有任何问题，这种命名让结构十分清晰，只看 html 或 CSS 就能看出它对应的模块或者模块的元素或者不同类型的模块，后期维护的增删也十分确定。
- 长长的 class 名增加了 html 的字节。从加载速度上来说，当然是名字越短越好。但是这个对应的就是语义化，取舍上我更倾向于语义化。

## BEM 的问题

但是 BEM 最大的问题却是这个：如何给 modifier 下的 element 定义规则呢？

```
.user-home-nav

  &-item

    &--small

      .user-home-nav__icon

      .user-home-nav__text

    &__icon

    &__text
```

这样做太不优雅了，太违背 sass 的优雅性质了。或许是我没有找到更好的写法？

还能产生更多的写法，例如 `.user-home-nav-item--small__icon` 、`.user-home-nav-item__icon--small`，但是或多或少会存在问题，还是尽量保持简单。

其他问题：

- 如何确定一个 block？就像上面 `.user-home-nav-item` 也可以写成 `.user-home-nav__item`，如果 item 下有 title，那么就是 `.user-home-nav__title`，以避免写成 `.user-home-nav__item__title`，但是如果 nav 已有 title `.user-home-nav__title` 了，或许我们要把 item 下的 title 写成 `.user-home-nav__item-title`，总之为了使 BEM 也不至于复杂化，命名上也许还是要纠结一番。所以我最终写成了 `.user-home-nav-item`，也许可以这么写下去，没有 B 和 M，trello 貌似就是这样，例如：`.attachment-thumbnail-details-options-item-text`。
- BEM 导致 CSS 规则重用性降低，如果重用尽量考虑写成通用模块.

## BEM + 命名空间

命名空间定义 block 间的关系，这种方式网站上还没有大范围使用，最常见的如 `.js－` 表示定义 JavaScript 钩子，不用于定义样式。常见命名空间：

- o-：表示一个对象（Object），如 `.o-layout`。
- c-：表示一个组件（Component），指一个具体的、特定实现的 UI。如 `.c-avatar`。
- u-：表示一个通用工具（Utility），如 `.u-hidden`。
- t-：表示一个主题（Theme），如 `.t-light`。
- s-：表示一个上下文或作用域（Scope），如 `.s-cms-content`。
- is-，has-：表示一种状态或条件样式。如 `.is-active`
- _：表示一个 hack，如 `._important`。
- js-：表示一个 JavaScript 钩子。如 `.js-modal`。
- qa-：表示测试钩子。

例如一个圆形头像组件：

```
.c-avatar-circle

  &__img
    display: block
    vertical-align: top
    max-width: 100%
    border-radius: 100%

  &__name
    text-align: center
```

以上，BEM 产生的重用性问题还是没有解决，如何解决？

## 模块

模块化类似于分离的概念，也是分离进化的结果，我们从分离中提取出 `.hidden {overflow: hidden}` 这样的命名，进而扩展 `.avatar {}` 这样的命名，不再只包含一条规则。看一下 airbnb 的圆形头像写法：

html：

```
a.pull-right.media-photo-badge.card-profile-picture.card-profile-picture-offset.is-superhost
  .media-photo.media-round
    img
```

CSS：

```
.card-profile-picture
  width: 60px
  height: 60px

  &-offset
    position: relative
    top: -40px
    margin-bottom: -40px

  &.is-superhost
    position: relative

  img
    width: 56px
    height: 56px

.media-photo
  backface-visibility: hidden
  position: relative
  display: inline-block
  vertical-align: bottom
  overflow: hidden
  background-color: #bbb

.media-round
  border-radius: 50%
  border: 2px solid #fff
```

这个是比较复杂，相对特例的。`.media-photo` 和 `.media-round` 是典型的抽象出来的模块，一个定义照片的基本属性，一个定义圆形属性。`.card-profile-picture` 是特定的命名定义特定具体的值。

## 总结

- 基本：以英文单词命名，避免无意义的缩写，以 `-` 连接。
- 我在一开始使用 BEM 的时候，也有很多疑惑，而且现在也不确定它完备的用法。
- BEM 不是万能的，但是无论如何 BEM 是应该使用的方法。
- 命名空间给 CSS 命名提供更多信息。
- 定义模块提高代码的重用。
- CSS 命名要求：语义化易于理解，可重用性高，后期维护容易，加载渲染快。

## 参考文章

- [精简高效的CSS命名准则/方法](http://www.zhangxinxu.com/wordpress/2010/09/%E7%B2%BE%E7%AE%80%E9%AB%98%E6%95%88%E7%9A%84css%E5%91%BD%E5%90%8D%E5%87%86%E5%88%99%E6%96%B9%E6%B3%95/)
- [MindBEMding – getting your head ’round BEM syntax](http://csswizardry.com/2013/01/mindbemding-getting-your-head-round-bem-syntax/)
- [More Transparent UI Code with Namespaces](http://csswizardry.com/2015/03/more-transparent-ui-code-with-namespaces/)
- [BEM 101](https://css-tricks.com/bem-101/)
- [CSS Guidelines](http://cssguidelin.es/)