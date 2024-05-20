#!/bin/bash
master=192.168.1.40
node1=192.168.1.41
node2=192.168.1.42
passwd=dosion123456
hosts=`cat host |grep -Po "\d+\.\d+\.\d+\.\d+"`

##
echo "IP-${master} Begin install sshpass expect wget curl ntpdate ..."
yum -y install sshpass expect wget curl ntpdate >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "SUCCESS---IP-${master} install sshpass expect wget curl ntpdate"
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
    echo "success ---Send install files to ${node1}"
fi
echo -e "Send install files to ${node2}"
sshpass -p ${passwd} scp -r /root/k8s_install/ root@${node2}:~/ >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success ---Send install files to ${node2}"
fi


##
for ip in ${hosts}
do
    {
    echo -e "IP-${ip} generating ssh-keygen ..."
    sshpass -p ${passwd} ssh root@${ip} "ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ’’" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} generate ssh-keygen"
    fi
    }&
done
wait

for ip in ${hosts}
do
    {
    echo -e "Sending id_rsa.pub to ${ip} ..."
    sshpass -p ${passwd} ssh-copy-id -i /root/.ssh/id_rsa.pub root@${ip} >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---Sended id_rsa.pub to ${ip}"
    fi
    }&
done
wait


for ip in ${hosts}
do
    {
    echo -e "IP-${ip} installing (wget curl ntpdate) ..."
    sshpass -p ${passwd} ssh root@${ip} "yum -y install wget curl ntpdate" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success  IP-${ip} installed (wget curl ntpdate)"
    fi

    echo -e "IP-${ip} closing firewalld ..."
    sshpass -p ${passwd} ssh root@${ip} "systemctl stop firewalld && systemctl disable firewalld" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} closed firewalld"
    fi

    echo -e "IP-${ip} closing selinux ..."
    sshpass -p ${passwd} ssh root@${ip} "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} closed selinux"
    fi

    echo -e "IP-${ip} closing swap ..."
    sshpass -p ${passwd} ssh root@${ip} "swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} closed swap"
    fi

    echo -e "IP-${ip} synchronizing time ..."
    sshpass -p ${passwd} ssh root@${ip} "ntpdate time.windows.com" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} synchronized time"
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
        echo "success ---IP-${ip} passes the bridged IPv4 trafficing to iptables"
    fi

    echo -e "IP-${ip} writing hosts ..."
    sshpass -p ${passwd} ssh root@${ip} "cat /root/k8s_install/host >> /etc/hosts" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} writed hosts"
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
        echo "success ---IP-${ip} installed docker"
    fi

    sshpass -p ${passwd} ssh root@${ip} "systemctl start docker" >/dev/null 2>&1
    echo -e "IP-${ip} setting cgroup and source of docker mirror ..."
    sshpass -p ${passwd} ssh root@${ip} "cat /root/k8s_install/daemon.json > /etc/docker/daemon.json" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} seted cgroup and source of docker mirror"
    fi

    echo -e "IP-${ip} rebooting docker and setting enable docker ..."
    sshpass -p ${passwd} ssh root@${ip} "systemctl daemon-reload && systemctl restart docker && sleep 3 && systemctl enable docker" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} rebooted docker and seted enable docker"
    fi

    echo -e "IP-${ip} adding source of kubernetes ..."
    sshpass -p ${passwd} ssh root@${ip} "cat /root/k8s_install/kubernetes.repo > /etc/yum.repos.d/kubernetes.repo" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} added source of kubernetes"
    fi

    echo -e "IP-${ip} installing kubelet kubeadm kubectl ..."
    sshpass -p ${passwd} ssh root@${ip} "yum install -y kubelet-1.15.9 kubeadm-1.15.9 kubectl-1.15.9 && systemctl enable kubelet" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} installed kubelet kubeadm kubectl"
    fi
    }&
done
wait

echo -e "Initializing kubernetes ..."
kubeadm init --apiserver-advertise-address=${master} --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.15.9 --service-cidr=10.1.0.0/18 --pod-network-cidr=10.244.0.0/18 >/dev/null 2>&1
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success ---Initialized kubernetes"
fi

#sleep 30
mkdir -p $HOME/.kube >/dev/null 2>&1
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
echo -e "Appling flannel ..."
kubectl apply -f kube-flannel.yml >/dev/null 2>&1
sleep 30
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success ---Apply flannel"
fi

kubeadm token create --print-join-command > join
kubeadm_join=`cat join`
for ip in ${node1} ${node2}
do
    {
    echo -e "Adding ${ip} to kuberbetes cluster ..."
    sshpass -p ${passwd} ssh root@${ip} "${kubeadm_join}" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---Add ${ip} to kuberbetes cluster"
    fi
    }&
done
wait

echo "Wait a while"
sleep 90

kubectl get node

#部署dashboard
echo "Appling dashboard ..."
kubectl apply -f dashboard.yaml >/dev/null 2>&1
sleep 30
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success Apply dashboard"
fi

echo "Generating forever token"
kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard >/dev/null 2>&1
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin >/dev/null 2>&1
echo "Generating dashboard token ..."
kubectl describe secrets -n kubernetes-dashboard $(kubectl -n kubernetes-dashboard get secret | awk '/dashboard-admin/{print $1}')
kubectl describe secrets -n kubernetes-dashboard $(kubectl -n kubernetes-dashboard get secret | awk '/dashboard-admin/{print $1}') > token
if [ $? != 0 ]; then
    echo "fail"
else
    echo "success ---Generated forever token"
fi

echo "Saved token to file(name is token)"


