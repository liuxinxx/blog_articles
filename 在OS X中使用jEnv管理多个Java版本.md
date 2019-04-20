```
tags:java
```



使用Java时会接触到不同的版本。大多数时候我在使用Java 8，但是因为某些框架或是工具的要求，这时不得不让Java 6上前线。<!--more-->一般情况下是配置JAVA_HOME，指定不同的Java版本，但是这需要人为手动的输入。如果又要选择其他版本，就需要对JAVA_HOME重新进行设置。这十分麻烦，所以在做这些操作时真是“会呼吸的痛”。终于，我发现了[jEnv](http://www.jenv.be/)。

正如它的官网所宣称的那样，它是来让你忘记怎么配置JAVA_HOME环境变量的神队友。使用简单的命令就可以在不同的Java版本之间进行切换。如果你使用过rbenv，你会发现jEnv就如同[rbenv](https://github.com/sstephenson/rbenv)的Java版一样。

**基本使用:**

在Mac OS X下使用[Homebrew](http://brew.sh/)安装jEnv：

```
`$ brew install jenv `
```

安装成功后需要进行一下简单的配置，让它可以起作用：

使用Bash的情况

```
`$ echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.bash_profile $ echo 'eval "$(jenv init -)"' >> ~/.bash_profile `
```

使用Zsh的情况

```
`$ echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc $ echo 'eval "$(jenv init -)"' >> ~/.zshrc `
```

好了，jEnv已经安装好了，让我们来看一下它找见哪个Java版本了：

```
`$ jenv versions * system (set by /Users/bxpeng/.jenv/version) `
```

它只找到了系统默认的Java，即使我已经下载了其他版本的Java。`*`表示当前选择的版本。

和rbenv不同的是，jEnv不能自己安装任何版本的Java，所以需要我们手动安装好之后再用jEnv指向它们。

安装Java 6，需要在[Apple](http://support.apple.com/kb/DL1572)进行下载。它将安装到`/System/Library/Java/JavaVirtualMachines/`下； 安装Java 7，可以在[Oracle](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)进行下载.它将安装到`/Library/Java/JavaVirtualMachines/`下； 安装Java 8，可以在[Oracle](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)进行下载.它将安装到`/Library/Java/JavaVirtualMachines/`下。

使用`jenv add`将Java 6加入jenv中：

```
`$ jenv add /System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home/ 1.6 added 1.6.0.65 added oracle64-1.6.0.65 added `
```

运行`jenv versions`时会显示：

```
`$ jenv versions * system (set by /Users/bxpeng/.jenv/version)   1.6   1.6.0.65   oracle64-1.6.0.65 `
```

同样的，使用`jenv add`将Java 7加入jenv中：

```
`$ jenv add /Library/Java/JavaVirtualMachines/jdk1.7.0_71.jdk/Contents/Home/ 1.7 added 1.7.0.71 added oracle64-1.7.0.71 added `
```

```
`$ jenv add /Library/Java/JavaVirtualMachines/jdk1.8.0_25.jdk/Contents/Home/ 1.8 added 1.8.0.25 added oracle64-1.8.0.25 added `
```

现在运行`jenv versions`会显示：

```
`$ jenv versions * system (set by /Users/bxpeng/.jenv/version)   1.6   1.6.0.65   oracle64-1.6.0.65   1.7   1.7.0.71   oracle64-1.7.0.71   1.8   1.8.0.25   oracle64-1.8.0.25 `
```

对于博主这种不是处女座的人来说，也觉得需要对版本再管理一下，使用`jenv remove`可以从jEnv中去掉不需要的Java版本：

```
`$ jenv remove 1.6 JDK 1.6 removed `
```

整理后，再运行`jenv versions`会显示：

```
`$ jenv versions * system (set by /Users/bxpeng/.jenv/version)   1.6.0.65   1.7.0.71   1.8.0.25 `
```

选择一个Java版本，运行`jenv local`，例如：

```
`$ jenv local 1.8.0.25 $ java -version java version "1.8.0_25" Java(TM) SE Runtime Environment (build 1.8.0_25-b17) Java HotSpot(TM) 64-Bit Server VM (build 25.25-b02, mixed mode) `
```

DangDangDangDang，我们已经成功地指定了某文件夹中local的Java版本。

你可以运行`jenv global`设置一个默认的Java版本，运行`jenv which java`显示可执行的Java的完整路径。

你也可以在特定的文件夹下使用.java-version文件来设定Java的版本。当我需要在Project中使用Java 6时，我仅仅需要把`1.6.0.65`作为内容保存在.java-version文件中，当我进入该文件夹时jEnv会自动地帮助我设定local的Java的版本。

没错，我们现在有了Java的多个版本，并且可以在它们之间轻松切换。更多的使用方法可以在[jEnv官网](http://www.jenv.be/)的官网查询到。

**参考文献:**

1. [jEnv官网](http://www.jenv.be/)
2. [Managing multiple versions of Java on OS X](http://andrew-jones.com/blog/managing-multiple-versions-of-java-on-os-x/)