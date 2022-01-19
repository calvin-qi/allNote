```shell
# 将 hbase 源码包放在/home/software目录下
cd /home/software
wget http://119.3.206.181/data/hbase-2.0.0-bin.tar.gz

# 解压hbase-2.0.0，并放到指定目录
tar -zxvf hbase-2.0.0-bin.tar.gz
mv hbase-2.0.0 /usr/local/hbase

# 设置环境变量及临时目录
echo "export HBASE_HOME=/usr/local/hbase\nexport PATH=$HBASE_HOME/bin:$PATH" >> /etc/profile
source /etc/profile

# 编辑hbase-env.s文件，指定系统运行环境
cd /usr/local/hbase/conf
echo "export JAVA_HOME=/usr/local/java/jdk1.8.0_191\nexport HBASE_CLASSPATH=/usr/local/hbase/conf\nexport HBASE_MANAGES_ZK=true\nexport HBASE_LOG_DIR=/var/log/hbase_log" >> hbase-env.sh

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
cp /export/server/hadoop-2.8.5/etc/hadoop/core-site.xml /usr/local/hbase/conf
cp /export/server/hadoop-2.8.5/etc/hadoop/hdfs-site.xml /usr/local/hbase/conf

# 拷贝环境变量
scp /etc/profile root@192.168.1.102:/etc/
scp /etc/profile root@192.168.1.103:/etc

# ssh免密码登录执行节点命令
source /etc/profile
source /etc/profile
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
# 把hbase安装目录拷贝给其他节点
scp -r /usr/local/hbase node1:/usr/local/
scp -r /usr/local/hbase node2:/usr/local/

sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.102 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.103 "source /etc/profile"

#启动HBase（在master上运行）
start-hbase.sh


```

