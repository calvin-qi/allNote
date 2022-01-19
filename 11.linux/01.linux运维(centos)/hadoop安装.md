# Hadoop安装

```shell
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
cd /
echo "同步到node1开始"
sshpass -p dosion123456 scp -r /export root@192.168.1.102:/
echo "同步到node1结束"
echo "同步到node2开始"
sshpass -p dosion123456 scp -r /export root@192.168.1.103:/
echo "同步到node1结束"

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
jps
echo "------------用jps看下node2--------------"
j
```

