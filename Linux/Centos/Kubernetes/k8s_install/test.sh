#!/bin/bash
#!/bin/bash
master=192.168.1.101
node1=192.168.1.102
node2=192.168.1.103
passwd=dosion123456
hosts=`cat host |grep -Po "\d+\.\d+\.\d+\.\d+"`

##
echo "Begin install sshpass expect wget curl ntpdate"
yum -y install sshpass expect wget curl ntpdate >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success"
fi

##
sed -i '/StrictHostKeyChecking/a\StrictHostKeyChecking no' /etc/ssh/ssh_config
service sshd restart >/dev/null 2>&1
sleep 3

echo -e "Send install files to ${node1}"
sshpass -p ${passwd} scp -r /root/k8s_install/ root@${node1}:~/ >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success"
fi
echo -e "Send install files to ${node2}"
sshpass -p ${passwd} scp -r /root/k8s_install/ root@${node2}:~/ >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success"
fi


##
for ip in ${hosts}
do
    echo -e "IP-${ip} generating ssh-keygen ..."
    sshpass -p ${passwd} ssh root@${ip} "ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''" >/dev/null 2>&1 &
done
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success"
fi


for ip in ${hosts}
do
    echo -e "Sending id_rsa.pub to ${ip} ..."
    sshpass -p ${passwd} ssh-copy-id -i /root/.ssh/id_rsa.pub root@${ip} >/dev/null 2>&1 &
done
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success"
fi


for ip in ${hosts}
do
    {
    echo -e "IP-${ip} installing (wget curl ntpdate) ..."
    sshpass -p ${passwd} ssh root@${ip} "yum -y install wget curl ntpdate" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    echo -e "IP-${ip} closing firewalld ..."
    sshpass -p ${passwd} ssh root@${ip} "systemctl stop firewalld && systemctl disable firewalld" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    echo -e "IP-${ip} closing selinux ..."
    sshpass -p ${passwd} ssh root@${ip} "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    echo -e "IP-${ip} closing swap ..."
    sshpass -p ${passwd} ssh root@${ip} "swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    echo -e "IP-${ip} synchronizing time ..."
    sshpass -p ${passwd} ssh root@${ip} "ntpdate time.windows.com" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi
    }&
done
wait

for ip in ${hosts}
do
    {
    echo -e "IP-${ip} passes the bridged IPv4 trafficing to iptables ..."
    sshpass -p ${passwd} ssh root@${ip} "cat /root/k8s_install/k8s.conf > /etc/sysctl.d/k8s.conf" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    echo -e "IP-${ip} writing hosts ..."
    sshpass -p ${passwd} ssh root@${ip} "cat /root/k8s_install/host >> /etc/hosts" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    sshpass -p ${passwd} ssh root@${ip} "sysctl --system" >/dev/null 2>&1
    echo -e "IP-${ip} adding source of docker ..."
    sshpass -p ${passwd} ssh root@${ip} "wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    echo -e "IP-${ip} installing docker ..."
    sshpass -p ${passwd} ssh root@${ip} "yum -y install docker-ce-18.09.9-3.el7 && mkdir /etc/docker" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    sshpass -p ${passwd} ssh root@${ip} "systemctl start docker" >/dev/null 2>&1
    echo -e "IP-${ip} setting cgroup and source of docker mirror ..."
    sshpass -p ${passwd} ssh root@${ip} "cat /root/k8s_install/daemon.json > /etc/docker/daemon.json" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    echo -e "IP-${ip} rebooting docker and setting enable docker ..."
    sshpass -p ${passwd} ssh root@${ip} "systemctl daemon-reload && systemctl restart docker && sleep 3 && systemctl enable docker" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    echo -e "IP-${ip} adding source of kubernetes ..."
    sshpass -p ${passwd} ssh root@${ip} "cat /root/k8s_install/kubernetes.repo > /etc/yum.repos.d/kubernetes.repo" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi

    echo -e "IP-${ip} installing kubelet kubeadm kubectl ..."
    sshpass -p ${passwd} ssh root@${ip} "yum install -y kubelet-1.15.9 kubeadm-1.15.9 kubectl-1.15.9 && systemctl enable kubelet" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success"
    fi
    }&
done
wait

echo "success success success"
