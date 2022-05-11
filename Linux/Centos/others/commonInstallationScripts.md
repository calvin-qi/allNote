# 1.初始化主机

```sh
cd /home
# 关闭swap,selinux
swapoff  -a
sed -ri 's/.*swap.*/#&/' /etc/fstab
sed -i 's/enforcing/disabled/' /etc/selinux/config
setenforce 0
#将桥接的IPv4流量传递到iptables的链
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

echo '=====同步时间====='

yum install -y  ntpdate
ntpdate time.windows.com
```


# 安装JDK1.8

```shell
#将jdk源码包放在/home/software目录下
cd ~/
wget http://119.3.206.181/data/jdk-8u191-linux-x64.tar.gz
mkdir /usr/local/java
tar -zxvf jdk-8u191-linux-x64.tar.gz -C /usr/local/java
#修改配置文件(配置java环境变量)
rm -rf jdk-8u191-linux-x64.tar.gz
echo -e '
#javaJDK
export JAVA_HOME=/usr/local/java/jdk1.8.0_191
export CLASSPATH=.:JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools/jar
export PATH=$PATH:$JAVA_HOME/bin ' >> /etc/profile

#保存之后通过以下命令使修改的配置生效
source /etc/profile

#测试 JDK是否安装成功
java -version
```



# 配置hosts,关闭防火墙和Selinux

```shell
echo"------------配置免密登录------------"
ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''
yum -y install sshpass expect

echo "-------------修改/etc/ssh/ssh_config------------"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.41 "sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config && service sshd restart"

sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.42 "sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config && service sshd restart"

sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.43 "sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config && service sshd restart"


echo "--------修改hosts配置在所有节点---------------"
echo -e '192.168.1.41    master\n192.168.1.42    node1\n192.168.1.43    node2' > /etc/hosts
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.42 "echo -e '192.168.1.41    master\n192.168.1.42    node1\n192.168.1.43    node2' > /etc/hosts"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.43 "echo -e '192.168.1.41    master\n192.168.1.42    node1\n192.168.1.43    node2' > /etc/hosts"

echo "--------------在node1和node2生成ssh-keygen----------------"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.42 "ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''"

sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.43 "ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''"

echo "---------------打通ssh免密本身和其他节点------------------"
sshpass -p dosion123456 scp ~/.ssh/id_rsa.pub root@192.168.1.41:~/
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.41 "cat id_rsa.pub > ~/.ssh/authorized_keys"

sshpass -p dosion123456 scp ~/.ssh/id_rsa.pub root@192.168.1.42:~/
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.42 "cat id_rsa.pub > ~/.ssh/authorized_keys"

sshpass -p dosion123456 scp ~/.ssh/id_rsa.pub root@192.168.1.43:~/
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.43 "cat id_rsa.pub > ~/.ssh/authorized_keys"



echo "=====关闭master防火墙和Selinux====="
systemctl stop firewalld
systemctl disable firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

echo "=====关闭node1防火墙和Selinux====="
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.42 "systemctl stop firewalld && systemctl disable firewalld && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"

echo "=====关闭node2防火墙和Selinux====="
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.43 "systemctl stop firewalld && systemctl disable firewalld && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"
```

```shell
master=192.168.1.101
node1=192.168.1.102
node2=192.168.1.103
passwd=dosion123456
hosts=`cat host |grep -Po "\d+\.\d+\.\d+\.\d+"`

yum -y install sshpass expect wget curl ntpdate
sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config
service sshd restart
sleep 3
for ip in ${hosts}
do
    sshpass -p ${passwd} ssh root@${ip} "ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''"
done

for ip in ${hosts}
do
    ssh-copy-id -i /root/.ssh/id_rsa.pub root@${ip}
done

for ip in ${hosts}
do
    sshpass -p ${passwd} ssh root@${ip} "yum -y install sshpass expect wget curl ntpdate && systemctl stop firewalld && systemctl disable firewalld && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config && swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab && ntpdate time.windows.com"
done
```

