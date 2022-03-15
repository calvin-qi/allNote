# [docker入门到实践传送门](https://yeasy.gitbook.io/docker_practice/)

# 一、镜像管理

- 列出镜像
  
  ```shell
  docker image ls
  docker images
  ```

- 删除镜像
  
  ```shell
  # 删除指定镜像
  docker rmi <镜像Id>
  #删除所有的镜像
  docker rmi -f $(docker images -qa)
  ```
  
- 导出镜像
  
  ```shelll
  # 将镜像保存为归档文件
  docker save
  ```

- 导入镜像
  
  ```shell
  docker load
  ```

# 二、Dockerfile构建镜像

Dockerfile 是一个文本格式的配 文件，用户可以使用 Dockerfile 来快速创建自定义的镜像。

Dockerfile 由一行行行命令语句组成，并且支持以＃开头的注释行.

- dockerfile常见指令
  
  ```shell
  FROM：指定基础镜像
  RUN：执行命令
  COPY：复制文件
  ADD：更高级的复制文件
  CMD：容器启动命令
  ENV：设置环境变量
  EXPOSE：暴露端口
  ```
  
  其它的指令还有ENTRYPOINT、ARG、VOLUME、WORKDIR、USER、HEALTHCHECK、ONBUILD、LABEL等等。

- 以下是一个docker实例
  
  ```shell
  FROM java:8
  MAINTAINER "jinshw"<jinshw@qq.com>
  ADD mapcharts-0.0.1-SNAPSHOT.jar mapcharts.jar
  EXPOSE 8080
  CMD java -jar mapcharts.jar
  ```

- 镜像构建
  
  ```shell
  docker build
  ```

- 镜像运行
  
  ```shell
  docker run [id]
  ```

# 三、容器

1. 容器生命周期
- 启动：启动容器有两种方式，一种是基于镜像新建一个容器并启动，另外一个是将在终止状态（stopped）的容器重新启动。
  
  ```shell
  # 新建并启动
  docker run [镜像名/镜像ID]
  # 启动已终止容器
  docker start [容器ID]
  ```

- 查看容器
  
  ```shell
  # 列出本机运行的容器
  docker ps
  # 列出本机所有的容器（包括停止和运行）
  docker ps -a
  #进入容器,其中字符串为容器ID:
  docker exec -it d27bd3008ad9 /bin/bash
  ```
  
- 停止容器
  
  ```shell
  # 停止运行的容器
  docker stop [容器ID]
  # 杀死容器进程
  docker kill [容器ID]
  #停用全部运行中的容器:
  docker stop $(docker ps -q)
  ```
  
- 重启容器
  
  ```shell
  docker restart [容器ID]
  ```

- 删除容器
  
  ```shell
  docker rm [容器ID]
  #删除全部容器：
  docker rm $(docker ps -aq)
  ```
  
- .一条命令实现停用并删除容器：

  ```shell
  docker stop $(docker ps -q) & docker rm $(docker ps -aq)
  ```
2. 进入容器
  
   进入容器有两种方式：
   
   ```shell
   # 如果从这个 stdin 中 exit，会导致容器的停止
   docker attach [容器ID]
   # 交互式进入容器
   docker exec [容器ID]
   ```
   
   进入容器通常使用第二种方式，`docker exec`后面跟的常见参数如下：
   
   － d, --detach 在容器中后台执行命令； － i, --interactive=true I false ：打开标准输入接受用户输入命令

3. 导入和导出
  
   - 导出容器
     
     ```shell
     #导出一个已经创建的容器到一个文件
     docker export [容器ID]
     ```
   
   - 导入容器
     
     ```shell
     # 导出的容器快照文件可以再导入为镜像
     docker import [路径]
     ```

4. 其它
  
   - 查看日志
     
     ```shell
     # 导出的容器快照文件可以再导入为镜像
     docker logs [容器ID]
     ```
     
     这个命令有以下常用参数 -f : 跟踪日志输出
   
   --since :显示某个开始时间的所有日志 -t : 显示时间戳 --tail :仅列出最新N条容器日志
   
   - 复制文件
     
     ```shell
     # 从主机复制到容器
     sudo docker cp host_path containerID:container_path
     # 从容器复制到主机
     sudo docker cp containerID:container_path host_path
     ```

```
curl -L https://get.daocloud.io/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

docker run -p 9996:8080 -p 50000:50000 -d  -v /data/jenkins-home:/var/jenkins_home  jenkins/jenkins:lts

```
