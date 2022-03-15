k8s删除services

```shell
kubectl delete -n local-test services jenkins
```

k8s删除Ingresses

```shell
kubectl delete -n local-test ingress jenkins
```

k8s删除Deployments

```shell
kubectl delete -n local-test deployment jenkins
```

k8s删除Pods

```shell
kubectl delete -n local-test pod jenkins-557cf6fd7f-6bdc9
```

k8s删除Replica Sets

```shell
kubectl delete -n local-test replicaset jenkins-557cf6fd7f
```

k8s删除persistentvolumeclaim

```shell
kubectl delete -n local-test persistentvolumeclaim jenkins-home
```

k8s删除secret

```shell
kubectl delete -n local-test secret jenkins-token-4m5k7
```



