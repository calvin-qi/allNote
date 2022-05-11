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