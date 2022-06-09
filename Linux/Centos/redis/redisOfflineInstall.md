# 安装redis
```
#下载
wget http://download.redis.io/releases/redis-4.0.6.tar.gz

#解压
tar -zxvf redis-4.0.6.tar.gz

yum install gcc -y
cd redis-4.0.6
make
make install

mkdir /usr/local/redis
cp redis.conf /usr/local/redis/
vim /usr/local/redis/redis.conf
#注释bind 127.0.0.1   修改daemonize yes为no 找到 protected-mode yes 将其改为protected-mode no

#设置开机启动
vim /etc/systemd/system/redis.service

[Unit]
Description=The redis-server Process Manager
After=syslog.target network.target
 
[Service]
Type=simple
ExecStart=/usr/local/bin/redis-server /usr/local/redis/redis.conf         
## ExecStart=/software/redis-6.0.10/src/redis-server  --protected-mode no
## /software/redis-6.0.10/src/redis-server  /software/redis-6.0.10/redis.conf --protected-mode no 
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -SIGINT $MAINPID
 
[Install]
WantedBy=multi-user.target


systemctl daemon-reload 
systemctl start redis
```










