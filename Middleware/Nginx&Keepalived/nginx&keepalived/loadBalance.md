安装keepalived

```shell
wget http://www.keepalived.org/software/keepalived-1.2.18.tar.gz --no-check-certificate
tar -zxvf keepalived-1.2.18.tar.gz -C /usr/local/
yum -y install openssl openssl-devel gcc
cd /usr/local/keepalived-1.2.18/
./configure --prefix=/usr/local/keepalived
make && make install

mkdir /etc/keepalived
cp /usr/local/keepalived/etc/keepalived/keepalived.conf /etc/keepalived/
cp /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/
cp /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
ln -s /usr/local/keepalived/sbin/keepalived /sbin/
ln -s /usr/local/sbin/keepalived /usr/sbin/
chkconfig keepalived on

service keepalived start
service keepalived stop
ps aux |grep keepalived
```

keepalived.conf

```sh
vrrp_script chk_nginx {
    script "/etc/keepalived/nginx_check.sh" #运行脚本，脚本内容下面有，就是起到一个nginx宕机以后，自动开启服务
    interval 2 #检测时间间隔
    weight -20 #如果条件成立的话，则权重 -20
}
# 定义虚拟路由，VI_1 为虚拟路由的标示符，自己定义名称
vrrp_instance VI_1 {
    state MASTER #来决定主从
    interface ens33 # 绑定虚拟 IP 的网络接口，根据自己的机器填写
    virtual_router_id 121 # 虚拟路由的 ID 号， 两个节点设置必须一样
    mcast_src_ip 192.168.70.106 #填写本机ip
    priority 100 # 节点优先级,主要比从节点优先级高
    nopreempt # 优先级高的设置 nopreempt 解决异常恢复后再次抢占的问题
    advert_int 1 # 组播信息发送间隔，两个节点设置必须一样，默认 1s
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    # 将 track_script 块加入 instance 配置块
    track_script {
        chk_nginx #执行 Nginx 监控的服务
    }

    virtual_ipaddress {
        192.168.70.100 # 虚拟ip,也就是解决写死程序的ip怎么能切换的ip,也可扩展，用途广泛。可配置多个。
    }
}
```
