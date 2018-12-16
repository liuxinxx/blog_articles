```
tags:docker
source_title:Docker 常用指令详解
source_url:https://www.jianshu.com/p/7c9e2247cfbd
```



##### 主要用法：`docker`  [ `docker命令选项` ][ `子命令` ] [ `子命令选项` ]

> `docker` [ `子命令` ] `--help` 可查看每个子命令的详细用法。

<!--more-->

### docker命令选项列表

------

| 选项                     | 说明                                                         | 其他                           |
| ------------------------ | ------------------------------------------------------------ | ------------------------------ |
| --config [string]        | 客户端本地配置文件路径                                       | 默认为 `~/.docker`             |
| -D, --debug              | 启用调试模式                                                 |                                |
| --help                   | 打印用法                                                     |                                |
| -H, --host list          | 通过socket访问指定的docker守护进程(服务端)                   | `unix://` , `fd://` , `tcp://` |
| -l, --log-level [string] | 设置日志级别 (`debug` 、`info` 、`warn` 、`error` 、`fatal`) | 默认为 `info`                  |
| --tls                    | 启用TLS加密                                                  |                                |
| --tlscacert [string]     | 指定信任的CA根证书路径                                       | 默认为 `~/.docker/ca.pem`      |
| --tlscert [string]       | 客户端证书路径                                               | 默认为 `~/.docker/cert.pem`    |
| --tlskey [string]        | 客户端证书私钥路径                                           | 默认为 `~/.docker/key.pem`     |
| --tlsverify              | 启用TLS加密并验证客户端证书                                  |                                |
| -v, --version            | 打印docker客户端版本信息                                     |                                |

### 1. 镜像仓库相关

------

#### 1.1 查找镜像

> docker search [条件]

```
# 查询三颗星及以上名字包含alpine的镜像
docker search -f=stars=3 alpine
```

#### 1.2 获取镜像

> docker pull [仓库]:[tag]

仓库格式为 `[仓库url]/[用户名]/[应用名]` , 除了官方仓库外的第三方仓库要指定url, 用户名就是在对应仓库下建立的账户, 一般只有应用名的仓库代表官方镜像, 如 `ubuntu`、`tomcat` 等, 而 `tag` 表示镜像的版本号, 不指定时默认为 `latest`

```
# 获取alpine Linux 的镜像
docker pull alpine
```

#### 1.3 推送镜像到仓库

> docker push [镜像名]:[tag]

当然, 需要先登录

```
ubuntu@VM-84-201-ubuntu:~$ docker push alpine
The push refers to a repository [docker.io/library/alpine]
3fb66f713c9f: Layer already exists
errors:
denied: requested access to the resource is denied(没有权限, 需要登录帐号)
unauthorized: authentication required
```

#### 1.4 登录/退出第三方仓库

> docker [login/logout] [仓库地址]

```
# 登录
ubuntu@VM-84-201-ubuntu:~$ docker login daocloud.io
Username (username): username
Password:
Login Succeeded
# 退出
ubuntu@VM-84-201-ubuntu:~$ docker logout daocloud.io
Removing login credentials for daocloud.io
```

### 2. 本地镜像

------

#### 2.1 查看本地镜像

> docker images

```
ubuntu@VM-84-201-ubuntu:~$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
alpine              latest              a41a7446062d        14 hours ago        3.97MB
hello-world         latest              48b5124b2768        4 months ago        1.84kB
```

#### 2.2 删除本地镜像

> docker rmi [镜像名 or 镜像id]

如果用镜像id作为参数, 可以只输入前几位, 能唯一确定即可(可以同时删除多个镜像, 空格隔开)。此外, 如果该镜像启动了容器需要先删除容器。

```
ubuntu@VM-84-201-ubuntu:~$ docker rmi a41
Untagged: alpine:latest
Untagged: alpine@sha256:0b94d1d1b5eb130dd0253374552445b39470653fb1a1ec2d81490948876e462c
Deleted: sha256:a41a7446062d197dd4b21b38122dcc7b2399deb0750c4110925a7dd37c80f118
Deleted: sha256:3fb66f713c9fa9debcdaa58bb9858bd04c17350d9614b7a250ec0ee527319e59
```

#### 2.3 查看镜像详情

> docker inspect [镜像名 or 镜像id]

