```
tags:scp
```
ssh 连接远程ssh非22端口服务器的方法

```
#ssh -p 2000 user@***.***.***.***
```
<!--more-->
scp 远程拷贝ssh非22端口的服务器文件使用方法
```
#scp -P 2000 other.zip user@***.***.***.***:/home/user
```
注：拷贝目录，-r是将目录下的子目录递归拷贝；".*"是将隐藏文件也拷贝过去
```
#scp -P 2000 -r /home/user/tools/.* user@***.***.***.***:/home/user
```