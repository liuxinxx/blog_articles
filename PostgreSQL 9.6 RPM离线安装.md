```
tags: postgres
```



项目使用pg，整理个初级的安装教程，简化实施。
 部分内容参考来源：https://www.jianshu.com/p/ba02513d4a24 

<!--more-->

# Postgresql RPM离线安装

## 1. 安装环境

RedHat 6.8/ 64位， 有ROOT权限

## 2. 准备工作

### 下载RPM包

访问PostgreSQL网站，根据系统类别，系统版本选择相关的包:
 https://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/repoview/postgresqldbserver96.group.html
 下载本页面下的全部文件：
 点击下载链接：
 https://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/postgresql96-9.6.10-1PGDG.rhel6.x86_64.rpm
 https://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/postgresql96-contrib-9.6.10-1PGDG.rhel6.x86_64.rpm
 https://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/postgresql96-libs-9.6.10-1PGDG.rhel6.x86_64.rpm
 https://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/postgresql96-server-9.6.10-1PGDG.rhel6.x86_64.rpm

### 目录文件：

```
postgresql96-9.6.10-1PGDG.rhel6.x86_64.rpm
postgresql96-contrib-9.6.10-1PGDG.rhel6.x86_64.rpm
postgresql96-libs-9.6.10-1PGDG.rhel6.x86_64.rpm
postgresql96-server-9.6.10-1PGDG.rhel6.x86_64.rpm
```

本教程编写时pg当前版本9.6.10. 在这里以postgresql  9.6.10版本安装为例。

## 3. 安装PG

将上述Postgres安装包放置在同一个文件夹中， 执行安装命令：

```
rpm -ivh postgresql96-*.rpm
```

通过RPM包安装， Postgres安装程序会在/var和/usr下创建文件夹.
 `/var/lib/pgsql`:  用于存放Postgres数据库默认的数据文件夹
 `/usr/pgsql-9.6`:  用于存放Postgres数据库的命令、依赖库及文档目录等信息
 `/var/lib/pgsql/9.6/data` : 用户存放PG默认配置的`pg_hba.conf,postgresql.conf`配置文件。(为什么默认安装不是在/etc呢？)

### 可选操作：

为了一些后期运维数据库维护简化操作，将postgresql 加入系统PATH，并测试postgres 命令是否有返回，测试安装是否成功。

```
vi /etc/profile
# 在文件最后加入以下语句
export PATH=$PATH:/usr/pgsql-9.6/bin  

source /etc/profile
postgres --version
# 返回 postgres (PostgreSQL) 9.6.10
```

## 4. 自定义数据存储目录(可选)

在实际生产部署中，可能数据存储路径需要单独定义。如要求放到：/data/postgres目录，以方便定期数据备份，与磁盘空间管理。
 这里以将postgresql的data数据存储到`/data/postgres`路径为例。

#### A 创建文件

修改目录权限，需要将权限配置给用户postgres用户，（postgres用户为安装postgres的时候创建的用户）

```
mkdir -p /data/postgres
chown -R postgres:postgres /data/postgres
```

#### B 修改PG启动脚本目录(可选)

编辑 `/etc/init.d/postgresql-9.6` 文件， 找到PGDATA变量，设置成/data/postgres。

```
...
 # Set defaults for configuration variables
PGENGINE=/usr/pgsql-9.6/bin
#PGDATA=/var/lib/pgsql/9.6/data  -- PG默认配置的路径，修改成/data/postgres。
PGDATA=/data/postgres
PGLOG=/var/lib/pgsql/9.6/pgstartup.log
# Log file for pg_upgrade
PGUPLOG=/var/lib/pgsql/$PGMAJORVERSION/pgupgrade.log
...
```

这里也显示PG默认的一些log路径。

## 5. 初始化数据库

配置好数据后（如果配置了自定义路径）数据库默认是未启动状态。 需要进行初始化。
 CentOS 6/Redhat 6

```
service postgresql-9.6 initdb
```

初始化数据库后，会默认在系统的目录里面初始化PG数据库
 如果自定义了目录，会在/data/postgres里面初始化文件，并生成pg_hba.conf,postgresql.conf

> 默认情况：
>
> /var/lib/pgsql: 用于存放Postgres数据库默认的数据文件夹
>  /usr/pgsql-9.6: 用于存放Postgres数据库的命令、依赖库及文档目录等信息
>  数据库只能本机访问，127.0.0.1 默认没有密码
>  /var/lib/pgsql/9.6/data : 用户存放PG默认配置的`pg_hba.conf,postgresql.conf`配置文件

## 5. 配置数据库远程访问

PG默认只能本机访问，但是实际情况中，应用服务器多单独部署，需要开通PG的远程访问权限，且是需要配置用户密码的。
 需要修改postgres.conf， pg_hba.conf文件。
 如果找不到文件在哪，使用 Find命令搜索：

```
find / -name postgresql.conf
# /usr/pgsql-9.6/share/postgresql.conf
# /var/lib/pgsql/9.6/data/postgresql.conf
```

##### 5.1 修改postgresql.conf

主要配置参数详解：

```
#listen_addresses='localhost'
listen_addresses='*'   --- 修改成'*'全部ip都可以访问改数据库。
```

其他参数：

