新建项目文件夹，把`start.sh`&`stop.sh`和`xxx.jar`放入文件夹当中
修改两个脚本中jar包名称
`./start.sh`启动会在同级文件夹生成`xxx.log`日志文件
使用`tail -f xxx.log`命令查看实时启动日志
`/etc/hosts`添加mysql、redis、minio等信息
nginx代理`vue.config.js`里的路径：端口