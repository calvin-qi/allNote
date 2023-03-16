
```sh
#华为预约一个端口访问两个服务
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
#http转https(xxxx替换443)
server {
        #listen 8000 ssl http2 default_server;
        listen  8000 ssl;
        #listen [::]:8000 ssl;
        server_name  integration.bjxch.gov.cn;
        ssl_certificate           /usr/local/nginx/ssl/lx-crt;
        ssl_certificate_key       /usr/local/nginx/ssl/lx-key;
        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;

        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;
        location / {
            #rewrite ^/(.*)$ https://integration.juwuye.com/bpmx/$1 permanent;
            #add_header Access-Control-Allow-Origin *;
            add_header 'Access-Control-Allow-Origin' https://integration.bjxch.gov.cn;
            add_header Access-Control-Allow-Headers X-Requested-With;
            add_header Access-Control-Allow-Methods GET,POST,OPTIONS;
            rewrite ^/(.*)$ https://integration.bjxch.gov.cn:8000/bpmx/$1 permanent;
        }
            
        #pc
        location /bpmx { 
            proxy_pass http://127.0.0.1:8080/bpmx;
            #index index.html index.htm;
            #try_files $uri $uri/ /index.html; 
            #proxy_pass http://127.0.0.1:8088/login/getBlueOauthCode.ht;
        }
        location /publiccms {
            proxy_pass http://127.0.0.1:8086;
        }

        location /include/ {
            alias /data/publiccms/web/site_1/include/;
        }
        location /integration {
            alias /data/publiccms/web/site_1/integration;
            index index.html;
            try_files $uri $uri/ /integration/index.html;
        }

        location /integration/upload/ {
            alias /data/publiccms/web/site_1/upload/;
            index index.html;
            #try_files $uri $uri/ /integration/index.html;
        }
        #location @router {
        #    rewrite ^.*$ /index.html last;
        #} 
    }
    server {
        #listen 8000 ssl http2 default_server;
        #listen [::]:8000 ssl;
        listen 8000 ssl;
        server_name integrationKX.bjxch.gov.cn;
        ssl_certificate           /usr/local/nginx/ssl/lx-crt;
        ssl_certificate_key       /usr/local/nginx/ssl/lx-key;
        #add_header 'Access-Control-Allow-Origin' *;
        add_header 'Access-Control-Allow-Headers' 'X-Requested-With';
        add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS'; 

        location / {
        }
     
        location /integration/ {
            alias /data/publiccms/web/site_1/integration;
            index index.html;
            try_files $uri $uri/ /integration/index.html;

        }

        location /integration/upload/ {
            alias /data/publiccms/web/site_1/upload/;
            index index.html;
            #try_files $uri $uri/ /integration/index.html;
        }

        location /publiccms {
            client_max_body_size 20m;
            proxy_redirect off;
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto  $scheme;
            proxy_connect_timeout 5;
            proxy_send_timeout 30;
            proxy_read_timeout 10;
            proxy_pass http://127.0.0.1:8086;
        }
    }
    

    location /oabggl {
        alias   /usr/share/nginx/oabggl;
        index  index.html index.htm;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Real-Port $remote_port;
        proxy_set_header X-Forwarded-$proxy_add_x_forwarded_for;
    }
```
