# 自动备份脚本
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

# 数据库逐个备份脚本

```shell
#!/bin/bash
#Author absolutely.xu@gmail.com
MAXIMUM_BACKUP_FILES=10              #最大备份文件数
BACKUP_FOLDERNAME="/home/mysql_backup"  #数据库备份文件的主目录
DB_HOSTNAME="localhost"              #mysql所在主机的主机名
DB_USERNAME="root"                   #mysql登录用户名
DB_PASSWORD="dosion123456"                 #mysql登录密码
DATABASES=(
                             #备份的数据库名
"nformation_schema"
"activity"
"app-auth"
"assets"
"assets1"
"assets2"
)
#=========
echo "Bash Database Backup Tool"
#CURRENT_DATE=$(date +%F)
CURRENT_DATE=$(date +%F)              #定义当前日期为变量
BACKUP_FOLDER="${BACKUP_FOLDERNAME}_${CURRENT_DATE}" #存放数据库备份文件的目录
mkdir -p $BACKUP_FOLDER #创建数据库备份文件目录
#统计需要被备份的数据库
count=0
while [ "x${DATABASES[count]}" != "x" ];do
    count=$(( count + 1 ))
done
echo "[+] ${count} databases will be backuped..."
#循环这个数据库名称列表然后逐个备份这些数据库
for DATABASE in ${DATABASES[@]};do
    echo "[+] Mysql-Dumping: ${DATABASE}"
    echo -n "   Began:  ";echo $(date)
    if $(mysqldump -h ${DB_HOSTNAME} -u${DB_USERNAME} -p${DB_PASSWORD} ${DATABASE} > "${BACKUP_FOLDER}/${DATABASE}.sql");then
        echo "  Dumped successfully!"
    else
        echo "  Failed dumping this database!"
    fi
        echo -n "   Finished: ";echo $(date)
done
echo
echo "[+] Packaging and compressing the backup folder..."
tar -cv ${BACKUP_FOLDER} | bzip2 > ${BACKUP_FOLDER}.tar.bz2 && rm -rf $BACKUP_FOLDER
BACKUP_FILES_MADE=$(ls -l ${BACKUP_FOLDERNAME}*.tar.bz2 | wc -l)
BACKUP_FILES_MADE=$(( $BACKUP_FILES_MADE - 0 )) 
#把已经完成的备份文件数的结果转换成整数数字
 
echo
echo "[+] There are ${BACKUP_FILES_MADE} backup files actually."
#判断如果已经完成的备份文件数比最大备份文件数要大，那么用已经备份的文件数减去最大备份文件数,打印要删除旧的备份文件
if [ $BACKUP_FILES_MADE -gt $MAXIMUM_BACKUP_FILES ];then
    REMOVE_FILES=$(( $BACKUP_FILES_MADE - $MAXIMUM_BACKUP_FILES ))
echo "[+] Remove ${REMOVE_FILES} old backup files."
#统计所有备份文件，把最新备份的文件存放在一个临时文件里，然后删除旧的文件，循环出临时文件的备份文件从临时目录里移到当前目录
    ALL_BACKUP_FILES=($(ls -t ${BACKUP_FOLDERNAME}*.tar.bz2))
    SAFE_BACKUP_FILES=("${ALL_BACKUP_FILES[@]:0:${MAXIMUM_BACKUP_FILES}}")
echo "[+] Safeting the newest backup files and removing old files..."
    FOLDER_SAFETY="_safety"
if [ ! -d $FOLDER_SAFETY ]
then mkdir $FOLDER_SAFETY
                                                                                                                    
fi
for FILE in ${SAFE_BACKUP_FILES[@]};do
                                                                                                                      
    mv -i  ${FILE}  ${FOLDER_SAFETY}
done
    rm -rf ${BACKUP_FOLDERNAME}*.tar.bz2
    mv  -i ${FOLDER_SAFETY}/* ./
    rm -rf ${FOLDER_SAFETY}
#以下显示备份的数据文件删除进度，一般脚本都是放在crontab里，所以我这里只是为了显示效果，可以不选择这个效果。
     
CHAR=''
for ((i=0;$i<=100;i+=2))
do  printf "Removing:[%-50s]%d%%\r" $CHAR $i
        sleep 0.1
CHAR=#$CHAR
done
    echo
fi

```

