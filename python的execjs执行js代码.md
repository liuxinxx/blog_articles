```
tags:python
```

在写爬虫经常会遇到很多JS代码，比如说某些参数加密，可以只用用Python来翻译，但是有时候代码不容易阅读（JS渣渣），所以这里直接去找一条捷径，直接用Python的第三方库去调用JS代码。<!--more-->


###  安装

```
# python3安装
pip install PyExecJS
# python2安装
pip install pyexecjs
```

###  execjs执行语法

```python
import execjs

jsFunc = '''
    function add(x,y){
    return x+y;
    }
'''
jscontext = execjs.compile(jsFunc)
a = jscontext.call('add',3,5)
print(a)
# 可识别字符串，元组，字典，列表等
```

###  python中调用js文件使用js方法

* 首先通过`get_js`方法，读取本地的 `des_rsa.js` 文件。
* 调用 `execjs.compile()` 编译并加载 js 文件内容。
* 使用`call()`调用js中的方法

```python
import execjs  
#执行本地的js  
   
def get_js():  
    # f = open("D:/WorkSpace/MyWorkSpace/jsdemo/js/des_rsa.js",'r',encoding='UTF-8')  
    f = open("./js/des_rsa.js", 'r', encoding='UTF-8')  
    line = f.readline()  
    htmlstr = ''  
    while line:  
        htmlstr = htmlstr + line  
        line = f.readline()  
    return htmlstr  
   
jsstr = get_js()  
ctx = execjs.compile(jsstr)  
print(ctx.call('enString','123456'))
```