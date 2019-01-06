```
tags:postgres
source_url:http://lazybios.com/2016/11/how-to-make-postgreSQL-can-be-accessed-from-remote-client/
sourcer_title:如何设置PostgreSQL允许被远程访问
```



但是Pg与MySQL一样都需要配置后才能远端外网访问，这篇文章就来介绍具体的配置方法。<!--more-->

##### 1. 修改postgresql.conf

`postgresql.conf`存放位置在`/etc/postgresql/9.x/main`下，这里的`x`取决于你安装PostgreSQL的版本号，编辑或添加下面一行，使PostgreSQL可以接受来自任意IP的连接请求。

```
listen_addresses = '*'
```

##### 2. 修改pg_hba.conf

`pg_hba.conf`，位置与`postgresql.conf`相同，虽然上面配置允许任意地址连接PostgreSQL，但是这在pg中还不够，我们还需在`pg_hba.conf`中配置服务端允许的认证方式。任意编辑器打开该文件，编辑或添加下面一行。

```
# TYPE  DATABASE  USER  CIDR-ADDRESS  METHOD
host  all  all 0.0.0.0/0 md5
```

默认pg只允许本机通过密码认证登录，修改为上面内容后即可以对任意IP访问进行密码验证。对照上面的注释可以很容易搞明白每列的含义，具体的支持项可以查阅文末参考引用。

完成上两项配置后执行`sudo service postgresql restart`重启PostgreSQL服务后，允许外网访问的配置就算生效了。

