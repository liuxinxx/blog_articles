```
tags:react native
```



本问是React Native在开发使用过程中遇到的问题的总结，会持续更新。<!--more-->

#### 开源组件源码错误

##### `/node_modules/react-native-scrollable-tab-view/SceneComponent.js`

> 第九行取消 ...props后边的,

##### `/node_modules/react-native-audio/index.js`

> 添加 PermissionsAndroid（安卓权限）



### error: bundling failed: Error: Unable to resolve module `scheduler/tracing` from



#### 这个错误是由于RN版本升级造成的有两种姐姐思路

##### 1.退回版本（哈哈哈哈...嗝....👻👻👻）

`如果是不小心把版本升级了，可以使用此方法😆😆😆😆👌`

##### 2.安装~~

`我试过不起作用`[传送门](https://github.com/facebook/react-native/issues/21150)


![image-20181107105434882](https://ws3.sinaimg.cn/large/006tNbRwly1fwzb9tvccrj30lj05z3yv.jpg)

#####  react-native-camera安装报错

```
Error:Could not resolve all files for configuration ':app:debugRuntimeClasspath'. > Could not find play-services-basement.aar (com.google.android.gms:play-services-basement:15.0.1). Searched in the following locations: https://jcenter.bintray.com/com/google/android/gms/play-services-basement/15.0.1/play-services-basement-15.0.1.aar
```

解决办法：[传送门](https://github.com/react-native-community/react-native-camera/issues/1878)

![image-20181108114118397](https://ws2.sinaimg.cn/large/006tNbRwly1fx0i89plduj30m308tq43.jpg)

将`jcenter()`放到最下边



##### 打包报错

![img](http://pd8738g5p.bkt.clouddn.com/20181112153919.png)

解决办法
**/android/build.gradle**

```
buildscript {

    
    ext {
        buildToolsVersion = "27.0.3"
        minSdkVersion = 16
        compileSdkVersion = 27
        targetSdkVersion = 26
        supportLibVersion = "27.1.1"
    }
    repositories {
        jcenter()
        google()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:3.1.4'
        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        mavenLocal()
        maven {
            // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
            url "$rootDir/../node_modules/react-native/android"
        }

        jcenter()
        maven { url "https://jitpack.io" }

        google()
        maven { url 'https://maven.google.com' }

    }
}

subprojects {
    afterEvaluate {project ->
        if (project.hasProperty("android")) {
            android {
                compileSdkVersion 27
                buildToolsVersion "27.0.2"
            }
        }
    }
}

task wrapper(type: Wrapper) {
    gradleVersion = '4.4'
    distributionUrl = distributionUrl.replace("bin", "all")
}

```

