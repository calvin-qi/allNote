修改有多实例数据库的用户密码

```sql
#修改文件权限组
chown oracle:oinstall 
#修改用户密码
export ORACLE_SID=whis1
sqlplus / as sysdba
ALTER USER bsadmin IDENTIFIED BY bsadminfy2023;
#删除用户
drop user USERNAME cascade;

shutdown immediate;
shutdown abort;

srvctl stop database -d whis
srvctl start database -d whis
lsnrctl stop
srvctl stop scan_listener
srvctl start scan_listener

col file_name for a60;
set linesize 160;
select file_name,tablespace_name,bytes from dba_data_files;

select username,default_tablespace from dba_users;

#到处数据库
expdp system/oracle@hisdb dumpfile=exp.dmp DIRECTORY=expdp schemas=BBP,HIHIS,dzjkk,FINEREPORT,PHCP,ISYNC,DZJKK,CARDDBTEST,EMR logfile=exp.log

expdp system/oracle@hisdb dumpfile=exp.dmp DIRECTORY=expdp schemas=BBP,HIHIS,dzjkk,FINEREPORT,PHCP,ISYNC,DZJKK,CARDDBTEST,EMR logfile=exp.log

expdp system/oracle@hisdb dumpfile=exp.dmp DIRECTORY=expdp schemas=BBP,HIHIS,dzjkk,FINEREPORT,PHCP,ISYNC,DZJKK,CARDDBTEST,EMR logfile=exp.log

expdp system/oracle@cshistest dumpfile=exptest.dmp DIRECTORY=expdp schemas=BSNENR,BSINTERFACE,BSHSS,BSPFLIS,ECIS,BSPLATFORM,BSCA,BSZDGX,BSENR,BSMOB,BSPORTAL,BSADMIN,BSEMR,BSQYLIS logfile=exptest.log

#导入数据库
impdp system/oracle@hisdb1 dumpfile=exp.dmp DIRECTORY=expdp schemas=BBP,HIHIS,dzjkk,FINEREPORT,PHCP,ISYNC,DZJKK,CARDDBTEST logfile=imp.log

impdp system/oracle@whis1 dumpfile=exptest.dmp DIRECTORY=expdp schemas=BSINTERFACE,BSHSS,BSPFLIS,ECIS,BSPLATFORM,BSCA,BSZDGX,BSMOB,BSPORTAL,BSADMIN,BSENR,BSQYLIS logfile=imptest.log
#查看表空间名字以及个数
col file_name for a60;
set linesize 160;
select file_name,tablespace_name,bytes from dba_data_files;

#查看用户名
select username,default_tablespace from dba_users;

#创建只读用户
create user read_only_user identified by read_only_userFy123 default tablespace users temporary tablespace TEMP;
grant select any table to read_only_user;
grant connect to read_only_user;

#创建表空间
alter tablespace 表空间名 add datafile '数据文件路径' size 1g autoextend on;

#查询数据文件路径
select name from v$datafile;

create user BSEMR identified by bsemrfy123 default tablespace BSEMR_DATA temporary tablespace TEMP;
grant connect,dba to BSEMR;
alter tablespace BSEMR_DATA add datafile '+DATADG' size 1g autoextend on;
```

```
ALTER USER bsadmin IDENTIFIED BY bsadminfy2023;
ALTER USER bsportal IDENTIFIED BY bsportalfy2023;
ALTER USER bsqylis IDENTIFIED BY bsqylisfy2023;
ALTER USER bsmob IDENTIFIED BY bsmobfy2023;
ALTER USER bsenr IDENTIFIED BY bsenrfy2023;
ALTER USER bszdgx IDENTIFIED BY bszdgxfy2023;
ALTER USER bsca IDENTIFIED BY bscafy2023;
ALTER USER BSPLATFORM IDENTIFIED BY BSPLATFORMfy2023;
ALTER USER BSINTERFACE IDENTIFIED BY BSINTERFACEfy2023;
ALTER USER ECIS IDENTIFIED BY ECISfy2023;
ALTER USER bspflis IDENTIFIED BY bspflisfy2023;
ALTER USER BSEMR IDENTIFIED BY BSEMRfy2023;
ALTER USER bshss IDENTIFIED BY bshssfy2023;
ALTER USER BSNENR IDENTIFIED BY BSNENRfy2023;

drop user BSADMIN      cascade;
drop user BSEMR      cascade;
drop user BSPORTAL     cascade;
drop user BSQYLIS      cascade;
drop user BSMOB      cascade;
drop user BSZDGX  cascade;
drop user BSCA      cascade;
drop user BSPLATFORM cascade;
drop user BSINTERFACE cascade;
drop user ECIS      cascade;
drop user BSPFLIS      cascade;
drop user BSHSS  cascade;
drop user BSNENR  cascade;
drop user BSENR cascade;

​
drop user BBP           cascade;
drop user CPYBFYREAD    cascade;
drop user HIHIS         cascade;
drop user FINEREPORT    cascade;
drop user PHCP          cascade;
drop user ISYNC         cascade;
drop user DZJKK         cascade;
drop user CARDDBTEST    cascade;
drop user INTERFACE     cascade;

drop user bbp cascade;
drop user hihis cascade;
drop user dzjkk cascade;
drop user finereport cascade;
drop user phcp cascade;
drop user isync cascade;
drop user carddbtest cascade;

alter user bbp identified by bbpfy2023;
alter user hihis identified by hihisfy2023;
alter user dzjkk identified by dzjkkfy2023;
alter user finereport identified by finereportfy2023;
alter user phcp identified by phcpfy2023;
alter user isync identified by isyncfy2023;
alter user carddbtest identified by carddbtestfy2023;

alter user bbp ACCOUNT UNLOCK;
alter user hihis ACCOUNT UNLOCK;
alter user dzjkk ACCOUNT UNLOCK;
alter user finereport ACCOUNT UNLOCK;
alter user phcp ACCOUNT UNLOCK;
alter user isync ACCOUNT UNLOCK;
alter user carddbtest ACCOUNT UNLOCK;
```
