# 修改mysql密码

1. 编辑MySQL配置文件(跳过权限校验)

   ```shell
   vim /etc/my.cnf
   
   #在[mysqld]选项中添加skip-grant-tables属性
   #[mysqld]
   skip-grant-tables
   ```

2. 重启MySQL服务

   ```shell
   systemctl restart mysqld
   ```

3. root用户无密码登录

   ```shell
   mysql -uroot -p
   #直接回车登录
   ```

4. 选择系统数据库

   ```shell
   use mysql;
   
   select host,user,authentication_string from user;
   update user set authentication_string=password('dosion123456') where user='root';
   ```

5. 刷新系统权限

   ```shell
   flush privileges;
   ```

6. 退出数据库还原my.conf配置

   注意：这里一定要重做第一步并且删除`skip-grant-tables`值后保存重启MySQL服务

   ```shell
   systemctl restart mysqld
   ```

7. 登录试试