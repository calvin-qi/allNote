# 安装nginx

```shell
#!/bin/sh
cd /home
yum install  -y gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel

wget -c https://nginx.org/download/nginx-1.22.0.tar.gz

tar -zxvf nginx-1.22.0.tar.gz
cd nginx-1.22.0
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_stub_status_module --with-file-aio --with-stream

make
make install
cd /usr/local/nginx/sbin/
./nginx 

rm -rf /home/nginx*
echo '/usr/local/nginx/sbin/nginx'  >> /etc/rc.local
chmod 755 /etc/rc.local



```

nginx -s stop
nginx -s quit
nginx -s reload
