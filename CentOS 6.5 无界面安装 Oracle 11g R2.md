```
tags:oracle
source_title:CentOS 6.5 无界面安装 Oracle 11g R2
source_url:https://blog.csdn.net/hdfg159/article/details/78156378
```



系统环境基于无外网和无图形化界面安装Oracle 11G。 <!--more-->

### 准备软件

* XShell+Xftp：用于连接Linux系统的终端模拟工具和FTP传输工具

* Oracle安装文件下载（Oracle Database 11g Release 2安装包文件总大小约2G）： 
  http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html 
  下载完毕后会有两个文件（我所安装的Linux服务器是64位）： 
  `linux.x64_11gR2_database_1of1.zip `
  `linux.x64_11gR2_database_2of2.zip`

### 检查系统配置

Oracle Database 11g Release 2官方的系统配置要求如下：

* 物理运行内存（Physical RAM）：1GB以上，推荐配置2GB以上 
  查看内存占用情况： 
  `free -g`
* 硬盘空间（Disk Space）：8GB以上，/tmp目录剩余空间在1GB以上 
  查看其他挂载区的目录使用情况： 
  `df -h`
* 查看目录的剩余空间： 
  `df -kh /tmp`
* 查看系统当前的版本： 
  `lsb_release -a`
* 查看系统对应的版本和位数： 
  `cat /proc/version`

我所安装的服务器环境是 Red Hat Enterprise Linux 4

### 系统安装Oracle 11g R2所必须的安装包
```
binutils-2.15.92.0.2
compat-libstdc++-33-3.2.3
elfutils-libelf-0.97
elfutils-libelf-devel-0.97
expat-1.95.7
gcc-3.4.6
gcc-c++-3.4.6
glibc-2.3.4-2.41
glibc-common-2.3.4
glibc-devel-2.3.4
glibc-headers-2.3.4
libaio-0.3.105
libaio-devel-0.3.105
libgcc-3.4.6
libstdc++-3.4.6
libstdc++-devel3.4.6
make-3.80
numactl-0.6.4.x86_64
pdksh-5.2.14
sysstat-5.0.5
```

* 查询系统安装软件是否缺失： 
  `rpm -qa|grep 软件包名`
我所安装Oracle的服务器不能连接外网，只能通过下载安装包用FTP传输到服务器上安装，以上安装包缺失可以到一下地址查找： 
  http://vault.centos.org/6.5/os/x86_64/Packages/

* 安装软件命令(具体安装顺序自己调配，不能用通配符批量安装，会出现依赖问题)： 
  `rpm -ivh 软件名.rpm`
### 配置内核参数和资源限制
  使用vi编辑器对/etc/sysctl.conf文件进行编辑： 
` vi /etc/sysctl.conf` 
  文件末尾添加一下内容：
```
  fs.aio-max-nr = 1048576
  fs.file-max = 6815744
  kernel.shmall = 2097152
  kernel.shmmax = 536870912
  kernel.shmmni = 4096
  kernel.sem = 250 32000 100 128
  net.ipv4.ip_local_port_range = 9000 65500
  net.core.rmem_default = 262144
  net.core.rmem_max = 4194304
  net.core.wmem_default = 262144
  net.core.wmem_max = 1048576
```
  * 使内核参数生效，执行命令: 
    `sysctl -p`
### 创建Oracle相关用户
  * 创建用户组oinstall： 
      `groupadd –g 200 oinstall`
  * 创建用户组dba： 
      `groupadd –g 201 dba`
  * 创建oracle用户并指定用户组和Oracle用户的用户目录： 
      `useradd –u 440 –g oinstall –G dba –d /home/oracle oracle`

* 更改Oracle用户的用户登录密码： 
  `passwd oracle`

### 修改登录系统参数

* 使用vi编辑器对/etc/pam.d/login文件进行编辑： 
  `vi /etc/pam.d/login `
  在文件末尾添加:
  `session required pam_limits.so`
  
### 修改Oracle软件安装用户的资源限制
* 使用vi编辑器对/etc/security/limits.conf文件进行编辑： 
    `vi /etc/security/limits.conf `
    在文件末尾添加:
   ```
    oracle soft nproc 2047
    oracle hard nproc 16384
    oracle soft nofile 1024
    oracle hard nofile 65536
   ```
 ###  修改环境变量文件
   * 使用vi编辑器对/etc/profile文件进行编辑： 
   ```
    vi /etc/profile 
    在文件末尾添加：
    if [ $USER = "oracle" ]; then
    if [ $SHELL = "/bin/ksh" ]; then
    ulimit -p 16384
    ulimit -n 65536
    else
    ulimit -u 16384 -n 65536
    fi
    fi
   ```
    * 更新配置文件更改： 
    `source profile`
### 创建目录并分配权限
   * 创建目录 

    `mkdir /oracle`
   * 授权目录给当前用户/其他用户/用户组 可读可写可执行 

    `chmod -R 775 /oracle`
    `chown –R oracle:oinstall /oracle`

   * 切换到oracle帐号并添加oracle用户下面的环境变量： 

    `su – oracle`

   * 使用vi编辑器对用户目录下.bash_profile文件进行编辑： 

    `vi ~/.bash_profile`
