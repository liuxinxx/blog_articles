```
tags:react native
```
目前使用一键分享比较主流的两个SDK：ShareSDK、友盟；

又因为友盟功能比较多且比较全，比如说友盟统计、友盟推送等，所以本文重点介绍的是友盟分享功能在rn上的应用以及要注意的点。 <!--more-->

### **react native绑定SDK两种方案（一个原理）：**

　　1.自己去要绑定的SDK官网下载SDK包，按照SDK安装指南分别在android/iOS上按步骤配置，然后在RN注册Package和Module实现RN和原生之间的通讯；

　　2.使用别人已经写过的Package和Module+SDK本身的配置，直接拿到rn项目中用；

总结：可以看出来第二种其实是比较偷懒的方式，但是可以实现功能，而且Package和Module的书写几乎一样都是大同小异的代码（除了Module暴露调用方法的顺序不同之外），所以如果市面上已经有相应的绑定大可直接拿来使用。

 

## 一键分享实现方案

我们本文要使用的友盟分享库是：[react-native-share](https://github.com/songxiaoliang/react-native-share) 

GitHub地址：<https://github.com/songxiaoliang/react-native-share>

配置详见上面GitHub里README部分，这里不在重复，本文重点要说的是注意事项。

 

## 注意事项（Android部分）

除了上文GitHub里面的10个步骤之后，接下来的配置也是必不可少的.

**1.需要在app目录build.gradle文件dependencies里面添加如下配置：**
```
dependencies {

    ...

　　//友盟分享

　　compile files('libs/weiboSDKCore_3.1.4.jar')

　　compile files('libs/wechat-sdk-android-with-mta-1.1.6.jar')

　　compile files('libs/umeng_social_tool.jar')

　　compile files('libs/umeng_social_net.jar')

　　compile files('libs/umeng_social_api.jar')

　　compile files('libs/SocialSDK_WeiXin_Full.jar')

　　compile files('libs/SocialSDK_Sina_Full.jar')

　　compile files('libs/SocialSDK_facebook.jar')

　　compile files('libs/SocialSDK_QQ_Full.jar')

　　compile files('libs/SocialSDK_alipay.jar')

　　compile files('libs/open_sdk_r5781.jar')

　　compile files('libs/libapshare.jar')

　　compile 'com.android.support:multidex:'

}
```
**2.需要注意修改apshare、module、wxapi、WBShareActivity.java里面的包名改成自己项目的包名；**

**3.MainActivity.java需要添加引用：**

```
import com.umeng.analytics.MobclickAgent;
import android.content.Intent;
import android.os.Bundle;
import com.umeng.socialize.UMShareAPI;
```

**4.MainApplication.java需要添加引用：**

```
import com.xxx.module.SharePackage;  //xxx为你的包名
import com.umeng.socialize.Config;
import com.umeng.socialize.PlatformConfig;
import com.umeng.socialize.UMShareAPI;
```

**5.以上配置完毕，运行依然报错“com.android.dex.DexIndexOverflowException: method ID not in [0, 0xffff]: 65935”**

解决方案：

①.在项目的build.gradle文件的dependencies 节中添加分包设置：

```
dependencies { 
   ... 
   compile 'com.android.support:multidex:' 
   ... 
}
```

②.通过在defaultConfig节中设置multiDexEnabled标签为true，开启multi-dexing支持.

```
defaultConfig { 
    ... 
    multiDexEnabled true 
    ... 
}
```

