# 一、在centos7下设置mysql的binlog

1. 开启binlog

   mysql5.7 的binlog默认是不开启的，所以需要手动的开启。修改/etc/my.cnf文件 增加如下配置

   先注释掉`client`下面的default-character-set=utf8,

   ```shell
   log-bin=/var/lib/mysql/mysql-bin  #binlog的文件路径到文件名
   expire-logs-days=7   #保存7天
   server-id=1  #必须设置server-id 每台机器的不要重复，如果没有设置server-id, 那么设置binlog后无法开启MySQL服务
   transaction_isolation = REPEATABLE-READ
   #系统变量binlog_format 指定二进制日志的类型。分别有STATEMENT、ROW、MIXED三种值。MySQL #5.7.6之前默认为STATEMENT模式。MySQL 5.7.7之后默认为ROW模式。这个参数主要影响主从复制。
   #复制的模式有下面几种:基于SQL语句的复制(statement-based replication, SBR)，基于行的复制(row-based replication, RBR)，混合模式复制(mixed-based replication, MBR)。
   binlog_format=MIXED 
   ```

   重启mysql systemctl restart mysqld.service

   进入mysql后 使用 show variables like 'log_%';  查看binlog配置 

   ![](https://gitee.com/calvinqi/typoraPic/raw/main/typora/image-20211221112136416.png)

   检查下binlog

   ```shell
   show master logs;
   +------------------+-----------+
   | Log_name         | File_size |
   +------------------+-----------+
   | mysql-bin.000001 |      1408 |
   | mysql-bin.000002 |       177 |
   | mysql-bin.000003 |       177 |
   | mysql-bin.000004 |       177 |
   | mysql-bin.000005 |      2318 |
   +------------------+-----------+
   
   [root@mysql mysql]# ll /var/lib/mysql
   总用量 188524
   -rw-r-----. 1 mysql mysql       56 12月 16 10:23 auto.cnf
   -rw-------. 1 mysql mysql     1680 12月 16 10:23 ca-key.pem
   -rw-r--r--. 1 mysql mysql     1112 12月 16 10:23 ca.pem
   -rw-r--r--. 1 mysql mysql     1112 12月 16 10:23 client-cert.pem
   -rw-------. 1 mysql mysql     1680 12月 16 10:23 client-key.pem
   -rw-r-----. 1 mysql mysql      550 12月 21 10:39 ib_buffer_pool
   -rw-r-----. 1 mysql mysql 79691776 12月 21 11:37 ibdata1
   -rw-r-----. 1 mysql mysql 50331648 12月 21 11:37 ib_logfile0
   -rw-r-----. 1 mysql mysql 50331648 12月 16 10:23 ib_logfile1
   -rw-r-----. 1 mysql mysql 12582912 12月 21 10:39 ibtmp1
   drwxr-x---. 2 mysql mysql     4096 12月 16 11:58 kube
   drwxr-x---. 2 mysql mysql     4096 12月 16 13:10 kube@002djob
   drwxr-x---. 2 mysql mysql     4096 12月 16 10:23 mysql
   -rw-r-----. 1 mysql mysql     1408 12月 21 10:32 mysql-bin.000001
   -rw-r-----. 1 mysql mysql      177 12月 21 10:37 mysql-bin.000002
   -rw-r-----. 1 mysql mysql      177 12月 21 10:38 mysql-bin.000003
   -rw-r-----. 1 mysql mysql      177 12月 21 10:39 mysql-bin.000004
   -rw-r-----. 1 mysql mysql     2318 12月 21 11:35 mysql-bin.000005
   -rw-r-----. 1 mysql mysql      160 12月 21 10:39 mysql-bin.index
   srwxrwxrwx. 1 mysql mysql        0 12月 21 10:39 mysql.sock
   -rw-------. 1 mysql mysql        5 12月 21 10:39 mysql.sock.lock
   drwxr-x---. 2 mysql mysql     8192 12月 16 10:23 performance_schema
   -rw-------. 1 mysql mysql     1680 12月 16 10:23 private_key.pem
   -rw-r--r--. 1 mysql mysql      452 12月 16 10:23 public_key.pem
   -rw-r--r--. 1 mysql mysql     1112 12月 16 10:23 server-cert.pem
   -rw-------. 1 mysql mysql     1680 12月 16 10:23 server-key.pem
   drwxr-x---. 2 mysql mysql     8192 12月 16 10:23 sys
   drwxr-x---. 2 mysql mysql       52 12月 21 11:30 test
   #这不就有了
   ```

2. 进入数据库创建表添加数据，删除数据，再删除表，然后用binlog进行恢复

   ```shell
   #创建测试的数据库
   mysql> create database test character set utf8;
   Query OK, 1 row affected (0.02 sec)
   
   mysql> use test
   Database changed
   #创建表
   mysql> create table test
       -> (
       ->     id int,
       ->     name varchar(20)
       -> ) character set utf8;
   Query OK, 0 rows affected (0.11 sec)
   #插入数据
   mysql> insert into test(id,name)
       -> values
       -> (1,'test1'),
       -> (2,'test2'),
       -> (3,'test3'),
       -> (4,'test4'),
       -> (5,'test5'),
       -> (6,'test6');
   Query OK, 6 rows affected (0.05 sec)
   Records: 6  Duplicates: 0  Warnings: 0
   #现在表是这样的
   mysql> select * from test;
   +------+-------+
   | id   | name  |
   +------+-------+
   |    1 | test1 |
   |    2 | test2 |
   |    3 | test3 |
   |    4 | test4 |
   |    5 | test5 |
   |    6 | test6 |
   +------+-------+
   6 rows in set (0.00 sec)
   ```

3. 备份还原（完整备份以及还原）

   先做一下每天的完整备份数据库任务

   ```shell
   mysqldump -uroot -pdosion123456 test > /data/mysqlbackup/test.sql
   ```

   模拟下失误操作，将id修改成一样的

   ```shell
   mysql> update test set id=0;
   Query OK, 6 rows affected (0.02 sec)
   Rows matched: 6  Changed: 6  Warnings: 0
   
   mysql> select * from test;
   +------+-------+
   | id   | name  |
   +------+-------+
   |    0 | test1 |
   |    0 | test2 |
   |    0 | test3 |
   |    0 | test4 |
   |    0 | test5 |
   |    0 | test6 |
   +------+-------+
   6 rows in set (0.00 sec)
   ```

   现在使用传统的方式来进行恢复：

   ```shell
    mysql -uroot -pdosion123456 test < /data/mysqlbackup/test.sql
   ```

   再次查询一下：

   ```shell
   mysql> select * from test;
   +------+-------+
   | id   | name  |
   +------+-------+
   |    1 | test1 |
   |    2 | test2 |
   |    3 | test3 |
   |    4 | test4 |
   |    5 | test5 |
   |    6 | test6 |
   +------+-------+
   6 rows in set (0.00 sec）
   ```
   可以看到数据都已经还原回来
   
4. 利用binlog模拟还原

   在原表的基础上在创建几条数据。

   ```shell
   mysql> insert into test(id,name)
       -> values
       -> (
       -> 7,'binlog'
       -> );
   Query OK, 1 row affected (0.03 sec)
   
   mysql> select * from test;
   +------+--------+
   | id   | name   |
   +------+--------+
   |    1 | test1  |
   |    2 | test2  |
   |    3 | test3  |
   |    4 | test4  |
   |    5 | test5  |
   |    6 | test6  |
   |    7 | binlog |
   +------+--------+
   7 rows in set (0.00 sec)
   ```

   如果这个时候我们把数据不小心修改了或者把库删除掉了，导致数据全部丢失，这个时候如果再用之前最新的备份文件 `test.sql`，去恢复数据的话，那么将会丢掉备份之后新插入的数据。

   *注意：如果真的使用最近的一次备份文件去做的话，一定是在万不得已的情况（比如binlog 被删除，整个硬盘挂掉、、、 想想都可怕。。。*

   模拟误操作，批量更改下用户的名字:

   ```shell
   mysql> update test set name='binlog';
   Query OK, 6 rows affected (0.05 sec)
   Rows matched: 7  Changed: 6  Warnings: 0
   ```

   不行，上一步不够狠，这里再狠一点，把表都给删除

   ```shell
   mysql> drop table test;
   Query OK, 0 rows affected (0.08 sec)
   ```

   由于之前我们一开始开启了binlog 日志选项，用binlog恢复数据库。下面从binlog入手，先检查一下binlog 文件，目前我的mysql 服务自开启binlog 后重启了好几次，所以有好几个个binlog文件；

   　　（***关于binlog文件的生成***：*每重启一次，便会重新生成一个binlog文件;还有一种情况就是运行了FLUSH LOGS命令也会重建一个;还有一种情况就是当这个binlog文件的大小到了设定的值后，就会重新生成一个新的*） 

   　　mysql-bin.index 文件中记录的是：自log-bin选项开启后，记录的所有的二进制日志清单列表。

   ![image-20211221130633390](https://gitee.com/calvinqi/typoraPic/raw/main/typora/image-20211221130633390.png)

   *注意：在实际生产环境中，如果遇到需要恢复数据库的情况，不要让用户能访问到数据库，以避免新的数据插入进来，以及在主从的环境下，关闭主从。*

   使用mysqlbinlog 命令可以查看binlog文件.我们看下最新的文件mysql-bin.00005(/var/lib/mysql)

   ```shell
   #这两个都可以查看
   [root@mysql mysql]# mysqlbinlog --base64-output=DECODE-ROWS -v mysql-bin.000005
   [root@mysql mysql]# mysqlbinlog mysql-bin.000005
   ```

   ![image-20211221131543007](https://gitee.com/calvinqi/typoraPic/raw/main/typora/image-20211221131543007.png)

   从最后可以看出有删除的操作。但是我们不能完全的恢复，因为最后还有删除的操作。

   　　现在我的思路就是，先将第一个binlog 和第二个binlog 文件导出来à利用指定的position位置的方式（*过滤掉删除表操作和**update test set name='binlog';**这条语句* ），导出2个sql 语句，最后我们将2个sql 合成一个sql，导入到数据库中即可。

   　　我们先用mysqlbinlog命令找到update 那条语句的位置，然后指定position 将mysql-bin.00001 导出来。

   ```shell
   # at 3365
   #211221 12:47:47 server id 1  end_log_pos 3536 CRC32 0xf1df7bcd         Query   thread_id=7     exec_time=0  error_code=0
   SET TIMESTAMP=1640062067/*!*/;
   INSERT INTO `test` VALUES (1,'test1'),(2,'test2'),(3,'test3'),(4,'test4'),(5,'test5'),(6,'test6')
   /*!*/;
   # at 3536
   #211221 12:47:47 server id 1  end_log_pos 3567 CRC32 0x8938eeda         Xid = 109
   COMMIT/*!*/;
   # at 3567
   #211221 12:47:47 server id 1  end_log_pos 3632 CRC32 0xbae36d32         Anonymous_GTID  last_committed=13    sequence_number=14       rbr_only=no
   SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
   # at 3632
   #211221 12:47:47 server id 1  end_log_pos 3748 CRC32 0x09a1de48         Query   thread_id=7     exec_time=0  error_code=0
   SET TIMESTAMP=1640062067/*!*/;
   /*!40000 ALTER TABLE `test` ENABLE KEYS */
   /*!*/;
   # at 3748
   #211221 12:55:33 server id 1  end_log_pos 3813 CRC32 0xddc5a8aa         Anonymous_GTID  last_committed=14    sequence_number=15       rbr_only=no
   SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
   # at 3813
   #211221 12:55:33 server id 1  end_log_pos 3892 CRC32 0xe99a3385         Query   thread_id=8     exec_time=0  error_code=0
   SET TIMESTAMP=1640062533/*!*/;
   SET @@session.foreign_key_checks=1, @@session.unique_checks=1/*!*/;
   SET @@session.sql_mode=1436549120/*!*/;
   BEGIN
   /*!*/;
   # at 3892
   #211221 12:55:33 server id 1  end_log_pos 4013 CRC32 0x627f3291         Query   thread_id=8     exec_time=0  error_code=0
   SET TIMESTAMP=1640062533/*!*/;
   insert into test(id,name)
   values
   (
   7,'binlog'
   )
   /*!*/;
   # at 4013
   #211221 12:55:33 server id 1  end_log_pos 4044 CRC32 0x491fda08         Xid = 130
   COMMIT/*!*/;
   # at 4044
   #211221 13:01:06 server id 1  end_log_pos 4109 CRC32 0x0e0efa11         Anonymous_GTID  last_committed=15    sequence_number=16       rbr_only=no
   SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
   # at 4109
   #211221 13:01:06 server id 1  end_log_pos 4188 CRC32 0xb7c40a29         Query   thread_id=8     exec_time=0  error_code=0
   SET TIMESTAMP=1640062866/*!*/;
   BEGIN
   /*!*/;
   # at 4188
   #211221 13:01:06 server id 1  end_log_pos 4291 CRC32 0x25a92a25         Query   thread_id=8     exec_time=0  error_code=0
   SET TIMESTAMP=1640062866/*!*/;
   update test set name='binlog'
   /*!*/;
   # at 4291
   #211221 13:01:06 server id 1  end_log_pos 4322 CRC32 0x4dd13d02         Xid = 132
   COMMIT/*!*/;
   # at 4322
   #211221 13:02:29 server id 1  end_log_pos 4387 CRC32 0xa830bd11         Anonymous_GTID  last_committed=16    sequence_number=17       rbr_only=no
   SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
   # at 4387
   #211221 13:02:29 server id 1  end_log_pos 4504 CRC32 0x432f45c6         Query   thread_id=8     exec_time=0  error_code=0
   SET TIMESTAMP=1640062949/*!*/;
   SET @@session.pseudo_thread_id=8/*!*/;
   DROP TABLE `test` /* generated by server */
   /*!*/;
   SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
   DELIMITER ;
   # End of log file
   /*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
   /*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
   ```

   从上面可以看到我们在做插入正常数据后的position 是4188，那么使用下面的命令导出sql(从start到stop之间，实际情况根据实际需要设置导出范围，如果没特殊需要，那就去掉–start-position=“xxxx”)

   ```sh
   [root@mysql mysql]# mysqlbinlog --start-position="1570" --stop-position="4188" /var/lib/mysql/mysql-bin.000005 > /data/mysqlbackup/binlogBackup_1.sql
   ```

   sql 语句已经导出来了。我们可以利用该语句直接恢复所有正常的数据。

   　　*注：本次恢复没有利用到之前的完整备份，因为我是开启binlog后，然后才做的所有建库建表操作，第一个binlog文件里已经记录了所有的数据库操作，所以不需要使用之前的完整备份（另外：实际的生产环境，还是需要利用到完整备份的，因为线上环境可能会有N多个binlog文件，所以需要利用到完整备份和最新的binlog文件来结合恢复）*

   开始恢复前，我们将原有的Test_DB数据库也给干掉吧。毕竟我们的binlog中有创建操作

   ```sh
   mysql> DROP DATABASE test;
   Query OK, 0 rows affected (0.03 sec)
   ```

   *恢复数据库时还可以利用在登陆mysql 后，用source 命令导入sql语句，*

   ```shell
   #登录mqsql后恢复
   source /data/mysqlbackup/binlogBackup_1.sql
   #在备份文件的目录下进行恢复
   [root@mysql mysqlbackup]# mysql -uroot -pdosion123456 < binlogBackup_1.sql 
   mysql: [Warning] Using a password on the command line interface can be insecure.
   ```

   恢复完成后，我们检查下表的数据是否完整

   ```shell
   mysql> show databases;
   +--------------------+
   | Database           |
   +--------------------+
   | information_schema |
   | kube               |
   | kube-job           |
   | mysql              |
   | performance_schema |
   | sys                |
   | test               |
   +--------------------+
   7 rows in set (0.00 sec)
   
   
   mysql> select * from test;
   +------+--------+
   | id   | name   |
   +------+--------+
   |    1 | test1  |
   |    2 | test2  |
   |    3 | test3  |
   |    4 | test4  |
   |    5 | test5  |
   |    6 | test6  |
   |    7 | binlog |
   +------+--------+
   7 rows in set (0.00 sec)
   ```

   Ok完整的都恢复过来了。

5. 总结

   1. 恢复方式：
      - 利用最新一次的完整备份加binlog 指定事件起始时间和终止时间或者position恢复数据库
      - 利用所有binlog指定事件起始位置和终止时间来合并sql文件恢复数据库（此方法要确保binlog文件的完整）
      - 利用mysqldump 使用完整恢复。（在确保最新一次的完整备份后的数据不重要，允许丢掉的情况下，直接恢复。该方法最简单、效率最高）
   2. 附:官方建议的备份原则（为了能睡个好觉….嗯，是的）
      - 在mysql安装好并运行时，就始终开启 log-bin选项，该日志文件位于datadir目录下，也要确保该目录所在存储介质是安全的。
      - 定期做完整的mysql 备份。
      - 定期使用 FlUSH LOGS 或者 mysqladmin flush-logs ，该操作会关闭当前的二进制日志文件，并新建一个binlog日志文件。(和重启mysql后新建的binlog操作一样)。以备份binlog日志，利用binlog日志也可以做增量备份。

   

   







