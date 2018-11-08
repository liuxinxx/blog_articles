```
tags:postgress
```



postgresql数据库的备份和还原命令pg_dump 
常用命令：

#### 备份：
```pg_dump -U postgres -d myDBname -f dump.sql```

##### 其中
```
postgres是用户名
myDBname是数据库名
dump.sql是文件名
```
#### 还原：
```
createdb newDBname
psql -d newDBname -U postgres -f dump.sql
```
##### 其中
* postgres是用户名
* newDBname是数据库名
* dump.sql是文件名
##### 参考：
```
pg_dump 把一个数据库转储为纯文本文件或者是其它格式.

用法:
  pg_dump [选项]... [数据库名字]

一般选项:
  -f, --file=FILENAME          输出文件或目录名
  -F, --format=c|d|t|p         输出文件格式 (定制, 目录, tar)
                              明文 (默认值))
  -j, --jobs=NUM               执行多个并行任务进行备份转储工作
  -v, --verbose                详细模式
  -V, --version                输出版本信息，然后退出
  -Z, --compress=0-9           被压缩格式的压缩级别
  --lock-wait-timeout=TIMEOUT  在等待表锁超时后操作失败
  -?, --help                   显示此帮助, 然后退出

控制输出内容选项:
  -a, --data-only              只转储数据,不包括模式
  -b, --blobs                  在转储中包括大对象
  -c, --clean                  在重新创建之前，先清除（删除）数据库对象
  -C, --create                 在转储中包括命令,以便创建数据库
  -E, --encoding=ENCODING      转储以ENCODING形式编码的数据
  -n, --schema=SCHEMA          只转储指定名称的模式
  -N, --exclude-schema=SCHEMA  不转储已命名的模式
  -o, --oids                   在转储中包括 OID
  -O, --no-owner               在明文格式中, 忽略恢复对象所属者

  -s, --schema-only            只转储模式, 不包括数据
  -S, --superuser=NAME         在明文格式中使用指定的超级用户名
  -t, --table=TABLE            只转储指定名称的表
  -T, --exclude-table=TABLE    不转储指定名称的表
  -x, --no-privileges          不要转储权限 (grant/revoke)
  --binary-upgrade             只能由升级工具使用
  --column-inserts             以带有列名的INSERT命令形式转储数据
  --disable-dollar-quoting     取消美元 (符号) 引号, 使用 SQL 标准引号
  --disable-triggers           在只恢复数据的过程中禁用触发器
  --enable-row-security        启用行安全性（只转储用户能够访问的内容）
  --exclude-table-data=TABLE   不转储指定名称的表中的数据
  --if-exists              当删除对象时使用IF EXISTS
  --inserts                    以INSERT命令，而不是COPY命令的形式转储数据
  --no-security-labels         不转储安全标签的分配
  --no-synchronized-snapshots  在并行工作集中不使用同步快照
  --no-tablespaces             不转储表空间分配信息
  --no-unlogged-table-data     不转储没有日志的表数据
  --quote-all-identifiers      所有标识符加引号，即使不是关键字
  --section=SECTION            备份命名的节 (数据前, 数据, 及 数据后)
  --serializable-deferrable   等到备份可以无异常运行
  --snapshot=SNAPSHOT          为转储使用给定的快照
  --strict-names               要求每个表和/或schema包括模式以匹配至少一个实体
  --use-set-session-authorization
               使用 SESSION AUTHORIZATION 命令代替
               ALTER OWNER 命令来设置所有权

联接选项:
  -d, --dbname=DBNAME       对数据库 DBNAME备份
  -h, --host=主机名        数据库服务器的主机名或套接字目录
  -p, --port=端口号        数据库服务器的端口号
  -U, --username=名字      以指定的数据库用户联接
  -w, --no-password        永远不提示输入口令
  -W, --password           强制口令提示 (自动)
  --role=ROLENAME          在转储前运行SET ROLE

如果没有提供数据库名字, 那么使用 PGDATABASE 环境变量
的数值.

报告错误至 <pgsql-bugs@postgresql.org>.
```