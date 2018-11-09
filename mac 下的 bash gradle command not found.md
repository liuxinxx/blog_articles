```
tags:other
source_title:mac 下的 bash gradle command not found
source_url:https://blog.csdn.net/u013424496/article/details/52684213
```



最近在用android studio 使用命令行打包的时候出现 bash gradle command not found这个问题，其实也就是因为自己唑gradle的环境变量给弄丢了。。但是由于来自大山的孩子对于mac不是很熟，所以不知道咋去找这个gradle的路径 <!--more-->

更不知道怎么去配置了，这里就以这个例子去说下怎么配置环境变量和去找一个文件的路径

##### 1.gradle路径的查找
直接贴图吧

![img](https://ws1.sinaimg.cn/large/006tNbRwly1fx1xprzj57j30l60bxgpz.jpg)

![img](https://ws4.sinaimg.cn/large/006tNbRwly1fx1xq1661ij30jp0bign7.jpg)

![img](https://ws1.sinaimg.cn/large/006tNbRwly1fx1xq7srgij30i00ae0tu.jpg)

然后点击这个gradle 右键 显示简介 复制下蓝色的
 你会得到这一行 
`/Applications/Android Studio.app/Contents/gradle/gradle-2.14.1/bin`

![img](https://ws3.sinaimg.cn/large/006tNbRwly1fx1xqfalj8j30b40feta6.jpg)

##### 2.环境变量的配置
打开terminal终端命令窗口

* 1、使用命令[cd ~]到home目录下      cd ~
* 2、接着使用     touch .bash_profile   
* 3、然后   open -e .bash_profile   会以文本的形式打开文件（如果2中不存在的话就新建一个.bash_profile文件）
* 4、在文件夹中添加如下带有选中颜色代码，如果不能操作是则是权限问题需要修改权限，具体下面会有介绍
![img](https://ws4.sinaimg.cn/large/006tNbRwly1fx1xrraw4jj30y008ajtj.jpg)

注意：因为复制后的链接中Android Studio.app中间有空格路径中不能带有空格之类的特殊字符。需要在空格前加\进行转意，如上 
保存退出，如果不能操作的话可以将.bash_profile复制粘贴一份，将原来的删除或者添加操作权限


export GRADLE_HOME=/Applications/Android\ Studio.app/Contents/gradle/gradle-2.8

export PATH=${PATH}:${GRADLE_HOME}/bin

啰嗦这么多也就是把红色的改成你自己滴  记得那个 \     在空格之前加
##### 5、最后用`source .bash_profile`命令使用修改后的

##### 6、操作完成后使用命令[gradle -v]看是否出现版本号  `gradle -v`
```
------------------------------------------------------------

Gradle 2.10

------------------------------------------------------------

 

Build time:   2015-12-21 21:15:04 UTC

Build number: none

Revision:     276bdcded730f53aa8c11b479986aafa58e124a6

 

Groovy:       2.4.4

Ant:          Apache Ant(TM) version 1.9.3 compiled on December 23 2013

JVM:          1.8.0_65 (Oracle Corporation 25.65-b01)

OS:           Mac OS X 10.11.1 x86_64

```

意外情况：
##### 7、如果不是这种情况的话可能会出现gradle 和gradle.bat执行权限不够的情况，进行权限修改
到刚才的bin目录下使用命令[ls -l]查看目录下文件的权限 

![img](https://ws1.sinaimg.cn/large/006tNbRwly1fx1xt70x42j30py044my0.jpg)如果中间没有x说明没有可执行权限，以上截图中已经做过修改，所以有可执行权限了。 
使用命令

```
chmod +x gradle.bat
chmod +x gradle
```

将权限加上，再出外边去执行gradle -v就好了，如果还不行的话重新启动一下应该就没问题了。然后就可以使用gradle的命令执行啦