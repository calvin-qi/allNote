# k8s部署kube-prometheus

## 准备工作

1. 下载kube-prometheus yaml文件

    ```sh
    git clone -b release-0.12 https://github.com/prometheus-operator/kube-prometheus.git
    ```

2. 修改镜像地址，国内无法下载`quay.io` `k8s.gcr.io`等仓库镜像
   代替源

    ```sh
    docker.io       docker.m.daocloud.io
    gcr.io          gcr.m.daocloud.io
    ghcr.io         ghcr.m.daocloud.io
    k8s.gcr.io      k8s-gcr.m.daocloud.io
    registry.k8s.io k8s.m.daocloud.io
    quay.io         quay.m.daocloud.io
    ```

    修改`kube-prometheus/manifests`里所有的镜像地址

    ```sh
    cd kube-prometheus/manifests
    sed -i "s#quay.io#quay.m.daocloud.io#g" *.yaml
    sed -i "s#k8s.gcr.io#k8s-gcr.m.daocloud.io#g" *.yaml
    sed -i "s#registry.k8s.io#k8s.m.daocloud.io#g" *.yaml
    ```

## 开始安装

1. 安装命令：

    ```sh
    kubectl create ns monitoring
    
    kubectl create -f kube-prometheus/manifests/setup
    
    # 待前面的容器启动后执行
    kubectl create -f kube-prometheus/manifests

    # 查看pod全部running则安装完成
    kubectl get pod -n monitoring
    ```

2. 用两种方式访问grafana
   - 第一种：用ingress方式访问
   创建一个gafana_ingress.yaml

   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: grafana-ingress
     namespace: monitoring  # 确保在正确的命名空间中创建Ingress
   spec:
     rules:
     - host: grafana.walkdusk.com  # 替换为你的域名
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: grafana
               port:
                 number: 3000
   ```

   - 第二种：NodePort方式访问
  新建一个service或者在原有service上修改

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: grafana-web
     namespace: monitoring
   spec:
     externalTrafficPolicy: Cluster
     internalTrafficPolicy: Cluster
     ipFamilies:
       - IPv4
     ipFamilyPolicy: SingleStack
     ports:
       - name: http
         nodePort: 31030
         port: 80
         protocol: TCP
         targetPort: 3000
     selector:
       app.kubernetes.io/component: grafana
       app.kubernetes.io/name: grafana
       app.kubernetes.io/part-of: kube-prometheus
     sessionAffinity: None
     type: NodePort
   ```
