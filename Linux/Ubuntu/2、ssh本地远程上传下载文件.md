# ssh本地远程上传下载文件

## 1.上传文件到服务器

scp /path/fileName userName@serverName:/path
例：scp /opt/demo.txt root@140.141.3.192:/usr/local/
把opt文件夹下的demo.txt文件上传到140.141.3.192服务器的/usr/local文件夹下

++++直接把文件/文件夹拖进终端可以得到文件/文件夹路径++++
++++上传/下载文件夹后面一般带/++++

--------------------------------------------------------------------



## 2.上传文件夹到服务器

```scp -r /path/folderName userName@serverName:/path/```
例：scp -r /usr/bin/ root@140.141.3.192:/usr/local/  

把usr文件夹下的bin文件夹上传到140.141.3.192服务器的/usr/local文件夹下

-----------------------



## 3.从服务器上下载文件

```scp userName@serverName:/path/fileName /path/```
例：scp root@140.141.3.192:/usr/local/demo.txt /opt/
把140.141.3.192服务器/usr/local文件夹下的demo.txt文件下载到本地的opt文件夹下

-----------------



## 4.从服务器上下载整个文件夹

```scp -r userName@serverName:/path/folderName/ /path/```
例：scp -r root@140.141.3.192:/usr/local/bin/ /opt/
把140.141.3.192服务器/usr/local文件夹下的bin文件夹下载到本地的opt文件夹下