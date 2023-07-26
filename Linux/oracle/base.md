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

```sql

登录10数据库
su - oracle
sqlplus /nolog
conn /as sysdba

重启数据库
等待用户完成当全部的语句
SHUTDOWN Immediate

SHUTDOWN Abort

startup
#启动监听

#删除用户及表数据
drop user his cascade;
drop user finereport cascade;
drop user emr cascade;
drop user bbp cascade;

注意：ORA-01940: cannot drop a user that is currently connected 出现此报错则需要将此用户sessionid kill掉在进行操作，若一直有新连接则在命令行执行lsnrctl stop命令停止监听
select username,sid,serial# from v$session where USERNAME='HIS'; 查询sessionid
alter system kill session'317,63481';

#创建用户并授权
create user his identified by bsoft123 default tablespace his temporary tablespace TEMP; 
grant connect,dba to his;

create user bbp identified by bsoft123 default tablespace bbp temporary tablespace TEMP; 
grant connect,dba to bbp;
create user emr identified by bsoft123 default tablespace emr temporary tablespace TEMP;
grant connect,dba to emr;
create user finereport identified by bsoft123 default tablespace finereport temporary tablespace TEMP;
grant connect,dba to finereport;

#整库导出
expdp \"\/ as sysdba\" dumpfile=6.10_all_2022-3-8.dmp FULL=y directory=DATA_PUMP_DIR logfile=6.10_all_expdp_2022-03-8.log compression=all

#导出数据库表结构
expdp prd_his/bsoft123 dumpfile=prdhis_2022-2-14.dmp directory=DATA_PUMP_DIR schemas=prd_his content=metadata_only logfile=his_expdp_2022-02-14.log
expdp 用户名/密码 dumpfile=导出的文件名 directory=DATA_PUMP_DIR schemas=表空间名 logfile=导入的日志文件名
expdp his/bsoft123 dumpfile=his_2022-2-14.dmp directory=DATA_PUMP_DIR schemas=his logfile=his_expdp_2022-02-14.log


#导入数据库

impdp 用户名/密码  directory=DATA_PUMP_DIR logfile=导入的日志文件名 dumpfile=导入的文件名 exclude=STATISTICS remap_schema=导出的表空间名:导入的表空间名 remap_tablespace=导出的表空间名:导入的表空间名
impdp his/bsoft123  directory=DATA_PUMP_DIR logfile=his_impdp_$(date +%F).log dumpfile=his_20211110_1018.dmp.c exclude=STATISTICS remap_schema=his:his remap_tablespace=his:his

impdp bbp/bsoft123  directory=DATA_PUMP_DIR logfile=bbp_impdp_$(date +%F).log dumpfile=bbp_expdp_20211110_1025.dmp.c exclude=STATISTICS remap_schema=bbp:bbp remap_tablespace=bbp:bbp

impdp emr/bsoft123  directory=DATA_PUMP_DIR logfile=emr_impdp_$(date +%F).log dumpfile=emr_20211110_1042.dmp.c exclude=STATISTICS remap_schema=emr:emr remap_tablespace=emr:emr

impdp finereport/bsoft123  directory=DATA_PUMP_DIR logfile=finereport_impdp_$(date +%F).log dumpfile=finereport_20211110_1049.dmp.c exclude=STATISTICS remap_schema=finereport:finereport remap_tablespace=finereport:finereport

#全库导入

#开启监听
lsnrctl start
# 查看表空间数据文件存放位置
 select t1.name,t2.name 

         from v$tablespace t1,v$datafile t2

         where t1.ts# = t2.ts#;

#查看表空间
select tablespace_name, sum(bytes)/1024/1024 from dba_data_files group by tablespace_name;

#查看具体表单所占空间
select Segment_Name,Sum(bytes)/1024/1024 From User_Extents Group By Segment_Name

#查看所有表空间占用率
SELECT
 tpsname,
 status,
 mgr,
 maxsize,
 c_userd,
 max_used 
FROM
 (
 SELECT
  d.tablespace_name tpsname,
  d.status status,
  d.segment_space_management mgr,
  d.contents TYPE,
  TO_CHAR( NVL( trunc( A.maxbytes / 1024 / 1024 ), 0 ), '99G999G990' ) maxsize,
  TO_CHAR( NVL(( a.bytes - NVL( f.bytes, 0 )) / a.bytes * 100, 0 ),'990D00' ) c_userd,
  TO_CHAR( NVL(( a.bytes - NVL( f.bytes, 0 )) / a.maxbytes * 100, 0 ),'990D00' ) max_used 
 FROM
  sys.dba_tablespaces d,
  (
  SELECT
   tablespace_name,
   sum( bytes ) bytes,
  SUM( CASE autoextensible WHEN 'N' THEN BYTES WHEN 'YES' THEN MAXBYTES ELSE NULL END ) maxbytes 
FROM
 dba_data_files 
GROUP BY
 tablespace_name 
 ) a,
 ( SELECT tablespace_name, SUM( bytes ) bytes, MAX( bytes ) largest_free FROM dba_free_space GROUP BY tablespace_name ) f 
WHERE
 d.tablespace_name = a.tablespace_name 
 AND d.tablespace_name = f.tablespace_name ( + ) 
 )
 ORDER BY max_used

#创建表空间

create tablespace his datafile '/oradata/ORCL/his.dbf' size 512M reuse autoextend on next 50M EXTENT MANAGEMENT LOCAL;

#新增表空间文件

alter tablespace his add datafile 'e:\datafile\his.dbf'  size 512M reuse autoextend on next 50M maxsize 31G;
alter tablespace undo add datafile '/oradata/ORCL/undotbs02.dbf'  size 512M reuse autoextend on next 50M maxsize 31G;

#查询视图修改时间
select created,object_name,LAST_DDL_TIME,timestamp from user_objects where object_name like '%MED_ORDER_EXEC_TZYY%';

#授予所有表查询权限
grant select any table to zlptr;


#授予创建函数权限
GRANT CREATE ANY PROCEDURE TO SCOTT;

#创建视图用户
CREATE USER crbbk IDENTIFIED BY   bsoft123  DEFAULT TABLESPACE phcp TEMPORARY TABLESPACE temp;
GRANT connect to crbbk;

#授权视图给用户
grant select on THIMMS_YZMX to yguser with grant option;


#授权函数给用户
赋权：grant execute on function1 to ucr_dtb1;
收回执行权限：revoke execute on function1 from ucr_dtb1;

# 创建同义词  （在需要授权的用户执行）
CREATE OR REPLACE PUBLIC SYNONYM tfbk_emrdead FOR PRD_HIS.tfbk_emrdead;

# 创建dblink

CREATE PUBLIC DATABASE LINK TO_BBP_51 CONNECT TO bbp IDENTIFIED BY bsoft123 USING '(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.6.20)(PORT =1521 ))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orcl)
    )
  )';
# 解锁语句
select 'alter system kill session '''||s.sid||','||s.serial#||',@'||l.inst_id||''' immediate ;'
from gv$lock l,gv$session s 
where l.type = 'TX' and l.LMODE =6 and (l.ID1,l.ID2) in 
(select id1,id2 from gv$lock where type like 'TX' and REQUEST =6) 
and l.inst_id=s.inst_id and l.sid=s.sid 
order by l.inst_id,s.sid asc;

# 查询死锁
  SELECT
 l.session_id sid,
 s.serial#,
 l.locked_mode locked_mode,
 l.oracle_username login_user,
 l.os_user_name os_user_name,
 s.machine machine_name,
 s.terminal terminal_name,
 o.object_name object_name,
 s.logon_time logon_time,
 nvl(max(v.ctime), 0) AS ctime,
 sq.sql_text as sql_text
FROM
 v$locked_object l,
 all_objects o,
 v$session s,
 v$lock v,
 V$SQLAREA  sq
WHERE
 l.object_id = o.object_id
 AND l.session_id = s.sid
 AND l.session_id = v.sid
 AND s.prev_sql_addr = sq.address 
        AND v.type in ('TM','TX')
GROUP BY
 l.session_id,
 s.serial#,
 l.locked_mode,
 l.oracle_username ,
 l.os_user_name ,
 s.machine ,
 s.terminal ,
 o.object_name,
 s.logon_time ,
  ctime,
  sq.sql_text


#查询行锁
SELECT RPAD('+', LEVEL, '-') || sid || ' ' || sess.module session_detail,sid,SERIAL#,'alter system kill session '''||SID||','||SERIAL#||',@'||sess.inst_id||''' immediate;' as kill_sql,
       blocker_sid,
       sess.inst_id,
       sess.type,
       wait_event_text,
       object_name,
       RPAD(' ', LEVEL) || sql_text sql_text
  FROM v$wait_chains c
  LEFT OUTER JOIN dba_objects o
    ON (row_wait_obj# = object_id)
  JOIN gv$session sess
 USING (sid)
  LEFT OUTER JOIN v$sql sql
    ON (sql.sql_id = sess.sql_id AND
       sql.child_number = sess.sql_child_number)
CONNECT BY PRIOR sid = blocker_sid
       AND PRIOR sess_serial# = blocker_sess_serial#
       AND PRIOR INSTANCE = blocker_instance
 START WITH blocker_is_valid = 'FALSE'

#删除DBLINK
drop public database link LINK_HIS; #删除公有的
drop database link LINK_HIS; #删除私有的
#查询DBLINK
select * from dba_db_links;
#更新dblink
update sys.link$ set host='(DESCRIPTION =
(ADDRESS_LIST =
(ADDRESS = (PROTOCOL = TCP)(HOST = 172.168.20.222)(PORT =1521 ))
)
(CONNECT_DATA =
(SERVICE_NAME = hisdb)
)
)' where name='HIHIS' 
```
