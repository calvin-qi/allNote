# rabbitmq部署

## docker部署方式

```shell
sudo docker run -d \
--name rabbitmq \
-e RABBITMQ_DEFAULT_USER=admin \
-e RABBITMQ_DEFAULT_PASS=123456 \
-p 15672:15672 \
-p 5672:5672 \
-v /data/rabbitmq/data:/var/lib/rabbitmq \
rabbitmq:latest

# 如果不加-e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=123456参数，则默认用户密码为guest guest

# 启用management插件，容器启动后执行命令
docker exec rabbitmq rabbitmq-plugins enable rabbitmq_management
# 如果使用rabbitmq:management镜像，则不需要执行上条命令

# 如果添加其它插件支持，则挂载相应的插件到容器的/plugins下面，例：
-v /data/rabbitmq/rabbitmq_delayed_message_exchange-3.9.0.ez:/plugins/rabbitmq_delayed_message_exchange-3.9.0.ez
# 然后执行启用插件命令命令
docker exec rabbitmq rabbitmq-plugins enable rabbitmq_delayed_message_exchange
```

## docker-compose部署方式

docker-compose.yml文件内容

```yml
version: '3'

services:
  rabbitmq:
    image: rabbitmq:latest
    container_name: rabbitmq
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - /data/rabbitmq/rabbitmq_delayed_message_exchange-3.9.0.ez:/plugins/rabbitmq_delayed_message_exchange-3.9.0.ez
      - /data/rabbitmq/data:/var/lib/rabbitmq
    environment:
      RABBITMQ_PLUGINS: "rabbitmq_delayed_message_exchange rabbitmq_management"
```

> 使用`docker-compose up -d`启动容器成功后
> 执行`docker exec rabbitmq rabbitmq-plugins enable rabbitmq_management`启用management插件
> 如果使用`rabbitmq:management`镜像，默认有management插件，则不用执行启用rabbitmq_management插件命令
> 挂载了其它插件比如`rabbitmq_delayed_message_exchange`则执行`docker exec rabbitmq rabbitmq-plugins enable rabbitmq_delayed_message_exchange`

## rabbitmq常用命令

```bash
# 启动 RabbitMQ 服务：
rabbitmq-server

#启动 RabbitMQ 服务（后台运行）：
rabbitmq-server -detached

#停止 RabbitMQ 服务：
rabbitmqctl stop

#检查 RabbitMQ 服务状态：
rabbitmqctl status

#启用插件：
rabbitmq-plugins enable plugin_name

#禁用插件：
rabbitmq-plugins disable plugin_name

#列出已启用的插件：
rabbitmq-plugins list --enabled

#查看 RabbitMQ 节点信息：
rabbitmqctl node_health_check

#重置 RabbitMQ 节点（停止并重新启动 RabbitMQ 服务）：
rabbitmqctl reset

#查看队列列表：
rabbitmqctl list_queues

#查看交换机列表：
rabbitmqctl list_exchanges

#查看绑定列表：
rabbitmqctl list_bindings

#创建用户：
rabbitmqctl add_user username password

#删除用户：
rabbitmqctl delete_user username

#授予用户角色：
rabbitmqctl set_user_tags username tag

#为用户设置权限：
rabbitmqctl set_permissions -p vhostname username ".*" ".*" ".*"
```
