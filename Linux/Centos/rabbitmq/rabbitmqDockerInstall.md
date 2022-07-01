```shell
sudo docker run -d \
--name rabbitmq \
-e RABBITMQ_DEFAULT_USER=admin \
-e RABBITMQ_DEFAULT_PASS=123456 \
-p 15672:15672 \
-p 5672:5672 \
-v /home/qyx/data/rabbitmq/data:/var/lib/rabbitmq \
rabbitmq:management
```