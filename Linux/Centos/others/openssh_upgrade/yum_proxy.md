# 1.代理yum源

1. 在文件`/etc/yum.conf`添加一行yum代理地址`proxy=http://192.124.1.220:6060`
![20220712173741](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20220712173741.png)

2. 在`~/.bashrc`中添加一行`export http_proxy="http://192.124.1.220:6060"`
![20220712174144](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20220712174144.png)
3. 在`/etc/yum.repos.d/CentOS-Base.repo`中添加一行`proxy=http://192.124.1.220:6060`

    ![20220712180633](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20220712180633.png)

```shell
[base]
name=CentOS-7- Base
baseurl=http://ftp.sjtu.edu.cn/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey= http://ftp.sjtu.edu.cn/centos/RPM-GPG-KEY-CentOS-7
proxy=http://192.124.1.220:6060

[update]
name=CentOS-7 - Updates
baseurl= http://ftp.sjtu.edu.cn/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey= http://ftp.sjtu.edu.cn/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-7 - Extras
baseurl= http://ftp.sjtu.edu.cn/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey= http://ftp.sjtu.edu.cn/centos/RPM-GPG-KEY-CentOS-7

[centosplus]
name=CentOS-7 - Plus
baseurl= http://ftp.sjtu.edu.cn/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey= http://ftp.sjtu.edu.cn/centos/RPM-GPG-KEY-CentOS-7
```

# 2.挂载iso镜像使用yum

1. 去官网下载CentOS-7-x86_64-DVD-2009.iso镜像
<http://isoredirect.centos.org/centos/7/isos/x86_64/>
![20220810191424](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20220810191424.png)
2. 上传下载好的镜像文件到服务器`/mnt`目录下

    ```shell
    #新建文件夹
    mkdir /media/CentOS7
    #以只读形式挂载镜像到/media/CentOS7
    mount -t iso9660 /mnt/CentOS-7-x86_64-DVD-2009.iso /media/CentOS7
    ```

3. 配置yum源

   ```shell
   cd /etc/yum.repos.d
   mkdir bak
   mv *.repo bak
   vi /etc/yum.repos.d/CentOS7-Localsource.repo

   #输入以下内容
   [CentOS7-Localsource]
   name=CentOS7-Localsource
   baseurl=file:///media/CentOS7
   enabled=1
   gpgcheck=0

   #更新yum配置
   yum clean all
   yum makecache
   ```

4. 愉快的使用yum安装依赖包

5. 开机自动挂载

    `df -h`查看磁盘信息
    ![20220810194641](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20220810194641.png)

    ```shell
    vi /etc/fstab
    #添加下面内容到/etc/fstab末尾行
    /mnt/CentOS-7-x86_64-DVD-2009.iso /media/CentOS7 iso9660 defaults,loop 0 0
    ```

6. 卸载挂载的iso镜像

   ```shell
   #不需要了就卸载了
   umount /media/CentOS7
   ```
