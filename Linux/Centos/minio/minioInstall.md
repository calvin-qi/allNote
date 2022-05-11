# docker安装minio

```shell
docker run  -p 9000:9000 --name minio \
 -d --restart=always \
 -e MINIO_ACCESS_KEY=dosion \
 -e MINIO_SECRET_KEY=dosion123456 \
 -v /data/minio/data:/data \
 -v /data/minio/config:/root/.minio \
  minio/minio server /data  --console-address ":9000" --address ":9090"
```