# 1.安装要求

- 准备三台或以上机器centos7

- 硬件配置：2GB或更多RAM，2个CPU或更多CPU，硬盘30GB或更多

- 集群中所有机器之间网络互通

- 可以访问外网，需要拉取镜像

- 禁止swap分区

- ```shell
  192.168.1.101   master
  192.168.1.102   node1
  192.168.1.103   node2
  ```

![image-20211202171200989](C:\Users\calvi\AppData\Roaming\Typora\typora-user-images\image-20211202171200989.png)

# 2.学习目标

1. 在所有节点上安装Docker和kubeadm
2. 部署Kubernetes Master
3. 部署容器网络插件
4. 部署 Kubernetes Node，将节点加入Kubernetes集群中
5. 部署Dashboard Web页面，可视化查看Kubernetes资

# 3.准备环境(三台机子都操作)

1. 关闭防火墙

   ```shell
   systemctl stop firewalld
   systemctl disable firewalld
   ```

2. 关闭selinux

   ```shell
   sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 
   setenforce 0
   ```

3. 关闭swap

   ```shell
   swapoff -a # 临时关闭
   # 注释 swap 行
   sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab"
   ```
   
4. 修改主机名称

   ```shell
   hostnamectl set-hostname 名字
   ```

5. 时间同步：

   ```shell
   yum -y install ntpdate
   ntpdate time.windows.com
   ```
   
   

5. 添加主机名与IP对应关系（记得设置主机名）

   ```shell
   v /etc/hosts 
   192.168.1.44 testmaster 
   192.168.1.45 testnode1 
   192.168.1.46 testnode2
   ```

6. 将桥接的IPv4流量传递到iptables的链

   ```shell
   cat > /etc/sysctl.d/k8s.conf << EOF
   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1
   EOF
   ```

7. 然后执行

   ```shell
    sysctl --system
    reboot
   ```

# 4.所有节点安装Docker/kubeadm/kubelet

1. 安装docker

   - 安装docker源

     ```shell
     wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
     ```

   - 安装docker

     ```shell
     yum -y install docker-ce-18.09.9-3.el7
     ```

   - 设置cgroup驱动

     ```shell
     mkdir /etc/docker
     cat > /etc/docker/daemon.json <<EOF
     {
       "exec-opts": ["native.cgroupdriver=systemd"],
       "log-driver": "json-file",
       "log-opts": {
         "max-size": "100m"
       },
       "storage-driver": "overlay2"
     }
     EOF
     ```

   - 设置镜像加速

     ```shell
     mkdir /etc/docker
     curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
     
     systemctl restart docker
     
     cat > /etc/docker/daemon.json <<EOF
     {"registry-mirrors": ["http://f1361db2.m.daocloud.io"],
       "exec-opts": ["native.cgroupdriver=systemd"],
       "log-driver": "json-file",
       "log-opts": {"max-size": "100m"
       },
       "storage-driver": "overlay2"
     }
     EOF
     systemctl daemon-reload
     systemctl restart docker
     ```

     

   - 设置开机自启和启动

     ```shell
     systemctl enable docker && systemctl start docker
     ```

   - 查看版本

     ```shell
     docker --version
     ```

2. 安装kubeadm，kubelet和kubectl

   - 添加阿里云YUM的软件源

     ```shell
     cat > /etc/yum.repos.d/kubernetes.repo << EOF
     [kubernetes]
     name=Kubernetes
     baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
     enabled=1
     gpgcheck=0
     repo_gpgcheck=0
     gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
     EOF
     ```

   - 安装kubeadm，kubelet和kubectl(这里是指定版本号安装的)

     ```shell
     yum list kubelet kubeadm kubectl  --showduplicates|sort -r
     yum install -y kubelet-1.15.9 kubeadm-1.15.9 kubectl-1.15.9
     ```
   
   - 设置开机自启
   
     ```shell
     systemctl enable kubelet
     ```
     
   - 镜像加速：
   
     ```shell
     curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
     ```
   
     

