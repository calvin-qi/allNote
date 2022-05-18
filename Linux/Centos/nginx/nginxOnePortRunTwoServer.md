
```sh
#华为预约例子
server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html/subscribe-h5;
                  try_files $uri $uri/ /subscribe-h5/index.html;
            index  index.html index.htm;
        }

        location /subscribe/ {
                  proxy_pass http://127.0.0.1:8089;
        }

              location /miniosubscribe/ {
                  proxy_pass http://127.0.0.1:9000;
              }

        location /web {
            alias  html/subscribe-web;
                  try_files $uri $uri/ /subscribe-web/index.html;
            index  index.html index.htm;
         }
        location @router {
                   rewrite ^.*$ /index.html last;
        }
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

   }

```
