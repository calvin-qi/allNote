```shell
docker run \
-p 3306:3306 \
--name mysql \
--privileged=true \
--restart unless-stopped \
-v /home/qyx/data/mysql/my.cnf:/etc/mysql/my.cnf:rw \
-v /home/qyx/data/mysql/logs:/var/log/mysql \
-v /home/qyx/data/mysql/data:/var/lib/mysql \
-v /etc/localtime:/etc/localtime \
-e MYSQL_ROOT_PASSWORD=123456 \
-d mysql:8.0.22
```

my.cnf:

```shell
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
character-set-server=utf8mb4

# Custom config should go here
!includedir /etc/mysql/conf.d/

[mysql]
default-character-set=utf8mb4

[client]
default-character-set=utf8mb4

```
