```
tags:react native,icon
```
在开发App的过程中我们会用到各种图标，经实践发现一个问题，在React Native中使用图片来显示图标加载会非常慢，经常出现图标留白，半天才加载出来的情况。这种时候使用字体图标就能够很好解决这个问题。与图片相比，使用字体图标有哪些好处呢？
<!--more-->
## 字体图标的优点

1. 基于Text组件来显示，加载速度快
2. 可以设置字体样式来改变图标的大小，颜色
3. 矢量图标，放大缩小不失真
4. 兼容性好，适用于各式浏览器
5. 设计简单，图标库丰富，如[FontAwesome](https://link.juejin.im?target=https%3A%2F%2Ffontawesome.com%2F)，[iconfont](https://link.juejin.im?target=http%3A%2F%2Fwww.iconfont.cn%2F)
6. 最重要的一点，不会像图片那样由于一点小小的改动就换来换去，我们直接修改字体样式就行了✌️

React Native中使用字体图标最好用的一个库是[react-native-vector-icons](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Foblador%2Freact-native-vector-icons)，日常开发中这个库包含的几个图标库基本能满足我们的需求，如果还有不足的可以使用自定义的字体图标。

**本篇文章主要介绍以下内容，总结和分享开发心得**

1. `react-native-vector-icons`的详细使用方法。
2. 从阿里官方图标库[iconfont](https://link.juejin.im?target=http%3A%2F%2Fwww.iconfont.cn%2F)下载字体图标的使用方法，不使用其它第三方库。
3. `react-native-vector-icons`的高级用法：使用基于iconfont下载的图标资源创建自定义字体。

## `react-native-vector-icons`的使用

首先说说安装配置：

### 安装和配置

1. 根目录下使用`npm install react-native-vector-icons --save`或`yarn add react-native-vector-icons`安装。
2. 安装完成后运行`react-native link react-native-vector-icons`命令link这个库
3. **Android端的配置**

执行`react-native link`命令后你会发现在Android目录下这个库已经自动为我们把字体文件引入到`app/src/main`中并创建了`assets/fonts`的目录

![16300bec161a885c](https://ws4.sinaimg.cn/large/006tNbRwly1fw376746uzj30ja0n875b.jpg)



接着我们要在`android/app/build.gradle`文件中添加以下内容：

```
// 自定义的字体文件需要在这里赋值声明，如果有多个都需要添加到数组中
project.ext.vectoricons = [
    iconFontNames: [ 'iconfont.ttf' ]
]

// 如果只是使用react-native-vector-icons中的图标，只添加下面这行就行了，上面那段配置可以不写
apply from: "../../node_modules/react-native-vector-icons/fonts.gradle"
```

1. **iOS端的配置**

运行`react-native link`命令后你会发现在iOS工程目录下info.plist文件中多了一行`Fonts provided by application`，也可以手动配置，需要把`react-native-vector-icons`中所有字体全部加进来，如下：

![16300b00dfdf1e91](https://ws3.sinaimg.cn/large/006tNbRwly1fw378jldgvj30vu0ca3zd.jpg)

 接着在Xcode的

```
Build Phase
```

中找到

```
Link Binary With Libraries
```

，把自动link进来的

```
libRNVectorIcons.a
```

这个静态库给删掉，点击+号按钮重新添加，这样iOS端就能编译成功了。



![16300b40475b8eb9](https://ws3.sinaimg.cn/large/006tNbRwly1fw377k93xpj319q0w80v4.jpg)



到这里，两边都已经配置好了，接下来就可以直接用了。

### 基本使用

**1. 用作Icon组件**

```
import Icon from 'react-native-vector-icons/FontAwesome';

<Icon name={'angle-right'} size={24} color={'#999'}
```

下图是一个设置界面，使用了FontAwesome的图标



![1539159711318](https://ws3.sinaimg.cn/large/006tNbRwly1fw37cbi4poj31401z4q6u.jpg)￼

如果同时使用几个资源库图标如FontAwesome、Ionicons、Feather等作为Icon组件引用，为了避免Icon组件名称混淆，在import的时候可以起不同的名字，使用的时候组件名对应import的名称就行。

```
import FontAwesomeIcon from 'react-native-vector-icons/FontAwesome';
import Icon from 'react-native-vector-icons/Ionicons';

<FontAwesomeIcon name={'angle-right'} size={24} color={'#999'}/>
<Icon name={'ios-sad'} size={100} color={'#999999'}/>

```

**￼2. 用作Button组件**

```
import Icon from 'react-native-vector-icons/FontAwesome';

<Icon.Button name="star" backgroundColor="#999999" onPress={this.starOnGithub}>
    Give me a star on Github😁
</Icon.Button>
```

**3. 用作静态的图片资源**

有时候我们可能不想用图标组件，而想使用Image组件来显示这些字体图标，这时怎么办呢？看代码：

```
import Icon from 'react-native-vector-icons/FontAwesome';

constructor(props) {
    super(props);
    this.state = {
      userIcon: null,
    };
}

componentWillMount() {
    Icon.getImageSource('user', 50, '#999').then((source) => {
      this.setState({
        userIcon: source
      })
    });
  }
```

先在state中声明一个userIcon，然后使用Icon组件的getImageSource方法获取图标资源赋值给userIcon，接着在render函数中需要用到Image组件的地方设置这个userIcon。

```
<Image source={this.state.userIcon}/>
```

**4. 配合TabBarIOS组件使用**

```
import Icon from 'react-native-vector-icons/Ionicons';

<Icon.TabBarItemIOS
    title={'Home'}
    iconName={'ios-home-outline'}
    selectedIconName={'ios-home'}
    iconColor={'#888'}
    selectedIconColor={'#ff0098'}
    selected={this.state.selectedTabIndex === 0}
    renderAsOriginal
    onPress={() => {
        this.setState({
            selectedTabIndex: 0
        })
    }}
>
```

**5. 在NavigatorIOS组件中使用**

`NavigatorIOS`是iOS专属组件，字体图标在这里主要是使用在NavigationBar上，使用方式与上面说到的第3点静态图片资源的使用是一样的，这里不多作赘述。有一点需要注意的是`NavigatorIOS`不会随着state中属性值改变而重新渲染，所以可能导致getImageSource之后NavigationBar上的图标不显示，这里请看看`react-native-vector-icons`的官方文档，很贴心的说明了避坑指南：

> Note: Since NavigatorIOS doesn't rerender with new state and the async nature of getImageSource you must not use it with initialRoute until the icon is rendered, but any view added by push should be fine. Easiest way is to simple add an if statment at the beginning of you render method like this:

```
render() {
    if (!this.state.myIcon) {
      return false;
    }
    return (<NavigatorIOS ... />);
  }
```

简而言之，就是取值之前加个判断...

**6. 在ToolbarAndroid组件中使用**

两种方式，一种是获取Icon组件的静态图片资源，用在原生的ToolbarAndroid组件中，一种是使用Icon.ToolbarAndroid组件。

```
import Icon from 'react-native-vector-icons/FontAwesome';

constructor(props) {
    super(props);
    this.state = {
      appLogo: null,
    };
  }
  
componentWillMount() {
    Icon.getImageSource('android', 36, '#92c029').then((source) => {
      this.setState({
        appLogo: source
      })
    });
}
  
render() {
    return (
      <View style={styles.container}>
        <ToolbarAndroid
          style={styles.toolbar_system}
          logo={this.state.appLogo}
          title={'This is an android toolbar'}
        />
        <Icon.ToolbarAndroid
          navIconName={'amazon'}
          style={styles.toolbar_iconfont}
          titleColor="white"
          title={'This is an Icon toolbar'}
        />
      </View>
    )
  }
```

## 阿里矢量图标库iconfont的使用

上面说到的都是基于第三方库的字体图标的使用方法，如果要使用自定义的图标，怎么办呢？这里以阿里官方图标库来说明。网站需要登录才能下载资源。

1. 在[iconfont](https://link.juejin.im?target=http%3A%2F%2Fwww.iconfont.cn%2F)随便选择一组图标，将所有图标加入到购物车中，点击购物车，点击下方下载代码将资源下载到本地。
2. 解压zip文件，可以看到文件夹中有以下文件：



![1539159746024](https://ws2.sinaimg.cn/large/006tNbRwly1fw37d32nggj30kc0mktam.jpg)

 其中

```
demo_unicode.html
```

包含了所有图标对应的unicode字符，我们就是用它来显示图标。



1. 将iconfont.ttf文件分别copy到Android和iOS工程目录下。

Android放置在`app/src/main/assets/fonts`文件夹中，并且在`app/src/build.gradle`中添加配置:

```
project.ext.vectoricons = [
    iconFontNames: [ 'iconfont.ttf' ]
]
```

这里前面已经说过了。

iOS需要将iconfont.ttf添加到工程里去，可以创建一个Fonts文件夹，将iconfont.ttf放入其中，再添加Fonts目录到工程中。在Info.plist中`Fonts provided by application`下添加一行iconfont.ttf。

### 使用原理

使用Text组件，设置unicode字符就可以将图标显示出来了。Text组件的`fontFamily`要设置为`iconfont`，`fontSize`可以用来设置字体图标大小。

在实践中我发现一个问题，单独使用Text组件给它设置unicode字符就能显示出图标，如果有多个图标我就想偷个懒，把所有unicode字符以字符串的形式放到数组中，用数组的map方法循环显示Text组件，这时Text组件取值为字符串，所有图标都不能正常显示，全部都是字符串。后来发现这种方式需要把unicode字符串转换一下，如`&#xe6a7;`转成`\ue6a7`就行了。

这里不贴代码了，上图：

![1539159776523](https://ws1.sinaimg.cn/large/006tNbRwly1fw37djb4qyj31401z4tf6.jpg)





## 使用`react-native-vector-icons`创建自定义图标库

直接使用unicode编码的方式比较简单，但是在代码层面来看就不怎么直观，毕竟都是unicode编码，还容易拼写出错。使用`react-native-vector-icons`创建自定义的图标库是更好的选择，维护起来更加方便，能有效避免出错。

先看看`react-native-vector-icons`中`FontAwesome`是怎么实现创建自定义字体图标库的：

```
import createIconSet from './lib/create-icon-set';
import glyphMap from './glyphmaps/FontAwesome.json';

const iconSet = createIconSet(glyphMap, 'FontAwesome', 'FontAwesome.ttf');

export default iconSet;

export const Button = iconSet.Button;
export const TabBarItem = iconSet.TabBarItem;
export const TabBarItemIOS = iconSet.TabBarItemIOS;
export const ToolbarAndroid = iconSet.ToolbarAndroid;
export const getImageSource = iconSet.getImageSource;
```

可以看到使用了`react-native-vector-icons`中的`createIconSet`方法创建图标库，同时根据`FontAwesome.json`来匹配图标。点开发现`FontAwesome.json`是图标名称和十进制编码的映射集合：

```
{
  "glass": 61440,
  "music": 61441,
  "search": 61442,
  ......
}
```

我们现在有了iconfont.ttf，也可以参照这种方法创建一套字体图标集合，然后像上面说到的FontAwesome和其它几个图标库的使用方式一样，来使用我们的iconfont。

**生成iconfont.json**

首先是获取iconfont.json文件，我们之前下载iconfont资源的时候解压出来的文件中有个iconfont.svg文件，可以在其中找到每个图标的名字和对应的十六进制unicode编码，将十六进制编码转换成十进制，组成类似上面的`FontAwesome.json`一样的json数据就行了。

But，一个个的来匹配图标名称和转换编码是繁琐而笨拙的，这里我们使用脚本来完成这个任务。

脚本参考：[github.com/zhengcx/RNI…](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Fzhengcx%2FRNIconfont)，我使用的是这位大神的脚本。

将iconfont_mapper.sh脚本文件和iconfont.svg放到同一目录中，打开命令行或终端，执行以下命令：

```
./iconfont_mapper.sh iconfont.svg
```

mac下如果报错`Permission denied`就先修改文件权限

```
chmod 777 iconfont_mapper.sh
```

然后再执行上述命令，将iconfont.svg转换得到一个iconfont.json文件。

**创建CustomIconFont**

将iconfont.json添加到我们的项目中，现在就可以来创建自定义的图标库了，创建一个CustomIconFont.js文件，添加以下代码：

```
import createIconSet from 'react-native-vector-icons/lib/create-icon-set';
import glyphMap from './iconfont.json';

// glyphMap, fontFamily, fontFile三个参数，注意看react-native-vector-icons官方文档中方法注释，
// Android中fontFamily可以随便写，iOS必须是正确的名字否则运行报错，iOS可以直接双击iconfont.ttf打开看字体实际叫什么名字
const iconSet = createIconSet(glyphMap, 'iconFont', 'iconfont.ttf');

export default iconSet;

export const Button = iconSet.Button;
export const TabBarItem = iconSet.TabBarItem;
export const TabBarItemIOS = iconSet.TabBarItemIOS;
export const ToolbarAndroid = iconSet.ToolbarAndroid;
export const getImageSource = iconSet.getImageSource;
```

到这里相信大家已经知道该怎么使用这个图标库了，没错，和`react-native-vector-icons`内置的图标库使用方法一样了。

使用示例：

```
import CustomIconFont from './CustomIconFont';

// 用作图标组件
<CustomIconFont name={'tubiaozhizuomobanyihuifu_'} size={24} color={'#00c06d'}/>

// 用作Button
<CustomIconFont.Button name={'tubiaozhizuomobanyihuifu_23'} backgroundColor={'#59ACEA'}>
    Test icon button
</CustomIconFont.Button>
```

最后附上一张效果图：

![1539159803894](https://ws2.sinaimg.cn/large/006tNbRwly1fw37e4ko1dj31401z4ajn.jpg)



**项目完整代码地址**：[github.com/mrarronz/re…](https://link.juejin.im?target=https%3A%2F%2Fgithub.com%2Fmrarronz%2Freact-native-blog-examples), Chapter9-IconfontExample

