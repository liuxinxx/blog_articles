```
tags:android
source_title:Mac环境下反编译apk
source_url:https://www.jianshu.com/p/dda9ff90a3c5
```

这里讲三种 <!--more-->

- Android Studio 2.2版本以上的APK Analyzer
- Android-classyshark
- dex2jar & jd-gui & apktool

## Android Studio 2.2的APK Analyzer

- 直接把需要反编译的apk直接拖到Android Studio的图标上即可。（这个亲测得Android Studio最小化的时候拖，拖完在点出来就有了）

或者

- 选项Build-->Analyze APK,然后选择要反编译的apk。



![img](https://ws1.sinaimg.cn/large/006tKfTcly1g13eubdpnxj308o095gm3.jpg)

选择apk文件.png

然后直接将apk给反编译出来。看图：



![img](https://ws4.sinaimg.cn/large/006tKfTcly1g13euegki1j315z0u048f.jpg)

反编译.png



![img](https://ws4.sinaimg.cn/large/006tKfTcly1g13eueqbrej314k0kujvg.jpg)

反编译1.png

这种方法可以获取到xml，以及图标等资源文件，但是我们发现在java代码部分只给出了方法数，方法名，并没有方法里具体的代码(在没有被加固的情况下)，这点有点不满意。后面有方法，暂且先按下，看看刚刚那几个文件夹以及文件干嘛的，看图：



![img](https://ws2.sinaimg.cn/large/006tKfTcly1g13eugj11mj314k0kujvg.jpg)

文件&文件夹.png

简要说明：

- assets文件夹：原始资源文件夹，对应着Android工程的assets文件夹，一般用于存放原始的图片、txt、css等资源文件。
- lib：存放应用需要的引用第三方SDK的so库。比如一些底层实现的图片处理、音视频处理、数据加密的库等。而该文件夹下有时会多一个层级，这是根据不同CPU 型号而划分的，如 ARM，ARM-v7a，x86等。
- META-INF：保存apk签名信息，保证apk的完整性和安全性。
- res：资源文件夹，其中的资源文件包括了布局(layout)，常量值(values)，颜色值(colors)，尺寸值(dimens)，字符串(strings)，自定义样式(styles)等。
- AndroidManifest.xml文件：全局配置文件，里面包含了版本信息、activity、broadcasts等基本配置。不过这里的是二进制的xml文件，无法直接查看，需要反编译后才能查看。
- classes.dex文件：这是安卓代码的核心部分,，dex是在Dalvik虚拟机上可以执行的文件。这里有classes.dex和classes2.dex两个文件，说明工程的方法数较多，进行了dex拆分。
- resources.arsc文件：记录资源文件和资源id的映射关系

## Android-classyshark

这种是看的[隋胖胖](https://www.jianshu.com/p/9e0d1c3e342e)里提供的方法。
 下载地址：[https://github.com/google/android-classyshark/releases](https://link.jianshu.com?t=https://github.com/google/android-classyshark/releases)，下载下来之后是一个可执行的jar文件，在终端执行

```
java -jar Classyshark.jar
```

即可打开图形化界面。在打开的图形操作界面中拖入待目标apk，即可展示出反编译之后的结果。
 这个实际和AndroidStudio的APK Analyzer功能差不多，也不能看到java代码。截个图感受一下。



![img](https://ws1.sinaimg.cn/large/006tKfTcly1g13eufcb2mj31740oy78g.jpg)

右边是输入的命令.png



![img](https://ws2.sinaimg.cn/large/006tKfTcly1g13euc658qj314k0kujvg.jpg)

也不能看到方法里具体代码，但是获取一下资源文件还是可以的。

## dex2jar & jd-gui & apktool

下面说下这个方法，重头戏。这个最恶心的就是下载了，mac环境下有很多讲这种方法的但是要么就是下载难要么就是给的命令行不懂，在这里，不要管别人那怎么样了，按我的走，保证走通。首先下载，话不多说，直接上传网盘。

- 反编译代码，也就是java文件：
  1. [dex2jar：把dex文件转换成jar文件](https://pan.baidu.com/s/1hsN6vVQ)
  2. [jd-gui：把jar文件转换成java文件](https://pan.baidu.com/s/1eSxlYzo)
- 反编译资源，也就是res文件
  1. [apktool：apk逆向工具](https://pan.baidu.com/s/1bpB5qVX)

#### 反编译代码

1. 首先解压dex-tool-2.0.zip得到dex2jar-2.0文件夹，mac环境下需要的三个文件是 d2j_invoke.sh & d2j-dex2jar.sh & lib，他们在同一目录级别。看图：



![img](https://ws4.sinaimg.cn/large/006tKfTcly1g13eujnkhsj30zi0u0aif.jpg)

1. 将apk文件的后缀改为zip，并解压（这时候其实我们可以得到该app使用的图片资源，但是xml是看不了的，还是需要反编译资源），然后将classes.dex文件移动到dex2jar-2.0的文件夹目录下，即与上述三个文件统一目录。看图：



![img](https://ws1.sinaimg.cn/large/006tKfTcly1g13eue0969j314j0m27bc.jpg)

1. 打开终端cd 到该目录下输入命令：

```
chmod a+x d2j_invoke.sh
chmod a+x d2j-dex2jar.sh
```

给这两个文件添加可执行权限。然后输入命令：

```
sh d2j-dex2jar.sh classes.dex
```

如图：



![img](https://ws4.sinaimg.cn/large/006tKfTcly1g13eufsbt5j315z0u048f.jpg)

111.png

这时候就会在dex2jar-2.0目录下生成一个classes-dexjar.jar文件，如图：



![img](https://ws3.sinaimg.cn/large/006tKfTcly1g13eui1xvvj30zi0pkjy5.jpg)

打开jd-gui-osx-1.4.0,使用JD-GUI.app打开classes-dexjar.jar即可。



![img](https://ws4.sinaimg.cn/large/006tKfTcly1g13eug3eh6j314k0kujvg.jpg)

结果展示一下：



![img](https://ws1.sinaimg.cn/large/006tKfTcly1g13euexwr2j31740oy78g.jpg)

是可以看到具体的代码的。

#### 反编译资源

在我的百度网盘里下载apktool，解压缩后有两个文件apktool.sh & apktool.jar,将apk文件移动到与上述两个文件相同的目录,终端cd到该目录，执行命令：

```
sh apktool.sh apktool d xxx.apk
```

如图：



![img](https://ws3.sinaimg.cn/large/006tKfTcly1g13euirmxdj31000di43b.jpg)

结束以后，就会多出一个xxx的文件夹，内容如下：



![img](https://ws3.sinaimg.cn/large/006tKfTcly1g13eugtqmij314k0kujvg.jpg)

反编译资源完成，xml文件都可以看。

1. 修改后重新打包命令：

```
sh apktool.sh b xxx -o Newxxx.apk
```

## 总结

这三种方法就介绍完了，反编译代码都是在apk未加固的情况下完成的，加固的就不要试了。但是，资源文件在apk加固的情况下也可以去获取的，如果想要一些小图标啥的，没有问题的。如果只是需要资源文件我建议就Android Studio自带的就很好了，只需要小手拖一拖。第三种方法需要的文件在我网盘上下就可以了。
 有问题留言，谢谢。