```
ubuntu@VM-84-201-ubuntu:~$ docker inspect a41
[
    {
        "Id": "sha256:a41a7446062d197dd4b21b38122dcc7b2399deb0750c4110925a7dd37c80f118",
        "RepoTags": [
            "alpine:latest"
        ],
        "RepoDigests": [
            "alpine@sha256:0b94d1d1b5eb130dd0253374552445b39470653fb1a1ec2d81490948876e462c"
        ],
        "Parent": "",
        "Comment": "",
        "Created": "2017-05-25T23:33:22.029729271Z",
        "Container": "19ee1cd90c07eb7b3c359aaec3706e269a871064cca47801122444cef51c5038",
    ......
        }
    }
]
```

#### 2.4 打包本地镜像, 使用压缩包来完成迁移

> docker save [镜像名] > [文件路径]

```
# 默认为文件流输出
docker save alpine > /usr/anyesu/docker/alpine.img

# 或者使用 '-o' 选项指定输出文件路径
docker save -o /usr/anyesu/docker/alpine.img alpine
```

#### 2.5 导入镜像压缩包

> docker load < [文件路径]

```
# 默认从标准输入读取
ubuntu@VM-84-201-ubuntu:~$ docker load < /usr/anyesu/docker/alpine.img
3fb66f713c9f: Loading layer [==================================================>]  4.221MB/4.221MB
Loaded image: alpine:latest

# 用 '-i' 选项指定输入文件路径
ubuntu@VM-84-201-ubuntu:~$ docker load -i /usr/anyesu/docker/alpine.img
Loaded image: alpine:latest
Loaded image ID: sha256:665ffb03bfaea7d8b7472edc0a741b429267db249b1fcead457886e861eae25f
Loaded image ID: sha256:a41a7446062d197dd4b21b38122dcc7b2399deb0750c4110925a7dd37c80f118
```

#### 2.6 修改镜像tag

> docker tag [镜像名 or 镜像id]  [新镜像名]:[新tag]

```
ubuntu@VM-84-201-ubuntu:~$ docker tag a41 anyesu/alpine:1.0
ubuntu@VM-84-201-ubuntu:~$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
anyesu/alpine       1.0                 a41a7446062d        15 hours ago        3.97MB
alpine              latest              a41a7446062d        15 hours ago        3.97MB
hello-world         latest              48b5124b2768        4 months ago        1.84kB
```

### 3. 容器相关

------

#### 3.1 创建、启动容器并执行相应的命令

> docker run [参数] [镜像名 or 镜像id] [命令]

如果没有指定命令是执行镜像默认的命令, 创建镜像的时候可设置。另外要注意的一点, 启动容器后要执行一个前台进程(就是能在控制台不断输出的, 如tomcat的catalina.sh)才能使容器保持运行状态, 否则, 命令执行完容器就关闭了, 比如下面这个例子。

```
ubuntu@VM-84-201-ubuntu:~$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```

#### run命令常用选项

| 选项                                   | 说明                                                         |
| -------------------------------------- | ------------------------------------------------------------ |
| -d                                     | 后台运行容器, 并返回容器ID；不指定时, 启动后开始打印日志, `Ctrl + C` 退出命令同时会关闭容器 |
| -i                                     | 以交互模式运行容器, 通常与 -t 同时使用；                     |
| -t                                     | 为容器重新分配一个伪输入终端, 通常与 -i 同时使用             |
| --name "anyesu-container"              | 为容器指定一个别名, 不指定时随机生成                         |
| -h docker-anyesu                       | 设置容器的主机名, 默认随机生成                               |
| --dns 8.8.8.8                          | 指定容器使用的DNS服务器, 默认和宿主一致                      |
| -e docker_host=172.17.0.1              | 设置环境变量                                                 |
| --cpuset="0-2" or --cpuset="0,1,2"     | 绑定容器到指定CPU运行                                        |
| -m 100M                                | 设置容器使用内存最大值                                       |
| --net bridge                           | 指定容器的网络连接类型, 支持 `bridge` / `host` / `none` / `container` 四种类型 |
| --ip 172.18.0.13                       | 为容器分配固定ip(需要使用自定义网络)                         |
| --expose 8081 --expose 8082            | 开放一个端口或一组端口, 会覆盖镜像设置中开放的端口           |
| -p [宿主机端口]:[容器内端口]           | 宿主机到容器的端口映射, 可指定宿主机的要监听的ip, 默认为 `0.0.0.0` |
| -P                                     | 注意是大写的, 宿主机随机指定一组可用的端口映射容器 `expose` 的所有端口 |
| -v [宿主机目录路径]:[容器内目录路径]   | 挂载宿主机的指定目录(或文件)到容器内的指定目录(或文件)       |
| --add-host [主机名]:[ip]               | 为容器hosts文件追加host, 默认会在hosts文件最后追加 `[主机名]:[容器ip]` |
| --volumes-from [其他容器名]            | 将其他容器的数据卷添加到此容器                               |
| --link [其他容器名]:[在该容器中的别名] | 添加链接到另一个容器, 在本容器hosts文件中加入关联容器的记录, 效果类似于 `--add-host` |

