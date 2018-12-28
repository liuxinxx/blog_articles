```
tags:react native
```
遇到了一个问题，安装之后第一次打开时，在有的Android手机上崩溃，之后再次运行就好了，好多Android机型都遇到这种情况，定位问题，发现是之前加载的第三方开源控件：**react-native-update**（热更新）导致的，为了软件的稳定性，不得不把刚刚没集成多久的热更新删除掉。
<!--more-->
#### 一. RN部分

1. 输入：npm uninstall react-native-update

```
注：这里的react-native-update是你要删除的组件名，我这里统一用这个来演示。
但是你会发现，在RN项目目录下的package.json文件中，这个组件的依赖依旧存在。
```

1. 删除掉在RN的package.json文件中的依赖
2. 输入：npm uninstall --save

```
如果是组件作为devDependencies，需要加上-D，
如果是从optionalDependencies中删除，还需要加上-o的参数，
我为了保险能删干净，直接输入一下命令，见第四部：
```

1. 输入：npm uninstall -s -D -O
    然后进入node_modules文件夹内，你会很高兴的发现终于你的这个组件包不在了。

#### 二. Android部分

然后编译运行在 **android** 上，发现，各种编译失败，所以还需要在native中删除相应的依赖。

1. 进入项目下的**android**目录下，然后打开**setting.gradle**，删除下面两行依赖：

```react
include ':react-native-update'
project(':react-native-update').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-update/android')
```

1. 然后进入 **android/app** 目录下，打开**build.gradle**，删除**dependencies**代码块内的一行依赖：

```
 compile project(':react-native-update')
```

1. 打开**android/app/src/main/java/com/包名/MainApplication.java**,找到 **RN** 调用的原生方法

```
new ReactUpdatePackage()
有的第三方不需要，属于RN调用原生那块代码
```

删除这行代码。

1. 去 **MainApplication** 文件中删除相关引入包。

#### 三. RN代码部分

如果你在RN项目中已经用了这个组件，在你调用的**js**文件中还要删除相关代码。

#### 四. ios部分

```
注：这部分我没有用到，主要是为了文章完成性，直接从参考文章拷过来的。
```

1. 打开**xcode**，找到**AppDelegate.m**，然后删除以下导入的代码：

```
#import <AVFoundation/AVFoundation.h>  // import
```

同时还要删除下面代码块内的导入代码：具体需要参考开源组件的说明：

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  ...  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];  // allow
  ...
}
对于react-native-video来说就是上面代码快中红色标记的那行代码，删之。
```

1. 此时编译**ios**，你会发现报了10多个错误，头大了，下面再继续删除：打开**xcode**，进入左侧主目录的**Libraies**中，右键删除这个库：**RCTVideo.xcodeproj** 

![2139461-c4d5d10b349bbab7](https://ws3.sinaimg.cn/large/006tNbRwly1fvmw1o4w6aj31kw0t2dmp.jpg)



1. 点击左侧你的第一个根目录（我的是first），接着点击右侧的**Build Phases**，打开下面的**Link Binary With Libraties**,找到你的依赖：我这里是**libRCTVideo.a**, 点击选中，最后点击下面的‘-’删除



![2139461-0b2b9cadb08e25c5](https://ws4.sinaimg.cn/large/006tNbRwly1fvmw0xd9rej31kw0sial4.jpg)

1. 点击**build Phases**同一行中的**Build Setting**，找到**Header Search Paths**,点击左侧小箭头展开，然后双击右侧的第一行目录，找到你的组件路径，点击下面的，减号删除你的组件的路径，如下所示：



![2139461-798d9bc1e7013d63](https://ws2.sinaimg.cn/large/006tNbRwly1fvmw4kdh8rj31dg13047j.jpg)





 最后在

xcode

中编译，成功。