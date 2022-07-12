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
