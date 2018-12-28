```
tags:ubuntu
```
```sh
$ sudo apt-get update
$ sudo apt-get install curl
```
#### 在安装curl时可能会出现错误,系统提示
<!--more-->
```sh
root@ubuntu:~# sudo get-apt install curl
sudo: get-apt: command not found
root@ubuntu:~# sudo apt install curl
Reading package lists... Done
Building dependency tree
Reading state information... Done
You might want to run 'apt-get -f install' to correct these:
The following packages have unmet dependencies:
 curl : Depends: libcurl3-gnutls (= 7.47.0-1ubuntu2.8) but 7.47.0-1ubuntu2.7 is to be installed
 linux-image-extra-4.4.0-119-generic : Depends: linux-image-4.4.0-119-generic but it is not going to be installed
 linux-image-extra-4.4.0-124-generic : Depends: linux-image-4.4.0-124-generic but it is not going to be installed
 linux-image-generic : Depends: linux-image-4.4.0-124-generic but it is not going to be installed
                       Recommends: thermald but it is not going to be installed
E: Unmet dependencies. Try 'apt-get -f install' with no packages (or specify a solution).
```
#### 造成原因是安装包被破坏了。。。。(mmp,莫名其妙的~_~).
#### 解决办法[原链接](https://askubuntu.com/questions/914428/unmet-dependencies-when-trying-to-install-r-base?rq=1&utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa)
```sh
sudo apt --fix-broken install
sudo apt-get update
sudo apt-get upgrade
```
#### 完美解决~~谢谢(Google)

