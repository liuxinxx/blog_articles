```
tags:react native
```
之前没搞过 React ，直接开撸的 React Native，使用过程也是各种踩坑填坑，磕磕绊绊，这里简单总结一下我用过的组件通信的几种方式吧。<!--more-->
题外话，说几句我对 React 与 React Native 关系的理解：

- React 主要用于浏览器端实现一些 UI 组件，也可用于服务端渲染。React 可以使用 HTML 提供的标签，也可封装自定义的组件，React 也提供直接操作 DOM 的方法；
- React Native 主要用于实现客户端应用（App）的 UI 组件，它只能使用 Facebook 封装的 Native 组件，或者自己封装的 Native 组件。开发中主要借助 JavaScript，基本告别 HTML 和 CSS 了，不过优点是可以用 ES6。

------
言归正传，正文开始
## React 最基础的 props 和 state

### 组件内部用 state

```
constructor(props) {
    super(props);

    this.state = {
        isOnline: true	//组件 state
    };
}
render() {
    if(this.state.isOnline){
        //...剩余代码
    }
    //...剩余代码
}
```





### 父子组件通信用 props

```
//父组件设置属性参数
<MyComponet isOnline={true} />

//子组件
class MyComponent extends Component {
    constructor(props) {
        super(props);

        //子组件获取属性
        let isOnline = this.props.isOnline;  
    }
    //...剩余代码
}
```

### 子父组件通信也可用 props

```
//子组件
class MyComponent extends Component {
    constructor(props) {
        super(props);
    }
    componentDidMount() {
        //子组件给父组件的方法传参
        this.props.onChange('newVal');
    }
    render() {
        return (
            <View />
        );
    }
}
//父组件
class parentCpt extends Component {
    constructor(props) {
        super(props);
        this.state = {
            key: 'defVal'
        };
    }
    //父组件接受子组件的参数，并改变 state
    handleChange(val) {
        this.setState({
            key: val 
        });
    }
    render() {
        //...剩余代码
        return (
            <MyComponent onChange={(val) => {this.handleChange(val)}} />
        );
    }
}
```

## 使用 Refs

```
//子组件
class MyComponent extends Component {
    constructor(props) {
        super(props);
    }
    //开放的实例方法
    doIt() {
        //...做点什么
    }
    render() {
        return (
            <View />
        );
    }
}
//父组件
class parentCpt extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        //this.myCpt 保存组件的实例
        return (
            <MyComponent ref={(c) => {this.myCpt = c;}} />
        );
    }
    componentDidMount() {
        //调用组件的实例方法
        this.myCpt.doIt();
    }
}
```

## 使用 global

`global` 类似浏览器里的 `window` 对象，它是全局的，一处定义，所有组件都可以访问，一般用于存储一些全局的配置参数或方法。

**使用场景：全局参数不想通过 props 层层组件传递，有些组件对此参数并不关心，只有嵌套的某个组件使用**

```
global.isOnline = true;
```

## 使用 RCTDeviceEventEmitter

`RCTDeviceEventEmitter` 是一种事件机制，[React Native 的文档](http://facebook.github.io/react-native/releases/0.39/docs/native-modules-android.html#sending-events-to-javascript)只是草草带过，也可以使用 `DeviceEventEmitter` ，它是把 `RCTDeviceEventEmitter` 封装了一层，用法略不同。

按文档所言，`RCTDeviceEventEmitter` 主要用于 Native 发送事件给 JavaScript，实际上也可以用来发送自定义事件。

**使用场景：多个组件都使用了异步模块，且异步模块之间有顺序依赖时，可以使用。**

```typescript
//引入模块
import RCTDeviceEventEmitter from 'RCTDeviceEventEmitter';

//监听自定义事件
RCTDeviceEventEmitter.addListener('customEvt', (o) => {
    console.log(o.data);    //'some data'

    //做点其它的
});

//发送自定义事件，可传数据
RCTDeviceEventEmitter.emit('customEvt', {
    data: 'some data'
});
```

## 使用 [AsyncStorage](http://facebook.github.io/react-native/releases/0.39/docs/asyncstorage.html)

这是官方提供的持久缓存的模块，类似浏览器端的 `localStorage`，用法也很类似，不过比 `localStorage` 多了不少 API。

使用场景：当然也类似，退出应用需要保存的少量数据，可以存在这里，至于大小限制，[Android 貌似是 6M](https://github.com/facebook/react-native/issues/3387) 。

```
import {
  AsyncStorage
} from 'react-native';

//设置
AsyncStorage.setItem('@MySuperStore:key', 'I like to save it.');
//获取
AsyncStorage.getItem('@MySuperStore:key')
```

综上所述，这是我能想到的组件通信方式，其它想到了再补充吧。