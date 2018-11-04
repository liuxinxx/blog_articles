---
tags:react native
---

做react-native地图应用时，主要使用的是高德地图，所以在导航上也准备调起高德地图应用来完成导航功能，这里简单说明一下高德地图和百度地图的调用

<!--more-->

### 高德地图导航URL

```
sourceApplication:你自己应用的名字，可不填 
slat：起点的latitude 
slon：起点的longitude 
sname：起点名 
dlat：终点的latitude 
dlon：终点的longitude 
dname：终点名 
其他几个参数目前我这样写是满足我的需求的。
```
`androidamap://route?sourceApplication=TCSP&sid=BGVIS1&slat=39.98871&slon=116.43234&sname=对外经贸大学&did=BGVIS2&dlat=40.055878&dlon=116.307854&dname=北京&dev=0&m=0&t=2`



腾讯地图下载地址[https://www.autonavi.com/](https://www.autonavi.com/)

### 腾讯地图导航URL

| 参数      | 必填 | 说明                                                         | 示例                                                      |
| --------- | ---- | ------------------------------------------------------------ | :-------------------------------------------------------- |
| type      | 是   | 路线规划方式参数： 公交：bus  驾车：drive  步行：walk  骑行：bike | type=bus 或 type=drive 或 type=walk 或 type=bike          |
| from      | 否   | 起点名称                                                     | from=鼓楼                                                 |
| fromcoord | 是   | 起点坐标，格式：lat,lng （纬度在前，经度在后，逗号分隔）  功能参数值：CurrentLocation ：使用定位点作为起点坐标 | fromcoord=39.907380,116.388501  fromcoord=CurrentLocation |
| to        | 否   | 终点名称                                                     | to=奥林匹克森林公园                                       |
| tocoord   | 是   | 终点坐标                                                     | tocoord=40.010024,116.392239                              |
| referer   | 是   | 请填写开发者key， [[点此申请\]](https://lbs.qq.com/console/key.html) | referer=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77               |

腾讯地图下载地址[https://pr.map.qq.com/j/tmap/download?key=YourKey](https://pr.map.qq.com/j/tmap/download?key=YourKey)

### RN代码

这个就比较简单了，直接打开你创建的rn项目中android目录，找到里面的androidManifest.xml,第二行中就是packagename

```
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  ScrollView,
  Button,
  Linking
} from 'react-native';
export default class LaunchImage extends Component {
  static navigationOptions = {
    title: 'Launch',    //设置navigator的title
  }
  constructor(props) {
    super(props);
    this.state = {
      url: 'androidamap://route?sid=BGVIS1&slat=39.98871&slon=116.43234&sname=对外经贸大学&did=BGVIS2&dlat=40.055878&dlon=116.307854&dname=北京&dev=0&m=0&t=2',
    }
  }
  render() {
    return (
      <View>
        <Button
          onPress={() => {
            Linking.canOpenURL(this.state.url).then(supported => {
              if (supported) {
                Linking.openURL(this.state.url);
              } else {
                console.log('无法打开该URI: ' + this.props.url);
                //可以在这里提示用户下载相应第三方地图软件
              }
            })
          }}
          title="进入高德导航"
        />
      </View>
    );
  }
}
```