```
Postgresql监听的网卡ip，默认仅仅本地，可以配置多个，使用“,”分割。“*” 代表所有的网卡ip
port=5432 　
Postgres服务端口
max_connections=100　　
最大服务器连接数
superuser_reserved_connections=3　
为管理员保留的专用连接数，普通用户无法使用这些连接，不能大于max_connections
authentication_timeout=60s　　
登录验证超时时间设置
ssl=false
是否使用SSL进行连接
password_encryption=true　　
当使用create user、alter user管理用户时，如果没有显示进行加密与否的限定，postgresql服务器是否自动进行密码密
shared_buffers=32m　
共享缓存，非常重要的性能参数，其最小值为（128k,16k*max_connections）
max_prepared_transactions=5
最大并行prepared 事务，如果为0，则禁止使用prepared事务，最大值与max_connections相同
temp_buffers=8m
每个会话可以使用的临时（表）缓存大小
work_mem=1m
指定内部排序、连接、group等等时，postgresql可以使用的内存大小，超过该值，将使用磁盘临时文件; 实际使用的内存该类操作同时执行的数目相乘
maintenance_work_men=16m　　
维护语句vacuum、create index等等可以使用的内存大小; 实际使用的内存和该类操作同时执行的数目相乘
fsync=on　　
（物理数据）日志必须同步写入磁盘　
可能导致严重的性能损失，却能确保最高的日志数据安全。
synchronous_commit=on
（逻辑事务数据）日志必须同步写入磁盘，如果设为on，会立即调用fsync，相当于设置了fsync=on
full_page_writes=on
写整页
wal_buffers=64K
WAL日志缓存大小
wal_writer_delay=200ms　　
将wal日志从wal_buffer中写入磁盘的时间周期
commit_delay=0ms　　
事务日志commit后，写入磁盘的延时。这个设置只有在commit_sibings（并行的多个排队事务）在延时内存在是才有效
commit_siblings=5
并行事务数
```

##### 5.2 修改pg_hba.conf

```
[root@pgserver ~]# vi pg_hba.conf
... ...

·"local" is for Unix domain socket connections only
local   all             all                                     trust
IPv4 local connections:
host    all             all             127.0.0.1/32            trust
host    all             all             0.0.0.0/0               md5    #-- 添加本行
```

添加`host all all 0.0.0.0/0 md5`

意思是：
 【主机】可以使用 **【全部】**数据库 ， **【全部】** 用户，使用IP【0.0.0.0】，通过MD5加密密码访问。
 连接数据库是需要密码的。

> 配置说明：
>
> 格式：TYPE DATABASE USER ADDRESS METHOD
>  参数：
>  TYPE： 值为local和host, Local值表示为主机Socket连接， host代表允许的主机地址连接
>  DATABASE: 允许访问的数据库名， all代表允许全部数据库
>  USER: 表示允许哪个用户访问数据库， all代表所有用户都可以访问
>  ADDRESS: 表示允许连接的主机信息，可以使用主机IP地址， 也可以使用网段来表示，如192.168.1.0/24表示192.168.1.0网段可以连接
>  METHOD： 连接方法， 通常使用的值为md5和trust

## 6. 启动数据库

#### 启动Postgres数据库

```
service postgresql-9.6 start
#Starting postgresql-9.6 service:                               [  OK  ]
```

## 7. 测试数据库

**PG模式是不能用root用户访问数据库**，使用时需要用`su postgres` 切换到postgres用户下。
 使用psql命令进行测试。

> psql命令详解：
>
> -h host, 指定连接的Postgres数据库IP地址
>  -U username: 指定连接数据库的用户名
>  -d database: 指定连接的数据库名
>  -p port: 指定数据库连接的服务端口
>  -w: 表示不提示用户输入密码
>  -W : 表示验证数据库用户密码
>  -l : 表示列出Postgres可用的数据库信息

示例如下：

```
su - postgres    # -- root 切换到postgres
psql -h localhost -U postgres -d postgres -W
#Password for user postgres: 
#psql (9.6.10)
#Type "help" for help.
# 
```

使用默认脚本service postgresql initdb或/usr/pgsql-9.6/bin/postgresql96-setup initdb初始化数据库时，需要修改用户的密码。在修改Postgres用户密码时，需要确保以下条件：

配置"pg_hba.conf"时需要确定服务器本地址的验证方法为trust, 即:
 host all all 127.0.0.1/32 trust
 如果为peer|indent|md5方法时，需要将其修改为trust, 否则登录时会提醒输入用户密码。

### 修改默认的postgres用户密码

切换系统用户为postgres, 通过psql -h localhost -U postgres -d postgres登录Postgres数据库，进入数据后，使用SQL

```
alter user postgres with password 'newpassword'
```

来为用户修改默认密码。

示例如下：

```
su - postgres    # -- root 切换到postgres
psql -h localhost -U postgres -d postgres -w
postgres=#  alter user postgres with password 'newpassword';
#ALTER ROLE
```

## 8. PG开机自启动

postges默认不自动启动，使用以下命令打开。

```
chkconfig postgresql-9.6 on
```

## 9. Postgres日常服务管理

启动数据库：pg_ctl start -D /data/postgres
 重启数据库： pg_ctl restart -D /data/postgres
 停止数据库：pg_ctl stop -D /data/postgres
 强制重启：pg_ctl restart -D /data/postgres -m f
 强制停止：pg_ctl stop -D /data/postgres -m f
 加载配置：pg_ctl reload -D /data/postgres
 显示服务状态：pg_ctl status -D /data/postgres
 连接数据库: psql -h 127.0.0.1 -U postgres -p 5432 -d postgres -W