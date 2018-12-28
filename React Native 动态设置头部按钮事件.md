```
tags:react native
```
当我们在头部设置左右按钮时，肯定避免不了要设置按钮的单击事件，但是此时会有一个问题，navigationOptions是被修饰为static类型的，所以我们在按钮的onPress的方法中不能直接通过this来调用Component中的方法。<!--more-->如何解决呢？在官方文档中，作者给出利用设置params的思想来动态设置头部标题。那么我们可以利用这种方式，将单击回调函数以参数的方式传递到params，然后在navigationOption中利用navigation来取出设置到onPress即可：

```typescript
export default class Home5 extends Component {

  static navigationOptions = ({navigation, screenProps}) => ({
      title: 'Home5',
      headerRight: (
        <Button
          title={'customAction'}
          onPress={() => navigation.state.params.customAction()}
        />
      )
    }
  )

  componentDidMount() {
    const {setParams} = this.props.navigation
    setParams({customAction: () => this.tempAction()})
  }

  tempAction() {
    alert('在导航栏按钮上调用Component内中的函数，因为static修饰的函数为静态函数，内部不能使用this')
  }

  render() {
    return (
      <View style={{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
        <Text>Home5</Text>
      </View>
    )
  }
}
```

