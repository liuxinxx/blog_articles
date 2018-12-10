---
tags:renct native
---

总会遇到给state设置值后，马上就会用到state里面的值的情况
 但是setState是异步的，就会导致用的时候还没有被set成功

<!--more-->

```
this.setState({
    plateNumber: '123456',
});
console.log(this.state.plateNumber); ------>null
```



# 一、第一种写法

```
this.setState({
  plateNumber:'123456',
}, () => {
  console.log(this.state.plateNumber); 
})
```

很是好奇，竟然还可以这么写的，马上就在网上查了查，666

确实，this.setState 的第二个参数，在这个回调里能拿到更新的state，完美解决异步问题

# 二、第二种方法,使用  InteractionManager.runAfterInteractions

```
this.setState({
    plateNumber: '123456',
});
InteractionManager.runAfterInteractions(() => {
     console.log(this.state.plateNumber);
});
```

# setState可能会引发不必要的渲染(renders)

因为只要setState了，React就去作整个视图的重新渲染，有可能state的值只是记录并不在页面上显示，还是会走render方法，造成不必要的渲染，对性能有一定的影响
 这个时候就会用到 shouldComponentUpdate 了

### shouldComponentUpdate(nextProps, nextState) 提供两个参数，返回true或者false

返回true，则重新渲染
 返回false，则不渲染

所以就可以在这个方法中对比当前的state的值和nextState的值，或者判断nextState的值来返回true或者false，决定要不要重新渲染
