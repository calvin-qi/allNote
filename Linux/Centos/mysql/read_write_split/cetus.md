# 安装

参考文档（详细）：<https://gitee.com/wangbin579/cetus/blob/master/doc/cetus-install.md>
安装依赖

```shell
yum install cmake gcc glib2-devel flex mysql-devel gperftools-libs zlib-devel -y 
```

安装步骤

```shell
git clone https://gitee.com/wangbin579/cetus.gitee
cd cetus
mkdir build
cd build
#利用cmake进行编译,-DCMAKE_INSTALL_PREFIX处修改安装路径
CFLAGS='-g -Wpointer-to-int-cast' cmake ../ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/home/user/cetus_install -DSIMPLE_PARSER=ON
make install
```

配置cetus

```shell
cd /usr/local/cetus
mkdir logs
cd conf
#修改文件名
cp XXX.json.example XXX.json
cp XXX.conf.example XXX.conf
```

配置user.json文件

```shell
{
        "users":        [{
                        "user": "root",
                        "client_pwd":   "Xuandong!@#0402",
                        "server_pwd":   "Xuandong!@#0402"
                }
                        ]
}
```

配置proxy.conf

```shell
[cetus]
# For mode-switch
daemon = true

# Loaded Plugins
plugins=proxy,admin

# Defines the number of worker processes.
worker-processes=1

# Proxy Configuration, For example: MySQL master and salve host ip are both 192.0.0.1
proxy-address=0.0.0.0:6001
proxy-backend-addresses=172.28.64.11:3306
proxy-read-only-backend-addresses=172.28.64.12:3306,172.28.64.13:3306

# Admin Configuration
admin-address=0.0.0.0:7001
admin-username=admin
admin-password=admin

# Backend Configuration, use test db and username created
default-db=rdpdata
default-username=root
default-pool-size=100
max-resp-size=10485760
long-query-time=100

# File and Log Configuration, put log in /data and marked by proxy port, /data/cetus needs to be created manually and has rw authority for cetus os user
max-open-files = 65536
pid-file = cetus6001.pid
plugin-dir=lib/cetus/plugins
log-file=/usr/local/cetus/logs/cetus.log
log-level=info

# Check salve delay
disable-threads=true
check-slave-delay=true
slave-delay-down=5
slave-delay-recover=1

# For trouble
keepalive=true
verbose-shutdown=true
log-backtrace-on-crash=true

# For performance
enable-tcp-stream=true
enable-fast-stream=true

# For MGR
group-replication-mode=0

/*#mode=READONLY*/
read-master-percentage=0
```

启动cetus

```shell
#启动命令
bin/cetus --defaults-file=conf/proxy.conf --conf-dir=/usr/local/cetus/conf/
#查看日志
tail -f logs/cetus.log
```

注：程序代码关闭读数据库的事务锁
