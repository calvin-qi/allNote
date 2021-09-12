# 1、Linux安装Java JDK1.8配置

## 1、下载安装包

[下载地址](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html)

![jdk1.8_8u291](https://i.loli.net/2021/07/15/2bzelo4vVIUB6cP.png)

## 2.创建文件夹并解压

```
mkdir -p /usr/local/programs/java/
mv jdk-8u291-linux-x64.tar.gz /usr/local/programs/java/
tar -zxvf ./jdk-8u291-linux-x64.tar.gz
```

## 3. 环境变量配置

vim打开文件

```
vim /etc/profile
```

添加配置变量

```
export JAVA_HOME=/usr/local/programs/java/jdk1.8.0_291
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
```

```
source /etc/profile
```

验证

```
java -version
```











