# 单独安装Hadoop

```shell
master=192.168.1.101
node1=192.168.1.102
node2=192.168.1.103

echo"------------配置免密登录------------"
ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''
yum -y install sshpass expect

echo "-------------修改/etc/ssh/ssh_config------------"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.101 "sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config && service sshd restart"

sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config && service sshd restart"

sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config && service sshd restart"


echo "--------修改hosts配置在所有节点---------------"
echo -e '192.168.1.101    master\n192.168.1.102    node1\n192.168.1.103    node2' > /etc/hosts
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "echo -e '192.168.1.101    master\n192.168.1.102    node1\n192.168.1.103    node2' > /etc/hosts"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "echo -e '192.168.1.101    master\n192.168.1.102    node1\n192.168.1.103    node2' > /etc/hosts"

echo "--------------在node1和node2生成ssh-keygen----------------"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''"
sshpass -p dosion123456 scp ~/.ssh/id_rsa.pub root@192.168.1.103:~/
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''"

echo "---------------打通ssh免密本身和其他节点------------------"
sshpass -p dosion123456 scp ~/.ssh/id_rsa.pub root@192.168.1.101:~/
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.101 "cat id_rsa.pub > ~/.ssh/authorized_keys"

sshpass -p dosion123456 scp ~/.ssh/id_rsa.pub root@192.168.1.102:~/
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "cat id_rsa.pub > ~/.ssh/authorized_keys"

sshpass -p dosion123456 scp ~/.ssh/id_rsa.pub root@192.168.1.103:~/
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "cat id_rsa.pub > ~/.ssh/authorized_keys"



echo "=====关闭master防火墙和Selinux====="
systemctl stop firewalld
systemctl disable firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

echo "=====关闭node1防火墙和Selinux====="
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "systemctl stop firewalld && systemctl disable firewalld && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"

echo "=====关闭node2防火墙和Selinux====="
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "systemctl stop firewalld && systemctl disable firewalld && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"

echo "=====下载hadoop包解压至指定路径====="
mkdir /home/software
cd /home/software
wget http://119.3.206.181/data/hadoop-2.8.5.tar.gz
mkdir -p /export/server
mkdir  /export/data
mkdir  /export/software
tar -zxvf hadoop-2.8.5.tar.gz -C /export/server/

echo "==========修改配置文件hadoop-env.sh==========="
cd /export/server/hadoop-2.8.5/etc/hadoop

echo -e 'export JAVA_HOME=/usr/local/java/jdk1.8.0_191\nexport HDFS_NAMENODE_USER=root\nexport HDFS_DATANODE_USER=root\nexport HDFS_SECONDARYNAMENODE_USER=root\nexport YARN_RESOURCEMANAGER_USER=root\nexport YARN_NODEMANAGER_USER=root' >> /export/server/hadoop-2.8.5/etc/hadoop/hadoop-env.sh

echo "==========修改core-site.xml================"
sed -i '/<configuration>/a\    <property>\n        <name>fs.defaultFS</name>\n        <value>hdfs://192.168.1.101:8020</value>\n    </property>\n    <property>\n        <name>hadoop.tmp.dir</name>\n        <value>/export/data/hadoop-2.8.5</value>\n    </property>\n    <property>\n        <name>hadoop.http.staticuser.user</name>\n        <value>root</value>\n    </property>' core-site.xml

echo "==========修改配置文件hdfs-site.xml=========="
sed -i '/<configuration>/a\    <property>\n        <name>dfs.namenode.secondary.http-address</name>\n        <value>192.168.1.102:9868</value>\n    </property>' hdfs-site.xml

echo "==========修改配置文件mapred-site.xm============="
mv mapred-site.xml.template mapred-site.xml
sed -i '/<configuration>/a\    <property>\n        <name>mapreduce.framework.name</name>\n        <value>yarn</value>\n    </property>\n    <property>\n        <name>yarn.app.mapreduce.am.env</name>\n        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>\n    </property>\n    <property>\n        <name>mapreduce.map.env</name>\n        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>\n    </property>\n    <property>\n        <name>mapreduce.reduce.env</name>\n        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>\n    </property>'  mapred-site.xml

echo "==========修改配置文件yarn-site.xml============="
sed -i '/<configuration>/a\    <property>\n        <name>yarn.resourcemanager.hostname</name>\n        <value>192.168.1.101</value>\n    </property>\n    <property>\n        <name>yarn.nodemanager.aux-services</name>\n        <value>mapreduce_shuffle</value>\n    </property>\n    <property>\n        <name>yarn.scheduler.minimum-allocation-mb</name>\n        <value>1024</value>\n    </property>\n    <property>\n        <name>yarn.scheduler.maximum-allocation-mb</name>\n        <value>2048</value>\n    </property>\n    <property>\n        <name>yarn.nodemanager.vmem-pmem-ratio</name>\n        <value>1</value>\n    </property>'  yarn-site.xml

echo "============修改配置文件salves============="

cat > slaves << EOF
master
node1
node2
EOF

echo "=====在master机器上将Hadoop安装包scp同步到其他机器====="
#cd /
#echo "同步到node1开始"
#sshpass -p dosion123456 scp -r /export root@192.168.1.102:/
#echo "同步到node1结束"
#echo "同步到node2开始"
#sshpass -p dosion123456 scp -r /export root@192.168.1.103:/
#echo "同步到node1结束"
for ip in ${node1} ${node2}
do
    {
    sshpass -p dosion123456 scp -r /export root@${node1}:/ >/dev/null 2>&1
    sshpass -p dosion123456 scp -r /export root@${node2}:/  >/dev/null 2>&1
    }&
done
wait
echo "同步文件结束"

echo -e '#Hadoop\nexport HADOOP_HOME=/export/server/hadoop-2.8.5\nexport PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> /etc/profile

echo "同步/etc/profile到node1"
sshpass -p dosion123456 scp /etc/profile root@192.168.1.102:/etc/
echo "同步/etc/profile到node2"
sshpass -p dosion123456 scp /etc/profile root@192.168.1.103:/etc/
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"

source /etc/profile
echo "========NameNode format======="
hadoop namenode -format
source /etc/profile
echo "==========启动hdfs和yarn》start-all.sh========"
start-all.sh
echo "------------用jps看下master--------------"
jps
echo "------------用jps看下node1--------------"
sshpass -p dosion123456 ssh root@192.168.1.102 "jps"
echo "------------用jps看下node2--------------"
sshpass -p dosion123456 ssh root@192.168.1.103 jps
```

