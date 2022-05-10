```shell
#!/bin/bash
#
#author patrick@mail@flightshen@163.com
#
#
#自定义变量
DB_USER=root
DB_PASSWD=dosion123456

DATE=`date -d"today" +%Y%m%d%H`
TIME=`date "+%Y-%m-%d %H:%M:%S"`
OneMouthDate=`date -d "1 month ago"  +%Y%m%d%H`

DB_BackupDir=/home/backup/mysqlBackup

DB_NAME=`mysql -u$DB_USER -p$DB_PASSWD -e "show databases" | tr -d "| " | grep -v Database | sed '/^performance_schema$/'d | sed '/^mysql/'d | sed '/^information_schema$/'d | sed '/^information_schema$/'d | sed '/^test$/'d `
#
#
#输出开始备份的时间到日志文件中去
echo  "-----------------$TIME------------------ "    >>  /$DB_BackupDir/logfile.log
#
#循环所有要备份的数据库
#
for basename in ${DB_NAME[@]}
do
#判断备份目录是否存在
        if [ ! -d "/$DB_BackupDir/$DATE" ]
        then
                mkdir -p /$DB_BackupDir/$DATE
        fi
#开始备份
        mysqldump -u$DB_USER -p$DB_PASSWD --single-transaction --master-data=2 --triggers --routines  $basename > /$DB_BackupDir/$DATE/$basename.sql
        if [ $? -eq 0 ]
        then
                echo  "/$DB_BackupDir/$DATE/$basename backup yes!" >> /$DB_BackupDir/logfile.log
        else
                echo  "/$DB_BackupDir/$DATE/$basename backup no!" >> /$DB_BackupDir/logfile.log
        fi
#压缩删除备份文件
        tar -zcvf /$DB_BackupDir/$DATE/$basename.tar.gz /$DB_BackupDir/$DATE/$basename.sql &> /dev/null
        if [ $? -eq 0 ]
        then
                echo  "/$DB_BackupDir/$DATE/$basename tar yes!" >> /$DB_BackupDir/logfile.log
        else
                echo  "/$DB_BackupDir/$DATE/$basename tar no!" >> /$DB_BackupDir/logfile.log
        fi
        rm -rf /$DB_BackupDir/$DATE/$basename.sql
                if [ $? -eq 0 ]
        then
                echo  "/$DB_BackupDir/$DATE/$basename rm yes!" >> /$DB_BackupDir/logfile.log
        else
                echo  "/$DB_BackupDir/$DATE/$basename rm no!" >> /$DB_BackupDir/logfile.log
        fi
done


#删除30天以前的备份
#c到脚本所在目录
cd `dirname $0`
#匹配当前目录下存在的所有的有2022的目录（ip名）
data_dir=`ls | grep -E "^[2][0][2][2]"`
for dir in ${data_dir}
do
    find ./${dir} -ctime +30 -name "*" -exec /bin/rm -rf {} \; &>/dev/null
done


#
#删除30天以前的备份

#        find /$DB_BackupDir/$OneMouthDate -name "*.tar.gz" -exec rm -rf {} \; &>/dev/null
#        if [ $? -eq 0 ]
#        then
#                echo  "$OneMouthDate delete  yes!" >> /$DB_BackupDir/logfile.log
#        else
#                echo  "none file delete" >> /$DB_BackupDir/logfile.log
#        fi

```

