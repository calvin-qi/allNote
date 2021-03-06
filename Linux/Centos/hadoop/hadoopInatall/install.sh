#!/bin/bash
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
echo "??????????????????hadoop"
mkdir -p /usr/local/hadoop/data
cd /home/
wget http://119.3.206.181/data/hadoop-2.8.5.tar.gz >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "????????????"
fi

tar -zxvf hadoop-2.8.5.tar.gz -C /usr/local/hadoop >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "???????????????/usr/local/hadoop"
fi


echo "??????????????????hadoop-env.sh"
cd /usr/local/hadoop/hadoop-2.8.5/etc/hadoop

echo -e 'export JAVA_HOME=/usr/local/java/jdk1.8.0_191\nexport HDFS_NAMENODE_USER=root\nexport HDFS_DATANODE_USER=root\nexport HDFS_SECONDARYNAMENODE_USER=root\nexport YARN_RESOURCEMANAGER_USER=root\nexport YARN_NODEMANAGER_USER=root' >> hadoop-env.sh
if [ $? != 0 ]; then
    echo "fail"
else
    echo "hadoop-env.sh????????????"
fi

echo "??????core-site.xml"
sed -i '/<configuration>/a\    <property>\n        <name>fs.defaultFS</name>\n        <value>hdfs://192.168.1.101:9000</value>\n    </property>\n    <property>\n        <name>hadoop.tmp.dir</name>\n        <value>/usr/local/hadoop/data/hadoop-2.8.5</value>\n    </property>\n    <property>\n        <name>hadoop.http.staticuser.user</name>\n        <value>root</value>\n    </property>' core-site.xml >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "core-site.xml????????????"
fi


echo "??????????????????hdfs-site.xml"
sed -i '/<configuration>/a\    <property>\n        <name>dfs.namenode.secondary.http-address</name>\n        <value>192.168.1.102:50090</value>\n    </property>' hdfs-site.xml >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "hdfs-site.xml????????????"
fi


echo "??????????????????mapred-site.xm"
mv mapred-site.xml.template mapred-site.xml
sed -i '/<configuration>/a\    <property>\n        <name>mapreduce.framework.name</name>\n        <value>yarn</value>\n    </property>\n    <property>\n        <name>yarn.app.mapreduce.am.env</name>\n        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>\n    </property>\n    <property>\n        <name>mapreduce.map.env</name>\n        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>\n    </property>\n    <property>\n        <name>mapreduce.reduce.env</name>\n        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>\n    </property>'  mapred-site.xml >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "mapred-site.xml????????????"
fi


echo "??????????????????yarn-site.xml"
sed -i '/<configuration>/a\    <property>\n        <name>yarn.resourcemanager.hostname</name>\n        <value>192.168.1.101</value>\n    </property>\n    <property>\n        <name>yarn.nodemanager.aux-services</name>\n        <value>mapreduce_shuffle</value>\n    </property>\n    <property>\n        <name>yarn.scheduler.minimum-allocation-mb</name>\n        <value>1024</value>\n    </property>\n    <property>\n        <name>yarn.scheduler.maximum-allocation-mb</name>\n        <value>2048</value>\n    </property>\n    <property>\n        <name>yarn.nodemanager.vmem-pmem-ratio</name>\n        <value>1</value>\n    </property>'  yarn-site.xml >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "yarn-site.xml????????????"
fi


echo "??????????????????salves"

cat > slaves << EOF
master
node1
node2
EOF
if [ $? != 0 ]; then
    echo "fail"
else
    echo "slaves????????????"
fi

