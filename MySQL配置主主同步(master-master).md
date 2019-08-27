```
tags:mysql
```



# MySQL配置主主同步(master-master)

MySQL主主同步跟MySQL主从同步类似，只是再另一台上反向再做一次主从同步。
 只不过MySQL的配置文件有些地方需要注意一下。

# 实验环境

| 名称  | IP地址        | 系统版本   | MySQL版本    |
| ----- | ------------- | ---------- | ------------ |
| testA | 192.168.1.235 | CentOS 6.5 | mysql-5.7.13 |
| testB | 192.168.1.237 | CentOS 6.5 | mysql-5.7.13 |

# 1. 创建用于同步数据的用户

## a. testA服务器

```
grant replication slave on *.* to 'sync'@'192.168.1.237' identified by '<YourPassword>';    #IP地址可以指定固定的IP，提高安全性。若用'%'则表示所有的IP均可
flush privileges;
```

## b. testB服务器

```
grant replication slave on *.* to 'sync'@'192.168.1.235' identified by '<YourPassword>';    #IP地址可以指定固定的IP，提高安全性。若用'%'则表示所有的IP均可
flush privileges;
```

# 2. MySQL数据库配置文件的注意点

```
[mysqld]
server-id                      = 1                     #[必须]服务器唯一ID，每台服务器需不同
log-bin                        = /home/mysql/mysql-bin #[必须]启用二进制文件
binlog_format                  = mixed                 #[不是必须]二进制文件启用混合模式
expire-logs-days               = 14                    #[不是必须]二进制文件过期时间，单位是天
sync-binlog                    = 1                     #[不是必须]当每进行1次事务提交之后，MySQL将进行一次磁盘同步指令来将binlog_cache中的数据强制写入磁盘

# MASTER DB #
binlog-do-db                   = test,androidpnserver                        #[不是必须]只将对应的数据库变动写入二进制文件。如果有多个数据库可用逗号分隔,或者使用多个binlog-do-db选项
binlog-ignore-db               = mysql,information_schema,performance_schema #[必须]不需要记录二进制日志的数据库。如果有多个数据库可用逗号分隔，或者使用多个binlog-do-db选项。一般为了保证主主同步不冲突，会忽略mysql数据库。
auto-increment-increment       = 10                                          #[必须]
auto-increment-offset          = 1                                           #[必须]
#做主主备份的时候，因为每台数据库服务器都可能在同一个表中插入数据，如果表有一个自动增长的主键，那么就会在多服务器上出现主键冲突。
#解决这个问题的办法就是让每个数据库的自增主键不连续。上面两项说的是，假设需要将来可能需要10台服务器做备份，将auto-increment-increment设为10。而auto-increment-offset=1表示这台服务器的序号。从1开始，不超过auto-increment-increment。

# SLAVE DB #
replicate-do-db                = test,androidpnserver                        #[不是必须]只同步对应的数据库。如果有多个数据库可用逗号分隔，或者使用多个replicate-do-db选项
replicate-ignore-db            = mysql,information_schema,performance_schema #[必须]不需要同步的数据库。如果有多个数据库可用逗号分隔，或者使用多个replicate-ignore-db选项。一般为了保证主主同步不冲突，会不同步mysql数据库。
relay_log                      = /home/mysql/relay-bin                       #[不是必须]开启中继日志，复制线程先把远程的变化复制到中继日志中，再执行。
log-slave-updates              = ON                                          #[必须]中继日志执行之后将变化写入自己的二进制文件

slave-skip-errors              = all                                         #[不是必须]跳过所有的sql语句失败
```

## a. testA的数据库配置文件

```
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

# Configuration name server

[mysql]

# CLIENT #
port                           = 3306
default-character-set          = utf8

[client]
socket                         = /home/mysql/mysql.sock

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
[mysqld]
# GENERAL #
user                           = mysql
default-storage-engine         = InnoDB
socket                         = /home/mysql/mysql.sock
pid-file                       = /home/mysql/mysql.pid
character-set-server           = utf8
lower-case-table-names         = 1
performance_schema             = ON
sql_mode                       = ''
server-id                      = 1

# MyISAM #
key-buffer-size                = 32M
myisam_recover_options         = FORCE,BACKUP

# SAFETY #
max-allowed-packet             = 16M
max-connect-errors             = 1000000

# DATA STORAGE #
datadir                        = /home/mysql/

# BINARY LOGGING #
log-bin                        = /home/mysql/mysql-bin
binlog_format                  = mixed
expire-logs-days               = 14
sync-binlog                    = 1
log-bin-trust-function-creators= 1

# MASTER DB #
#binlog-do-db                   = mdm,androidpnserver
binlog-ignore-db               = mysql,information_schema,performance_schema
auto-increment-increment       = 2
auto-increment-offset          = 1

# SLAVE DB #
#replicate-do-db                = mdm,androidpnserver
replicate-ignore-db            = mysql,information_schema,performance_schema
relay_log                      = /home/mysql/relay-bin
log-slave-updates              = ON

# CACHES AND LIMITS #
tmp-table-size                 = 32M
max-heap-table-size            = 32M
query-cache-type               = 0
query-cache-size               = 0
max-connections                = 500
thread-cache-size              = 50
open-files-limit               = 65535
table-definition-cache         = 1024
table-open-cache               = 2048

# INNODB #
innodb-flush-method            = O_DIRECT
innodb-log-files-in-group      = 2
innodb-log-file-size           = 256M
innodb-flush-log-at-trx-commit = 1
innodb-file-per-table          = 1
innodb-buffer-pool-size        = 4G

# LOGGING #
log-error                      = /home/mysql/mysql-error.log
log-queries-not-using-indexes  = 1
#slow-query-log                 = 1
#slow-query-log-file            = /home/mysql/mysql-slow.log

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
```

