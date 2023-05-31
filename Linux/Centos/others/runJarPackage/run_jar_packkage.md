# 运行jar包的方式

## 用脚本的方式运行

新建项目文件夹，把`start.sh`&`stop.sh`和`xxx.jar`放入文件夹当中
修改两个脚本中jar包名称
`./start.sh`启动会在同级文件夹生成`xxx.log`日志文件
使用`tail -f xxx.log`命令查看实时启动日志
`/etc/hosts`添加mysql、redis、minio等信息
nginx代理`vue.config.js`里的路径：端口

启动脚本：

```sh
#!/bin/sh
rm -f tpid
APP_NAME=campus-auth
APP_JAR=$(dirname $0)/$APP_NAME".jar"
##nohup命令提交作业，那么在缺省情况下该作业的所有输出都被重定向到一个名为nohup.out的文件中，除非另外指定了输出文件。这里指定输出文件在为./fm-eureka-client-1.0-SNAPSHOT.log
nohup java -jar $APP_JAR > $APP_NAME".log" 2>&1 &
echo $! > $APP_NAME".tpid"
echo ------------------------------------------------- $APP_NAME 启动成功！

```

停止脚本：

```sh
#!/bin/sh
APP_NAME=campus-auth

tpid=`ps -ef|grep $APP_NAME|grep -v grep|grep -v kill|awk '{print $2}'`
if [ ${tpid} ]; then
    echo 'Stopping' $APP_NAME '...'
    kill -15 $tpid
fi
sleep 5
tpid=`ps -ef|grep $APP_NAME|grep -v grep|grep -v kill|awk '{print $2}'`
if [ ${tpid} ]; then
    echo 'Kill' $APP_NAME 'Process!'
    kill -9 $tpid
else
    echo $APP_NAME 'Stoped Success!'
fi

```
