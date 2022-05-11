#!/bin/sh
APP_NAME=account-main-1.0.0

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

