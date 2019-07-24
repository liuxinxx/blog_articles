```
tags:sftp
```

### 1、查看openssh的版本

<!--more-->

```
ssh -v
```

> 使用ssh -v 命令来查看openssh的版本，版本必须大于4.8p1，低于的这个版本需要升级。
>  如果提示**-bash: ssh: command not found**，则需自行安装openssh客户端，安装命令如下

```
yum -y install openssh-clients
```

### 2、创建sftp组

```
groupadd sftp
```

> 在执行**groupadd xxx**时有可能报错：
>  **groupadd : cannot open /etc/xxx**
>  解决方法：

```
chattr -i /etc/group
chattr -i /etc/gshadow
```

### 3、创建一个sftp用户，用户名为mysftp，密码为mysftp

> 修改用户密码和修改Linux用户密码是一样的。

```
useradd -g sftp -s /bin/false mysftp    #创建mysftp用户
passwd mysftp  #设置mysftp用户的密码
```

> 如报下面的错：
>  **useradd : cannot open /etc/xxx**
>  解决方法：

```
chattr -i /etc/passwd
chattr -i /etc/shadow
```

### 4、为sftp组用户设置统一home目录

> sftp组的用户的home目录统一指定到/data/sftp下，按用户名区分，这里先新建一个mysftp目录，然后指定mysftp的home为/data/sftp/mysftp

```
mkdir -p /data/sftp/mysftp
usermod -d /data/sftp/mysftp mysftp
```

### 5、配置sshd_config

文本编辑器打开 **/etc/ssh/sshd_config**

```
vi /etc/ssh/sshd_config
```

找到如下这行，用#符号注释掉，应该是在**132**行。（按esc，输入**:set nu**显示行号）

```
#Subsystem      sftp    /usr/libexec/openssh/sftp-server
```

在文件最后面添加如下几行内容，然后保存。

```
Subsystem       sftp    internal-sftp  #使用sftp服务使用系统自带的internal-sftp
Match Group sftp  #匹配sftp组的用户，如果要匹配多个组，多个组之间用逗号分割
ChrootDirectory /data/sftp/%u  #用chroot将用户的根目录指定到/data/sftp/%u，%u代表用户名，这样用户就只能在/data/sftp/%u下活动
ForceCommand    internal-sftp  #指定sftp命令
AllowTcpForwarding no
X11Forwarding no
AllowGroups cdckongj cdchaitaol cdchuanl anchnet ansible ops Anchnet B2B_PROD_IVM sftp # 注意看一下有没有sftp，没有的话会出现登录问题
```

### 6、设定Chroot目录权限

```
chown root:sftp /data/sftp/mysftp
chmod 755 /data/sftp/mysftp
```

### 7、建立SFTP用户登入后可写入的目录

> 照上面设置后，在重启sshd服务后，用户mysftp已经可以登录。但使用chroot指定根目录后，根应该是无法写入的，所以要新建一个目录供mysftp上传文件。这个目录所有者为mysftp，所有组为sftp，所有者有写入权限，而所有组无写入权限。命令如下：

```
mkdir /data/sftp/mysftp/upload
chown mysftp:sftp /data/sftp/mysftp/upload
chmod 755 /data/sftp/mysftp/upload
```

### 8、修改/etc/selinux/config

文本编辑器打开/etc/selinux/config

```
vi /etc/selinux/config
```

将文件中的 **SELINUX=enforcing** 修改为 **SELINUX=disabled** ，然后保存。
 再输入命令

```
setenforce 0
```

### 9、重启sshd服务

输入命令重启服务

```
service sshd restart
```

### 10、验证sftp环境

用mysftp用户名登录，yes确定，回车输入密码。

```
sftp mysftp@127.0.0.1
```

显示 **sftp>** 则sftp搭建成功。

------
注意：sftp服务的根目录的所有者必须是root*，权限不能超过*755*(上级目录也必须遵循此规则)，sftp的用户目录所有者也必须是*root*,且最高权限不能超过*755*。