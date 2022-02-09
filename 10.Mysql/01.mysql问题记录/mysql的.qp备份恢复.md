# mysql备份的.qp文件恢复

## 安装恢复工具percona-xtrabackup

1. 下载xtrabackup仓库文件并安装仓库包

   ```shell
   yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
   ```

   对于MySQL 5.6和5.7，请下载XtraBackup 2.4.9及其以上版本。
   对于MySQL 8.0，请下载XtraBackup 8.0及其以上版本。

2. 安装xtrabackup，mysql-community-libs-compat（MySQL5.7版本依赖）可解决：安装percona-xtrabackup-24报错： file /etc/my.cnf from install of Percona-Server-shared-56-5.6.48-rel88

   ```shell
   yum -y install mysql-community-libs-compat percona-xtrabackup-24
   ```

3. 版本查看

   ```shell
   innobackupex --version
   xtrabackup --version
   ```

## 安装qp文件解压工具qpress-11-linux.x64.tar

```shell
wget http://www.quicklz.com/qpress-11-linux-x64.tar
#解压安装工具
tar -xvf qpress-11-linux-x64.tar 
cp qpress /usr/bin/
```

## qp文件全量备份数据恢复

1. 数据恢复

   ```shell
   #创建一个临时目录backupdir
   mkdir backupdir 
   #解压文件qp全备文件，让XtraBackup可识别
   xbstream -x -p 4 < /root/map.qp -C ./backupdir/  
   innobackupex --parallel 4 --decompress ./backupdir
   #读取应用日志，准备恢复数据
   innobackupex --apply-log ./backupdir
   #已启动的MySQL需要停止服务
   systemctl stop mysqld 
   #备份原来的数据库目录
   mv /var/lib/mysql/* /var/lib/mysqldata_bak/
   #恢复数据
   innobackupex --defaults-file=/etc/my.cnf --copy-back ./backupdir
   #修改恢复后数据的目录权限，如果不更改目录权限，数据库服务启动会报错
   chown -R mysql:mysql  /var/lib/
   ```

2. 数据恢复后启动数据库

3. 登录数据库，查看数据恢复结果

   ```shell
   mysql -u root -p
   show databases;
   ```

   登录的时候如果密码错误怎么也登不进去，就重置密码吧