```
tags:nginx
```
### 修改nginx对于上传文件大小的限制
<!--more-->
```sh
server {
        listen 80;
        listen [::]:80;
        server_name 65.49.***.**;
        passenger_enabled on;
        rails_env    staging;
        root     /home/deploy/other/current/public;
        client_max_body_size 1000M;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
           root html;
        }
```

#### 然后重启服务器

```sh
user@ubuntu: #service nginx restart
```

