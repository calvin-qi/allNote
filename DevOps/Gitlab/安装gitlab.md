# 安装gitlab

## docker方式安装gitlab

1. 设置hostname，添加hosts文件映射,格式为：`ip domain hostname`.
例：`192.168.122.10 gitlab.walkdusk.top gitlab`
新建`/data/`目录，授予权限：`chmod 777 -R /data/`
执行创建容器命令：

    ```bash
    docker run -d \
        -p 443:443 -p 8080:80 -p 2222:22 \
        --hostname gitlab.walkdusk.top \
        --name gitlab \
        --restart always \
        --privileged=true \
        -v /data/gitlab/config:/etc/gitlab \
        -v /data/gitlab/logs:/var/log/gitlab \
        -v /data/gitlab/data:/var/opt/gitlab \
        -v /etc/localtime:/etc/localtime \
        gitlab/gitlab-ce:latest
    ```

2. 查看root用户初始登录密码

    ```bash
    docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
    # 命令输出如下：
    # Password: ZunWGbH6iahZeG6qs7PXfvRIg71maxc9ggzcT0H68Kk=
    # "ZunWGbH6iahZeG6qs7PXfvRIg71maxc9ggzcT0H68Kk="这就是密码
    ```

    > 在哪台电脑访问gitlab，就在哪台电脑配置hosts，格式为：ip domain
3. 修改配置文件
   没有修改前git clone地址的端口不显示，这样http方式和ssh方式录取推动不了代码
   修改前如下图所示：
    ![20240407175734](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20240407175734.png)
    配置容器中`/etc/gitlab/gitlab.rb`的配置文件，因为我们已经把容器的/etc目录映射到了本机的`/data/gitlab/config` 这个目录，我们打开宿主机`/data/gitlab/config/gitlab.rb` 这个文件就可以修改
    修改的内容如下：

    ```bash
    # ssh连接的端口，ssh这个端口和运行容器时的保持一致
    gitlab_rails['gitlab_shell_ssh_port'] = 2222
    ```

    此时已经修改好了ssh连接的端口，图片显示问题没显示全，如下图所示：
    ![20240407181111](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20240407181111.png)

    现在修改http连接方式的端口：

    ```bash
    # 执行命令进入容器内部
    docker exec -it gitlab bash

    # 编辑/var/opt/gitlab/gitlab-rails/etc/gitlab.yml
    vi /var/opt/gitlab/gitlab-rails/etc/gitlab.yml
    # 下面部分修改ip为8080,然后保存退出
    host: gitlab.walkdusk.top
    port: 8080 
    https: false

    # 容器内部执行命令重启
    gitlab-ctl restart
    ```

    然后访问刷新再看下，如下图所示就修改好了：
    ![20240407181850](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20240407181850.png)

## gitlab备份与恢复

### docker方式安装的备份和恢复

```bash
# 1.手动备份方式
docker exec -it <gitlab_container_name> gitlab-rake gitlab:backup:create

# 2.crontab定时任务自动备份方式
crontab -e
# 执行crontab -e后把表达式和备份命令添加进去保存退出就行
0 1 * * * docker exec -it <gitlab_container_name> gitlab-rake gitlab:backup:create
# 备份好的文件存储在宿主机/data/gitlab/data/backups/这个目录下


# 3.恢复
#将备份文件复制到GitLab容器内：
#将备份文件复制到GitLab容器内部，确保备份文件在容器内可访问。
docker cp /path/on/host/<backup_file> <gitlab_container_name>:/var/opt/gitlab/backups/
#登录到GitLab容器：使用docker exec命令登录到GitLab容器内部。
docker exec -it <gitlab_container_name>  bash
# cd到容器内备份目录/var/opt/gitlab/backups/ 执行恢复命令：<backup_file>不加文件名后缀
gitlab-rake gitlab:backup:restore BACKUP=<backup_file>

# 然后刷新访问看看
```
