# 关闭selinux,swap,防火墙

```shell
echo"------------配置免密登录------------"
ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''
yum -y install sshpass expect

echo "-------------修改/etc/ssh/ssh_config------------"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.41 "sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config && service sshd restart"

sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.42 "sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config && service sshd restart"

sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.43 "sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config && service sshd restart"


echo "--------修改hosts配置在所有节点---------------"
echo -e '192.168.1.41    k8sMaster\n192.168.1.42    k8sNode1\n192.168.1.43    k8sNode2' > /etc/hosts
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.42 "echo -e '192.168.1.41    k8sMaster\n192.168.1.42    k8sNode1\n192.168.1.43    k8sNode2' > /etc/hosts > /etc/hosts"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.43 "echo -e '192.168.1.41    k8sMaster\n192.168.1.42    k8sNode1\n192.168.1.43    k8sNode2' > /etc/hosts > /etc/hosts"

echo "--------------在node1和node2生成ssh-keygen----------------"
sshpass -p dosion123456 ssh -o "StrictHostKeyChecking no" root@192.168.1.42 "ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''"
sshpass -p dosion123456 scp ~/.ssh/id_rsa.pub root@192.168.1.103:~/
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

#

```shell
```

