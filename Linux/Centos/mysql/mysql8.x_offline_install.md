1. 下载软件包
官网下载：<https://dev.mysql.com/downloads/mysql/>
![20220725165942](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20220725165942.png)
快速下载地址：<http://calvinqi.oss-cn-beijing.aliyuncs.com/files/mysql/mysql-8.0.29-1.el7.x86_64.rpm-bundle_2.tar>
2. 删除原有的mariadb
`rpm -qa|grep mariadb`
删除命令(删除所有包含mariadb的包)
`rpm -e --nodeps mariadb-libs
`
3. 上传解压安装

   ```shell
   tar -xvf mysql-8.0.29-1.el7.x86_64.rpm-bundle_2.tar
   #提示依赖就安装相应的依赖包
   mysql-community-common-8.0.29-1.el7.x86_64.rpm
   mysql-community-libs-8.0.29-1.el7.x86_64.rpm
   mysql-community-client-8.0.29-1.el7.x86_64.rpm
   mysql-community-server-8.0.29-1.el7.x86_64.rpm
   #net-tools下载
   wget http://mirror.centos.org/centos/7/os/x86_64/Packages/net-tools-2.0-0.25.20131004git.el7.x86_64.rpm
   ```

4. 服务启动初始化

   ```shell
   #查看状态
   systemctl status mysqld
   #停止服务
   systemctl stop mysqld
   #初始化数据库
   mysqld --initialize --console
   #目录授权
   chown -R mysql:mysql /var/lib/mysql/
   #启动服务
   systemctl start mysqld
   systemctl status mysqld
   ```

5. 登录数据库修改密码授权远程登录

   ```shell
   #查看临时密码
   cat /var/log/mysqld.log
   #登录 回车输入密码
   mysql -u root -p
   #修改mysql密码
   alter USER 'root'@'localhost' IDENTIFIED BY '123456';
   #授权远程连接
   show databases;
   use mysql;
   select host, user, authentication_string, plugin from user;
   update user set host = "%" where user='root';
   flush privileges;

   #尝试使用navacat远程连接，会出现2059的错误，解决如下
   use mysql;
   alter USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
   flush privileges;
   ```
