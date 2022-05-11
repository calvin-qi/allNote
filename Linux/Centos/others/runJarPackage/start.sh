#!/bin/sh
rm -f tpid
APP_NAME=account-main-1.0.0
APP_JAR=$APP_NAME".jar"
##nohup命令提交作业，那么在缺省情况下该作业的所有输出都被重定向到一个名为nohup.out的文件中，除非另外指定了输出文件。这里指定输出文件在为./fm-eureka-client-1.0-SNAPSHOT.log
nohup java -jar $APP_JAR > $APP_NAME".log" 2>&1 &
echo $! > $APP_NAME".tpid"
echo ------------------------------------------------- $APP_NAME 启动成功！

