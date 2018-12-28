```
tags:html5,定位
```
## html5

### 什么是html5？

- 万维网的核心语言、标准通用标记语言下的一个应用超文本标记语言（HTML）的第五次重大修改版本，2014年10月29日，万维网联盟宣布，经过接近8年的艰苦努力，该标准规范终于制定完成，命名为html5。
- HTML5草案的前身名为 Web Applications1.0，于2004年被WHATWG提出，于2007年被W3C接纳，并成立了新的HTML 工作团队。HTML 5 的第一份正式草案已于2008年1月22日公布。
- HTML5 仍处于完善之中。然而，大部分现代浏览器已经具备了某些HTML5支持。2012年12月17日，万维网联盟（W3C）正式宣布凝结了大量网络工作者心血的HTML5规范已经正式定稿。根据W3C的发言稿称：“HTML5是开放的Web网络平台的奠基石。”
<!--more-->
### html5有什么特点和优势？

- 支持Html5的浏览器包括Firefox（火狐浏览器），IE9及其更高版本，Chrome（谷歌浏览器），Safari，Opera等；国内的遨游浏览器（Maxthon），以及基于IE或Chromium（Chrome的工程版或称实验版）所推出的360浏览器、搜狗浏览器、QQ浏览器、猎豹浏览器等国产浏览器同样具备支持HTML5的能力。
- HTML5手机应用的最大优势就是可以在网页上直接调试和修改。
- HTML5的设计目的是为了在移动设备上支持多媒体。新的语法特征被引进以支持这一点，如video、audio和canvas标记。HTML5还引进了新的功能，可以真正改变用户与文档的交互方式。

### html能做什么？

- 移动web
- 手机APP
- 更好的PC站点优化

## html5 - 地理位置定位技术

- 这里是我在我的demo下的实现思路，你大可作为参考也可以指正一下我的思路的问题，谢谢。
- 地理位置（Geolocation）是 HTML5 的重要特性之一，提供了确定用户位置的功能，借助这个特性能够开发基于位置信息的应用。在我的demo中使用的是百度提供的api接口，调用html5的geolocation方法获取客户端当前经纬度，从而获得客户端所在的地理位置，包括省市区信息，甚至有街道、门牌号等详细的地理位置信息。
- 值得注意的一点是，PC很多浏览器对于html5的定位技术是不太友好的，很多浏览器都是默认拒绝定位，一般只有IE是可以正常使用，但是获取到的经纬度偏差很大（这个原因很可能是因为PC的定位获取客户机位置的时候不是当前电脑的位置，而可能是浏览器调用服务器的物理机器的位置，不知道这个原因）；相反在手机访问的时候，由于一般手机上都有GPS模块，所以定位效果会好很多，原因就在于手机上的GPS模块对geolocation特性的支持是很好的。最终的结论是，html5的定位在手机上测试是最佳的选择，PC建议使用IE浏览器。

## 具体实现方案

- 好了，废话不多说（其实已经说了很多），立马进入实战阶段。

```js
function getLocation() {
    var options = {
        enableHighAccuracy : true,
        maximumAge : 1000
    }
    alert('this is getLocation()');
    if (navigator.geolocation) {
        //浏览器支持geolocation
        navigator.geolocation.getCurrentPosition(onSuccess, onError, options);
    } else {
        //浏览器不支持geolocation
        alert('您的浏览器不支持地理位置定位');
    }
}
```

- 这里我写了一个方法，主要功能是在调用html5的geolocation()前，先判断当前浏览器是否支持html5，这个判断基本在很多PC浏览器都会让程序挂掉（原因就是PC绝大部分浏览器不支持或者拒绝html5定位）.
- 如果浏览器支持，那么程序就会调用geolocation方法了，这是方法里面有2个回调函数：一个是定位成功后的处理操作（一般程序会返回经纬度给你进行后续的定位数据处理），另外一个是定位失败后的处理操作（具体大概就是错误信息，然后就是你的定位失败后的后续操作），第三个参数很少用到，我自己也没有去关注它有什么用，各位看官有兴趣可以了解一下。