> 单字符选项可以合并, 如 `-i -t` 可以合并为 `-it`

```
# 创建一个名为anyesu_net、网段为172.18.0.0的网桥(docker默认创建的网段为172.17.0.0)
docker network create --subnet=172.18.0.0/16 anyesu_net

# 创建并启动一个配置复杂的容器
ubuntu@VM-84-201-ubuntu:~$ docker run -d --name anyesu-container -h docker-anyesu --dns 8.8.8.8 -e docker_host=172.18.0.1 -e docker_host2=172.18.0.2 --net anyesu_net --ip 172.18.0.13 --expose 8081 --expose 8082 -P -p 8000:8000 -p 8001:8001 -v /usr/anyesu:/usr/anyesu --add-host anyesu_host:172.18.0.1 tomcat:7
912e6632161de0783a057aa02380e676753f66cfb367ef1686d4d09cdc931659
ubuntu@VM-84-201-ubuntu:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                                                                                                         NAMES
912e6632161d        tomcat:7              "catalina.sh run"   6 seconds ago       Up 5 seconds        0.0.0.0:8000-8001->8000-8001/tcp, 0.0.0.0:32783->8080/tcp, 0.0.0.0:32782->8081/tcp, 0.0.0.0:32781->8082/tcp   anyesu-container
 
```

#### 3.2 查看运行中的容器

```
 docker ps 
```

加 `-a` 选项可查看所有的容器

#### 3.3 开启/停止/重启容器

```
# 关闭容器(发送SIGTERM信号,做一些'退出前工作',再发送SIGKILL信号)
docker stop anyesu-container
# 强制关闭容器(默认发送SIGKILL信号, 加-s参数可以发送其他信号)
docker kill anyesu-container
# 启动容器
docker start anyesu-container
# 重启容器
docker restart anyesu-container
```

#### 3.4 删除容器

> docker rm [容器名 or 容器id]

可以指定多个容器一起删除, 加 `-f` 选项可强制删除正在运行的容器

```
ubuntu@VM-84-201-ubuntu:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS              PORTS                                                                                                         NAMES
fd7a6c1ba0f0        tomcat              "catalina.sh run"   20 seconds ago       Up 18 seconds       0.0.0.0:32798->8080/tcp, 0.0.0.0:32797->8081/tcp, 0.0.0.0:32796->8082/tcp                                     musing_newton
61941bea1c87        tomcat              "catalina.sh run"   About a minute ago   Up About a minute   0.0.0.0:8000-8001->8000-8001/tcp, 0.0.0.0:32795->8080/tcp, 0.0.0.0:32794->8081/tcp, 0.0.0.0:32793->8082/tcp   anyesu-container
ubuntu@VM-84-201-ubuntu:~$ docker rm musing_newton anyesu-container -f
musing_newton
anyesu-container
```

#### 3.5 查看容器详情

> docker inspect [容器名 or 容器id]

```
docker inspect anyesu-container
```

#### 3.6 查看容器中正在运行的进程

> docker top [容器名 or 容器id]

```
ubuntu@VM-84-201-ubuntu:~$ docker top anyesu-container
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                31769               31752               1                   00:26               ?                   00:00:03            /docker-java-home/jre/bin/java -Djava.util.logging.config.file=/usr/local/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -classpath /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar -Dcatalina.base=/usr/local/tomcat -Dcatalina.home=/usr/local/tomcat -Djava.io.tmpdir=/usr/local/tomcat/temp org.apache.catalina.startup.Bootstrap start
```

