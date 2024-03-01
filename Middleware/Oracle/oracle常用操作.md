# Oracle 常用操作

## 启动 Oracle 数据库和实例

```bash
#换到 Oracle 用户的环境
su - oracle

#进入 Oracle 数据库的安装目录。默认情况下，Oracle 数据库的安装目录是 /u01/app/oracle/product/<版本号>/dbhome_1。
cd /u01/app/oracle/product/<版本号>/dbhome_1
或者
cd $ORACLE_HOME

#执行以下命令来启动 Oracle 数据库实例
./bin/dbstart $ORACLE_HOME

#验证数据库是否成功启动，可以使用以下命令连接到数据库实例：
sqlplus / as sysdba

#运行以下命令来检查数据库实例的状态,两种方法都可以查看：
lsnrctl status
ps -ef | grep pmon

#如果发现实例没有启动，打开 SQL*Plus 工具，并使用 sysdba 角色连接到数据库，执行STARTUP启动实例。
sqlplus / as sysdba
startup

#如果有多个实例，分别执行export ORACLE_SID=intance_name，然后执行上一步去启动实例
```

## 重启 Oracle 数据库

```bash
#切换到 Oracle 用户的环境
su - oracle
#进入 SQL*Plus 工具
sqlplus / as sysdba
#停止数据库实例
shutdown immediate
#重新启动数据库实例
startup
```

## 创建数据库用户名和表空间

```bash
#执行以下SQL语句创建ECIS用户
CREATE USER ecis IDENTIFIED BY ecis123;
#授予ECIS用户必要的权限
GRANT CONNECT, RESOURCE, CREATE SESSION TO ecis;
#创建ECIS表空间，并将其存储在DATEDG存储中，下面语句假设你的DATEDG存储已经配置好，并且使用了+DATADG作为存储路径。请根据你的实际环境进行调整
CREATE TABLESPACE ecis DATAFILE '+DATADG' SIZE 1G AUTOEXTEND ON;
#非+DATADG的存储方式使用这个
CREATE TABLESPACE ecis DATAFILE '/u01/app/oracle/oradata/CSHISTEST/ecis.dbf' SIZE 1G AUTOEXTEND ON;
#授予ECIS用户对ECIS表空间的使用权限：
GRANT UNLIMITED TABLESPACE TO ecis;
#为ECIS用户分配默认表空间和临时表空间：
ALTER USER ecis DEFAULT TABLESPACE ecis TEMPORARY TABLESPACE temp;
```

## 使用 expdp 备份&impdp 恢复数据库文件

1. 备份

```bash
#使用 expdp 命令导出数据库时，你可以通过设置自定义的 DIRECTORY 目录来指定导出文件的存储位置。先设置自定义 DIRECTORY 目录。以 sysdba 身份登录到 Oracle 数据库。
#`MY_DIRECTORY` 可以自定义，将 /path/to/directory 替换为你希望导出文件存储的实际路径。
CREATE DIRECTORY MY_DIRECTORY AS '/path/to/directory';

#授予适当的权限给用户或角色，以便他们可以在自定义目录中读取和写入文件。例如，你可以使用以下命令将权限授予 SCOTT 用户，这里授权给system用户
#将 MY_DIRECTORY 替换为你创建的自定义目录名称，SYSTEM 替换为你希望授予权限的用户名。
GRANT READ, WRITE ON DIRECTORY MY_DIRECTORY TO SYSTEM;

#使用root用户授权/path/to/directory文件夹
chmod 777 -R /path/to/directory

#system/oracle@orcl是用户名/密码@实例名，MY_DIRECTORY 是你创建的自定义目录名称，export.dmp 是导出文件的名称，your_schema 是要导出的数据库模式名称，同时导出多个实例名用“ ，”隔开。logfile是日志文件
expdp system/oracle@orcl dumpfile=expdp.dmp DIRECTORY=expdp schemas=ECIS,HIHIS logfile=expdp.log
```

1. 恢复

```bash
#将使用expdp导出的dmp文件放入另一台服务器的DIRECTORY目录下，如果懒得查就创建新一个，在root用户下并授予文件oracle oinstall权限组。
chown -R oracle:oinstall /expdp

#使用impdp进行导入
impdp system/oracle@orcl dumpfile=expdp.dmp DIRECTORY=expdp schemas=BBP,HIHIS logfile=imp.log 

#如果删除旧的用户和数据再进行导入的话，注意：ORA-01940: cannot drop a user that is currently connected 出现此报错则需要将此用户sessionid kill掉在进行操作，若一直有新连接则在命令行执行lsnrctl stop命令停止监听
select username,sid,serial from v$session where USERNAME='HIS';
alter system kill session'317,63481';
```

## 查看表空间使用情况

```sql
select f.tablespace_name tablespace_name,
       round((d.maxbytes / 1024 / 1024 / 1024), 2) total_g,
       round((d.maxbytes - d.sumbytes + f.sumbytes) / 1024 / 1024 / 1024, 2) free_g,
       round((d.sumbytes - f.sumbytes) / 1024 / 1024 / 1024, 2) used_g,
       round((d.sumbytes - f.sumbytes) * 100 / d.maxbytes, 2) used_percent
  from (select tablespace_name, sum(bytes) sumbytes
          from dba_free_space
         group by tablespace_name) f,
       (select tablespace_name,
               sum(bytes) sumbytes,
               sum(case
                 when autoextensible = 'YES' then
                  maxbytes
                 else
                  bytes
               end) as maxbytes
          from dba_data_files
         group by tablespace_name, autoextensible) d
 where f.tablespace_name = d.tablespace_name
 order by used_percent desc;
```

## 查询某个时间节点前的数据

```sql
#先查询，后插入到新表中
select * from hi_enr_record_detail as of timestamp to_timestamp('2024-01-24 17:50:00','yyyy-mm-dd hh24:mi:ss');

insert into HI_ENR_RECORD_DETAIL_BAK20240124 select * from hi_enr_record_detail as of timestamp to_timestamp('2024-01-24 17:50:00','yyyy-mm-dd hh24:mi:ss');
```
