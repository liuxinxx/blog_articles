```
tags:react native
source_title:React Native之prop-types进行属性确认
source_url:https://blog.csdn.net/xiangzhihong8/article/details/78836136
```

React Native已经升级到0.51.0了，版本升级很快，但是对老项目也会有一些问题，常见的就是属性找不到的问题。

<!--more-->

例如： 

![img](https://ws4.sinaimg.cn/large/006tNbRwly1fwza2sv3oij30cf0lkwhz.jpg)

主要原因是随着React Native的升级，系统废弃了很多的东西，过去我们可以直接使用 React.PropTypes 来进行属性确认，不过这个自 React v15.5 起就被移除了，转而使用prop-types库来进行替换

### 属性确认
#### 属性确认的作用
使用 React Native 创建的组件是可以复用的，所以我们开发的组件可能会给项目组其他同事使用。但别人可能对这个组件不熟悉，常常会忘记使用某些属性，或者某些属性传递的数据类型有误。因此我们可以在开发 React Native 自定义组件时，可以通过属性确认来声明这个组件需要哪些属性。

注意：为了保证 React Native 代码高效运行，属性确认仅在开发环境中有效，正式发布的 App 运行时是不会进行检查的。

#### prop-types 库使用

和其他的第三方库使用类似，prop-types的安装首先进入项目根目录，执行如下代码安装 prop-types 库：

`npm install --save prop-types`

然后在需要使用PropTypes属性的地方引入：

`import PropTypes from 'prop-types';`

#### 例子
例如，我们写一个导航栏的例子，效果如下： 

![img](https://ws2.sinaimg.cn/large/006tNbRwly1fwza371qe3j30bx0i4q3p.jpg)

```
import React, {
  Component
} from 'react'
import {
  StyleSheet,
  View,
  Animated,
  Image,
  TouchableOpacity,
  TouchableNativeFeedback,
  Platform
} from 'react-native'
import px2dp from '../utils/Utils'
import Icon from 'react-native-vector-icons/Ionicons'
import PropTypes from 'prop-types';

export default class NavBar extends Component{

    static propTypes = {
        title: PropTypes.string,
        leftIcon: PropTypes.string,
        rightIcon: PropTypes.string,
        leftPress: PropTypes.func,
        rightPress: PropTypes.func,
        style: PropTypes.object
    }
    static topbarHeight = (Platform.OS === 'ios' ? 64 : 44)
    renderBtn(pos){
      let render = (obj) => {
        const { name, onPress } = obj
        if(Platform.OS === 'android'){
          return (
            <TouchableNativeFeedback onPress={onPress} style={styles.btn}>
              <Icon name={name} size={px2dp(26)} color="#fff" />
            </TouchableNativeFeedback>
          )
        }else{
          return (
            <TouchableOpacity onPress={onPress} style={styles.btn}>
              <Icon name={name} size={px2dp(26)} color="#fff" />
            </TouchableOpacity>
          )
        }
      }
      if(pos == "left"){
        if(this.props.leftIcon){
          return render({
            name: this.props.leftIcon,
            onPress: this.props.leftPress
          })
        }else{
          // return (<ImageButton style={styles.btn} source={require('../images/ic_back_white.png')}/>)
            return (<View style={styles.btn}/>)
        }
      }else if(pos == "right"){
        if(this.props.rightIcon){
          return render({
            name: this.props.rightIcon,
            onPress: this.props.rightPress
          })
        }else{
          return (<View style={styles.btn}/>)
        }
      }
    }
    render(){
        return(
            <View style={[styles.topbar, this.props.style]}>
                {this.renderBtn("left")}
                <Animated.Text numberOfLines={1} style={[styles.title, this.props.titleStyle]}>{this.props.title}</Animated.Text>
                {this.renderBtn("right")}
            </View>
        )
    }
}

const styles = StyleSheet.create({
    topbar: {
        height: NavBar.topbarHeight,
        backgroundColor: "#06C1AE",
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingTop: (Platform.OS === 'ios') ? 20 : 0,
        paddingHorizontal: px2dp(10)
    },
    btn: {
      width: 22,
      height: 22,
      justifyContent: 'center',
      alignItems: 'center'
    },
    title:{
        color: "#fff",
        fontWeight: "bold",
        fontSize: px2dp(16),
        marginLeft: px2dp(5),
    }
});
```



#### 语法
##### 1，要求属性是指定的 JavaScript 基本类型。例如：

```
属性: PropTypes.array,
属性: PropTypes.bool,
属性: PropTypes.func,
属性: PropTypes.number,
属性: PropTypes.object,
属性: PropTypes.string,
```

#### 2，要求属性是可渲染节点。例如：

```属性: PropTypes.node```

##### 3，要求属性是某个 React 元素。例如：

```属性: PropTypes.element```

##### 4，要求属性是某个指定类的实例。例如：

```属性: PropTypes.instanceOf(NameOfAClass),```

##### 5，要求属性取值为特定的几个值。例如：

```属性: PropTypes.oneOf(['value1', 'value2'])```

##### 6，要求属性可以为指定类型中的任意一个。例如：
```
属性: PropTypes.oneOfType([
  PropTypes.bool,
  PropTypes.number,
  PropTypes.instanceOf(NameOfAClass),
])
```
##### 7，要求属性为指定类型的数组。例如：

```属性: PropTypes.arrayOf(PropTypes.number)```

##### 8，要求属性是一个有特定成员变量的对象。例如：

```属性: PropTypes.objectOf(PropTypes.number)```

##### 9，要求属性是一个指定构成方式的对象。例如：
```
属性: PropTypes.shape({
  color: PropTypes.string,
  fontSize: PropTypes.number,
})
```

##### 10，属性可以是任意类型。例如：

``属性: PropTypes.any```

将属性声明为必须
使用关键字 isRequired 声明它是必需的。
```
属性: PropTypes.array.isRequired,
属性: PropTypes.any.isRequired,
属性: PropTypes.instanceOf(NameOfAClass).isRequired,
```
(evaluating’_react3.default.PropType.shape’)报错
如果遇到Navigator报上面的错误，请按下面的方法解决。react-native@0.44后navigator被分离了出去，如果想在后面的版本中使用Navigator可以需要安装依赖库：react-native-deprecated-custom-components
```
import {
  Navigator
} from 'react-native-deprecated-custom-components';
```
如果还报错，请检查你的react版本，如果是react:16.0.0，请将版本换成。

`react": "^16.0.0-alpha.12`