--------------------------------------------------

# 单独安装hbase

```shell
# 将 hbase 源码包放在/home/software目录下
cd /home/
wget http://119.3.206.181/data/hbase-2.0.0-bin.tar.gz
# 解压hbase-2.0.0，并放到指定目录
tar -zxvf hbase-2.0.0-bin.tar.gz -C /usr/local/
wait
mv /usr/local/hbase-2.0.0 /usr/local/hbase
# 设置环境变量及临时目录
echo -e 'export HBASE_HOME=/usr/local/hbase\nexport PATH=${HBASE_HOME}/bin:$PATH' >> /etc/profile
source /etc/profile

# 编辑hbase-env.s文件，指定系统运行环境
cd /usr/local/hbase/conf
echo -e 'export JAVA_HOME=/usr/local/java/jdk1.8.0_191\nexport HBASE_CLASSPATH=/usr/local/hbase/conf\nexport HBASE_MANAGES_ZK=true\nexport HBASE_LOG_DIR=/var/log/hbase_log' >> hbase-env.sh

# 编辑hbase-site.xml核心配置文件
cd /usr/local/hbase/conf
true > hbase-site.xml
cat >> hbase-site.xml << EOF
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://192.168.1.101:8020/usr/local/hbase</value>
  </property>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>   
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>192.168.1.101:2181,192.168.1.102:2181,192.168.1.103:2181</value>
  </property>
  <property>
    <name>hbase.zookeeper.property.dataDir</name>
    <value>/home/workspace/data/zookeeper/data</value>
  </property>
</configuration>
EOF

# 配置区域服务器（regionserver），加入到RegionServer节点列表
cd /usr/local/hbase/conf
true > regionservers
cat >> regionservers << EOF
192.168.1.102
192.168.1.103
EOF

# 把 hadoop 的配置文件 core-site.xml 和 hdfs-site.xml 复制到 hbase 的配置文件目录下
cp /usr/local/hadoop/hadoop-2.8.5/etc/hadoop/core-site.xml /usr/local/hbase/conf
cp /usr/local/hadoop/hadoop-2.8.5/etc/hadoop/hdfs-site.xml /usr/local/hbase/conf

# 拷贝环境变量
scp /etc/profile root@192.168.1.102:/etc/
scp /etc/profile root@192.168.1.103:/etc/

# ssh免密码登录执行节点命令
source /etc/profile
source /etc/profile
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
# 把hbase安装目录拷贝给其他节点
for ip in ${node1} ${node2}
do
    {
    scp -r /usr/local/hbase root@${ip}:/usr/local/
    }&
done
wait
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"

#启动HBase（在master上运行）
start-hbase.sh


```

