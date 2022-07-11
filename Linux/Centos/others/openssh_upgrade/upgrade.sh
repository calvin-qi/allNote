#!/bin/sh
yum -y install xinetd telnet-server
systemctl start telnet.socket
systemctl stop sshd

yum install -y pam* zlib*
mv /etc/ssh /etc/ssh_bak
# wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz
# wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.0p1.tar.gz
tar -zxvf openssh-9.0p1.tar.gz
tar -zxvf openssl-1.1.1g.tar.gz
cd ./openssl-1.1.1g
./config --prefix=/usr/ --openssldir=/usr/ shared
make && make install
openssl version

cd ../openssh-9.0p1
./configure --with-zlib --with-ssl-dir --with-pam --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc/ssh
make && make install
cp contrib/redhat/sshd.init /etc/init.d/sshd
ssh -V
sed -i '/#PermitRootLogin\ prohibit-password/a\PermitRootLogin\ yes' /etc/ssh/sshd_config
setenforce 0
nohup service sshd restart
chkconfig --add sshd
ssh -V
