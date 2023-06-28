```shell
sudo docker run \
--name es \
-e  ES_JAVA_OPTS="-Xms512m -Xmx512m" \
-e "discovery.type=single-node"   \
-p 9200:9200 -p 9300:9300 \
-v /etc/localtime:/etc/localtime:ro \
-v /home/qyx/data/elasticsearch/data:/usr/share/elasticsearch/data  \
-d elasticsearch:7.9.2
```