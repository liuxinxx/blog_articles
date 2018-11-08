```
tags:telegram
source_title:Telegram MTproxy代理搭建完全指南
source_url:https://github.com/shellhub/blog/issues/9
```

[视频演示传送门](https://youtu.be/1O7OQLLZ5M8)

最近更新了最新版本的ios Telegram后，发现无法链接到服务器，一直处于Connectting状态，即使是开启了ss的全局模式也是没有任何作用，强制让Telegram去监听socks5的端口号，试了`1080`，`1086`，`1087`等一些列端口号都无果，最终的解决方案是通过[Telegram MTProxy](https://github.com/TelegramMessenger/MTProxy)得以解决<!--more-->

### 编译源码

通过SSH链接到自己的服务器

```
ssh root@140.61.22.18
```

更新软件包

```
yum update -y # For Debian/Ubuntu:
apt update -y # For On CentOS/RHEL:
```

安装对应的依赖包
Debian/Ubuntu:

```
apt install git curl build-essential libssl-dev zlib1g-dev
```

CentOS/RHEL

```
yum install openssl-devel zlib-devel
yum groupinstall "Development Tools"
```

获取MTProxy源代码

```
git clone https://github.com/TelegramMessenger/MTProxy
cd MTProxy # to source directory
```

编译源代码生成可以执行文件，这里使用make进行编译

```
make && cd objs/bin
```

如果编译失败，执行`make clean` 清理以下重试

### 运行

获取用于链接Telegram服务器的secret

```
curl -s https://core.telegram.org/getProxySecret -o proxy-secret
```

获取telegram配置文件

```
curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf
```

生成一个32位16进制secret用于客服端链接

```
head -c 16 /dev/urandom | xxd -ps
```

运行mtproto-proxy

```
chmod +x mtproto-proxy
./mtproto-proxy -u nobody -p 8888 -H 443 -S <secret> --aes-pwd proxy-secret proxy-multi.conf -M 1
```

**注意⚠️**
请将`-p 8888` `-H 443` `-S <secret>`替换为自己的，分别为本地端口号，用于链接服务器的端口，32位16进制secret

### Telegram客服端链接代理

IOS端设置如下
Setting > Data Storage > Use Proxy > + Add Proxy > MTProto
分别输入
`Server`:服务器ip地址
`Port`:端口号
`Secret`:32位16进制端口号