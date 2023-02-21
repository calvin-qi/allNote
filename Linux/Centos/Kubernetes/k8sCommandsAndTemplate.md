# k8s命令和yaml模版

## 一、命令大全

命令链接：<https://blog.csdn.net/footless_bird/article/details/125798691>
|资源类型|资源简称|
|:----|:----|
|node |no|
|namespaces |ns|
|deployment |deploy|
|ReplicaSet |rs|
|pod |po|
|service |svc|
|ingress |ing|
|DaemonSets |ds|
|StatefulSets |sts|
|ConfigMap |cm|
|PersistentVolume |pv|
|PersistentVolumeClaim |pvc|
|HorizontalPodAutoscaler |hpa|
|ComponentStatus |cs|

## 二、YAML模版

1. deployment模版

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment # deploy的名字
      labels:                # 标签
        app: nginx
    spec:
      replicas: 3            # 期望的副本数
      selector:              # 选择器
        matchLabels:
          app: nginx
      strategy:
        rollingUpdate:
          maxSurge: 25%
          maxUnavailable: 25%
        type: RollingUpdate
      template:              # 容器模板
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:latest
            imagePullPolicy: IfNotPresent
            ports:
            - containerPort: 80
              protocol: TCP
            resources:
              limits:
                cpu: "1"     #100m
                memory: 900Mi
              requests:
                cpu: "1"
                memory: 900Mi
          dnsPolicy: ClusterFirst
          hostAliases:
          - ip: "192.168.18.12"
            hostnames:
            - "kube-mysql"
            - "kube-minio"
          restartPolicy: Always
          schedulerName: default-scheduler
          securityContext: {}
          terminationGracePeriodSeconds: 30
    ```

2. service模版

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        app: kube-web
      name: kube-web
      namespace: kube
    spec:
      ports:
      - name: http-8080
        nodePort: 30583
        port: 8080
        protocol: TCP
        targetPort: 8080
      selector:
        app: kube-web
      sessionAffinity: None
      type: NodePort
    ```
3. Ingrgess模版
参考链接：<https://blog.csdn.net/zhangjunli/article/details/109049435>
