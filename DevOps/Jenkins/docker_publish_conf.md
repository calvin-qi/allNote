# jenkins自动化构建发布docker项目

## 一、配置jdk maven nodejs

安装后jenkins，选择默认安装插件，然后再安装“SSH”“NodeJS ”插件
系统管理-->系统配置里面配
![20221208144152](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208144152.png)
![20221208144234](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208144234.png)
系统管理-->全局工具配置
![20221208144456](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208144456.png)
![20221208144543](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208144543.png)
![20221208144606](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208144606.png)

## 二、项目配置

添加自由风格项目

1. 参数化构建项目
![20221208145048](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208145048.png)
2. 添加git项目地址
![20221208145303](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208145303.png)
3. 构建步骤
   3.1 前端
   选择nodejs
   ![20221208145434](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208145434.png)
   构建推送镜像
   ![20221208145553](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208145553.png)
   执行ssh脚本
   ![20221208145642](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208145642.png)
   3.2 后端
   打包
   ![20221208150522](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208150522.png)
   构建推送镜像
   ![20221208150614](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208150614.png)
   执行shell脚本
   ![20221208150656](https://calvinqi.oss-cn-beijing.aliyuncs.com/images/allnote/20221208150656.png)

## 三、涉及的脚本

vue项目打包

```shell
npm install
npm run build[:prod]
```

java项目打包

```shell
clean
package
-Dmaven.skip.test=true
```

构建推动镜像

```shell
sudo docker login -u xuandong -p Xuandong123 39.99.129.221:81
sudo docker build -f ./Dockerfile -t 39.99.129.221:81/xdspringcloud/xd-ui:${dockerImageVersion} .
sudo docker push 39.99.129.221:81/xdspringcloud/xd-ui:${dockerImageVersion}
```

运行容器（先判断容器是否存在，然后停止删除，运行新容器）

```shell
#查询容器是否存在，存在则删除
# 容器id
containerId=$(docker ps -a | grep -w ${containerName} | awk '{print $1}')
if [ "$containerId" != "" ] ;
then
  #停掉容器
  docker stop "$containerId"
  echo "容器${containerName}已停止"
  #删除容器
  docker rm "$containerId"
  echo "容器${containerName}已删除"
fi

#查询镜像是否存在，存在则删除
# 镜像id
imageId=$(docker images | grep -w ${containerName} | awk '{print $3}')
if [ "$imageId" != "" ] ;
then
  #删除镜像
  docker rmi -f "$imageId"
fi

docker run -itd --name xd-ui -p 80:80 -v /data/xdspringcloud/nginx/nginx.conf:/etc/nginx/nginx.conf --network xd --network-alias xd-ui 39.99.129.221:81/xdspringcloud/xd-ui:${dockerImageVersion}
sleep 3
if [ "$containerId" != "" ] ;then
  echo "${containerName}已成功运行"
else
  echo "${containerName}运行失败"
fi
```
