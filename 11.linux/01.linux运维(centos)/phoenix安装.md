```shell
# 下载软件包
cd /home/software
wget http://119.3.206.181/data/apache-phoenix-5.0.0-HBase-2.0-bin.tar.gz

#解压phoenix源码包并存放在指定的master节点目录下
tar -xvf apache-phoenix-5.0.0-HBase-2.0-bin.tar.gz
mv apache-phoenix-5.0.0-HBase-2.0-bin /usr/local/hbase/phoenix

# 添加phoenix环境变量
echo -e "export PNX_HOME=/usr/local/hbase/phoenix\nexport PATH=$PATH:$PNX_HOME/bin" >> /etc/profile
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
cd /export/server/hadoop-2.8.5/etc/hadoop
cp core-site.xml hdfs-site.xml /usr/local/hbase/phoenix/bin

# 重启hbase集群，使Phoenix的jar包生效
stop-hbase.sh
start-hbase.sh

# 修改权限
cd /usr/local/hbase/phoenix/bin
chmod 777 psql.py
chmod 777 sqlline.py

# 测试能否运行
cd /usr/local/hbase/phoenix/
bin/sqlline.py master,node1,node2:2181


```

