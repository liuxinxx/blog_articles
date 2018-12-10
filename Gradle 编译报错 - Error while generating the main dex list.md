```
tags:gradle
source_title:Gradle 编译报错 - Error while generating the main dex list
source_url:https://blog.csdn.net/stupid56862/article/details/81130589
```



今天编译项目,编译报错。

```
FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:transformClassesWithMultidexlistForInstant_runDebug'.
> com.android.build.api.transform.TransformException: Error while generating the main dex list.
```
习惯上直接 copy 错误 ,在 stackoverflow 上查找答案。 
花了十几分钟仍然没找到答案。 
直接在 Android Studio 中的命令行中运行。
`gradle  assembleDebug  --stacktrace`

发现了以下错误 :
```
Caused by: com.android.tools.r8.errors.CompilationError: Program type already present: okhttp3.Authenticator$1
```
原因很简单 jar 包冲突了 。 
我使用了一个第三方库,第三方库依赖了 OkHttp 。 而我项目中原本就有 OkHttp 。
```
 compile ("com.facebook.react:react-native:0.55.4")
```
找到问题的原因后,解决就很快了。直接移除第三方库所依赖的 OkHttp 即可。
```
    compile ("com.facebook.react:react-native:0.55.4") {
        exclude group: 'com.squareup.okhttp3'
    }
```
如果你也遇到了这样的报错 , 可能是 jar 包冲突 。 
通常这样的问题是在 Gradle 中新添加的依赖第三方库引起的。

### 如何来排查复杂些的问题呢 ?
Android 项目中大部分通过 Gradle 远程依赖, 建议通过查看依赖树来排查问题 : 
例如我的 Android 工程主 Module 名称为 app 。我想查看依赖树,进入项目根目录,执行命令:

`gradlew   app:dependencies`

Terminal 中会打印出很多文字 , 如 :



其中 recyclerview 是我在 build.gradle 中直接依赖的。

`implementation 'com.android.support:recyclerview-v7:26.1.0`

而下面三行代码是 recyclerview 所依赖的库。
```
|    +--- com.android.support:support-annotations:26.1.0 (*)
|    +--- com.android.support:support-compat:26.1.0 (*)
|    \--- com.android.support:support-core-ui:26.1.0 (*)
```
因此大多数情况下的冲突是因为,依赖库所依赖的其他库版本冲突。

想要处理这种问题,我给大家介绍几种方法。

### exclude
exclude : 剔除依赖 。还给大家举上面的例子。 
recyclerview 不想要依赖 `com.android.support:support-annotations:26.1.0` 怎么办 ? 
有办法 :
```
    implementation ('com.android.support:recyclerview-v7:26.1.0'){
        exclude group: 'com.android.support', module: 'support-annotations'  // 根据组织名 + 构建名剔除
        // 你也可以分别通过  group 和 module 剔除 对应的模块。
    }
```
执行后的依赖树如下 :
```
+--- com.android.support:recyclerview-v7:26.1.0
|    +--- com.android.support:support-compat:26.1.0 (*)
|    \--- com.android.support:support-core-ui:26.1.0 (*)
```
### force
force : 强制指定依赖版本。 
例如,我想要所有` com.android.support:support-annotations:26.1.0 `的依赖版本为 27.1.1 怎么办呢 ? 
在只需要在 build.gradle 中加上 force true 即可 :
```
   implementation("com.android.support:support-annotations:27.1.1"){
        force true
    }
```
执行后查看依赖树的结果 :
```
+--- com.android.support:recyclerview-v7:26.1.0
|    +--- com.android.support:support-annotations:26.1.0 -> 27.1.1
|    +--- com.android.support:support-compat:26.1.0 (*)
|    \--- com.android.support:support-core-ui:26.1.0 (*)
```
大家看到多了 -> 27.1.1 . 也就是原依赖版本为 26.1.0 ,在工程中修改依赖为 27.1.1 。

### transitive
transitive : 依赖传递特性,使用的时候,通常设置为 false 。即关闭依赖传递

例如项目中不希望 recyclerview 使用它所依赖的库 :
```
|    +--- com.android.support:support-annotations:26.1.0 (*)
|    +--- com.android.support:support-compat:26.1.0 (*)
|    \--- com.android.support:support-core-ui:26.1.0 (*)
```
在只需要在 build.gradle 中加上 transitive false 即可 :
```
 implementation ('com.android.support:recyclerview-v7:26.1.0'){
        transitive  false
 }
```
执行后查看依赖树的结果 , recyclerview 的依赖都消失了。当然这是一个危险的操作,因为 
缺少依赖,你可能无法正常编译。最好确认你项目中已经依赖了你所剔除在外的库。

```+--- com.android.support:recyclerview-v7:26.1.0```
上述操作等同于 :
```
 implementation('com.android.support:recyclerview-v7:26.1.0') {
        exclude group : 'com.android.support'
  }
```
因为 recyclerview 依赖的三个库组织名都是 com.android.support

总结
解决冲突用的最多是 force 和 exclude 。 
本来这么简单一个问题,应该在1分钟内解决的。却前前后后花了 十几分钟。 
发现自己太依赖 Google 了。 
首先应该是锻炼自己排查问题的能力,然后再面向 Github 编程 和 面向 stackoverflow 编程