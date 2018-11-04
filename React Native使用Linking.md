```
tags:react native
source_title:近日使用React Native Linking踩过的坑
source_url:https://www.jianshu.com/p/351c2f690569
```
<!--more-->

使用react native（以下简称rn）开发移动端app已经有四个月的时间了（包括第一个月的上手），感谢rn，让前端开发人员也能够开发原生的app。前几天遇到一个需求：打开第三方的支付应用并监听返回的结果。听上去这个需求并不难，然而使用rn来实现就会遇到大大小小的坑。为了能让其他开发人员少走弯路，在这里总结一下。

### 使用Linking

写这篇博客的原因还有一个：网上有很多关于Linking的博客，然而有深度的文章少之又少，大部分都是简单介绍了Linking的使用方法（我搜过好几篇文章内容和代码都是一样的）。

#### Linking基本使用方法

这里我建议去rn的[中文官网](https://link.jianshu.com?t=http://reactnative.cn/)学习，那里讲解的十分详细。通过查看文档我们了解到，Linking使用url来唤起系统应用或链接。其实Linking还可以唤起其他的app，前提条件是你的手机上已经安装了它。

#### 唤起其他app

使用Linking唤起其他app比较简单，只需要简单的两个步骤：1.检查该app能否被唤起，也就是检查该app是否已安装成功；2.唤起并传递参数。

Linking提供了canOpenURL这个方法，用来检测某个url是否可以打开：

```
Linking.canOpenURL('appName://').then(canOpen=>{
    ...
})
```

使用Linking打开app也比较简单，调用openURL方法即可：

```
Linking.openURL('appName://?params');
```

为了方便演示，我准备了两个app：lka和lkb。这两个应用功能比较简单，只含有一个button，点击的时候唤起另外一个app，同时传递参数。被唤起的app获取参数并alert出来。



![img](https://ws4.sinaimg.cn/large/006tNbRwly1fww64uchetj30b804vq2t.jpg)



![img](https://ws4.sinaimg.cn/large/006tNbRwly1fww655hf8nj30az04cwec.jpg)



现在，我需要在lka里唤起lkb，代码是这样的：

```
Linking.canOpenURL('lkb://').then(canOpen=>{
    if(canOpen){
        Linking.openURL('lkb://?orderId=1');
    }
});
```

你如果直接点击button的话是肯定不会跳转的，因为canOpen是false。可能有些人会问：我明明已经安装了lkb，为什么会打不开？这里就要说到scheme了，我们可以把它理解为一个app的标识，当url的协议部分与scheme匹配时，app就会被打开。

我们需要在AndroidManifest.xml里进行相关的配置：

```
<activity
    android:name=".MainActivity"
/*add  -->*/ android:launchMode="singleTask"
    android:label="@string/app_name"
    android:configChanges="keyboard|keyboardHidden|orientation|screenSize"
    android:windowSoftInputMode="stateAlwaysHidden|adjustPan"
>
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
        <action android:name="android.intent.action.DOWNLOAD_COMPLETE"/>    
    </intent-filter>
/*add start*/
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="lka" />
    </intent-filter>
/*add end*/
</activity>
```

我们添加了两块代码：launchMode和intent-filter。关于launchMode可以参考[这篇文章](https://link.jianshu.com?t=http://blog.csdn.net/liuhe688/article/details/6754323/)学习。我们新添加了一个intent-filter，关于intent-filter的相关知识可以自行上网搜索。Intent-filter顾名思义就是意图过滤器，它就像过滤器一样筛选每次传过来的url，只要有符合条件的url就会执行intent-filter里面的相关操作。

在本代码中，我们在intent-filter里配置了scheme，只要url的协议为lka就会打开lka app。请注意，不要把两个intent-filter合并到一起，虽然你的app能够正常运行，但是你将会在手机上找不到app的图标。

再次点击openLkb按钮，唤起成功。



![img](https://ws3.sinaimg.cn/large/006tNbRwly1fww65gdo59j309t05gdfp.jpg)



```
//lkb
componentDidMount(){
    Linking.getInitialURL().then(url=>{
        alert(url);
    })
}
```

#### 开始踩坑

现在，lka已经能够成功唤起lkb了，并且传递的参数在lkb里也能接收到，那么反过来也是一样的？现在我们增加一下需求，只要lka从后台运行到了前台或者首次打开均弹出url。

实现起来比较简单，我们需要监听app的运行状态，需要用到AppState：

```
//lka
import {
    Linking,
    AppState
} from 'react-native'
...
componentDidMount(){
    AppState.addEventListener('change',(appState)=>{
        if(appState=='active'){
            Linking.getInitialURL().then(url=>{
                alert('stateChange'+url)        
            })
        }
    })
    Linking.getInitialURL().then(url=>{
        alert('didmount:'+url);
    })
}
//lkb
openLka(){
    Linking.canOpenURL('lka://').then(res=>{
        if(res){
            Linking.openURL('lka://?name=sunnychuan&age=23');
        }
    });
}
```

同样的，为lka配置好AndroidManifest.xml，把scheme配置成lka。我们首先把lka关掉，然后在lkb里唤起它，结果如下：



![img](https://ws2.sinaimg.cn/large/006tNbRwly1fww65z47l8j309z05l0sp.jpg)



我们通过任务管理切回到lkb，然后点击按钮再次唤起lka，你得到的结果还是正确的：



![img](https://ws2.sinaimg.cn/large/006tNbRwly1fww65zznjkj309y05oq2x.jpg)

image.png

先别急着高兴，我们把lka和lkb都关掉，重新打开lka，你将得到“didmount:null”的结果。这是当然的，因为你是自己打开的嘛。

然后，我们通过lka唤起lkb，再通过lkb唤起lka，你得到的结果如下：



![img](https://ws3.sinaimg.cn/large/006tNbRwly1fww664oqijj309y05jq2t.jpg)

image.png

发现问题没有？你可以多尝试几次，最终会发现一个规律：`AppState.addEventListener`里面获取的url的值永远与`componentDidMount`里直接获取的url的值相同。只要首次获取的是null，那么以后永远都是null；只要首次获取的是有值的，那么以后永远都是有值的。

我们看一下Linking的源码吧：

```
//node_modules/react-native/ReactAndroid/src/main/java/com/facebook/react/modules/intent/IntentModule.java
...
@ReactMethod
public void getInitialURL(Promise promise) {
    try {
        Activity currentActivity = getCurrentActivity();
        String initialURL = null;
        if (currentActivity != null) {
            Intent intent = currentActivity.getIntent();
            String action = intent.getAction();
            Uri uri = intent.getData();
            if (Intent.ACTION_VIEW.equals(action) && uri != null) {
                initialURL = uri.toString();
            }
        }
        promise.resolve(initialURL);
    } catch (Exception e) {
        promise.reject(new JSApplicationIllegalArgumentException(
        "Could not get the initial URL : " + e.getMessage()));
      }
}
```

每一次调用getInitialURL，android端都会获取当前的activity，并且返回activity对象里面的data值（uri）。

我们可以把`AppState.addEventListener`里面获取的url称为脏数据。通过上网翻阅相关资料后我发现，原生的android跳转其实是activity之间的跳转。现在回过头来看一下我们的xml，只有一个activity。你可以尝试一下把activity拆成两个，其中一个专门用来配置scheme，运行结果并不符合我们的预期。

原因是什么呢？这是因为react native只配置了一个activity，整个应用都是在这个activity里运行的。当lka尚未启动，由lkb唤起时，lka的activity会执行`onCreate`生命周期钩子，初始化intent，此时你将会得到全新的url：null。当lka已经运行在后台，由lkb唤起时，lka的activity不会执行`onCreate`方法，你得到的url还是旧值：null。

解决方案参考了[这篇文章](https://link.jianshu.com?t=http://blog.csdn.net/langtuteng136/article/details/44812143)，在android/app/src/main/java/com/lka/MainActivity.java的最下面添加：

```
@Override
public void onNewIntent(Intent intent){
    super.onNewIntent(intent);
    setIntent(intent);
}
```

重新打包之后（每次修改android文件夹里面的东西后都需要重新打包才能生效），我们再尝试一下：1.关掉lka和lkb；2.打开lka，你会收到null值；3.唤起lkb；4.由lkb唤起lka。你得到的结果如下：



![img](https://ws4.sinaimg.cn/large/006tNbRwly1fww66dkmlwj30a305dq2x.jpg)

image.png

结果与我们的预期相符。

#### 另一个问题

其实这里还有一个潜在的问题。同样的，通过lkb唤起lka，你将接收到正确的参数“lka://?name=sunnychuan&age=23”。然后，我们手动将lka运行在后台，然后重新让它运行在前台（不通过lkb唤起），你得到的值依旧是“lka://?name=sunnychuan&age=23”。



![img](https://ws3.sinaimg.cn/large/006tNbRwly1fww66kzx9mj30aw04xmx0.jpg)





![img](https://ws3.sinaimg.cn/large/006tNbRwly1fww66q2w16j307705iwef.jpg)





![img](https://ws1.sinaimg.cn/large/006tNbRwly1fww66y1mc9j30a8065weh.jpg)



从代码上来看，这个结果是正确的，因为没有人更改activity的url，所以值一直没有改变；从需求上来看，这个结果是不正确的。我们假设lka在监听函数里获取url的参数，如果url有参数就跳转到支付成功页面。现在，只要lka由后台运行到前台都会跳转到支付成功页面（没准真的有用户喜欢来回切换应用）。这样显然是不合理的，我们期望的是：只有lka是由lkb唤起的（无论lka已经运行在后台还是尚未启动），才会跳转到支付成功页面。

我的思路是，在`getInitialURL.then`里，首先将activity的intent重置成默认值，这需要我们自己封装android方法，我们先看一下封装后的代码：

```
//lka
import {
    Linking,
    AppState,
    NativeModules
} from 'react-native'
...
componentDidMount(){
    AppState.addEventListener('change',(appState)=>{
        if(appState=='active'){
            Linking.getInitialURL().then(url=>{
                NativeModules.LinkingCustom.resetURL().then(()=>{
                    alert('stateChange'+url)
                });     
            })
        }
    })
    Linking.getInitialURL().then(url=>{
        NativeModules.LinkingCustom.resetURL().then(()=>{
            alert('didmount'+url)
        }); 
    })
}
```

下面我们来为lka封装一下这个方法，如果你是安卓工程师，这点操作就是小儿科；如果你是前端工程师，并且对安卓不了解，跟着我一步一步写，很简单。

#### CustomLinking

首先，我们需要在与MainActivity.java同级的目录下新建一个java文件，导入必要的java包：

```
//android/app/src/main/java/com/lka/LinkingCustom.java
package com.lka;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import com.facebook.react.bridge.JSApplicationIllegalArgumentException;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;
```

其次，创建CustomLinking类，你需要继承ReactContextBaseJavaModule类，并实现getName函数。这里的getName函数是必须的，返回值就是你在js端通过NativeModules拿到的模块名"LinkingCustom"一致：

```
public class LinkingCustom extends ReactContextBaseJavaModule {
    public LinkingCustom(ReactApplicationContext reactContext) {
        super(reactContext);
    }
    @Override
    public String getName() {
        return "LinkingCustom";
    }
}
```

然后，我们实现重置intent的函数，将其命名为resetURL：

```
...
@Override
public String getName() {
    return "LinkingCustom";
}
//必须添加@ReactMethod关键字才能在js侧被调用
@ReactMethod
//不可以直接将结果return，因为js侧是异步获取结果的，这里将结果返回成promise，
public void resetURL(Promise promise) {
    try {
        Activity currentActivity = getCurrentActivity();
        if (currentActivity != null) {
            Intent intent = new Intent(Intent.ACTION_MAIN);
            currentActivity.setIntent(intent);
        }
        promise.resolve(true);
    } catch (Exception e) {
        promise.reject(new JSApplicationIllegalArgumentException("Could not reset URL"));
      }
}
```

#### LinkingCustomReactPackage

我们在同级下新建LinkingCustomReactPackage.java文件，用来注册模块：

```
//android/app/src/main/java/com/lka/LinkingCustomReactPackage.java
package com.coomarts;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
//必须实现ReactPackage接口和createNativeModules方法
public class LinkingCustomReactPackage implements ReactPackage{
    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext){
        List<NativeModule> modules=new ArrayList<>();
        //在这里添加你想注册的模块
        modules.add(new LinkingCustom(reactContext));
        return modules;
    }

    @Override
    public List<Class<? extends JavaScriptModule>> createJSModules(){
        return Collections.emptyList();
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContent){
        return Collections.emptyList();
    }
}
```

#### 为包管理添加实例

最后一步就是在MainApplication.java里添加实例，与添加第三方组件实例相同：

```
//android/app/src/main/java/com/lka/MainApplication.java
...
@Override
protected List<ReactPackage> getPackages() {
    return Arrays.<ReactPackage>asList(
        new SQLitePluginPackage(),
        new MainReactPackage(),
        new RNDeviceInfo(),
        new VectorIconsPackage(),
        new LinkingCustomReactPackage()
    );
}
```



除非lka是由lkb唤起的，否则在其他情况下运行lka得到的均是null值。