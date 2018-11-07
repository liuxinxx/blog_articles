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