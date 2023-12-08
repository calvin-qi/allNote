# 离线安装docker&docker-compose

1. 下载docker安装包`docker-20.10.20.tgz`和docker-compose包`docker-compose-linux-x86_64`。或者去[docker官网下载](https://download.docker.com/linux/static/stable/x86_64/)

    ```shell
    https://calvinqi.oss-cn-beijing.aliyuncs.com/files/docker/docker-20.10.20.tgz
    https://calvinqi.oss-cn-beijing.aliyuncs.com/files/docker/docker-compose-linux-x86_64
    ```

2. 安装脚本`install-docker.sh`放在安装同级目录下运行

   ```shell
   #!/bin/bash

   echo 'create a docker group'
   groupadd docker
   echo 'tar file  docker-20.10.20.tgz'
   tar -xvf docker-20.10.20.tgz
   echo 'mv docker to /usr/bin...'
   mv docker/* /usr/bin/
   echo 'copy docker.service to /etc/systemd/system/ ...'
   cp docker.service /etc/systemd/system/
   echo 'create docker daemod.json'
   mkdir -p /etc/docker/
   cat <<EOF > /etc/docker/daemon.json
   {
     "registry-mirrors": ["https://3x8fih0m.mirror.aliyuncs.com"],
     "exec-opts": ["native.cgroupdriver=systemd"],
     "insecure-registries": ["172.168.30.71:5000"],
     "log-opts": {
       "max-size": "100m",
       "max-file": "3"
     }
   }
   EOF
   echo 'chmod +x docker.service ...'
   chmod +x /etc/systemd/system/docker.service
   echo 'systemctl daemon-reload ...'
   systemctl daemon-reload
   echo 'start docker...'
   systemctl start docker
   echo 'systemctl enable docker.service..'
   systemctl enable docker.service
   echo 'docker install success...'
   docker -v
   echo 'cp docker-compose...'
   cp docker-compose-linux-x86_64 /usr/bin/docker-compose
   echo 'chmod +x docker-compose...'
   chmod +x /usr/bin/docker-compose
   echo 'docker-compose --version...'
   docker-compose --version
   echo 'change socket file group ownership'
   chgrp docker /var/run/docker.sock
   echo "remove temp directories"
   rm -rf docker
   exit 0
   ```

3. 创建docker.service,安装脚本会自动创建

   ```shell
   [Unit]
   Description=Docker Application Container Engine
   Documentation=<https://docs.docker.com>
   After=network-online.target firewalld.service
   Wants=network-online.target
   
   [Service]
   Type=notify
   ExecStart=/usr/bin/dockerd
   ExecReload=/bin/kill -s HUP $MAINPID
   LimitNOFILE=infinity
   LimitNPROC=infinity
   TimeoutStartSec=0
   Delegate=yes
   KillMode=process
   Restart=on-failure
   StartLimitBurst=3
   StartLimitInterval=60s
   
   [Install]
   WantedBy=multi-user.target
   ```

# 安装docker和docker-compose

```sh
echo "=====开始安装docker，docker-compose====="
yum -y install wget curl vim ntpdate
ntpdate time.windows.com
#添加docker源
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo

#安装docker
yum -y install docker-ce-18.09.9-3.el7
echo "=====设置cgroup====="
#设置cgroup驱动，添加镜像加速
mkdir /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "registry-mirrors": [
  "https://paucfus3.mirror.aliyuncs.com",
  "https://hub-mirror.c.163.com",
  "https://registry.aliyuncs.com",
  "https://registry.docker-cn.com",
  "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF
echo "=====重启docker====="
systemctl restart docker
sleep 3
echo "=====添加镜像加速====="
#镜像加速
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
echo "=====重启dodcker====="
systemctl daemon-reload
systemctl restart docker
sleep 3
#查看镜像加速有没有添加进去
echo "=====查看镜像加速有没有添加成功====="
cat /etc/docker/daemon.json
#开机自启
systemctl enable docker && systemctl start docker

#安装dockeer-compose
echo "=====安装docker-compose====="
curl -L https://get.daocloud.io/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

#添加执行权限
chmod +x /usr/local/bin/docker-compose
echo "=====查看版本====="
docker --version
docker-compose version

echo "=====docker,docker-compose安装完成====="
```
