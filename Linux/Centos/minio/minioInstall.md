# docker安装minio

```shell
docker run  -p 9000:9000 --name minio \
 -d --restart=always \
 -e MINIO_ACCESS_KEY=admin \
 -e MINIO_SECRET_KEY=siqikeji \
 -v /data/minio/data:/data \
 -v /data/minio/config:/root/.minio \
  minio/minio server /data  --console-address ":9000" --address ":9090"
```