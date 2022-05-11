```shell
yum install epel-release
sudo yum update
yum install redis
# 启动redis
service redis start
# 停止redis
service redis stop
# 查看redis运行状态
service redis status
# 查看redis进程
ps -ef | grep redis

#设置redis为开机自动启动
chkconfig redis on

#打开配置文件
vi /etc/redis.conf
#使用配置文件启动 redis
redis-server /etc/redis.conf &
#使用端口登录
redis-cli -h 127.0.0.1 -p 6179

# 打开redis配置文件
vi /etc/redis.conf
# 找到 bind 127.0.0.1 将其注释
# 找到 protected-mode yes 将其改为
protected-mode no

service redis stop
service redis start
```