```js
//成功时
function onSuccess(position) {
    //返回用户位置
    //经度
    var longitude = position.coords.longitude;
    //纬度
    var latitude = position.coords.latitude;
    alert('当前地址的经纬度：经度' + longitude + '，纬度' + latitude);
    //根据经纬度获取地理位置，不太准确，获取城市区域还是可以的
    var map = new BMap.Map("allmap");
    var point = new BMap.Point(longitude, latitude);
    var gc = new BMap.Geocoder();
    gc.getLocation(point, function(rs) {
        var addComp = rs.addressComponents;
        alert(addComp.province + ", " + addComp.city + ", "+ addComp.district + ", " + addComp.street + ", "+ addComp.streetNumber);
    });
    postData(longitude, latitude);
}
```

- 我这里写了一个成功后的回调函数，第一步获取定位成功返回的经纬度数据，然后结合百度那边提供的接口进行具体位置的转换，最后我还有一个数据提交的方法，这个是我具体业务的后续操作了，你可以根据具体情况进行特殊处理。下面附上百度接口：

```js
<script src="http://api.map.baidu.com/api?v=1.4" type="text/javascript"></script>
```

```
//失败时
function onError(error) {
    switch (error.code) {
        case 1:
            alert("位置服务被拒绝");
            break;
        case 2:
            alert("暂时获取不到位置信息");
            break;
        case 3:
            alert("获取信息超时");
            break;
        case 4:
            alert("未知错误");
            break;
    }
    //经度
    var longitude = 23.1823780000;
    //纬度
    var latitude = 113.4233310000;
    postData(longitude, latitude);
}
```

- 紧接着就是定位失败的回调函数了，这个就简单输出错误信息，然后我也写了一个失败后的后续操作，你可以根据你的需要进行自己的具体操作。
- 这样，整个html5定位算是完成了，不算太难，但也不简单，因为里面有很多可挖掘的空间，比如定位精度，定位范围，还有具体的地图定位和导航扩展的后续开发，可以说可扩展性很强，难度也会逐步提升，所以是一个值得研究的技术，我的技术有限，先研究到这里吧，最后附上完整的代码。

## 完整demo代码

```js
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
    <title>demo</title>
</head>
<body>
</body>
</html>
<script src="http://api.map.baidu.com/api?v=1.4" type="text/javascript"></script>
<script type="text/javascript" >

function getLocation() {
    var options = {
        enableHighAccuracy : true,
        maximumAge : 1000
    }
    alert('this is getLocation()');
    if (navigator.geolocation) {
        //浏览器支持geolocation
        navigator.geolocation.getCurrentPosition(onSuccess, onError, options);
    } else {
        //浏览器不支持geolocation
        alert('您的浏览器不支持地理位置定位');
    }
}

//成功时
function onSuccess(position) {
    //返回用户位置
    //经度
    var longitude = position.coords.longitude;
    //纬度
    var latitude = position.coords.latitude;
    alert('当前地址的经纬度：经度' + longitude + '，纬度' + latitude);
    //根据经纬度获取地理位置，不太准确，获取城市区域还是可以的
    var map = new BMap.Map("allmap");
    var point = new BMap.Point(longitude, latitude);
    var gc = new BMap.Geocoder();
    gc.getLocation(point, function(rs) {
        var addComp = rs.addressComponents;
        alert(addComp.province + ", " + addComp.city + ", "+ addComp.district + ", " + addComp.street + ", "+ addComp.streetNumber);
    });
    // 这里后面可以写你的后续操作了
    postData(longitude, latitude);
}
//失败时
function onError(error) {
    switch (error.code) {
        case 1:
            alert("位置服务被拒绝");
            break;
        case 2:
            alert("暂时获取不到位置信息");
            break;
        case 3:
            alert("获取信息超时");
            break;
        case 4:
            alert("未知错误");
            break;
    }
    // 这里后面可以写你的后续操作了
    //经度
    var longitude = 23.1823780000;
    //纬度
    var latitude = 113.4233310000;
    postData(longitude, latitude);
}

// 页面载入时请求获取当前地理位置
window.onload = function(){
    // html5获取地理位置
    getLocation();
};
</script>
```

## 总结

- html5定位技术的扩展性很强，技术应用范围很广，也是很有价值的一门技术，值得研究。
- geolocation的两个回调函数有很多想象空间，值得我们深思研究。
- 对于我来说，我算是收获一门技能，在手机定位上的一个技术。