在.base_profile里面添加如下内容（有些内容存在就不用加，对照着修改） 
ORACLE_HOME在配置时注意后面不要带有:分隔符，否则PATH会取不到； 
ORACLE_HOME的路径； 
ORACLE_SID是对应后面创建数据库SID的，可以随时更改； 
以下是配置内容：
```
PATH=$PATH:$HOME/bin
umask 022
export PATH
export ORACLE_BASE=/oracle
export ORACLE_SID=orcl      
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin:
```
### 安装数据库
* Ctrl+D注销Oracle用户，切换成root用户

* 解压Oracle 11g R2 数据库压缩包（在本文我已经把数据库压缩包用FTP软件传输到/tmp目录下），执行命令： 
```
cd /tmp 
unzip linux.x64_11gR2_database_1of2.zip 
unzip linux.x64_11gR2_database_2of2.zip
```
* 拷贝database/response/下面的dbca.rsp、db_install.rsp及netca.rsp三个文件至/home/oracle目录中： 
```
cp database/response/dbca.rsp /home/oracle/ 
cp database/response/db_install.rsp /home/oracle/ 
cp database/response/netca.rsp /home/oracle/ 
chmod 777 /home/oracle/dbca.rsp
```

* 使用vi编辑数据库安装的配置文件db_install.rsp： 

```
cd /home/oracle 
vi db_install.rsp 
```
修改如下参数:
```
Oracle.install.option=INSTALL_DB_SWONLY 
ORACLE_HOSTNAME= master 
UNIX_GROUP_NAME=oinstall 
INVENTORY_LOCATION=/oracle/oraInventory 
SELECTED_LANGUAGES=en,zh_CN 
ORACLE_HOME=/oracle/product/11.2.0/dbhome_1 
ORACLE_BASE=/oracle 
Oracle.install.db.InstallEdition=EE 
Oracle.install.db.DBA_GROUP=dba 
Oracle.install.db.OPER_GROUP=oinstall 
Oracle.install.db.config.starterdb.type=GENERAL_PURPOSE 
Oracle.install.db.config.starterdb.globalDBName=orcl 
Oracle.install.db.config.starterdb.SID=orcl 
Oracle.install.db.config.starterdb.characterSet=ZHS16GBK 
Oracle.install.db.config.starterdb.password.ALL=oracle 
DECLINE_SECURITY_UPDATES=true
```
* 切换到oracle 帐号，创建oraInventory目录： 
`su – oracle` 
`mkdir /oracle/oraInventory`

* 切换到刚才解压的Oracle安装文件根目录中： 
`cd /tmp/database`
* 开始执行安装操作： 
`./runInstaller -silent -ignorePrereq -responseFile /home/oracle/db_install.rsp`
在/oracle/oraInventory/logs/可以查看对应的安装日志文件。

* 上述执行成功会提示执行两个脚本 
Ctrl+D注销Oracle用户，切换成root用户 
执行orainstRoot.sh及root.sh两脚本： 
```
cd /oracle/oraInventory 
sh orainstRoot.sh 
cd /oracle/product/11.2.0/dbhome_1 
sh root.sh
```
* 切换成oracle用户： 
`su - oracle`

* 安装监听,直接执行监听脚本: 
`netca /silent /responseFile /home/oracle/netca.rsp`
### 安装数据库实例
* 使用vi编辑配置文件dbca.rsp： 
`vi dbca.rsp`
修改以下配置，后面5个都要删掉前面的#号改参数值:
```
GDBNAME="orcl"
SID="orcl"
DATAFILEDESTINATION="/oracle/oradata"
RECOVERYAREADESTINATION="/oracle/flash_recovery_area"
CHARACTERSET="ZHS16GBK"
TOTALMEMORY="800"
SYSPASSWORD = "password"
SYSTEMPASSWORD = "password"
```
上面配置注意去掉#,不然是注释不生效 
SYSPASSWORD和SYSTEMPASSWORD是sys和system数据库用户的默认密码（自己自行设置），不设置密码无法安装实例，显示终端一直滚动换行。

* 静默模式建实例（确保在oracle用户下执行）: 
```
cd ~ 
dbca –silent –responseFile ~/dbca.rsp
```
另外：删除数据库实例方法，更改以上配置文件中的OPERATION_TYPE,默认为createDatabase，变更为一下内容：

```OPERATION_TYPE = "deleteDatabase"```

执行命令： 
`dbca –silent –responseFile ~/dbca.rsp`

### 测试和修改Oracle用户密码有效期
* 执行命令： 
`sqlplus /nolog`

* SQLPlus： 
以sysdba身份登录： 
`conn / as sysdba`
查询用户密码有效时间： 
`SELECT * FROM dba_profiles s WHERE s.profile='DEFAULT' AND resource_name='PASSWORD_LIFE_TIME';`
修改有效时间为不限制： 
`ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;`

#### 附上一些命令查看Oracle端口和Oracle进程
* 查看Oracle开放的1521端口号： 
`netstat -lnp|grep 1521`

* 查看oracle进程： 
`ps -ef|grep oracle`

参考文章： 
http://docs.oracle.com/cd/E11882_01/install.112/e24326/toc.htm#CEGIHDBF 
http://haowen.blog.51cto.com/3486731/1599042 
https://zhuanlan.zhihu.com/p/22600543?utm_source=qq&utm_medium=social