---

# 单独安装phoenix

```shell
# 下载软件包
cd /home/
wget http://119.3.206.181/data/apache-phoenix-5.0.0-HBase-2.0-bin.tar.gz

#解压phoenix源码包并存放在指定的master节点目录下
tar -xvf apache-phoenix-5.0.0-HBase-2.0-bin.tar.gz
mv apache-phoenix-5.0.0-HBase-2.0-bin /usr/local/hbase/phoenix

# 添加phoenix环境变量
echo -e 'export PNX_HOME=/usr/local/hbase/phoenix\nexport PATH=$PATH:$PNX_HOME/bin' >> /etc/profile
source /etc/profile
# 拷贝jar包到各个节点
cd /usr/local/hbase/phoenix
cp phoenix-core-5.0.0-HBase-2.0.jar phoenix-5.0.0-HBase-2.0-server.jar /usr/local/hbase/lib
scp phoenix-core-5.0.0-HBase-2.0.jar phoenix-5.0.0-HBase-2.0-server.jar node1:/usr/local/hbase/lib
scp phoenix-core-5.0.0-HBase-2.0.jar phoenix-5.0.0-HBase-2.0-server.jar node2:/usr/local/hbase/lib

# 复制hbase安装目录下的conf目录下hbase-site.xml到phoenix安装目录下的bin中
cd /usr/local/hbase/conf
cp hbase-site.xml /usr/local/hbase/phoenix/bin

# 复制 hadoop安装目录即/export/server/hadoop-2.8.5/etc/hadoop目录下的core-site.xml hdfs-site.xml到phoenix安装目录下的bin中
cd /u/hadoop-2.8.5/etc/hadoop
cp core-site.xml hdfs-site.xml /usr/local/hbase/phoenix/bin

# 重启hbase集群，使Phoenix的jar包生效
stop-hbase.sh
start-hbase.sh

# 修改权限
cd /usr/local/hbase/phoenix/bin
chmod 777 psql.py
chmod 777 sqlline.py

# 测试能否运行
sqlline.py master,node1,node2:2181


```

----

# 一键安装hadoop hbas phoenix

