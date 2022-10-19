# k8s基础

## 一.k8s由两部分组成：`master`节点和`node`节点

![20221018155701](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221018155701.png)

1. master节点：API Server、Scheduler、Controller manager、etcd

- `API Server`:
  > 所有对集群进行的查询和管理都要通过API来进行。集群内部的组件(如kubelet)也是通过Apiserver更新和同步数据到etcd中。所有模块之前并不会之间互相调用，而是通过和 API Server 打交道来完成自己那部分的工作。API Server 提供的验证和授权保证了整个集群的安全。API Server 负责和 Etcd 交互存放集群用到的运行数据。
- `Scheduler`：
  >Scheduler负责节点资源管理，接收来自kube-apiserver创建Pods的任务，收到任务后它会检索出所有符合该Pod要求的Node节点（通过预选策略和优选策略），开始执行Pod调度逻辑。调度成功后将Pod绑定到目标节点上。
- `Controller manager`:
  >controller-manager 作为 k8s 集群的管理控制中心，负责集群内 Node、Namespace、Service、Token、Replication 等资源对象的管理，使集群内的资源对象维持在预期的工作状态。
每一个 controller 通过 api-server 提供的 restful 接口实时监控集群内每个资源对象的状态，当发生故障，导致资源对象的工作状态发生变化，就进行干预，尝试将资源对象从当前状态恢复为预期的工作状态，常见的 controller 有 Namespace Controller、Node Controller、Service Controller、ServiceAccount Controller、Token Controller、ResourceQuote Controller、Replication Controller等。
- `Etcd`:
  > Kubernetes中没有用到数据库，它把关键数据都存放在etcd中，这使kubernetes的整体结构变得非常简单。在kubernetes中，数据是随时发生变化的，比如说用户提交了新任务、增加了新的Node、Node宕机了、容器死掉了等等，都会触发状态数据的变更。状态数据变更之后呢，Master上的kube-scheduler和kube-controller-manager，就会重新安排工作，它们的工作安排结果也是数据。这些变化，都需要及时地通知给每一个组件。etcd有一个特别好用的特性，可以调用它的api监听其中的数据，一旦数据发生变化了，就会收到通知。有了这个特性之后，kubernetes中的每个组件只需要监听etcd中数据，就可以知道自己应该做什么。kube-scheduler和kube-controller-manager呢，也只需要把最新的工作安排写入到etcd中就可以了，不用自己费心去逐个通知了

2. node节点：kubelet、kube-proxy、pod

- `kubelet`:
   > 运行在每个计算节点上,kubelet 组件通过 api-server 提供的接口监测到 kube-scheduler 产生的 pod 绑定事件，然后从 etcd 获取 pod 清单，下载镜像并启动容器。同时监视分配给该Node节点的 pods，周期性获取容器状态，再通过api-server通知各个组件。
  
- `kube-proxy`:
   > 首先k8s 里所有资源都存在 etcd 中，各个组件通过 apiserver 的接口进行访问etcd来获取资源信息
   kube-proxy 会作为 daemon（守护进程） 跑在每个节点上通过watch的方式监控着etcd中关于Pod的最新状态信息,它一旦检查到一个Pod资源被删除了或新建或ip变化了等一系列变动，它就立即将这些变动，反应在iptables 或 ipvs规则中，以便之后 再有请求发到service时，service可以通过ipvs最新的规则将请求的分发到pod\总结：kube-proxy和service的关系:
   Kube-proxy负责制定数据包的转发策略，并以守护进程的模式对各个节点的pod信息实时监控并更新转发规则，service收到请求后会根据kube-proxy制定好的策略来进行请求的转发，从而实现负载均衡
- `Pod`:
  > Pod是Kubernetes最基本的操作单元。一个Pod代表着集群中运行的一个进程，它内部封装了一个或多个紧密相关的容器。

上面说了那么多，可以简单总结为以下几条
1，etcd保存了整个集群的状态；
2，apiserver提供了资源操作的唯一入口，并提供认证、授权、访问控制、API注册和发现等机制；
3，controller manager负责维护集群的状态，比如故障检测、自动扩展、滚动更新等；
4，scheduler负责资源的调度，按照预定的调度策略将Pod调度到相应的机器上；
5，kubelet负责维护容器的生命周期，同时也负责Volume（CVI）和网络（CNI）的管理；
6，kube-proxy负责为Service提供cluster内部的服务发现和负载均衡；