#### 3.7 将容器保存为镜像

> docker commit [容器名 or 容器id] [镜像名]:[tag]

```
ubuntu@VM-84-201-ubuntu:~$ docker commit anyesu-container anyesu/tomcat:1.0
sha256:582fcffd3209a2478e2179c9381a1ef67e0df9ba95aba713875c0857f5dae4e5
ubuntu@VM-84-201-ubuntu:~$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
anyesu/tomcat       1.0                 582fcffd3209        2 seconds ago       334MB
alpine              latest              a41a7446062d        17 hours ago        3.97MB
tomcat              latest              3695a0fe8320        2 days ago          334MB
hello-world         latest              48b5124b2768        4 months ago        1.84kB
```

#### 3.8 使用Dockerfile构建镜像

> docker build -t [镜像名]:[tag] -f [DockerFile名] [DockerFile所在目录]

数据是实时更新的, [点击](https://www.jianshu.com/p/a0892512f86c)查看详细用法

### 4. 硬件资源相关

------

#### 4.1 显示容器硬件资源使用情况

> docker stats [选项] [0个或多个正在运行容器]

```
# 不指定容器时显示所有正在运行的容器
ubuntu@VM-84-201-ubuntu:~$ docker stats
CONTAINER           CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
9bb9d6bed6e6        0.00%               20.57MiB / 864.5MiB   2.38%               104kB / 1.99MB      4.9MB / 4.1kB       11
```

#### 4.2 更新容器的硬件资源限制

> docker update [选项]

这个操作可能会显示下面的内容

> Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap

[解决办法](https://link.jianshu.com?t=https://segmentfault.com/q/1010000002888521#a-1020000002890127)

```
# /etc/default/grub
sudo vi /etc/default/grub

# 添加内核启动参数
GRUB_CMDLINE_LINUX="...   cgroup_enable=memory swapaccount=1"

# 更新 grub
sudo update-grub

# 重启
sudo reboot
```

注意是在 `GRUB_CMDLINE_LINUX` 项追加上述参数内容, 我试过简单粗暴的在文件末尾添加下面内容, 这么做会覆盖原有的启动参数, 导致网络连接失败。网络坏了, ssh都连不上了, 幸好可以在腾讯云的网页控制台登录, 修改内容重启就好了。所以呢, 这一步操作一定要慎重。

#### 4.3 使用压力测试工具 `stress` 验证效果

使用已有的stress镜像 [progrium/stress](https://link.jianshu.com?t=https://hub.docker.com/r/progrium/stress), 开两个终端, 在一个终端中执行下面命令

```
docker run -m 100m --rm -it progrium/stress --cpu 2 --io 1 --vm 10 --vm-bytes 9M
```

在另一个终端执行 `docker stats` 进行监控

```
CONTAINER           CPU %               MEM USAGE / LIMIT   MEM %               NET I/O             BLOCK I/O           PIDS
9eb0                88.42%              92.22MiB / 100MiB   92.22%              0B / 0B             1.65MB / 2.88MB     14
```

再开一个终端执行

```
# 9eb0为容器id开头, 请根据实际情况替换。内存限制只能调大不能调小
docker update -m 200m 9eb0
```

##### 相关文章:

- [docker容器的参数如何指定配额](https://link.jianshu.com?t=http://www.cnblogs.com/liuyansheng/p/6113512.html)
- [设置Docker容器中Java应用的内存限制](https://link.jianshu.com?t=http://www.cnblogs.com/ilinuxer/p/6648681.html)
- [Docker 运行时资源限制](https://link.jianshu.com?t=http://blog.csdn.net/candcplusplus/article/details/53728507)
- [Docker内存限制](https://link.jianshu.com?t=http://blog.csdn.net/s1070/article/details/52301410)

### 基础子命令列表

------

| 选项    | 说明                                                         |
| ------- | ------------------------------------------------------------ |
| attach  | 进入运行中的容器, 显示该容器的控制台界面。注意, 从该指令退出会导致容器关闭 |
| build   | 根据 Dockerfile 文件构建镜像                                 |
| commit  | 提交容器所做的改为为一个新的镜像                             |
| cp      | 在容器和宿主机之间复制文件                                   |
| create  | 根据镜像生成一个新的容器                                     |
| diff    | 展示容器相对于构建它的镜像内容所做的改变                     |
| events  | 实时打印服务端执行的事件                                     |
| exec    | 在已运行的容器中执行命令                                     |
| export  | 导出容器到本地快照文件                                       |
| history | 显示镜像每层的变更内容                                       |
| images  | 列出本地所有镜像                                             |
| import  | 导入本地容器快照文件为镜像                                   |
| info    | 显示 Docker 详细的系统信息                                   |
| inspect | 查看容器或镜像的配置信息, 默认为json数据                     |
| kill    | `-s` 选项向容器发送信号, 默认为SIGKILL信号(强制关闭)         |
| load    | 导入镜像压缩包                                               |
| login   | 登录第三方仓库                                               |
| logout  | 退出第三方仓库                                               |
| logs    | 打印容器的控制台输出内容                                     |
| pause   | 暂停容器                                                     |
| port    | 容器端口映射列表                                             |
| ps      | 列出正在运行的容器, `-a` 选项显示所有容器                    |
| pull    | 从镜像仓库拉取镜像                                           |
| push    | 将镜像推送到镜像仓库                                         |
| rename  | 重命名容器名                                                 |
| restart | 重启容器                                                     |
| rm      | 删除已停止的容器, `-f` 选项可强制删除正在运行的容器          |
| rmi     | 删除镜像(必须先删除该镜像构建的所有容器)                     |
| run     | 根据镜像生成并进入一个新的容器                               |
| save    | 打包本地镜像, 使用压缩包来完成迁移                           |
| search  | 查找镜像                                                     |
| start   | 启动关闭的容器                                               |
| stats   | 显示容器对资源的使用情况(内存、CPU、磁盘等)                  |
| stop    | 关闭正在运行的容器                                           |
| tag     | 修改镜像tag                                                  |
| top     | 显示容器中正在运行的进程(相当于容器内执行 `ps -ef` 命令)     |
| unpause | 恢复暂停的容器                                               |
| update  | 更新容器的硬件资源限制(内存、CPU等)                          |
| version | 显示docker客户端和服务端版本信息                             |
| wait    | 阻塞当前命令直到对应的容器被关闭, 容器关闭后打印结束代码     |
| daemon  | 这个子命令已过期, 将在Docker 17.12之后的版本中移出, 直接使用dockerd |

### 用于管理的子命令列表

------

| 选项      | 说明                                                         |
| --------- | ------------------------------------------------------------ |
| container | 管理容器                                                     |
| image     | 管理镜像                                                     |
| network   | 管理容器网络(默认为bridge、host、none三个网络配置)           |
| plugin    | 管理插件                                                     |
| system    | 管理系统资源。其中, `docker system prune` 命令用于清理没有使用的镜像, 容器, 数据卷以及网络 |
| volume    | 管理数据卷                                                   |
| swarm     | 管理Swarm模式                                                |
| service   | 管理Swarm模式下的服务                                        |
| node      | 管理Swarm模式下的docker集群中的节点                          |
| secret    | 管理Swarm模式下的敏感数据                                    |
| stack     | Swarm模式下利用compose-file管理服务                          |

#### 说明

其中 `container` 、`image` 、`system` 一般用前面的简化指令即可。`Swarm` 模式用来管理docker集群, 它将一群Docker宿主机变成一个单一的虚拟的主机, 实现对多台物理机的集群管理。

- [初试Docker swarm命令](https://link.jianshu.com?t=https://my.oschina.net/tantexian/blog/785740)
- [优雅地实现安全的容器编排 - Docker Secrets](https://link.jianshu.com?t=https://yq.aliyun.com/articles/91396)
- [解读1.13.1 | 探究Docker Stack和可对接网络](https://link.jianshu.com?t=https://segmentfault.com/a/1190000008469023)

### [系列文章](https://www.jianshu.com/nb/13876015)

------

#### [Docker 学习总结](https://www.jianshu.com/p/74f29cf5a999)

#### [使用Dockerfile构建镜像](https://www.jianshu.com/p/a0892512f86c)

#### [使用Docker-compose构建容器](https://www.jianshu.com/p/ee8e7d2eb645)

#### [Docker Daemon连接方式详解](https://www.jianshu.com/p/7ba1a93e6de4)

#### [Docker下的网络模式](https://www.jianshu.com/p/f510aaa470cc)