```shell
#!/bin/bash
#脚本执行source /etc/profile貌似不成功，安装完请手动执行，用jps看下组件其不齐全。然后启动start-all.sh,start-hbase.sh,sqlline.py master,node1,node2:2181测试
master=192.168.1.101
node1=192.168.1.102
node2=192.168.1.103
passwd=dosion123456
hosts=`cat host |grep -Po "\d+\.\d+\.\d+\.\d+"`
javaJkdPath=/usr/local/java/jdk1.8.0_191

echo "IP-${master} Begin install sshpass expect wget curl ntpdate ..."
yum -y install sshpass expect wget curl ntpdate >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "SUCCESS---IP-${master} install sshpass expect wget curl ntpdate"
fi

##
sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config
service sshd restart >/dev/null 2>&1
sleep 3

echo -e "Send install files to ${node1}"
sshpass -p ${passwd} scp -r /root/hadoop/ root@${node1}:~/ >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success ---Send install files to ${node1}"
fi
echo -e "Send install files to ${node2}"
sshpass -p ${passwd} scp -r /root/hadoop/ root@${node2}:~/ >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success ---Send install files to ${node2}"
fi



for ip in ${hosts}
do
    {
    echo -e "IP-${ip} generating ssh-keygen ..."
    sshpass -p ${passwd} ssh root@${ip} "ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} generate ssh-keygen"
    fi
    }&
done
wait

for ip in ${hosts}
do
    {
    echo -e "Sending id_rsa.pub to ${ip} ..."
    sshpass -p ${passwd} ssh-copy-id -i /root/.ssh/id_rsa.pub root@${ip} >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---Sended id_rsa.pub to ${ip}"
    fi
    echo -e "IP-${ip} writing hosts ..."
    sshpass -p ${passwd} ssh root@${ip} "cat /root/hadoop/host >> /etc/hosts" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} writed hosts"
    fi
    }&
done
wait


for ip in ${hosts}
do
    {
    echo -e "IP-${ip} installing (wget curl ntpdate) ..."
    sshpass -p ${passwd} ssh root@${ip} "yum -y install wget curl ntpdate" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success  IP-${ip} installed (wget curl ntpdate)"
    fi

    echo -e "IP-${ip} closing firewalld ..."
    sshpass -p ${passwd} ssh root@${ip} "systemctl stop firewalld && systemctl disable firewalld" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} closed firewalld"
    fi

    echo -e "IP-${ip} closing selinux ..."
    sshpass -p ${passwd} ssh root@${ip} "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} closed selinux"
    fi

    echo -e "IP-${ip} closing swap ..."
    sshpass -p ${passwd} ssh root@${ip} "swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} closed swap"
    fi

    echo -e "IP-${ip} synchronizing time ..."
    sshpass -p ${passwd} ssh root@${ip} "ntpdate time.windows.com" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} synchronized time"
    fi
    }&
done
wait

####################################################################
echo "开始下载解压hadoop"
mkdir -p /usr/local/hadoop/data
cd /home/
wget http://119.3.206.181/data/hadoop-2.8.5.tar.gz >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "下载成功"
fi

tar -zxvf hadoop-2.8.5.tar.gz -C /usr/local/hadoop >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "解压成功到/usr/local/hadoop"
fi


echo "修改配置文件hadoop-env.sh"
cd /usr/local/hadoop/hadoop-2.8.5/etc/hadoop

echo -e 'export JAVA_HOME=/usr/local/java/jdk1.8.0_191\nexport HDFS_NAMENODE_USER=root\nexport HDFS_DATANODE_USER=root\nexport HDFS_SECONDARYNAMENODE_USER=root\nexport YARN_RESOURCEMANAGER_USER=root\nexport YARN_NODEMANAGER_USER=root' >> hadoop-env.sh
if [ $? != 0 ]; then
    echo "fail"
else
    echo "hadoop-env.sh修改成功"
fi

echo "修改core-site.xml"
sed -i '/<configuration>/a\    <property>\n        <name>fs.defaultFS</name>\n        <value>hdfs://192.168.1.101:8020</value>\n    </property>\n    <property>\n        <name>hadoop.tmp.dir</name>\n        <value>/usr/local/hadoop/data/hadoop-2.8.5</value>\n    </property>\n    <property>\n        <name>hadoop.http.staticuser.user</name>\n        <value>root</value>\n    </property>' core-site.xml >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "core-site.xml修改成功"
fi


echo "修改配置文件hdfs-site.xml"
sed -i '/<configuration>/a\    <property>\n        <name>dfs.namenode.secondary.http-address</name>\n        <value>192.168.1.102:9868</value>\n    </property>' hdfs-site.xml >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "hdfs-site.xml修改成功"
fi


echo "修改配置文件mapred-site.xm"
mv mapred-site.xml.template mapred-site.xml
sed -i '/<configuration>/a\    <property>\n        <name>mapreduce.framework.name</name>\n        <value>yarn</value>\n    </property>\n    <property>\n        <name>yarn.app.mapreduce.am.env</name>\n        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>\n    </property>\n    <property>\n        <name>mapreduce.map.env</name>\n        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>\n    </property>\n    <property>\n        <name>mapreduce.reduce.env</name>\n        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>\n    </property>'  mapred-site.xml >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "mapred-site.xml修改成功"
fi


echo "修改配置文件yarn-site.xml"
sed -i '/<configuration>/a\    <property>\n        <name>yarn.resourcemanager.hostname</name>\n        <value>192.168.1.101</value>\n    </property>\n    <property>\n        <name>yarn.nodemanager.aux-services</name>\n        <value>mapreduce_shuffle</value>\n    </property>\n    <property>\n        <name>yarn.scheduler.minimum-allocation-mb</name>\n        <value>1024</value>\n    </property>\n    <property>\n        <name>yarn.scheduler.maximum-allocation-mb</name>\n        <value>2048</value>\n    </property>\n    <property>\n        <name>yarn.nodemanager.vmem-pmem-ratio</name>\n        <value>1</value>\n    </property>'  yarn-site.xml >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "yarn-site.xml修改成功"
fi


echo "修改配置文件salves"

cat > slaves << EOF
master
node1
node2
EOF
if [ $? != 0 ]; then
    echo "fail"
else
    echo "slaves修改成功"
fi

echo -e '#Hadoop\nexport HADOOP_HOME=/usr/local/hadoop/hadoop-2.8.5\nexport PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> /etc/profile
source /etc/profile
for ip in ${node1} ${node2}
do
    {
    echo "分发安装包到${ip}"
    sshpass -p ${passwd} scp -r /usr/local/hadoop root@${ip}:/usr/local/ >/dev/null 2>&1
    sshpass -p ${passwd} scp -r /etc/profile root@${ip}:/etc/
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "发送到${ip}成功"
    fi
    }&
done
wait

for ip in ${hosts}
do
    sshpass -p ${passwd} ssh root@${ip} "source /etc/profile"  >/dev/null 2>&1
done
for ip in ${hosts}
do
    sshpass -p ${passwd} ssh root@${ip} "source /etc/profile"  >/dev/null 2>&1
done
wait
source /etc/profile
sleep 5
echo "namenode format"
hadoop namenode -format
wait

echo "一键启动，等一会儿"
start-all.sh >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "启动成功"
fi

for ip in ${hosts}
do
    echo "${ip}看下好了没"
    ssh root@${ip} jps
done



# 将 hbase 源码包放在/home/software目录下
cd /home/
wget http://119.3.206.181/data/hbase-2.0.0-bin.tar.gz
# 解压hbase-2.0.0，并放到指定目录
tar -zxvf hbase-2.0.0-bin.tar.gz -C /usr/local/
wait
mv /usr/local/hbase-2.0.0 /usr/local/hbase
# 设置环境变量及临时目录
echo -e 'export HBASE_HOME=/usr/local/hbase\nexport PATH=${HBASE_HOME}/bin:$PATH' >> /etc/profile
source /etc/profile

# 编辑hbase-env.s文件，指定系统运行环境
cd /usr/local/hbase/conf
echo -e 'export JAVA_HOME=/usr/local/java/jdk1.8.0_191\nexport HBASE_CLASSPATH=/usr/local/hbase/conf\nexport HBASE_MANAGES_ZK=true\nexport HBASE_LOG_DIR=/var/log/hbase_log' >> hbase-env.sh

# 编辑hbase-site.xml核心配置文件
cd /usr/local/hbase/conf
true > hbase-site.xml
cat >> hbase-site.xml << EOF
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://192.168.1.101:8020/usr/local/hbase</value>
  </property>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>   
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>192.168.1.101:2181,192.168.1.102:2181,192.168.1.103:2181</value>
  </property>
  <property>
    <name>hbase.zookeeper.property.dataDir</name>
    <value>/home/workspace/data/zookeeper/data</value>
  </property>
</configuration>
EOF

# 配置区域服务器（regionserver），加入到RegionServer节点列表
cd /usr/local/hbase/conf
true > regionservers
cat >> regionservers << EOF
192.168.1.102
192.168.1.103
EOF

# 把 hadoop 的配置文件 core-site.xml 和 hdfs-site.xml 复制到 hbase 的配置文件目录下
cp /usr/local/hadoop/hadoop-2.8.5/etc/hadoop/core-site.xml /usr/local/hbase/conf
cp /usr/local/hadoop/hadoop-2.8.5/etc/hadoop/hdfs-site.xml /usr/local/hbase/conf

# 拷贝环境变量
scp /etc/profile root@192.168.1.102:/etc/
scp /etc/profile root@192.168.1.103:/etc/

# ssh免密码登录执行节点命令
source /etc/profile
source /etc/profile
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
# 把hbase安装目录拷贝给其他节点
for ip in ${node1} ${node2}
do
    {
    scp -r /usr/local/hbase root@${ip}:/usr/local/
    }&
done
wait
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"

#启动HBase（在master上运行）



# 下载软件包
cd /home/
wget http://119.3.206.181/data/apache-phoenix-5.0.0-HBase-2.0-bin.tar.gz

#解压phoenix源码包并存放在指定的master节点目录下
tar -xvf apache-phoenix-5.0.0-HBase-2.0-bin.tar.gz
mv apache-phoenix-5.0.0-HBase-2.0-bin /usr/local/hbase/phoenix

# 添加phoenix环境变量
echo -e 'export PNX_HOME=/usr/local/hbase/phoenix\nexport PATH=$PATH:$PNX_HOME/bin' >> /etc/profile
source /etc/profile
# 拷贝jar包到各个节点
cd /usr/local/hbase/phoenix
cp phoenix-core-5.0.0-HBase-2.0.jar phoenix-5.0.0-HBase-2.0-server.jar /usr/local/hbase/lib
scp phoenix-core-5.0.0-HBase-2.0.jar phoenix-5.0.0-HBase-2.0-server.jar node1:/usr/local/hbase/lib
scp phoenix-core-5.0.0-HBase-2.0.jar phoenix-5.0.0-HBase-2.0-server.jar node2:/usr/local/hbase/lib

# 复制hbase安装目录下的conf目录下hbase-site.xml到phoenix安装目录下的bin中
cd /usr/local/hbase/conf
cp hbase-site.xml /usr/local/hbase/phoenix/bin

# 复制 hadoop安装目录即/export/server/hadoop-2.8.5/etc/hadoop目录下的core-site.xml hdfs-site.xml到phoenix安装目录下的bin中
cd /u/hadoop-2.8.5/etc/hadoop
cp core-site.xml hdfs-site.xml /usr/local/hbase/phoenix/bin

# 重启hbase集群，使Phoenix的jar包生效
stop-hbase.sh
start-hbase.sh

# 修改权限
cd /usr/local/hbase/phoenix/bin
chmod 777 psql.py
chmod 777 sqlline.py

# 测试能否运行 !quit退出
sqlline.py master,node1,node2:2181




```

