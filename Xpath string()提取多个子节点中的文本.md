```
tags:scrapy,Xpath
source_url:https://www.cnblogs.com/thunderLL/p/8038927.html
source_title:Xpath string()提取多个子节点中的文本
```

Xpath string()提取多个子节点中的文本

<!--more-->

```
<div>
    <ul class="show">
        <li>275万购昌平邻铁三居 总价20万买一居</li>
        <li>00万内购五环三居 140万安家东三环</li>
        <li>北京首现零首付楼盘 53万购东5环50平</li>
        <li>京楼盘直降5000 中信府 公园楼王现房</li>
    </ul>
</div>
```

我想要把所有li标签中的文本提取出来,并且放到一个字符串中.
在网上查了下发现使用xpath的string()函数可以实现(string()和text()的区别请自行google)
先看下常见的方法:

```
>>> from lxml import etree
...
>>> result = html.xpath("//div/ul[@class='show']")[0]
>>> result.xpath('string(.)')
 '                 275万购昌平邻铁三居 总价20万买一居                 00万内购五
环三居 140万安家东三环                 北京首现零首付楼盘 53万购东5环50平
  京楼盘直降5000 中信府 公园楼王现房             '
```

这是我查到的多数人使用的方法,还有人使用了concat()函数,更麻烦就不提了.
但是上面的匹配明显感觉可以写到一条xpath里面的,为什么非要分开写!忍不住吐槽一下


**xpath string()函数的调用写法**:

```
>>> html.xpath("string(//div/ul[@class='show'])")
'                 275万购昌平邻铁三居 总价20万买一居                 00万内购五
环三居 140万安家东三环                 北京首现零首付楼盘 53万购东5环50平
  京楼盘直降5000 中信府 公园楼王现房             '
```

再吐槽下上面那种写法.在xpath语法里面,点(.)表示当前节点,当前节点不就是`html.xpath("//div/ul[@class='show']")[0]`取到的节点元素吗!!!

