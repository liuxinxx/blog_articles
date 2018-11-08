```
tags:telegram
source_title:Telegram专用代理MTProxy脚本
source_url:https://github.com/shellhub/blog/issues/12
```

写一个专门用于搭建Telegram代理MTProxy的脚本<!--more-->

<https://github.com/shellhub/shellhub/blob/master/proxy/mt_proxy.sh>

### 支持版本

- Centos
- Debian/Ubuntu

### 如何使用

复制到服务器中自动编译安装

```
wget -N --no-check-certificate https://raw.githubusercontent.com/shellhub/shellhub/master/proxy/mt_proxy.sh && chmod +x mt_proxy.sh && ./mt_proxy.sh
```

输入用于客服端连接的端口号,可以直接自动生成

```
Input server port (defalut: Auto Generated):
```

输入一个32位16进制的密码用于客服端用来验证服务器，回车自动生成

```
Input secret (defalut: Auto Generated)：
```

完成安装

```
***************************************************
* Server : 140.82.22.61
* Port   : 1094
* Secret : 3c6c1efb0244e0285a4c3a28ebc6ce9c
***************************************************

Here is a link to your proxy server:
https://t.me/proxy?server=140.82.22.61&port=1094&secret=3c6c1efb0244e0285a4c3a28ebc6ce9c

And here is a direct link for those who have the Telegram app installed:
tg://proxy?server=140.82.22.61&port=1094&secret=3c6c1efb0244e0285a4c3a28ebc6ce9c
***************************************************
```

客服端链接到代理服务器

- 可以手动输入ip地址，端口号，密钥进行链接
- 可以复制https开头的链接到浏览器打开，浏览器自动打开Telegram配置
- 可以在app里面直接打开tg:开头的链接

视频教程

[![IMAGE ALT TEXT HERE](https://camo.githubusercontent.com/a87c19735eca1a1b5c9756eeae086b1fe4d32c52/68747470733a2f2f696d672e796f75747562652e636f6d2f76692f472d5a56673230427367492f302e6a7067)](https://www.youtube.com/watch?v=G-ZVg20BsgI) 

##### 卸载
这个没有安装到硬盘(从源码可知)，只是暂时性运行在内存上，如果想停止可以重启服务器，如果不想重启就杀死对应的进程，
方式如下

`ps -aux | grep mtproto-proxy`
找到对应的pid
然后执行kill pid执行杀死对应进程