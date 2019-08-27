```
tags:python
```

## 问题的由来

在开发过程中，可能会遇到多个版本同时部署的情况。

- Mac OS自带的Python版本是2.x，自己开发需要Python3.x
- 系统自带的是2.6.x，开发环境是2.7.x
- 由于Mac机器系统保护的原因，默认的Python无法对PIP一些包升级，需要组建新的Python环境
- 此时需要在系统中安装多个版本的Python，但又不能影响系统自带的Python，即需要实现Python的多版本共存。`pyenv`就是这样一个Python版本管理器。

## Pyenv

`pyenv`是Python版本管理工具。`pyenv`可以改变全局的Python版本，安装多个版本的Python，设置目录级别的Python版本，还能创建和管理vitual python enviroments。所有的设置都是用户级别的操作，不需要`sudo`命令。

`pyenv`主要用来管理Python的版本，比如一个项目需要Python2.x，一个项目需要Python3.x。而virtualenv主要用来管理Python包的依赖。不同项目需要依赖的包版本不同，则需要使用虚拟环境。

`pyenv`通过系统修改环境变量来实现Python不同版本的切换。而vitualenv通过Python包安装到一个目录来作为Python虚拟包环境，通过切换目录来实现不同包环境间的切换。

`pyenv`的美好之处在于，它并没有使用将不同的 PATH植入不同的shell这种高耦合的工作方式，而是简单地在PATH植入不同的shell这种高耦合的工作方式，而是简单地在PATH 的最前面插入了一个垫片路径（shims）：~/.pyenv/shims:/usr/local/bin:/usr/bin:/bin。所有对 Python 可执行文件的查找都会首先被这个 shims 路径截获，从而使后方的系统路径失效。

## 安装之前

不同系统请参考 [Common build problems](https://link.jianshu.com?t=https%3A%2F%2Fgithub.com%2Fpyenv%2Fpyenv%2Fwiki%2FCommon-build-problems)，安装必须的工具。

## pyenv安装

### 安装homebrew

[如何安装homebrew？](https://link.jianshu.com?t=https%3A%2F%2Fbrew.sh%2F)

### 安装pyenv

#### 使用homebrew安装

Mac下安装了`homebrew`之后使用`homebrew`安装`pyenv`。

```
brew update
brew install pyenv
brew upgrade pyenv #之后如果需要更新pyenv
```

在安装成功之后需要在`.bashrc`或者`.bash_profile`中添加三行来开启自动补全。

```
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

#### 自动安装

`pyenv`提供了自动安装的工具，执行命令安装即可。

```
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
```

需要保证系统又`git`，否则需要安装`git`。

#### 手动安装

也可以采用手动安装的方式，将`pyenv`检出到你想安装的目录。

```
cd ~
git clone git://github.com/yyuu/pyenv.git .pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

添加环境变量。`PYENV_ROOT` 指向 `pyenv` 检出的根目录，并向 `$PATH` 添加 `$PYENV_ROOT/bin` 以提供访问 `pyenv`命令的路径。

这里的 shell 配置文件`（~/.bash_profile）`依不同 Linux 而需作修改，如果使用 Zsh 则需要相应的配置 ~/.zshrc

在使用 `pyenv` 之后使用 `pip` 安装的第三方模块会自动安装到当前使用 python 版本下，不会和系统模块产生冲突。使用 pip 安装模块之后，如果没有生效，记得使用 `pyenv rehash` 来更新垫片路径。

### pyenv常用命令

使用`pyenv commands`可以查看所有pyenv命令。

#### 查看已安装Python版本

- `pyenv versions`

```
ferdinand@ferdinanddeMacBook-Pro  ~  pyenv versions
  system
* 3.6.3 (set by /Users/ferdinand/.python-version)
```

带*号的是当前路径下所使用的Python版本。

#### 查看可安装的Python版本

- `pyenv install -l`

```
erdinand@ferdinanddeMacBook-Pro  ~  pyenv install -l
Available versions:
  2.1.3
  2.2.3
  2.3.7
  2.4
  2.4.1
  2.4.2
  2.4.3
  2.4.4
  2.4.5
  2.4.6
  2.5
  2.5.1
  2.5.2
  2.5.3
  2.5.4
  2.5.5
  2.5.6
  2.6.6
  2.6.7
  2.6.8
  2.6.9
  2.7-dev
  2.7
  2.7.1
  2.7.2
  2.7.3
  …………
```

#### 安装Python

```
pyenv install <version> # version为版本号
```

#### Python版本管理

```
pyenv global <version>  # 全局设置python版本为指定版本，设置全局的 Python 版本，通过将版本号写入 ~/.pyenv/version 文件的方式。
pyenv local <version>   # 设置当前路径下python版本为指定版本，设置 Python 本地版本，通过将版本号写入当前目录下的 .python-version 文件的方式。通过这种方式设置的 Python 版本优先级较 global 高。
pyenv shell <version>   # 设置当前shell窗口使用的python版本为指定版本，设置面向 shell 的 Python 版本，通过设置当前 shell 的 PYENV_VERSION 环境变量的方式。这个版本的优先级比 local 和 global 都要高。–unset 参数可以用于取消当前 shell 设定的版本。
```

使用pyenv切换Python 版本之后可以通过`which python`或者是`python --version`来查看是否生效。

```
ferdinand@ferdinanddeMacBook-Pro  ~  which python
/Users/ferdinand/.pyenv/shims/python
ferdinand@ferdinanddeMacBook-Pro  ~  python --version
Python 3.6.3
```

- Python版本的优先级

> shell > local > global
>
> pyenv会从当前目录开始向上逐级查找`.python-versiob`文件，直到根目录为止，若找不到，则使用global版本。

```
pyenv rehash  # 创建垫片路径（为所有已安装的可执行文件创建 shims，如：~/.pyenv/versions/*/bin/*，因此，每当你增删了 Python 版本或带有可执行文件的包（如 pip）以后，都应该执行一次本命令）
```

#### Python卸载

```
pyenv isntall <version> # 安装版本号为<version>的Python
pyenv uninstall <version> #卸载版本号为<version>的Python
```