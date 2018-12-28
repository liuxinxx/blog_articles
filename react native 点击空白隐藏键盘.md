```
tags:react native
```
当我们点击输入框时，手机的软键盘会自动弹出，以便用户进行输入。但有时我们想在键盘弹出时对页面布局做个调整，或者在程序中使用代码收起这个软键盘，这些借助 React Native 框架提供的Keyboard API 就可以实现。
<!--more-->

一、Keyboard API提供的方法
Keyboard API提供如下的静态函数供开发者使用：


1、`addListener(eventName, callback)`
（1）这个函数用来加载一个指定事件的事件监听器，函数中的 eventName 可以是如下值：
```
keyboardWillShow：软键盘将要显示
keyboardDidShow：软键盘显示完毕
keyboardWillHide：软键盘将要收起
keyboardDidHide：软键盘收起完毕
keyboardWillChangeFrame：软件盘的 frame 将要改变
keyboardDidChangeFrame：软件盘的 frame 改变完毕
```
（2）这个函数返回一个对象。我们可以保存这个对象，在需要释放事件监听器时，调用这个对象的 remove 方法。


2、`removeListener(eventName, callback)`
这个函数用来释放一个特定的键盘事件监听器。

3、`removeAllListener(eventName)`
这个函数用来释放一个指定键盘事件的所有事件监听器。

4、`dissmiss()`
这个方法让操作系统收起软键盘


二、使用样例
在TextInput中输入文本，会弹出软键盘，点击空白部分，遗失焦点并隐藏软键盘，具体做法如下：

监听软键盘的弹出和隐藏

