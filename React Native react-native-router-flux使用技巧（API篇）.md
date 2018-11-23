```
tags:react native
source_title:react-native-router-flux使用技巧（API篇）
source_url:https://www.jianshu.com/p/37428d579cf6
```



### 强烈推荐使用该三方

如果在使用过程中遇到什么问题，可以加入`react-native兴趣交流群`群号：`397885169`一起讨论学习，也欢迎在评论区评论。

####  [RN项目模板，还未完成，但react-native-router-flux的Demo在里面](https://link.jianshu.com?t=https%3A%2F%2Fgithub.com%2FSurpassRabbit%2Freact-native-template)

#### 本文会持续更新，只要该库作者不停止更新，那么我也不会停下脚步。

可能很多人之前就用过这个三方，也可能有些人听过没用过。在这系列文章中，有这样几方面原因：

> 1. 通用性：在最新的V4版本中是基于`react-navigation`实现的，如果使用过`react-native-router-flux`那么使用新版本的学习成本会低很多；
> 2. 实用性：`react-navigation`虽然是官方推荐的导航库，但其库内部提供的，可以直接使用的功能很简单，有些还需要配合redux来实现需要的功能。而`react-native-router-flux`基于`react-navigation`实现其没有提供的API`popTo(跳回指定页面)`，`refresh(刷新页面)`，`replace`，`Modal(类似iOS从底部弹出个新页面的效果)`等常用到的功能，在下面的翻译中有详细说明；
> 3. 更新维护：这点上我很佩服库的作者，从V1更新到V4，从未背离作者的初衷，一直在对`react-native`的导航进行优化、封装，而且最让我佩服的一点是，作者好似将`react-navigation`的`Issues`全都翻看过，库里面将`react-navigation`可能存在或者已经存在的坑都填上了，而且实时更新。如果有时间，可以查看一下[CHANGELOG.md](https://link.jianshu.com?t=https%3A%2F%2Fgithub.com%2Faksonov%2Freact-native-router-flux%2Fblob%2Fmaster%2FCHANGELOG.md)，里面有着全部的更新记录。

稍后我会提供一个相对完整的Demo来作为对本文的补充，当然，其实作者提供的Demo已经很棒了，但作者将很多功能放在了一起，第一次接触的时候，很可能会被绕进去。

## Available imports

- `Router`
- `Scene`
- `Tabs`
- `Stack`
- `Tabbed Scene`
- `Drawer`
- `Modal`
- `Lightbox`
- `Actions`
- `ActionConst`

## Router:

| Property             | Type       | Default  | Description                                                  |
| -------------------- | ---------- | -------- | ------------------------------------------------------------ |
| children             |            | required | 页面根组件                                                   |
| `wrapBy`             | `Function` |          | 允许集成诸如Redux（connect）和Mobx（observer）之类的状态管理方案 |
| `sceneStyle`         | `Style`    |          | 适用于所有场景的Style（可选）                                |
| `backAndroidHandler` | `Function` |          | 允许在Android中自定义控制返回按钮（可选）。有关更多信息，请查看[BackHandler](https://link.jianshu.com?t=https%3A%2F%2Ffacebook.github.io%2Freact-native%2Fdocs%2Fbackhandler.html) |
| `uriPrefix`          | `string`   |          | 通过uri来深层链接，从App外跳入App内的某个页面，如果您想支持`www.example.com/user/1234/`的深度链接，可以通过`example.com`将路径匹配到`/user/1234/` |

```
backAndroidHandler用法：
const onBackPress = () => {
    if (Actions.state.index !== 0) {
      return false
    }
    Actions.pop()
    return true
}

backAndroidHandler={onBackPress}
```

## Scene:

此路由器的最重要的组件， 所有 `<Scene>` 组件必须要有一个唯一的 `key`。父节点`<Scene>`不能将`component`作为`prop`，因为它将作为其子节点的组件。

| Property                       | Type              | Default         | Description                                                  |
| ------------------------------ | ----------------- | --------------- | ------------------------------------------------------------ |
| `key`                          | `string`          | `required`      | 将用于标识页面，例如`Actions.name(params)`。必须是独一无二的 |
| `path`                         | `string`          |                 | 将被用来匹配传入的深层链接和传递参数，例如：`/user/:id/`将从`/user/1234/`用params {id：1234}调用场景的操作。接受uri的模板标准[https://tools.ietf.org/html/rfc6570](https://link.jianshu.com?t=https%3A%2F%2Ftools.ietf.org%2Fhtml%2Frfc6570) |
| `component`                    | `React.Component` | `semi-required` | 要显示的组件，定义嵌套时不需要`Scene`，参见示例。            |
| `back`                         | `boolean`         | `false`         | 如果是`true`，则显示后退按钮，而不是由上层容器定义的左侧/drawer按钮。 |
| `backButtonImage`              | `string`          |                 | 设置返回按钮的图片                                           |
| `backButtonTintColor`          | `string`          |                 | 自定义后退按钮色调                                           |
| `init`                         | `boolean`         | `false`         | 如果是`true`后退按钮不会显示                                 |
| `clone`                        | `boolean`         | `false`         | 标有`clone`的场景将被视为模板，并在被推送时克隆到当前场景的父节点中。详情请参见示例。 |
| `contentComponent`             | `React.Component` |                 | 用于呈现抽屉内容的组件（例如导航）。                         |
| `drawer`                       | `boolean`         | `false`         | 载入[DrawerNavigator](https://link.jianshu.com?t=https%3A%2F%2Freactnavigation.org%2Fdocs%2Fnavigators%2Fdrawer)内的子页面 |
| `failure`                      | `Function`        |                 | 如果`on`返回一个“falsey”值，那么`failure`将被调用。          |
| `backTitle`                    | `string`          |                 | 指定场景的后退按钮标题                                       |
| `backButtonTextStyle`          | `Style`           |                 | 用于返回按钮文本的样式                                       |
| `rightTitle`                   | `string`          |                 | 为场景指定右侧的按钮标题                                     |
| `headerMode`                   | `string`          | `float`         | 指定标题应该如何呈现：（float渲染单个标题，保持在顶部，动画随着屏幕的变化，这是iOS上的常见样式。）screen（每个屏幕都有一个标题，并且标题淡入，与屏幕一起出现，这是Android上的常见模式）如果为none（不会显示标题） |
| `hideNavBar`                   | `boolean`         | `false`         | 隐藏导航栏                                                   |
| `hideTabBar`                   | `boolean`         | `false`         | 隐藏标签栏（仅适用于拥有`tabs`指定的场景）                   |
| `hideBackImage`                | `boolean`         | `false`         | 隐藏返回图片                                                 |
| `initial`                      | `boolean`         | `false`         | 设置为`true`后，会默认显示该页面                             |
| `leftButtonImage`              | `Image`           |                 | 替换左侧按钮图片                                             |
| `leftButtonTextStyle`          | `Style`           |                 | 左侧按钮的文字样式                                           |
| `leftButtonStyle`              | `Style`           |                 | 左侧按钮的样式                                               |
| `leftButtonIconStyle`          | `Style`           |                 | 左侧按钮的图标样式                                           |
| `modal`                        | `boolean`         | `false`         | 将场景容器定义为`modal`，即所有子场景都将从底部弹起到顶部。它仅适用于containers（与v3版本的语法不同） |
| `navBar`                       | `React.Component` |                 | 可以使用自定义的React组件来定义导航栏                        |
| `navBarButtonColor`            | `string`          |                 | 设置导航栏返回按钮的颜色                                     |
| `navigationBarStyle`           | `Style`           |                 | 导航栏的样式                                                 |
| `navigationBarTitleImage`      | `Object`          |                 | 导航栏中的图像中覆盖`title`的`Image`                         |
| `navigationBarTitleImageStyle` | `object`          |                 | `navigationBarTitleImage`的样式                              |
| `navTransparent`               | `boolean`         | `false`         | 导航栏是否透明                                               |
| `on`                           | `Function`        |                 | 又名 `onEnter`                                               |
| `onEnter`                      | `Function`        |                 | 当`Scene`要被跳转时调用。`props`将被作为参数提供。只支持定义了'component'的场景。 |
| `onExit`                       | `Function`        |                 | 当`Scene`要跳转离开时调用。只支持定义了'component'的场景。   |
| `onLeft`                       | `Function`        |                 | 当导航栏左侧按钮被点击时调用。                               |
| `onRight`                      | `Function`        |                 | 当导航栏右侧按钮被点击时调用。                               |
| `renderTitle`                  | `React.Component` |                 | 使用React组件显示导航栏的title                               |
| `renderLeftButton`             | `React.Component` |                 | 使用React组件显示导航栏的左侧按钮                            |
| `renderRightButton`            | `React.Component` |                 | 使用React组件显示导航栏的右侧按钮                            |
| `renderBackButton`             | `React.Component` |                 | 使用React组件显示导航栏的返回按钮                            |
| `rightButtonImage`             | `Image`           |                 | 设置右侧按钮的图片                                           |
| `rightButtonTextStyle`         | `Style`           |                 | 右侧按钮文字的样式                                           |
| `success`                      | `Function`        |                 | 如果`on`返回一个"真实"的值，那么`success`将被调用。          |
| `tabs`                         | `boolean`         | `false`         | 将子场景加载为[TabNavigator](https://link.jianshu.com?t=https%3A%2F%2Freactnavigation.org%2Fdocs%2Fnavigators%2Ftab)。其他[标签导航器属性](https://link.jianshu.com?t=https%3A%2F%2Freactnavigation.org%2Fdocs%2Fnavigators%2Ftab%23TabNavigatorConfig)也是适用的。 |
| `title`                        | `string`          |                 | 要显示在导航栏中心的文本。                                   |
| `titleStyle`                   | `Style`           |                 | title的样式                                                  |
| `type`                         | `string`          | `push`          | 可选的导航操作。你可以使用`replace`来替换此场景中的当前场景  |
| all other props                |                   |                 | 此处未列出的其他属性将转交给`Scene`的`component`             |

## Tabs (`<Tabs>` or `<Scene tabs>`)

标签栏组件。
 你可以使用`<Scene>`中的所有`props`来作为`<Tabs>`的属性。 如果要使用该组件需要设置 `<Scene tabs={true}>`。

| Property                  | Type              | Default | Description                                                  |
| ------------------------- | ----------------- | ------- | ------------------------------------------------------------ |
| `wrap`                    | `boolean`         | `true`  | 自动使用自己的导航栏包装每个场景（如果不是另一个容器）。     |
| `activeBackgroundColor`   | `string`          |         | 指定焦点的选项卡的选中背景颜色                               |
| `activeTintColor`         | `string`          |         | 指定标签栏图标的选中色调颜色                                 |
| `inactiveBackgroundColor` | `string`          |         | 指定非焦点的选项卡的未选中背景颜色                           |
| `inactiveTintColor`       | `string`          |         | 指定标签栏图标的未选中色调颜色                               |
| `labelStyle`              | `object`          |         | 设置tabbar上文字的样式                                       |
| `lazy`                    | `boolean`         | `false` | 在选项卡处于活动状态之前，不会渲染选项卡场景(推荐设置成true) |
| `tabBarComponent`         | `React.Component` |         | 使用React组件以自定义标签栏                                  |
| `tabBarPosition`          | `string`          |         | 指定标签栏位置。iOS上默认为`bottom`，安卓上是`top`。         |
| `tabBarStyle`             | `object`          |         | 标签栏演示                                                   |
| `tabStyle`                | `object`          |         | 单个选项卡的样式                                             |
| `showLabel`               | `boolean`         | `true`  | 是否显示标签栏文字                                           |
| `swipeEnabled`            | `boolean`         | `true`  | 是否可以滑动选项卡。                                         |
| `animationEnabled`        | `boolean`         | `true`  | 切换动画                                                     |
| `tabBarOnPress`           | `function`        |         | 自定义tabbar点击事件                                         |
| `backToInitial`           | `boolean`         | `false` | 如果选项卡图标被点击，返回到默认选项卡。                     |

## Stack (`<Stack>`)

将场景组合在一起的组件，用于自己的基于堆栈实现的导航。使用它将为此堆栈创建一个单独的navigator，因此，除非您添加`hideNavBar`，否则将会出现两个导航条。

## Tab Scene (child `<Scene>` within `Tabs`)

用于实现`Tabs`的效果展示，可以自定义icon和label。

| Property      | Type        | Default     | Description                |
| ------------- | ----------- | ----------- | -------------------------- |
| `icon`        | `component` | `undefined` | 作为选项卡图标放置的RN组件 |
| `tabBarLabel` | `string`    |             | tabbar上的文字             |

## Drawer (`<Drawer>` or `<Scene drawer>`)

用于实现抽屉的效果，如果要使用该组件需要设置 `<drawer tabs={true}>`。

| Property           | Type                                               | Default | Description                                                  |
| ------------------ | -------------------------------------------------- | ------- | ------------------------------------------------------------ |
| `drawerImage`      | `Image`                                            |         | 替换抽屉'hamburger'图标，你必须把它与`drawer`一起设置        |
| `drawerIcon`       | `React.Component`                                  |         | 用于抽屉'hamburger'图标的任意组件，您必须将其与`drawer`道具一起设置 |
| `hideDrawerButton` | `boolean`                                          | `false` | 是否显示`drawerImage`或者`drawerIcon`                        |
| `drawerPosition`   | `string`                                           |         | 抽屉是在右边还是左边。可选属性`right`或`left`                |
| `drawerWidth`      | `number`                                           |         | 抽屉的宽度（以像素为单位）（可选）                           |
| `drawerLockMode`   | `enum('unlocked', 'locked-closed', 'locked-open')` |         | 指定抽屉的锁模式[(https://facebook.github.io/react-native/docs/drawerlayoutandroid.html#drawerlockmode)](https://link.jianshu.com?t=https%3A%2F%2Ffacebook.github.io%2Freact-native%2Fdocs%2Fdrawerlayoutandroid.html%23drawerlockmode) |

## Modals (`<Modal>` or `<Scene modal>`)

想要实现模态，您必须将其`<Modal>`作为您`Router`的根场景。在`Modal`将正常呈现第一个场景（应该是你真正的根场景），它将渲染第一个元素作为正常场景，其他所有元素作为弹出窗口（当它们 被push）。

示例：在下面的示例中，`root`场景嵌套在`<Modal>`中，因为它是第一个嵌套`Scene`，所以它将正常呈现。如果要`push`到`statusModal`，`errorModal`或者`loginModal`，他们将呈现为`Modal`，默认情况下会从屏幕底部向上弹出。重要的是要注意，目前`Modal`不允许透明的背景。

```
//... import components
<Router>
  <Modal>
    <Scene key="root">
      <Scene key="screen1" initial={true} component={Screen1} />
      <Scene key="screen2" component={Screen2} />
    </Scene>
    <Scene key="statusModal" component={StatusModal} />
    <Scene key="errorModal" component={ErrorModal} />
    <Scene key="loginModal" component={LoginModal} />
  </Modal>
</Router>
```

## Lightbox (`<Lightbox>`)

`Lightbox`是用于将组件渲染在当前组件上`Scene`的组件 。与`Modal`不同，它将允许调整大小和背景的透明度。

示例：
 在下面的示例中，`root`场景嵌套在中<Lightbox>，因为它是第一个嵌套`Scene`，所以它将正常呈现。如果要`push`到`loginLightbox`，他们将呈现为`Lightbox`，默认情况下将放置在当前场景的顶部，允许透明的背景。

```
//... import components
<Router>
  <Lightbox>
    <Scene key="root">
      <Scene key="screen1" initial={true} component={Screen1} />
      <Scene key="screen2" component={Screen2} />
    </Scene>

    {/* Lightbox components will lay over the screen, allowing transparency*/}
    <Scene key="loginLightbox" component={loginLightbox} />
  </Lightbox>
</Router>
```

## Actions

该对象的主要工具是为您的应用程序提供导航功能。 假设您的`Router`和`Scenes`配置正确，请使用下列属性在场景之间导航。 有些提供添加的功能，将React道具传递到导航场景。

这些可以直接使用，例如，`Actions.pop()`将在源代码中实现的操作，或者，您可以在场景类型中设置这些常量，当您执行`Actions.main()`时，它将根据您的场景类型或默认值来执行动作。

| Property       | Type       | Parameters                          | Description                                                  |
| -------------- | ---------- | ----------------------------------- | ------------------------------------------------------------ |
| `[key]`        | `Function` | `Object`                            | `Actions`将'自动'使用路由器中的场景`key`进行导航。如果需要跳转页面，可以直接使用`Actions.key()`或`Actions[key].call()` |
| `currentScene` | `String`   |                                     | 返回当前活动的场景                                           |
| `jump`         | `Function` | `(sceneKey: String, props: Object)` | 用于切换到新选项卡. For `Tabs` only.                         |
| `pop`          | `Function` |                                     | 回到上一个页面                                               |
| `popTo`        | `Function` | `(sceneKey: String, props: Object)` | 返回到指定的页面                                             |
| `push`         | `Function` | `(sceneKey: String, props: Object)` | 跳转到新页面                                                 |
| `refresh`      | `Function` | `(props: Object)`                   | 重新加载当前页面                                             |
| `replace`      | `Function` | `(sceneKey: String, props: Object)` | 从堆栈中弹出当前场景，并将新场景推送到导航堆栈。*没有过度动画。* |
| `reset`        | `Function` | `(sceneKey: String, props: Object)` | 清除路由堆栈并将场景推入第一个索引. *没有过渡动画。*         |
| `drawerOpen`   | `Function` |                                     | 如果可用，打开`Drawer`                                       |
| `drawerClose`  | `Function` |                                     | 如果可用，关闭`Drawer`                                       |

## ActionConst

键入常量以确定Scene转换，这些是**优先**于手动键入其值，因为项目更新时可能会发生更改。

| Property                   | Type     | Value                                   | Shorthand |
| -------------------------- | -------- | --------------------------------------- | --------- |
| `ActionConst.JUMP`         | `string` | 'REACT_NATIVE_ROUTER_FLUX_JUMP'         | `jump`    |
| `ActionConst.PUSH`         | `string` | 'REACT_NATIVE_ROUTER_FLUX_PUSH'         | `push`    |
| `ActionConst.PUSH_OR_POP`  | `string` | 'REACT_NATIVE_ROUTER_FLUX_PUSH_OR_POP'  | `push`    |
| `ActionConst.REPLACE`      | `string` | 'REACT_NATIVE_ROUTER_FLUX_REPLACE'      | `replace` |
| `ActionConst.BACK`         | `string` | 'REACT_NATIVE_ROUTER_FLUX_BACK'         | `pop`     |
| `ActionConst.BACK_ACTION`  | `string` | 'REACT_NATIVE_ROUTER_FLUX_BACK_ACTION'  | `pop`     |
| `ActionConst.POP_TO`       | `string` | 'REACT_NATIVE_ROUTER_FLUX_POP_TO'       | `popTo`   |
| `ActionConst.REFRESH`      | `string` | 'REACT_NATIVE_ROUTER_FLUX_REFRESH'      | `refresh` |
| `ActionConst.RESET`        | `string` | 'REACT_NATIVE_ROUTER_FLUX_RESET'        | `reset`   |
| `ActionConst.FOCUS`        | `string` | 'REACT_NATIVE_ROUTER_FLUX_FOCUS'        | *N/A*     |
| `ActionConst.BLUR`         | `string` | 'REACT_NATIVE_ROUTER_FLUX_BLUR'         | *N/A*     |
| `ActionConst.ANDROID_BACK` | `string` | 'REACT_NATIVE_ROUTER_FLUX_ANDROID_BACK' | *N/A*     |

## Universal and Deep Linking

#### 用例

- 考虑这样一个web应用程序和app配对,这可能有一个url`https://thesocialnetwork.com/profile/1234/.` 
- 如果我们同时构建一个web应用程序和一个移动应用程序，我们希望能够通过path `/profile/:id/`。
- 在web上，我们可能想要用一个路由器来打开我们的`<Profile />`和参数`{ id: 1234 }` 
- 在移动设备上，如果我们正确地设置了Android / iOS环境来启动我们的应用程序并打开RNRF`<Router />,`，那么我们还需要导航到我们的移动`<Profile />`场景和参数`{ id: 1234 }` 

#### 使用

```
<Router uriPrefix={'thesocialnetwork.com'}>
  <Scene key="root">
     <Scene key={'home'} component={Home} />
     <Scene key={'profile'} path={"/profile/:id/"} component={Profile} />
     <Scene key={'profileForm'} path={"/edit/profile/:id/"} component={ProfileForm} />
  </Scene>
</Router>
```

如果用户点击`http://thesocialnetwork.com/profile/1234/`在他们的设备,他们会打开`<Router/ >`,然后调用操作`Actions.profile({ id:1234 })`
