# 一.如何安装oracle

1.拉取镜像



```undefined
    docker pull  docker.io/arahman/docker-oracle-xe-11g
```

2.运行镜像



```kotlin
docker run -d -v /home/docker/data/oracle_data:/data/oracle_data -p 49160:22 -p 1521:1521 -e ORACLE_ALLOW_REMOTE=true docker.io/arahman/docker-oracle-xe-11g
```

**-e oracle_allow_remote=true表示允许远程连接**
 3.连接参数：



```undefined
hostname: localhost
port: 1521
sid: xe
username: system
password: oracle
```

# 二.设置用户

如何新建表空间和用户：
 (1).进入容器,连接到oracle服务



```bash
docker exec -it 容器id /bin/bash
su oracle
cd $ORACLE_HOME
bin/sqlplus / as sysdba
```

(2).创建表空间



```bash
create tablespace ESCDB datafile  '/u01/app/oracle/escdb/escdb.dbf' size 100M;
```

**这一步可能会有问题，是因为容器里/u01/app/oracle文件夹下不存在escdb目录。可以先手动新建一个test目录，再给这个目录赋权限**



```bash
cd /u01/app/oracle
mkdir escdb
chmod 777 escdb
```

**然后再执行create tablespace ESCDB datafile  '/u01/app/oracle/escdb/escdb.dbf' size 100M;**
 (3).创建用户



```csharp
create user escdb identified by para123456 default tablespace ESCDB;
```

```
账号: escdb
密码: para123456
```

<img src="D:\me\myBlog\articles\blog_articles\images\image-20200519225738763.png" alt="image-20200519225738763" style="zoom:50%;" />

(4).给用户授权



```cpp
grant connect,resource to escdb;
grant dba to escdb;//授予dba权限后，这个用户能操作所有用户的表
```

> 注：如果新建用户失败，可能是这个用户已经存在，要先删除



```rust
drop user escdb cascade;
```

