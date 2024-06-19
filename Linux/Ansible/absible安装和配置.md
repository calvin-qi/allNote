# Ansible安装和配置

## Redhat系Linux发行版在线安装Ansible

- 安装 EPEL 仓库
  Ansible 包在 EPEL（Extra Packages for Enterprise Linux）仓库中可用，因此需要先安装 EPEL 仓库：

  ```bash
  sudo yum install epel-release -y
  ```

- 安装 Ansible
  安装 EPEL 仓库后，可以直接安装 Ansible：

  ```bash
  sudo yum install ansible -y
  ```

- 验证安装

  ```bash
  ansible --version
  ```
  
  > 你应该看到类似于以下的输出，显示 Ansible 的版本信息：
  >
  > ```bash
  > ansible 2.x.x
  > config file = /etc/ansible/ansible.cfg
  > configured module search path = Default w/o overrides
  > python version = 2.7.x (default, xxx xx xxxx,xx:xx:xx) [GCC x.x.x xxxxxxxxxx]

## Redhat系Linux发行版离线安装Ansible

首先，找一台联网的什么都没安装过的同版的linux服务器，如果你不懂的话，就一定要保证什么都没安装过，因为安装过某些软件后，已经安装了某个依赖的话，在下载你想要的软件和依赖的时候，它是不会下载服务器上已经安装过的软件包和依赖包的。

- 联网服务器上安装 yum-plugin-downloadonly

  ```bash
  sudo yum install yum-plugin-downloadonly -y
- 联网服务器上启用 EPEL 仓库
  确保 EPEL 仓库已经启用，因为 Ansible 包在 EPEL 仓库中可用：

  ```bash
  sudo yum install epel-release -y
- 联网服务器上创建一个目录来存放下载的 RPM 包

  ```bash
  mkdir ansible-download
- 联网服务器上下载 Ansible 及其依赖项

  ```bash
  sudo yum install --downloadonly --downloaddir=/path/to/ansible-download ansible

把下载好的ansible文件夹传输到离线服务器

- 在离线服务器上安装

  ```bash
  cd /path/to/ansible-download
  sudo yum localinstall *.rpm -y
  #如果有报错什么依赖的问题，使用rpm命令强制安装
  sudo rpm -ivh --force --nodeps *.rpm
- 验证安装

  ```bash
  ansible --version
  ```
  
  > 你应该看到类似于以下的输出，显示 Ansible 的版本信息：
  >
  > ```bash
  > ansible 2.x.x
  > config file = /etc/ansible/ansible.cfg
  > configured module search path = Default w/o overrides
  > python version = 2.7.x (default, xxx xx xxxx,xx:xx:xx) [GCC x.x.x xxxxxxxxxx]

## 配置Ansible

Ansible 的配置文件位于 /etc/ansible/ansible.cfg，你可以根据需要进行修改。默认情况下，Ansible 会使用 /etc/ansible/hosts 文件作为其清单文件，你可以在其中定义你的主机和组。

- 简单的主机列表
  最基本的写法是列出主机名或 IP 地址，每行一个：

  ```bash
  192.168.1.10
  192.168.1.11
  server1.example.com
  server2.example.com
- 主机别名
  为主机指定别名，可以使用 ansible_host 变量：

  ```bash
  [webservers]
  web1 ansible_host=192.168.1.10
  web2 ansible_host=192.168.1.11
- 主机变量
  为特定主机设置变量：

  ```bash
  [webservers]
  web1 ansible_host=192.168.1.10 ansible_user=root
  web2 ansible_host=192.168.1.11 ansible_user=rancher
- 组变量
  为整个组设置变量，可以在组名后添加 :vars：

  ```bash
  [webservers]
  web1 ansible_host=192.168.1.10
  web2 ansible_host=192.168.1.11
  
  [webservers:vars]
  ansible_user=admin
  ansible_port=22
- 组内分组

  ```bash
  [databases]
  db1.example.com
  db2.example.com
  
  [webservers]
  web1.example.com
  web2.example.com
  
  [production:children]
  databases
  webservers
- 动态库存
使用动态库存脚本或插件生成主机列表。动态库存脚本通常是 Python 脚本，输出 JSON 格式的数据。
- 范围表达式
  使用范围表达式定义一系列主机：

  ```bash
  [webservers]
  web[01:05].example.com
  
  #表示192.168.1.10到20之间的所有IP
  192.168.1.[10:20]
- 混合写法
  结合以上多种写法：

  ```bash
  [webservers]
  web1 ansible_host=192.168.1.10 ansible_user=admin
  web2 ansible_host=192.168.1.11 ansible_user=admin
  
  [databases]
  db1 ansible_host=192.168.1.20
  db2 ansible_host=192.168.1.21
  
  [production:children]
  webservers
  databases
  
  [production:vars]
  ansible_port=22
  ansible_user=root
- 使用 YAML 格式
  除了 INI 格式，Ansible 也支持使用 YAML 格式定义库存：

  ```YAML
  all:
    hosts:
      web1:
        ansible_host: 192.168.1.10
      web2:
        ansible_host: 192.168.1.11
    children:
      webservers:
        hosts:
          web1:
          web2:
      databases:
        hosts:
          db1:
            ansible_host: 192.168.1.20
          db2:
            ansible_host: 192.168.1.21
      production:
        children:
          webservers:
          databases:
        vars:
          ansible_port: 22
          ansible_user: root

>通过这些灵活的写法，你可以根据需要组织和管理你的主机和组。
