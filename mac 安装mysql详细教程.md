```
tags:mysql
source_url:https://www.jianshu.com/p/07a9826898c0
source_title:mac 安装mysql详细教程
```

## 一：下载[最新的MySQL社区版](https://dev.mysql.com/downloads/mysql/)  

为了安装更方便，建议下载dmg安装包。 最新的版本是5.7.20。<!--more-->
![img](https://ws2.sinaimg.cn/large/006tKfTcly1g1ieudsfahj317q0u0teu.jpg)

## 二：安装MySQL

双击 mysql-5.7.20-macos10.12-x86_64.dmg 文件，加载镜像
双击 mysql-5.7.20-macos10.12-x86_64.pkg ，开始安装

![img](https://ws2.sinaimg.cn/large/006tKfTcly1g1ieuofaznj30yg0ocjvo.jpg)

一直点击继续就可以安装成功。

> 注意：安装完成之后会弹出一个对话框，告诉我们生成了一个root账户的临时密码。请注意保存，否则重设密码会比较麻烦。



![img](https://ws3.sinaimg.cn/large/006tKfTcly1g1ieutzlz5j30hn09bwhc.jpg)

网上找了一张图片提醒大家，我安装的时候没有保存，所以安装完不能登录，稍后会告诉大家怎么解决忘记密码的问题。

## 三：启动MySQL

打开系统偏好设置，会发现多了一个MySQL图标，点击它，会进入MySQL的设置界面：

![img](https://ws3.sinaimg.cn/large/006tKfTcly1g1iev1csnrj31140hgjvu.jpg)

安装之后，默认MySQL的状态是stopped，关闭的，需要点击“Start MySQL Server”按钮来启动它，启动之后，状态会变成running。下方还有一个复选框按钮，可以设置是否在系统启动的时候自动启动MySQL，默认是勾选的，建议取消，节省开机时间。

## 四：终端连接MySQL

打开终端，为Path路径附加MySQL的bin目录

```
PATH="$PATH":/usr/local/mysql/bin
```

然后通过以下命令登陆MySQL（密码就是前面自动生成的临时密码）

```
mysql -u root -p
```

登陆成功，但是运行命令的时候会报错，提示我们需要重设密码。
 mysql> show databases;ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.mysql>
 修改密码，新密码为123456

```
set PASSWORD =PASSWORD('123456');
```

再次执行show databases;就正常了。

![img](https://ws2.sinaimg.cn/large/006tKfTcly1g1ieve1sy2j30vo0p40wv.jpg)

## 五：忘记密码

解决MAC下MySQL忘记初始密码的方法
 我在安装的过程中忽略了初始密码，导致安装成功之后无法登陆
 不过只要大家注意安装过程中的提示，就不会再踩这个坑了😄

#### 第一步

点击系统偏好设置->最下边点MySQL，在弹出页面中，关闭服务

![img](https://ws1.sinaimg.cn/large/006tKfTcly1g1ievk7t2cj31140hgjvu.jpg)

#### 第二步

进入终端输入

```
cd /usr/local/mysql/bin/
```

回车后 登录管理员权限

```
 sudo su
```

回车后输入以下命令来禁止mysql验证功能

```
./mysqld_safe --skip-grant-tables &
```

回车后mysql会自动重启（偏好设置中mysql的状态会变成running）

### 第三步

输入命令

```
./mysql
```

回车后，输入命令

```
FLUSH PRIVILEGES
```

回车后，输入命令

```
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('你的新密码');
```

OK，可以了，新密码设置成功！！！



### Mac 用户可以使用 [Selquel pro](http://www.sequelpro.com)  客户端
![20170322111647804](https://ws1.sinaimg.cn/large/006tKfTcly1g1if6eh5j2j31dd0u0q70.jpg)
#### 链接错误

```
Authentication plugin 'caching_sha2_password' cannot be loaded: dlopen(/usr/local/mysql/lib/plugin/caching_sha2_password.so, 2): image not found
```

### 解决方法

```sql
mysql > ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'yourpassword';
```

