```
tags:react native
```
网上搜的添加如下依赖
 `compile 'com.facebook.fresco:animated-gif:0.13.0'`
.<!--more-->

 缺少文件，闪退；

 改为

 `compile 'com.facebook.fresco:animated-gif:0.12.0'`

 缺少不同于0.13的文件，闪退；
 其实都少了fresco基包。
 需要同时依赖

```
compile 'com.facebook.fresco:fresco:+'
compile 'com.facebook.fresco:animated-gif:+'
```