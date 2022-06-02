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