# 5.部署Kubernetes Master(在master上执行)

```shell
kubeadm init \
--apiserver-advertise-address=192.168.1.41 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.15.9 \
--service-cidr=10.1.0.0/18 \
--pod-network-cidr=10.244.0.0/18
```

![img](https://img-blog.csdnimg.cn/2020010814064484.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

> 由于默认拉取镜像地址k8s.gcr.io国内无法访问，这里指定阿里云镜像仓库地址

![img](https://img-blog.csdnimg.cn/20200108140759201.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

- 已经初始化完成

![img](https://img-blog.csdnimg.cn/20200108140916701.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

- 使用kubectl工具：

  ```shell
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```

# 6.安装Pod网络插件

```shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

> 确保能够访问到quay.io这个registery。
>
> 如果下载失败，可以改成这个镜像地址：lizhenliang/flannel:v0.11.0-amd6
>
> 也可以去下载。然后用下面这条命令
>
> ```shell
> kubectl apply -f kube-flannel.yml
> ```
>
> ![img](https://img-blog.csdnimg.cn/20200108141559390.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

# 7.加入Kubernetes Node

- 在node上安装fannel

  ```shell
  docker pull lizhenliang/flannel:v0.11.0-amd64
  ```

  > 上面执行可能会遇到结尾这个字样的错误443: read: connection reset by peer
  >
  > - 解决方案：
  >
  > 修改docker镜像获取源文件**daemon.json**，即
  >
  > ```shell
  > vim /etc/docker/daemon.json
  > ```
  >
  > 清除原内容，copy以下：
  >
  > ```shell
  > {
  >     "registry-mirrors": ["http://hub-mirror.c.163.com",
  >         "https://docker.mirrors.ustc.edu.cn",
  >         "https://registry.docker-cn.com",
  >         "http://hub-mirror.c.163.com",
  >         "https://docker.mirrors.ustc.edu.cn"
  >         ]
  > }
  > ```
  > 
  >重启docker
  > 
  >```shell
  > systemctl restart docker
  > ```
  > 
  >再拉取镜像！
  
- 一键生成加入节点的命令

  ```shell
  kubeadm token create --print-join-command
  ```

  在node节点中执行生成的命令

  ```shell
  kubeadm join 192.168.0.160:6443 --token jyrdb4.eah9wjrt33jy96cq     --discovery-token-ca-cert-hash sha256:4b40829eb6c7a19110394fb9c5ec1290fea5e4fc5fa37a15ac6db533017c9e7f
  ```

  ![img](https://img-blog.csdnimg.cn/20200108142415759.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

- 查看Node

  ```shell
  kubectl get node
  ```

  ![img](https://img-blog.csdnimg.cn/20200108151656809.png)

  添加一下node2，命令如上。切记，先执行在node上安装flannel

  ![img](https://img-blog.csdnimg.cn/2020010815181254.png)

  已经完全准备完成

  ```shell
  kubectl get pods -n kube-system
  ```

  ![img](https://img-blog.csdnimg.cn/20200108152313199.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

# 8.测试kubernetes集群.

在Kubernetes集群中创建一个pod，验证是否正常运行

- **创建nginx容器**

  ```shell
  kubectl create deployment nginx --image=nginx
  ```

- **暴露对外端口**

  ```shell
  kubectl expose deployment nginx --port=80 --type=NodePort
  ```

-   **查看nginx是否运行成功**

  ```shell
  kubectl get pod,svc
  ```

  ![img](https://img-blog.csdnimg.cn/20200108152607842.png)

在浏览器访问。三个结点都可访问，说明集群已经搭建完成

![img](https://img-blog.csdnimg.cn/20200108152655274.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

# 9.部署Dashboard

先前已经给配置配置文件。
默认镜像国内无法访问，修改镜像地址为： lizhenliang/kubernetes-dashboard-amd64:v1.10.1
默认Dashboard只能集群内部访问，修改Service为NodePort类型，暴露到外部：

- **先下载yaml文件**

  ```shell
  wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml  
  ```

  修改文件里面如图所示

  ![img](https://img-blog.csdnimg.cn/20200108153956631.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

  ```shell
  vim recommended.yaml
  ```

  

- **执行kubernetes-dashboard.yaml 文件**

  ```shell
  kubectl apply -f recommended.yaml
  ```

安装成功

![img](https://img-blog.csdnimg.cn/2020010815404548.png)

**查看暴露的端口**

```shell
kubectl get pods -n kubernetes-dashboard -o wide
```

![img](https://img-blog.csdnimg.cn/20200108164453386.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

# 10.访问dashboard的web界面

访问地址：[https://NodeIP:30001](https://nodeip:30001/) 【必须是https】

![img](https://img-blog.csdnimg.cn/20200108164554291.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)

用这个命令生成节点加入的命令，token就在里面,这个token只能临时登录，在接下来的步骤生成永久的token

```shell
kubeadm token create --print-join-command
```

- 创建service account并绑定默认cluster-admin管理员集群角色：【依次执行】

  ```shell
  kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
  
  kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin
  
  kubectl describe secrets -n kubernetes-dashboard $(kubectl -n kubernetes-dashboard get secret | awk '/dashboard-admin/{print $1}')
  ```

  ![img](https://img-blog.csdnimg.cn/20200108164747779.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)
  
- 查看永久token

  ```shell
  kubectl get secret
  kubectl describe secret def-ns-admin-token-8vzj5
  ```

  

已经部署完成。

![img](https://img-blog.csdnimg.cn/20200108164833885.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2hlaWFuXzk5,size_16,color_FFFFFF,t_70)





# k8s存储

安装nfs

```sh
yum -y install nfs-utils
```

主节点

```sh
vim /etc/exports
添加 /data/kubernetes *(rw,no_root_squash)
systemctl start nfs
systemctl enable nfs
mkdir -p /data/kubernetes/
```

子节点

```shell
mkdir -p /data/kubernetes
mount -t nfs 192.168.1.43:/data/kubernetes /data/kubernetes
```



```shell
kubectl create -f rbac.yaml
kubectl create -f class.yaml
docker pull quay.io/external_storage/nfs-client-provisioner:latest

vi deployment.yaml
修改IP

kubectl apply -f deployment.yaml
```

-------------------------------

# ingress

```shell
kubectl apply -f ingress-controller.yaml
```

安装nginx

```shell
https://www.cnblogs.com/boonya/p/7907999.html
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_stub_status_module --with-file-aio --with-stream
```
配置4层交换

```shell
stream {
	server {
		listen 80;
		proxy_pass ingress_server80;
	}
	server {
		listen 443;
		proxy_pass ingress_server443;
	}
	upstream ingress_server80 {
		server 192.168.1.44:80;
	}
	upstream ingress_server443 {
		server 192.168.1.44:443;
	}
}
```



# metrics

kubectl apply  -f .



# promethus

修改配置

```shell
vim prometheus-configmap.yaml

kubectl apply  -f prometheus-configmap.yaml
kubectl apply  -f prometheus-rbac.yaml
kubectl apply  -f prometheus-rules.yaml
kubectl apply  -f prometheus-service.yaml
kubectl apply  -f prometheus-statefulset.yaml
kubectl apply  -f node-exporter-ds.yml
kubectl apply  -f grafana.yaml
kubectl apply  -f kube-state-metrics-rbac.yaml
kubectl apply  -f kube-state-metrics-deployment.yaml
kubectl apply  -f kube-state-metrics-service.yaml
```

# elk

```shell
kubectl apply  -f elasticsearch.yaml
kubectl apply  -f filebeat-kubernetes.yaml
kubectl apply  -f kibana.yaml

filebeat-7.3.2-*
```

# terminal

```shell
kubectl apply -f k8-deploy.yaml
```

















