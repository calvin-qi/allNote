- 配置文件弄好之后安装etcd

  ```shell
  yum -y install etcd
  ```

- 校验状态

  ```shell
  etcdctl member list
  etcdctl cluster-health
  ```

- 
