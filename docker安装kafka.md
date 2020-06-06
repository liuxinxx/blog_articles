# docker安装kafka1:kafka需要zookeeper管理，所以需要先安装zookeeper。 下载docker pull wurstmeister/zookeeper:latest版本
```
docker pull wurstmeister/zookeeper
```
![img](https:////upload-images.jianshu.io/upload_images/14796116-307d1c0c1efd1229.png?imageMogr2/auto-orient/strip|imageView2/2/w/647/format/webp)

2：启动镜像生成容器

```
docker run -d --name zookeeper -p 2181:2181 -v /etc/localtime:/etc/localtime wurstmeister/zookeeper
```



![img](https:////upload-images.jianshu.io/upload_images/14796116-c4eb11a2b8f2f4e7.png?imageMogr2/auto-orient/strip|imageView2/2/w/1186/format/webp)

3：下载kafka镜像
```
docker pull wurstmeister/kafka
```
![img](https:////upload-images.jianshu.io/upload_images/14796116-f1dc71635b24d8eb.png?imageMogr2/auto-orient/strip|imageView2/2/w/638/format/webp)

4：启动kafka镜像生成容器
```
docker run -d --name kafka -p 9092:9092 -e KAFKA_BROKER_ID=0 -e KAFKA_ZOOKEEPER_CONNECT=192.168.155.56:2181/kafka -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.155.56:9092 -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 -v /etc/localtime:/etc/localtime wurstmeister/kafka
```

**-e KAFKA_BROKER_ID=0 在kafka集群中，每个kafka都有一个BROKER_ID来区分自己
**

**-e KAFKA_ZOOKEEPER_CONNECT=192.168.155.56:2181/kafka 配置zookeeper管理kafka的路径192.168.155.56:2181/kafka
**

**-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.155.56:9092 把kafka的地址端口注册给zookeeper
**

**-e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 配置kafka的监听端口
**

**-v /etc/localtime:/etc/localtime 容器时间同步虚拟机的时间**

![img](https:////upload-images.jianshu.io/upload_images/14796116-4565050db8e8115f.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

5：验证kafka是否可以使用

进入容器
```
docker exec -it kafka /bin/sh
```
进入路径：`/opt/kafka_2.11-2.0.0/bin`下

运行kafka生产者发送消息
```
./kafka-console-producer.sh --broker-list localhost:9092 --topic sun
```
发送消息
```
{"datas":[{"channel":"","metric":"temperature","producer":"ijinus","sn":"IJA0101-00002245","time":"1543207156000","value":"80"}],"ver":"1.0"}
```
![img](https:////upload-images.jianshu.io/upload_images/14796116-43aa4c10f76894be.png?imageMogr2/auto-orient/strip|imageView2/2/w/1138/format/webp)

‘

运行kafka消费者接收消息
```
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic sun --from-beginning
```
![img](https:////upload-images.jianshu.io/upload_images/14796116-83a67ecf3b2f4c61.png?imageMogr2/auto-orient/strip|imageView2/2/w/1135/format/webp)





**-------------------------------------------------------------------关键总结------------------------------------------------------------------------**

**1：进入zookeeper容器内，可以看到kafka注册信息**

**docker exec -it zookeeper /bin/sh**

**进入bin目录**

![img](https:////upload-images.jianshu.io/upload_images/14796116-d83a20041541403a.png?imageMogr2/auto-orient/strip|imageView2/2/w/651/format/webp)

**运行zkCli.sh进入zookeeper客户端**

**./zkCli.sh**

**
**

![img](https:////upload-images.jianshu.io/upload_images/14796116-892a97de85e8ff28.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

**ls / 可以查看zookeeper根节点下都挂了那些目录**

![img](https:////upload-images.jianshu.io/upload_images/14796116-c18fd13b09cf3921.png?imageMogr2/auto-orient/strip|imageView2/2/w/257/format/webp)

**可以看到我注册的kafka目录，运行**

**ls /kafka/brokers/topics/sun/partitions 
**

**可以看到我建立的topic叫sun主题的partitions信息**

![img](https:////upload-images.jianshu.io/upload_images/14796116-caf9829a34569b6d.png?imageMogr2/auto-orient/strip|imageView2/2/w/591/format/webp)

**get命令会显示该节点的节点数据内容和属性信息**
**get /kafka/brokers/topics/sun**

![img](https:////upload-images.jianshu.io/upload_images/14796116-34064db5ad1e14da.png?imageMogr2/auto-orient/strip|imageView2/2/w/519/format/webp)

**ls2命令会显示该节点的子节点信息和属性信息
**

**ls2 /kafka/brokers/topics/sun**

![img](https:////upload-images.jianshu.io/upload_images/14796116-630a5d53bcacc228.png?imageMogr2/auto-orient/strip|imageView2/2/w/510/format/webp)

**通过命令行创建topic和partitions**

**kafka-topics.sh --create --zookeeper 192.168.155.56:2181/kafka --topic topic-test1 --replication-factor 1 --partitions 2**

![img](https:////upload-images.jianshu.io/upload_images/14796116-94e14e20955def09.png?imageMogr2/auto-orient/strip|imageView2/2/w/643/format/webp)

**当创建的replication-factor=2时，因为zookeeper的zoo.cfg配置文件中tickTime=2000会报链接超时，把这个值调大一些，重启zookeeper，再创建topic正常。**

![img](https:////upload-images.jianshu.io/upload_images/14796116-b77ca5319b1c783b.png?imageMogr2/auto-orient/strip|imageView2/2/w/1173/format/webp)

#### **删除topic 使用命令：**

若 delete.topic.enable=true 

直接彻底删除该 Topic。

若 delete.topic.enable=false

如果当前 Topic 没有使用过即没有传输过信息：可以彻底删除。

如果当前 Topic 有使用过即有过传输过信息：并没有真正删除 Topic 只是把这个 Topic 标记为删除(marked for deletion)，重启 Kafka Server 后删除。

我的kafka版本是最新的，在service.config文件中是找不到delete.topic.enable=true，系统默认是true.

进入kafka容器，cd opt/kafka/bin

kafka-topics.sh --delete --zookeeper 192.168.155.56:2181/kafka --topic sun

![img](https:////upload-images.jianshu.io/upload_images/14796116-09656f3074e52240.png?imageMogr2/auto-orient/strip|imageView2/2/w/646/format/webp)

命令可以删除容器中的topic数据，还有zookeeper中的topic目录。

可以在zookeeper中查看目录是否已经删除掉了

进入zookeeper容器，在bin下运行./zkCli.sh

ls /kafka/brokers/topics

![img](https:////upload-images.jianshu.io/upload_images/14796116-f8bd882c138b2533.png?imageMogr2/auto-orient/strip|imageView2/2/w/582/format/webp)

还有一种暴力删除方法，因为我启动kafka容器的时候，没有外挂topic路径。所以我直接把容器删除掉，再重新启动一个新的容器也能实现topic的删除。（这种方式不推荐用）

#### **docker kafka 数据文件保存的路径：**

在配置文件service.config中配置的，log.dirs配置保存路径。

进入kafka容器,找到配置文件路径/opt/kafka_2.11-2.0.0/config

vi service.config 

![img](https:////upload-images.jianshu.io/upload_images/14796116-37cb85979bd42d80.png?imageMogr2/auto-orient/strip|imageView2/2/w/577/format/webp)

默认配置在/kafka/kafka-logs-4eaa3ff7f59d下

![img](https:////upload-images.jianshu.io/upload_images/14796116-70ee5558650d606c.png?imageMogr2/auto-orient/strip|imageView2/2/w/539/format/webp)



作者：szgl_lucifer
链接：https://www.jianshu.com/p/e8c29cba9fae
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。