componentWillMount这个方法是在render渲染之前调用，只调用一次，componentWillUnmount这个方法在销毁的时候调用，移出软键盘。
```
componentWillMount() {
        //监听键盘弹出事件
        this.keyboardDidShowListener = Keyboard.addListener(
            "keyboardDidShow",
            this.keyboardDidShowHandler.bind(this)
        );
        //监听键盘隐藏事件
        this.keyboardDidHideListener = Keyboard.addListener(
            "keyboardDidHide",
            this.keyboardDidHideHandler.bind(this)
        );
    }

    componentWillUnmount() {
        //卸载键盘弹出事件监听
        if (this.keyboardDidShowListener != null) {
            this.keyboardDidShowListener.remove();
        }
        //卸载键盘隐藏事件监听
        if (this.keyboardDidHideListener != null) {
            this.keyboardDidHideListener.remove();
        }
    }
     
    //键盘弹出事件响应
    keyboardDidShowHandler(event) {
        this.setState({ KeyboardShown: true });
    }
     
    //键盘隐藏事件响应
    keyboardDidHideHandler(event) {
        this.setState({ KeyboardShown: false });
    }
```
在View的第一层包裹一个点击事件
```
<View style={[styles.flex, styles.topStatus]}>
       <TouchableOpacity activeOpacity={1.0} onPress={this.dissmissKeyboard.bind(this)}>
                    ...
       </TouchableOpacity>
</View>
```
如果点击事件控件使用的是TouchableOpacity,如果不想看到点击效果的话，记得设置激活的透明度为1
在点击onPress后隐藏软件盘
```js
//强制隐藏键盘
dissmissKeyboard() {
    // Toast.info("点击", 1);
    Keyboard.dismiss();
}
```
完整代码：
```
import React, { Component, PropTypes } from "react";
import {
    AppRegistry,
    StyleSheet,
    Text,
    ScrollView,
    Image,
    Alert,
    FlatList,
    TextInput,
    View,
    Linking,
    TouchableOpacity,
    TouchableWithoutFeedback,
    Keyboard
} from "react-native";
import { Button, Modal, Toast } from "antd-mobile";
import Communications from "react-native-communications";
const Dimensions = require("Dimensions");
export const screenW = Dimensions.get("window").width;
export const screenH = Dimensions.get("window").height;
 
const styles = StyleSheet.create({
    tabBarImage: {
        width: 24,
        height: 24
    },
    flex: {
        flex: 1
    },
    flex2: {
        // flex: 1
    },
    flexDirection: {
        flexDirection: "row"
    },
    topStatus: {
        marginTop: 10
    },
 
    textareaContent: {
        backgroundColor: "#fff",
        paddingLeft: 15
    },
    title: {
        fontSize: 16,
        color: "#333"
    },
    tcTitle: {
        fontSize: 16,
        color: "#333",
        marginBottom: 10,
        marginTop: 10
    },
    tcInput: {
        fontSize: 14,
        height: 100
    },
    inputHeight: {
        height: 45
    },
    inputContent: {
        backgroundColor: "#fff",
        paddingLeft: 15,
        marginTop: 10,
        height: 45
    },
    input: {
        height: 45,
        marginLeft: 5,
        paddingLeft: 5,
        fontSize: 14
    },
    icTitle: {
        height: 45,
        justifyContent: "center",
        // alignItems: "center",
        width: 90
    },
    phone: {
        backgroundColor: "#fff",
        paddingLeft: 15,
        marginTop: 10,
        height: 45
    },
    center: {
        justifyContent: "center",
        alignItems: "center"
    },
    phoneLeft: {
        marginLeft: 100
    }
});
class Feedback extends Component {
    
    constructor(props) {
        super(props);
        this.state = { text: "", textarea: "", KeyboardShown: false };
        this.submit = this.submit.bind(this);
        this.keyboardDidShowListener = null;
        this.keyboardDidHideListener = null;
    }
    render() {
        return (
            <View style={[styles.flex, styles.topStatus]}>
                <TouchableOpacity activeOpacity={1.0} onPress={this.dissmissKeyboard.bind(this)}>
                    <View style={[styles.textareaContent, styles.flex2]}>
                        <Text style={styles.tcTitle}>反馈内容：</Text>
                        <TextInput
                            ref="textareaInput"
                            multiline={true}
                            style={styles.tcInput}
                            autoCapitalize="none"
                            placeholder="请填写您的宝贵意见，让58不断进步，谢谢！"
                            placeholderTextColor="#CCC"
                            onChangeText={(textarea) => this.setState({ textarea })}
                            // onEndEditing={this.dissmissKeyboard.bind(this)}
                        />
                    </View>
                    <View style={[styles.flexDirection, styles.inputContent, styles.flex2]}>
                        <View style={styles.icTitle}>
                            <Text style={styles.title}>联系方式：</Text>
                        </View>
                        <View style={styles.flex}>
                            <TextInput
                                ref="phoneInput"
                                style={styles.input}
                                autoCapitalize="none" //不自动切换任何字符成大写
                                keyboardType="numeric"
                                placeholder="请填写有效的联系方式"
                                onChangeText={(text) => this.setState({ text })}
                                // onEndEditing={this.dissmissKeyboard.bind(this)}
                            />
                        </View>
                    </View>
                    <View style={[styles.flexDirection, styles.phone, styles.flex2]}>
                        <View style={styles.center}>
                            <Text style={[styles.title, styles.center]}>客服电话</Text>
                        </View>
                        {/* <TouchableOpacity onPress={() => Communications.phonecall('10105858', true)}>
                    <View style={styles.center}>
                        <Text style={styles.title}>10105858</Text>
                    </View>
                    </TouchableOpacity> */}
                        <View
                            style={[styles.center, styles.phoneLeft]}
                            onPress={() => Communications.phonecall("10105858", true)}>
                            <Text style={styles.title} onPress={() => this.linking("tel:10105858")}>
                                10105858
                            </Text>
                        </View>
                    </View>
                    <View style={{ height: 200 }}>
                        <Text />
                    </View>
                   
                </TouchableOpacity>
            </View>
        );
    }
 
    componentDidMount() {
        // 通过在componentDidMount里面设置setParams
        this.props.navigation.setParams({
            submit: this.submit
        });
    }
    //拨打电话
    linking(url) {
        Linking.canOpenURL(url)
            .then((supported) => {
                if (!supported) {
                    Toast.info("Can't handle url: " + url);
                } else {
                    return Linking.openURL(url);
                }
            })
            .catch((err) => Toast.error("An error occurred", err));
    }
    //表单提交
    submit() {
        let self = this;
        let postData = {};
        postData.content = this.state.textarea;
        postData.phone = this.state.text;
        if (!postData.content) {
            Toast.fail("请输入反馈信息", 2);
            return;
        }
        if (postData.content.length < 15 || postData.content.length > 380) {
            Toast.fail("请输入反馈信息(字数在15-380之间)", 2);
            return;
        }
        if (!postData.phone) {
            Toast.fail("（必填）请输入有效电话号码", 2);
            return;
        }
        Toast.info(JSON.stringify(postData), 2);
        // Alert.alert(JSON.stringify(postData))
    }
 
    componentWillMount() {
        //监听键盘弹出事件
        this.keyboardDidShowListener = Keyboard.addListener(
            "keyboardDidShow",
            this.keyboardDidShowHandler.bind(this)
        );
        //监听键盘隐藏事件
        this.keyboardDidHideListener = Keyboard.addListener(
            "keyboardDidHide",
            this.keyboardDidHideHandler.bind(this)
        );
    }
 
    componentWillUnmount() {
        //卸载键盘弹出事件监听
        if (this.keyboardDidShowListener != null) {
            this.keyboardDidShowListener.remove();
        }
        //卸载键盘隐藏事件监听
        if (this.keyboardDidHideListener != null) {
            this.keyboardDidHideListener.remove();
        }
    }
 
    //键盘弹出事件响应
    keyboardDidShowHandler(event) {
        this.setState({ KeyboardShown: true });
    }
 
    //键盘隐藏事件响应
    keyboardDidHideHandler(event) {
        this.setState({ KeyboardShown: false });
    }
 
    //强制隐藏键盘
    dissmissKeyboard() {
        // Toast.info("点击", 1);
        Keyboard.dismiss();
    }
}
 
export default Feedback;
```

