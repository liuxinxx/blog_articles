```
tags:react native
```
获取屏幕的尺寸需要使用Dimensions，直接从node_mules中引入即可。
<!--more-->
```react
//引入
var Dimensions = require('Dimensions');
class Demo extends Component {
    render() {
        return ( 
           <View style={styles.outViewStyle}>     
                <Text>当前屏幕宽度:{Dimensions.get('window').width}</Text>
                <Text>当前屏幕高度:{Dimensions.get('window').height}</Text> 
                <Text>当前屏幕分辨率:{Dimensions.get('window').scale}</Text>    
        </View>       
     ); 
   }}
   const styles = StyleSheet.create({ 
     outViewStyle:{  
      justifyContent:'center',
      alignItems:'center',
      flex:1, 
      backgroundColor:'orange
      }
     })
```



也可以写作:

```react
var {height, width, scale} = Dimensions.get('window');
<View style={styles3.outViewStyle}>
  <Text>当前屏幕宽度:{width}</Text>
  <Text>当前屏幕高度:{height}</Text>
  <Text>当前屏幕分辨率:{scale}</Text>
</View>
```

![1946614-29091b25f87a7030](https://ws1.sinaimg.cn/large/006tNc79ly1fvo03uq9buj30af0ijmxa.jpg)