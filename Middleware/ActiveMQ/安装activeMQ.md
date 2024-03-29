# activemq的安装
## 原生安装
- 前提条件 需要先 安装 JDK 并配置环境变量，JAVA_HOME=/usr/local/java/jdk1.7.0_72

### 安装

```shell
# 1.进入/home文件夹下面（看要求，有的实在/usr/home/services/下），创建一个activemq文件夹
cd /home/
mkdir activemq

# 2.下载activemq压缩包，并解压
wget http://archive.apache.org/dist/activemq/5.14.5/apache-activemq-5.14.5-bin.tar.gz
tar -zxvf apache-activemq-5.14.5-bin.tar.gz

# 3.查看下
ls

# 4.更换下文件名
mv apache-activemq-5.14.5 activemq
```

### 启动和停止

```shell
# 进入bin目录
cd bin/
#启动activemq
./activemq start

#查看activemq进程
ps -ef| grep activemq

-------------------------------------------------------------
停止服务
./activemq stop
启动服务
./activemq start
重启服务
./activemq restart
-------------------------------------------------------------

************设置开机自启************
#建立软连接
ln -s /home/activemq/bin/activemq /etc/init.d/
#注册为系统服务
vim /etc/init.d/activemq

#添加下面内容到/etc/init.d/activemq

# chkconfig: 345 63 37
# description: Auto start ActiveMQ
JAVA_HOME=/home/jdk1.8.0_144
JAVA_CMD=java

#设置开机自启
chkconfig activemq on
reboot

#可以以系统服务的方式启动、查看状态和停止服务
service activemq start
service activemq status
service activemq stop
*********************************
```

- 防火墙的设置添加8161和61616端口号：

  ```shell
  firewall-cmd --zone=public --add-port=8161/tcp --permanent #--permanent永久生效，没有此参数重启后失效
  firewall-cmd --zone=public --add-port=61616/tcp --permanent
  ```

  ![img](https://i.loli.net/2021/11/26/a2cArp7BHd61Swx.png)

- 重新载入，查看端口是否设置成功

  ```bash
  firewall-cmd --reload
  firewall-cmd --zone=public --list-ports
  ```

- 验证结果：http://ip地址:8161/admin  用户名:admin 密码：admin

  ![img](https://i.loli.net/2021/11/26/HNyV28dogTsZRU6.png)

## docker安装activemq
```shell
 docker run --name activemq \
      -itd \
      -p 8161:8161 \
      -p 61616:61616 \
      -e ACTIVEMQ_ADMIN_LOGIN=admin \
      -e ACTIVEMQ_ADMIN_PASSWORD=admin \
      --restart=always \
      -v /data/activemq:/data/activemq \
      -v /data/activemq/log:/var/log/activemq \
      webcenter/activemq:latest
```
