# Kubeadm安装k8s1.24版本

## 主机初始化

1.主机准备

| hostname    | ip             | os        | role                       |
| ----------- | -------------- | --------- | -------------------------- |
| k8s-master | 192.168.122.11 | centos7.9 | controlplane、worker、etcd |
| k8s-node1   | 192.168.122.10 | centos7.9 | worker                     |

2. 修改每台节点hostname

```
# 修改 hosts 配置
hostnamectl set-hostname <hostname>
```

3. 写入hosts映射
每台主机配置所有hosts

```shell
cat >> /etc/hosts << EOF
192.168.122.11 k8s-master
192.168.122.10 k8s-node1
EOF
```

4. 关闭防火墙和selinux和swap

```
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭selinux
# 永久
sed -i 's/enforcing/disabled/' /etc/selinux/config  
# 临时
setenforce 0  

# 关闭swap
# 临时
swapoff -a  
# 永久# 
sed -ri 's/.*swap.*/#&/' /etc/fstab    
```

5. 部署基础软件

```shell
yum -y install lrzsz vim gcc glibc openssl openssl-devel net-tools wget curl telnet ipset ipvsadm
```

6. 内核参数优化

```shell
cat >> /etc/sysctl.conf <<EOF
vm.swappiness=0
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.neigh.default.gc_thresh1=4096
net.ipv4.neigh.default.gc_thresh2=6144
net.ipv4.neigh.default.gc_thresh3=8192
EOF

# 在内核中加载模块
modprobe br_netfilter 
sysctl -p
```

7. 设置文件打开限制

```shell
cat >> /etc/security/limits.conf <<EOF
root soft nofile 65535
root hard nofile 65535
* soft nofile 65535
* hard nofile 65535
EOF
```

8. 设置ipvs内核模块

```shell
#3.x内核用下面这个
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

#5.x内核用这个，高版本内核已经把nf_conntrack_ipv4替换为nf_conntrack
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

9. 设置ssh tcp传输

```shell
sed -i 's/^#\(AllowTcpForwarding yes\)/\1/' /etc/ssh/sshd_config
systemctl restart sshd
```

10. 时间同步

```shell
yum install -y ntpdate 
ntpdate time.windows.com
```
## K8s初始化
1. Master节点初始化
   ```
   kubeadm init --cri-socket unix:///var/run/cri-dockerd.sock --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/16 --kubernetes-version=1.24.8
   ```