echo -e '#Hadoop\nexport HADOOP_HOME=/usr/local/hadoop/hadoop-2.8.5\nexport PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> /etc/profile
source /etc/profile
for ip in ${node1} ${node2}
do
    {
    echo "??????????????????${ip}"
    sshpass -p ${passwd} scp -r /usr/local/hadoop root@${ip}:/usr/local/ >/dev/null 2>&1
    sshpass -p ${passwd} scp -r /etc/profile root@${ip}:/etc/
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "?????????${ip}??????"
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

echo "???????????????????????????"
start-all.sh >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "????????????"
fi

for ip in ${hosts}
do
    echo "${ip}???????????????"
    ssh root@${ip} jps
done



# ??? hbase ???????????????/home/software?????????
cd /home/
wget http://119.3.206.181/data/hbase-2.0.0-bin.tar.gz
# ??????hbase-2.0.0????????????????????????
tar -zxvf hbase-2.0.0-bin.tar.gz -C /usr/local/
wait
mv /usr/local/hbase-2.0.0 /usr/local/hbase
# ?????????????????????????????????
echo -e 'export HBASE_HOME=/usr/local/hbase\nexport PATH=${HBASE_HOME}/bin:$PATH' >> /etc/profile
source /etc/profile

# ??????hbase-env.s?????????????????????????????????
cd /usr/local/hbase/conf
echo -e 'export JAVA_HOME=/usr/local/java/jdk1.8.0_191\nexport HBASE_CLASSPATH=/usr/local/hbase/conf\nexport HBASE_MANAGES_ZK=true\nexport HBASE_LOG_DIR=/var/log/hbase_log' >> hbase-env.sh

# ??????hbase-site.xml??????????????????
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

# ????????????????????????regionserver???????????????RegionServer????????????
cd /usr/local/hbase/conf
true > regionservers
cat >> regionservers << EOF
192.168.1.102
192.168.1.103
EOF

# ??? hadoop ??????????????? core-site.xml ??? hdfs-site.xml ????????? hbase ????????????????????????
cp /usr/local/hadoop/hadoop-2.8.5/etc/hadoop/core-site.xml /usr/local/hbase/conf
cp /usr/local/hadoop/hadoop-2.8.5/etc/hadoop/hdfs-site.xml /usr/local/hbase/conf

# ??????????????????
scp /etc/profile root@192.168.1.102:/etc/
scp /etc/profile root@192.168.1.103:/etc/

# ssh?????????????????????????????????
source /etc/profile
source /etc/profile
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
# ???hbase?????????????????????????????????
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

#??????HBase??????master????????????



# ???????????????
cd /home/
wget http://119.3.206.181/data/apache-phoenix-5.0.0-HBase-2.0-bin.tar.gz

#??????phoenix??????????????????????????????master???????????????
tar -xvf apache-phoenix-5.0.0-HBase-2.0-bin.tar.gz
mv apache-phoenix-5.0.0-HBase-2.0-bin /usr/local/hbase/phoenix

# ??????phoenix????????????
echo -e 'export PNX_HOME=/usr/local/hbase/phoenix\nexport PATH=$PATH:$PNX_HOME/bin' >> /etc/profile
source /etc/profile
# ??????jar??????????????????
cd /usr/local/hbase/phoenix
cp phoenix-core-5.0.0-HBase-2.0.jar phoenix-5.0.0-HBase-2.0-server.jar /usr/local/hbase/lib
scp phoenix-core-5.0.0-HBase-2.0.jar phoenix-5.0.0-HBase-2.0-server.jar node1:/usr/local/hbase/lib
scp phoenix-core-5.0.0-HBase-2.0.jar phoenix-5.0.0-HBase-2.0-server.jar node2:/usr/local/hbase/lib

# ??????hbase??????????????????conf?????????hbase-site.xml???phoenix??????????????????bin???
cd /usr/local/hbase/conf
cp hbase-site.xml /usr/local/hbase/phoenix/bin

# ?????? hadoop???????????????/export/server/hadoop-2.8.5/etc/hadoop????????????core-site.xml hdfs-site.xml???phoenix??????????????????bin???
cd /u/hadoop-2.8.5/etc/hadoop
cp core-site.xml hdfs-site.xml /usr/local/hbase/phoenix/bin

# ??????hbase????????????Phoenix???jar?????????
stop-hbase.sh
start-hbase.sh

# ????????????
cd /usr/local/hbase/phoenix/bin
chmod 777 psql.py
chmod 777 sqlline.py

# ??????????????????
sqlline.py master,node1,node2:2181




