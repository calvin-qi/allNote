#!/bin/bash
master=192.168.1.40
node1=192.168.1.41
node2=192.168.1.42
passwd=dosion123456
hosts=`cat host |grep -Po "\d+\.\d+\.\d+\.\d+"`

for ip in ${hosts}
do
    {
    echo -e "IP-${ip} installing nfs-utils ..."
    sshpass -p ${passwd} ssh root@${ip} "yum -y install nfs-utils " >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} installed nfs"
    fi
    }&
done
wait

mkdir -p /data/kubernetes
echo "/data/kubernetes *(rw,no_root_squash)" >> /etc/exports
for ip in ${hosts}
do
    {
    echo -e "IP-${ip} installing nfs-utils ..."
    sshpass -p ${passwd} ssh root@${ip} "systemctl start nfs &&  systemctl enable nfs" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---IP-${ip} enable nfs "
    fi
    }&
done
wait

for ip in ${node1} ${node2}
do
    {
    echo -e "Adding ${ip} node nfs mount ..."
    sshpass -p ${passwd} ssh root@${ip} "mkdir -p /data/kubernetes" >/dev/null 2>&1
    sshpass -p ${passwd} ssh root@${ip} "mount -t nfs 192.168.1.40:/data/kubernetes /data/kubernetes" >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo "fail"
    else
        echo "success ---Add ${ip} mount nfs"
    fi
    }&
done
wait
cd ./nfs-client
docker pull quay.io/external_storage/nfs-client-provisioner:latest
kubectl create -f rbac.yaml
kubectl create -f class.yaml
kubectl apply -f deployment.yaml

cd /root/k8s_install/ingress
kubectl apply -f ingress-controller.yaml
cd /home
yum install  -y gcc-c++
yum install -y pcre pcre-devel
yum install -y zlib zlib-devel
yum install -y openssl openssl-devel
wget -c https://nginx.org/download/nginx-1.20.0.tar.gz

tar -zxvf nginx-1.20.0.tar.gz
cd nginx-1.20.0
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_stub_status_module --with-file-aio --with-stream

make
make install
cd /usr/local/nginx/sbin/
./nginx 
rm -rf /home/nginx-1.20.0.tar.gz

cd /root/k8s_install/metrics-server
kubectl apply -f .

cd /root/k8s_install/prometheus
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

cd /root/k8s_install/elk
kubectl apply  -f elasticsearch.yaml
kubectl apply  -f filebeat-kubernetes.yaml
kubectl apply  -f kibana.yaml

cd /root/k8s_install/terminal
kubectl apply -f k8-deploy.yaml
