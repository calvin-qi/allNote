# 文件夹同步

1. 安装inotify-tools和rsync软件包：

  ```bash
  yum install -y inotify-tools rsync
  ```

2. 创建文件将文件保存为sync_script.sh（或其他你喜欢的名称）。

```shell
#!/bin/sh

SOURCE_DIR="/home/test"
DESTINATION_SERVER="username@destination_server_ip"
DESTINATION_DIR="/home/"

inotifywait -m -r -e modify,create,delete,move "$SOURCE_DIR" | while read path action file; do
    rsync -avz --delete "$SOURCE_DIR" "$DESTINATION_SERVER:$DESTINATION_DIR"
done


请根据实际情况修改脚本中的变量：
SOURCE_DIR：源文件夹的路径。
DESTINATION_SERVER：目标服务器的用户名和IP地址。
DESTINATION_DIR：目标文件夹的路径。
保存脚本并赋予执行权限（例如，chmod +x sync_script.sh）。然后在终端中运行脚本，它将实时监视/home/test文件夹的修改、创建、删除和移动事件，并使用rsync命令将变化同步到目标服务器的相同路径。

请注意，这个脚本只会同步文件夹中的改变，而不会同步文件夹本身的更改。如果要同步文件夹本身的更改（例如，文件夹的权限或所有权），可以在rsync命令中添加--perms和--owner选项。
```

3. 在终端中运行以下命令，为脚本添加执行权限：
`chmod +x sync_script.sh`
4. 在终端中运行以下命令，启动脚本并开始实时同步文件夹的改变：
`./sync_script.sh`
后台启动：
`nohup /root/sync_finereport.sh > /root/sync_finereport.log &`
