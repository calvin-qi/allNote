# k8s部署项目

## 1.制作镜像

- 基础镜像
- 服务镜像
- 项目镜像

## 2.控制器管理pod

- Deployment:无状态部署，例如web,微服务，API
- StatefulSet:有状态部署,例如数据库，zookpeer,ETCD
- DaemonSet:守护进程部署，例如监控Agent，日志Agent
- Job&CronJob:批处理,例如数据库备份，邮件通知



## 3. Pod数据持久化

容器部署过程中一般有一下三种数据：

- 启动时需要的==初始数据==

- 启动过程中产生的==临时数据==，该临时数据需要多个容器间共享

- 启动过程中产生的==业务数据==

  ![image-20211227110010461](https://gitee.com/calvinqi/typoraPic/raw/main/typora/image-20211227110010461.png)

## 4.暴露应用

Service

- service定义了pod的逻辑集合和访问这个集群的策略

- service引入了为了解决pod的动态变化，提供服务发现和负载均衡

- 使用CoreDNS解析service名称

  ![image-20211227110327995](https://gitee.com/calvinqi/typoraPic/raw/main/typora/image-20211227110327995.png)



## 5.对外发布应用

使用Ingress对外暴露应用

- 通过service关联pod

- 基于域名访问

- 通过IngressController实现pod的负载均衡

- 支持TCP/UDP4层和HTTP7层

  ![image-20211227110601120](https://gitee.com/calvinqi/typoraPic/raw/main/typora/image-20211227110601120.png)

## 6.日志/监控





## 7.传统部署与k8s部署的区别

- 传统部署

  ![image-20211227110957122](../../AppData/Roaming/Typora/typora-user-images/image-20211227110957122.png)

- k8s部署

  ![image-20211227111323404](https://gitee.com/calvinqi/typoraPic/raw/main/typora/image-20211227111323404.png)

---------------------

## 7.部署案例

![image-20211227144542911](https://gitee.com/calvinqi/typoraPic/raw/main/typora/image-20211227144542911.png)

1. Java项目

   安装java-1.8.0-openjdk maven

   `yum install java-1.8.0-openjdk maven -y`

   进入项目进行编译
   
   ```shell
   mvn clean package -Dmaven.test.skip=true
   ```
   
2. 构建镜像
  
  ```shell
  docker build -t java-demo:v1 .
  ```
  
  给镜像打标签
  
  ```shell
  docker tag java-demo:v1 192.168.1.43:8080/demo/java-demo:v1
  ```
  
  登录镜像仓库用secret，以后就不用手动登录了
  
  ```shell
  kubectl create secret docker-registry docker-auth --docker-username=admin --docker-password=qyx54321 --docker-server=192.168.1.43:8080
  ```
  
  推送到harbor镜像仓库(先登录)
  
  ```shell
  docker push 192.168.1.43:8080/demo/java-demo:v1
  ```
  
3. 部署

  生成一个deployment.yaml

  ```shell
  kubectl create deployment java-demo --image=192.168.1.43:8080/demo/java-demo:v1 -o yaml --dry-run > java-demo.yaml
  ```

  

   

   

   