## b. testB的数据库配置文件

```
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

# Configuration name server

[mysql]

# CLIENT #
port                           = 3306
default-character-set          = utf8

[client]
socket                         = /home/mysql/mysql.sock

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
[mysqld]
# GENERAL #
user                           = mysql
default-storage-engine         = InnoDB
socket                         = /home/mysql/mysql.sock
pid-file                       = /home/mysql/mysql.pid
character-set-server           = utf8
lower-case-table-names         = 1
performance_schema             = ON
sql_mode                       = ''
server-id                      = 2

# MyISAM #
key-buffer-size                = 32M
myisam_recover_options         = FORCE,BACKUP

# SAFETY #
max-allowed-packet             = 16M
max-connect-errors             = 1000000

# DATA STORAGE #
datadir                        = /home/mysql/

# BINARY LOGGING #
log-bin                        = /home/mysql/mysql-bin
binlog_format                  = mixed
expire-logs-days               = 14
sync-binlog                    = 1
log-bin-trust-function-creators= 1

# MASTER DB #
#binlog-do-db                   = mdm,androidpnserver
binlog-ignore-db               = mysql,information_schema,performance_schema
auto-increment-increment       = 2
auto-increment-offset          = 2

# SLAVE DB #
#replicate-do-db                = mdm,androidpnserver
replicate-ignore-db            = mysql,information_schema,performance_schema
relay_log                      = /home/mysql/relay-bin
log-slave-updates              = ON

# CACHES AND LIMITS #
tmp-table-size                 = 32M
max-heap-table-size            = 32M
query-cache-type               = 0
query-cache-size               = 0
max-connections                = 500
thread-cache-size              = 50
open-files-limit               = 65535
table-definition-cache         = 1024
table-open-cache               = 2048

# INNODB #
innodb-flush-method            = O_DIRECT
innodb-log-files-in-group      = 2
innodb-log-file-size           = 256M
innodb-flush-log-at-trx-commit = 1
innodb-file-per-table          = 1
innodb-buffer-pool-size        = 4G

# LOGGING #
log-error                      = /home/mysql/mysql-error.log
log-queries-not-using-indexes  = 1
#slow-query-log                 = 1
#slow-query-log-file            = /home/mysql/mysql-slow.log

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
```

# 3. 分别重启MySQL服务

```
service mysqld restart
```

# 4. 查看主服务器状态

## a. testA服务器

```
mysql> flush tables with read lock; #防止进入新的数据 
Query OK, 0 rows affected (0.00 sec) 
mysql> show master status\G;
*************************** 1. row ***************************
             File: mysql-bin.000010
         Position: 64353552
     Binlog_Do_DB: 
 Binlog_Ignore_DB: mysql,information_schema,performance_schema
Executed_Gtid_Set: 
1 row in set (0.00 sec)
```

## b. testB服务器

```
mysql> flush tables with read lock; #防止进入新的数据 
Query OK, 0 rows affected (0.00 sec) 
mysql> show master status\G;
*************************** 1. row ***************************
             File: mysql-bin.000008
         Position: 64355767
     Binlog_Do_DB: 
 Binlog_Ignore_DB: mysql,information_schema,performance_schema
Executed_Gtid_Set: 
1 row in set (0.00 sec)
```

# 5. 使用change master语句指定同步位置

## a. testA服务器

```
CHANGE MASTER TO MASTER_HOST='192.168.1.237',MASTER_USER='sync',MASTER_PASSWORD='<YourPassword>',MASTER_LOG_FILE='mysql-bin.000008',MASTER_LOG_POS=64355767;
```

## b. testB服务器

```
CHANGE MASTER TO MASTER_HOST='192.168.1.235',MASTER_USER='sync',MASTER_PASSWORD='<YourPassword>',MASTER_LOG_FILE='mysql-bin.000010',MASTER_LOG_POS=64353552;
```

# 6. 分别启动从服务器线程

```
mysql> start slave; 
Query OK, 0 rows affected (0.00 sec)
```

# 7. 查看从服务器状态

## a. testA服务器

```
mysql> show slave status\G; 
*************************** 1. row *************************** 
主要关注以下 2 个参数： 
... 
... 
Slave_IO_Running: Yes 
Slave_SQL_Running: Yes 
... 
... 
```

## b. testB服务器

```
mysql> show slave status\G; 
*************************** 1. row *************************** 
主要关注以下 2 个参数： 
... 
... 
Slave_IO_Running: Yes 
Slave_SQL_Running: Yes 
... 
... 
```

# 8. 验证测试

略

# 9. 参考链接

[mysql 主主互备](https://link.jianshu.com?t=http://www.cnblogs.com/kristain/articles/4142970.html)
 [MySQL 主主同步配置步骤](https://link.jianshu.com?t=http://www.jb51.net/article/36369.htm)