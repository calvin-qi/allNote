# 搭建配置局域网DNS服务器

在局域网内的ip为192.168.1.10的centos7.9服务器上搭建一个dns服务器，在局域网中ip为192.168.1.100域名为test.walkdusk.com的服务器上部署了test服务，在局域网中ip为192.168.1.200域名为pro.walkdusk.com服务器上部署了另一个pro服务，其它电脑配置dns后能通过域名能访问到部署的test和pro服务

在局域网中的CentOS 7.9服务器上搭建DNS服务器的步骤如下：

1. 更新系统软件包：

   ```
   sudo yum update
   ```

2. 安装BIND（BIND是一个常用的DNS服务器软件）：

   ```
   sudo yum install bind bind-utils
   ```

3. 配置BIND：
   - 打开BIND配置文件：

     ```
     sudo vi /etc/named.conf
     ```

   - 在文件中找到 `options` 部分，并进行以下配置：

     ```
     options {
         listen-on port 53 { any; };
         listen-on-v6 port 53 { any; };
         directory     "/var/named";
         dump-file     "/var/named/data/cache_dump.db";
         statistics-file "/var/named/data/named_stats.txt";
         memstatistics-file "/var/named/data/named_mem_stats.txt";
         allow-query     { any; };
         recursion yes;
         dnssec-enable yes;
         dnssec-validation yes;
         dnssec-lookaside auto;
         /* Path to ISC DLV key */
         bindkeys-file "/etc/named.iscdlv.key";
         managed-keys-directory "/var/named/dynamic";
     };
     ```

   - 保存并关闭文件。

4. 配置正向解析（将域名映射到IP地址）：
   - 打开正向解析配置文件：

     ```
     sudo vi /var/named/forward.zone
     ```

   - 添加以下内容：

     ```
     $TTL 1D
     @       IN SOA  ns1.walkdusk.com. admin.walkdusk.com. (
                  2019010101 ; serial
                  8H ; refresh
                  2H ; retry
                  4W ; expire
                  1D ; minimum
                 )
     @       IN NS   ns1.walkdusk.com.
     test    IN A    192.168.1.100
     pro     IN A    192.168.1.200
     ns1     IN A    192.168.1.10
     ```

   - 保存并关闭文件。

5. 配置反向解析（将IP地址映射到域名）：
   - 打开反向解析配置文件：

     ```
     sudo vi /var/named/reverse.zone
     ```

   - 添加以下内容（将 `1.168.192` 替换为你的局域网的网络地址的反向形式）：

     ```
     $TTL 1D
     @       IN SOA  ns1.walkdusk.com. admin.walkdusk.com. (
                  2019010101 ; serial
                  8H ; refresh
                  2H ; retry
                  4W ; expire
                  1D ; minimum
                 )
     @       IN NS   ns1.walkdusk.com.
     10      IN PTR  ns1.walkdusk.com.
     100     IN PTR  test.walkdusk.com.
     200     IN PTR  pro.walkdusk.com.
     ```

   - 保存并关闭文件。

6. 设置文件权限：

   ```
   sudo chown named:named /var/named/forward.zone
   sudo chown named:named /var/named/reverse.zone
   ```

7. 启动并设置BIND服务：
   - 启动BIND服务：

     ```
     sudo systemctl start named
     ```

   - 设置BIND服务开机自启动：

     ```
     sudo systemctl enable named
     ```

8. 配置防火墙规则（如果有启用防火墙）：
   - 允许DNS服务通过防火墙：

     ```
     sudo firewall-cmd --permanent --add-service=dns
     sudo firewall-cmd --reload
     ```

现在，已经在局域网的CentOS 7.9服务器上成功搭建了DNS服务器，并配置了test.walkdusk.com和pro.walkdusk.com的解析记录。其他设备可以通过配置该DNS服务器来访问这些服务。

对于其他设备，需要将它们的DNS服务器设置为192.168.1.10（你的DNS服务器的IP地址）。这样，当设备尝试访问test.walkdusk.com或pro.walkdusk.com时，DNS服务器将返回相应的IP地址。设备就可以通过域名访问到部署在192.168.1.100上的test服务和部署在192.168.1.200上的pro服务了。
