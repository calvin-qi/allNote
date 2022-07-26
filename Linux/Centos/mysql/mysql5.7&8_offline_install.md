# 安装mysql8

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
   rpm -ivh mysql-community-common-8.0.29-1.el7.x86_64.rpm
   rpm -ivh mysql-community-client-plugins-8.0.29-1.el7.x86_64.rpm
   rpm -ivh mysql-community-libs-8.0.29-1.el7.x86_64.rpm
   rpm -ivh mysql-community-client-8.0.29-1.el7.x86_64.rpm
   rpm -ivh mysql-community-icu-data-files-8.0.29-1.el7.x86_64.rpm
   rpm -ivh net-tools-2.0-0.25.20131004git.el7.x86_64.rpm
   rpm -ivh mysql-community-server-8.0.29-1.el7.x86_64.rpm
   #net-tools下载
   wget http://mirror.centos.org/centos/7/os/x86_64/Packages/net-tools-2.0-0.25.20131004git.el7.x86_64.rpm

   #如果缺什么依赖包就去https://centos.pkgs.org/7/centos-x86_64/下载.有网的就yum -y install xxx安装
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
   cat /var/log/mysqld.log | grep password
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

6. 添加用户和授权

   ```shell
   #创建新用户
   create user 'username'@'host' identified by 'password';
   #其中username为自定义的用户名；host为登录域名，host为'%'时表示为 任意IP，为localhost时表示本机，或者填写指定的IP地址；paasword为密码

   # 为用户授权
   grant all privileges on *.* to 'username'@'%' with grant option; 
   #其中*.*第一个*表示所有数据库，第二个*表示所有数据表，如果不想授权全部那就把对应的*写成相应数据库或者数据表；username为指定的用户；%为该用户登录的域名

   #授权之后刷新权限
   flush privileges; 
   ```

7. 修改`/etc/my.cnf`,添加下面内容

   ```shell
   [client]
   default-character-set=utf8
   [mysql]
   default-character-set=utf8
   [mysqld]
   character-set-server=utf8
   ```

# 安装mysql5.7

1. 删除自带的mariadb

   ```shell
   rpm -qa|grep mariadb
   rpm -e --nodeps mariadb-libs
   ```

2. 下载mysql5.7的包上传解压

   ```shell
   #可以去官网下载，也可以用下面命令下载我存储的包，速度快点
   wget http://calvinqi.oss-cn-beijing.aliyuncs.com/files/mysql/mysql-5.7.38-1.el7.x86_64.rpm-bundle.tar
   #解压
   tar -xf mysql-5.7.38-1.el7.x86_64.rpm-bundle.tar
   #安装
   rpm -ivh mysql-community-common-5.7.38-1.el7.x86_64.rpm
   rpm -ivh mysql-community-common-5.7.38-1.el7.x86_64.rpm
   rpm -ivh mysql-community-libs-*
   rpm -ivh mysql-community-devel-5.7.38-1.el7.x86_64.rpm
   #这是会需要net-tools依赖包，用下面命令下载安装
   wget http://mirror.centos.org/centos/7/os/x86_64/Packages/net-tools-2.0-0.25.20131004git.el7.x86_64.rpm
   rpm -ivh net-tools-2.0-0.25.20131004git.el7.x86_64.rpm
   rpm -ivh mysql-community-client-5.7.38-1.el7.x86_64.rpm
   rpm -ivh mysql-community-server-5.7.38-1.el7.x86_64.rpm
   #如果缺什么依赖包就去https://centos.pkgs.org/7/centos-x86_64/下载.有网的就yum -y install xxx安装
   ```

3. 启动mysql登录

   ```shell
   systemctl start mysqld
   systemctl ststus mysqld

   #查看临时密码
   cat /var/log/mysqld.log | grep password
   # 登录 回车输入密码
   mysql -u root -p
   ```

4. 修改密码授权

   ```shell
   # 设置密码等级
   set global validate_password_length=4;
   set global validate_password_policy=0;
   # 修改默认密码，注意替换后面的密码
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '您的密码';
   #设置远程登录
   use mysql;
   # 注意将密码替换掉
   GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '您的密码' WITH GRANT OPTION;
   FLUSH PRIVILEGES;

   #创建用户和授权
   #创建用户
   CREATE USER 'username'@'host' IDENTIFIED BY 'password';
   #删除用户
   DROP USER 'username'@'host'；
   #授权所有权限
   grant all privileges on *.* to 'username'@'%' identified by 'test123';
   #授权部分权限
   grant select,update on testDB.* to 'test'@'%' identified by 'test123';
   #刷新权限表
   flush privileges;

   #然后就可以去登录了。后续如果在navicat创建用户时密码策略失败，就登录登录mysql执行
   set global validate_password_policy=0;
   FLUSH PRIVILEGES;
   ```

5. 修改`/etc/my.cnf`,添加下面内容

   ```shell
   [client]
   default-character-set=utf8
   [mysql]
   default-character-set=utf8
   [mysqld]
   character-set-server=utf8
   ```
