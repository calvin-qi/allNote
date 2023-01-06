# mysql互为主从

1
my.cnf add conf

log-bin = mysql-bin
binlog_format = mixed
server-id = 1
relay-log = relay-bin
relay-log-index = slave-relay-bin.index
auto-increment-increment = 2
auto-increment-offset = 1

restart mysql

2
my.cnf add conf

log-bin = mysql-bin
binlog_format = mixed
server-id = 2
relay-log = relay-bin
relay-log-index = slave-relay-bin.index
auto-increment-increment = 2
auto-increment-offset = 2

restart mysql

1
将1设为2的主服务器,在1上创建授权账户，允许在2上连接
mysql -uroot -p
grant replication slave on *.* to root@'%' identified by 'qyx54321';

查看主服务1的当前binlog状态信息
show master status;

2
在2上将1设为自己的主服务器并开启slave功能

change master to
master_host='192.168.18.31',
master_user='root',
master_password='qyx54321',
master_log_file='mysql-bin.000001',
master_log_pos=442;

start slave;

show slave status\G
其中slave_io_running与slave_sql_running必须为yes

将2设为1的主服务器,在2上创建授权账户，允许在1上连接
mysql -uroot -p
grant replication slave on *.* to root@'%' identified by 'qyx54321';
Flush privileges;

查看主服务2当前binlog状态信息
语法：show master status;

1
在主服务1上将主服务2设为自己的主服务器并开启slave功能
change master to
master_host='192.168.18.32',
master_user='root',
master_password='qyx54321',
master_log_file='mysql-bin.000001',
master_log_pos=442;

start slave;
查看状态
语法：show slave status\G
其中slave_io_running与slave_sql_running必须为yes
