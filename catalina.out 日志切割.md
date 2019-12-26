```
tags:tomcat
```



随着业务发展，catalina.out 越来越大，运维很不方便，研究了一下catalina分割方法。

下面记录使用cronolog切割catalina的方法

首先安装 下载安装包

> 1.下载安装包
> \#wget  https://files.cnblogs.com/files/crazyzero/cronolog-1.6.2.tar.gz
> 2.解压安装包
> \#tar zxvf cronolog-1.6.2.tar.gz
> 3.进入解压文件
> \#cd cronolog-1.6.2
> 4.使用默认配置安装
> \#./configure 
> \#make&&make install
> 5.查找文件安装位置
> \# which cronolog
> \# /usr/local/sbin/cronolog 

至此 安装结束

下面配置Tomcat

进入tomcat/bin目录下 找到Catalina.sh 文件 进入修改以下内容

> \#vim bin/catalina.sh
> 1.输入下面参数
> /touch "$CATALINA_OUT" 
> 并修改为 #touch "$CATALINA_OUT"（注释掉 达到不生成CATALINA_OUT文件的目的）
> 2.往下查找十几行找到
>  org.apache.catalina.startup.Bootstrap "$@" start \
>    \>> "$CATALINA_OUT" 2>&1 "&"
> 3.将其替换为下面
> org.apache.catalina.startup.Bootstrap "$@" start 2>&1 | /usr/local/sbin/cronolog "$CATALINA_BASE"/logs/catalina.out.%Y-%m-%d_%H.log >> /dev/null &
> 4.往下查找十几行，同上找到同样脚本 并替换

解释下替换的脚本内容
1./usr/local/sbin/cronolog为which cronolog 查找出的工具安装目录 如果和我安装不一致，请自行修改
2."$CATALINA_BASE"/logs/为日志生成目录，一般不要修改
3.catalina.out.%Y-%m-%d_%H.log 为生成日志文件名，可以根据自己的需要修改后面参数，规则是参数变化就会生成新的日志文件，如我这里最后用%H（小时）结尾，那么就会根据小时数生成新的文件，自行修改

> y   两位数的年份(00 .. 99)
> Y   四位数的年份(1970 .. 2038)
> m   月数 (01 .. 12)
> d   当月中的天数 (01 .. 31)
> H   小时(00..23)
> I   小时(01..12)
> p   该locale下的AM或PM标识
> M   分钟(00..59)
> S   秒 (00..61, whichallows forleap seconds)