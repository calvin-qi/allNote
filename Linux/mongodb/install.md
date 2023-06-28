借鉴<https://zhuanlan.zhihu.com/p/81496897>

1. 下载安装包，server和shell的rpm包
<https://www.mongodb.com/try/download/community>
![20220914113712](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20220914113712.png)
2. 安装配置

```shell
rpm -ivh xxx.rpm
#修改配置文件
vim /etc/mongod.conf
#修改数据库存放路径和日志路径
---
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# Where and how to store data.
storage:
  dbPath: /var/lib/mongo
  journal:
    enabled: true
#  engine:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongodb/mongod.pid  # location of pidfile
  timeZoneInfo: /usr/share/zoneinfo

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0  # Enter 0.0.0.0,:: to bind to all IPv4 and IPv6 addresses or, alternatively, use the net.bindIpAll setting.


#security:
security:
  authorization: enabled
#operationProfiling:

#replication:

#sharding:

## Enterprise-Only Options

#auditLog:

#snmp:
---

#修改文件夹权限，mongodb的启动脚本默认的是mongod用户，mongod组，所以需要给对应的数据目录和日志目录加上对应的权限（必须加，不然启不起来，一直报没有权限）
chown mongod:mongod /var/lib/mongdb -R
chown mongod:mongod /var/lib/mongdb
```

3. 启动，创建超级管理员

```shell
#启动mongodb， systemctl start mongod，查看状态systemctl status mongod
#创建超级管理员
# 切换到admin数据库
use admin
# 创建root用户赋予root角色
db.createUser({user:"root", pwd: "123456", roles: ["root"]})
# 验证创建的用户
db.auth("root", "123456") 


#创建自己数据的管理员
# 切换/创建自己的数据库
use rdpdata
# dbOwner：表示在当前数据库中可以执行任意操作
# 这里创建的clancy用户只对mall这个数据库有用
# 当然也可以在admin数据库创建用户，然后登录的时候需要admin数据库认证
# 这里我们是在bigdata数据库创建的用户，所以后面登录的时候认证的数据库是bigdata
db.createUser({user: "integration", pwd: "123456", roles: [{ role: "dbOwner", db: "rdpdata" }]})
#创建用户成功后，再用创建的账号登录
内建的角色
数据库用户角色：read、readWrite;
数据库管理角色：dbAdmin、dbOwner、userAdmin；
集群管理角色：clusterAdmin、clusterManager、clusterMonitor、hostManager；
备份恢复角色：backup、restore；
所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
超级用户角色：root // 这里还有几个角色间接或直接提供了系统超级用户的访问（dbOwner 、userAdmin、userAdminAnyDatabase）
内部角色：__system

角色说明：
Read：允许用户读取指定数据库
readWrite：允许用户读写指定数据库
dbAdmin：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
userAdmin：允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户
clusterAdmin：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
readAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读权限
readWriteAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读写权限
userAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
dbAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
root：只在admin数据库中可用。超级账号，超级权限


```

4. 修改配置文件，开启权限认证，修改绑定ip访问，然后重启MongoDB，systemctl restart mongod

```shell
#配置文末尾添加
security:
  authorization: enabled
```

终端创建好数据库然后在Navicat连接，插入数据后数据库才会保留，否则再次连接将会消失
