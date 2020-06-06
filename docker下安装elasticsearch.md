# docker下安装elasticsearch

# 1、查找elasticsearch版本

```undefined
docker search elasticsearch
```
# 2、选择一个版本，拉取镜像（本次拉取是2.4.6）

```css
docker pull elasticsearch:2.4.6
```
![img](images/2501393-10a4fccad9fac142.png)

# 3、查看镜像

```undefined
docker images
```
![](images/2501393-13d29ed982818185.webp)
# 4、通过镜像，启动一个容器，并将9200和9300端口映射到本机
```css
docker run -d -p 9200:9200 -p 9300:9300 --name elasticsearch elasticsearch:2.4.6
```
![img](images/2501393-55083cbe6ac8abc9.webp)
# 5、查看已启动容器
```undefined
docker ps
```
![img](images/2501393-611a5809e4c3125d.webp)
 验证是否安装成功？访问：(本机ip地址:9200)
http://192.168.43.107:9200
![img](https:////upload-images.jianshu.io/upload_images/2501393-a8d63d1c33d1e2d5.png?imageMogr2/auto-orient/strip|imageView2/2/w/580/format/webp)

# 6、安装插件，先进入容器：

```bash
docker exec -it elasticsearch /bin/bash
```
![img](images/2501393-726d9ce61c0bb9f6.webp)

# 7、进入容器bin目录，并执行安装插件命令：

```bash
cd bin
ls 
plugin install mobz/elasticsearch-head
```
![img](images/2501393-e1e4183306bbe066.webp)

 访问：
http://192.168.43.107:9200/_plugin/head/

![img](images/2501393-14966cb3a67f4bd4.webp)
插件安装成功