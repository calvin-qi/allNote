# Ansible常用任务

## ansible模块

Ansible 提供了一系列命令行工具，用于管理和自动化 IT 任务。以下是一些常用的 Ansible 命令及其解释：

### 1. `ansible`

用于在一组主机上执行单个任务。

```bash
ansible all -m ping
```

- `all`：表示所有主机。
- `-m ping`：使用 `ping` 模块检查主机是否可达。

### 2. `ansible-playbook`

用于运行 Ansible 剧本（playbook），这是 Ansible 最常用的命令之一。

```bash
ansible-playbook site.yml
```

- `site.yml`：要运行的剧本文件。

### 3. `ansible-galaxy`

用于管理 Ansible 角色和集合。

```bash
ansible-galaxy install geerlingguy.apache
```

- `install`：安装指定的角色或集合。
- `geerlingguy.apache`：角色的名称。

### 4. `ansible-vault`

用于加密和解密敏感数据，如密码和密钥。

```bash
ansible-vault encrypt secrets.yml
```

- `encrypt`：加密文件。
- `secrets.yml`：要加密的文件。

### 5. `ansible-doc`

用于查看模块的文档和示例。

```bash
ansible-doc yum
```

- `yum`：查看 `yum` 模块的文档。

### 6. `ansible-config`

用于查看和管理 Ansible 配置。

```bash
ansible-config list
```

- `list`：列出所有配置选项及其当前值。

### 7. `ansible-inventory`

用于列出和验证库存文件。

```bash
ansible-inventory --list
```

- `--list`：以 JSON 格式列出库存文件中的所有主机和组。

### 8. `ansible-pull`

用于从版本控制系统（如 Git）中拉取并执行剧本，常用于配置管理。

```bash
ansible-pull -U https://github.com/your-repo/your-playbook.git
```

- `-U`：指定要克隆的 Git 仓库 URL。

### 9. `ansible-console`

提供一个交互式命令行界面，用于执行 Ansible 命令。

```bash
ansible-console
```

进入交互式界面后，可以直接输入 Ansible 命令。

### 10. `ansible-test`

用于运行 Ansible 的测试工具，主要用于开发和测试 Ansible 本身或其插件。

```bash
ansible-test sanity
```

- `sanity`：运行代码质量检查。

### 11.`ansible-playbook`

#### ansible-playbook --check

在剧本中添加 `--check` 选项进行干运行（dry run），不会对目标主机进行实际更改。

```bash
ansible-playbook site.yml --check
```

#### ansible-playbook --diff

在剧本中添加 `--diff` 选项显示所做更改的差异。

```bash
ansible-playbook site.yml --diff
```

#### ansible-playbook --limit

限制剧本运行的主机范围。

```bash
ansible-playbook site.yml --limit webservers
```

`--limit webservers`：只在 `webservers` 组的主机上运行剧本。

#### ansible-playbook --tags

只运行带有特定标签的任务。

```bash
ansible-playbook site.yml --tags "setup,deploy"
```

`--tags "setup,deploy"`：只运行带有 `setup` 和 `deploy` 标签的任务。

#### ansible-playbook --skip-tags

跳过带有特定标签的任务。

```bash
ansible-playbook site.yml --skip-tags "cleanup"
```

`--skip-tags "cleanup"`：跳过带有 `cleanup` 标签的任务。

总结

Ansible 提供了丰富的命令行工具，涵盖了从单任务执行到复杂剧本管理、角色管理、加密、配置管理等多个方面。通过熟练掌握这些命令，你可以更高效地使用 Ansible 进行自动化任务。

## ansible -m常用命令

- 执行单条命令

  ```bash
  ansible k8s-test -m shell -a "df -h"
- 执行多条命令

  ```bash
  ansible k8s-test -m shell -a "cd /tmp; mkdir test_dir; ls -l"
- 使用多行字符串

  ```bash
  ansible k8s-test -m shell -a '|
  cd /tmp
  mkdir test_dir
  ls -l
  '
- 传输文件

  ```bash
  ansible k8s-test -m copy -a "src=/path/to/clean_logs.sh dest=/home/clean_logs.sh mode=0755"
- 使用 yum 模块安装软件包

  ```bash
  ansible all -m yum -a "name=httpd state=present" -b
  ansible 192.168.1.100 -m yum -a "name=httpd state=present" -b -i 192.168.1.100,
- 使用 service 模块操作服务

  ```bash
  ansible all -m service -a "name=httpd state=started" -b
  ansible 192.168.1.100 -m service -a "name=httpd state=started" -b -i 192.168.1.100,

## ansible-playbook常用模板

- 使用sshpass免密登录主机
   方法一：
   你可以在 hosts 文件中直接指定这些变量：

    ```bash
    [target_servers]
    target_server ansible_user=user ansible_ssh_pass=your_password
    ```

    ```yaml
    ---
    - name: Setup SSH key for passwordless login
      hosts: target_servers
      become: yes
      tasks:
        - name: Ensure the .ssh directory exists
          file:
            path: /root/{{ ansible_user }}/.ssh
            state: directory
            mode: 0700
            owner: "{{ ansible_user }}"
            group: "{{ ansible_user }}"

        - name: Copy SSH public key to target servers
          authorized_key:
            user: "{{ ansible_user }}"
            state: present
            key: "{{ lookup('file', '/root/.ssh/id_rsa.pub') }}"
    ```

    方法二：
    在 Playbook 中使用 vars 和 vars_prompt 来动态设置 ansible_user 和 ansible_ssh_pass,在执行的时候只交互输入一次用户密码

    ```yml
  ---
  - name: Ensure user is in sudoers file
    hosts: k8s-by-all
    gather_facts: no
    vars_prompt:
      - name: "target_user"
        prompt: "Enter the username for the target server"
        private: no
      - name: "root_password"
        prompt: "Enter the root password for the target server"
        private: yes
  
    tasks:
      - name: Check if target user is root
        set_fact:
          is_root_user: "{{ target_user == 'root' }}"
  
      - name: Check if target user is in sudoers
        command: "grep -E '^{{ target_user }} ALL=\\(ALL:ALL\\) NOPASSWD: ALL' /etc/  sudoers"
        register: sudoers_check
        ignore_errors: yes
        become: yes
        become_user: root
        when: not is_root_user
  
      - name: Add target user to sudoers if not present and not root
        lineinfile:
          path: /etc/sudoers
          state: present
          regexp: '^{{ target_user }} ALL=\\(ALL:ALL\\) NOPASSWD: ALL'
          line: '{{ target_user }} ALL=(ALL:ALL) NOPASSWD: ALL'
          validate: 'visudo -cf %s'
        when: not is_root_user and sudoers_check.rc != 0
        become: yes
        become_user: root
        vars:
          ansible_become_pass: "{{ root_password }}"
  
      - name: Ensure the .ssh directory exists
        file:
          path: "/home/{{ target_user }}/.ssh"
          state: directory
          mode: '0700'
          owner: "{{ target_user }}"
          group: "{{ target_user }}"
        become: yes
        become_user: "{{ target_user }}"
        when: not is_root_user
  
      - name: Ensure the .ssh directory exists for root
        file:
          path: "/root/.ssh"
          state: directory
          mode: '0700'
          owner: root
          group: root
        become: yes
        become_user: root
        when: is_root_user
  
      - name: Copy SSH public key to target servers
        authorized_key:
          user: "{{ target_user }}"
          state: present
          key: "{{ lookup('file', '/root/.ssh/id_rsa.pub') }}"
        become: yes
        become_user: "{{ target_user }}"
        when: not is_root_user
  
      - name: Copy SSH public key to root
        authorized_key:
          user: root
          state: present
          key: "{{ lookup('file', '/root/.ssh/id_rsa.pub') }}"
        become: yes
        become_user: root
        when: is_root_user
  
  
    ```

- 向 [k8s] 主机组新增 rancher 用户并设置密码为 123123

    ```yml
     ---
     - name: Add rancher user and set password
       hosts: k8s
       become: yes
       tasks:
         - name: Add rancher user
           user:
             name: rancher
             state: present
    
         - name: Set password for rancher user
           ansible.builtin.user:
             name: rancher
             password: "{{ '123123' | password_hash('sha512') }}"
    ```

- 读取服务器ip和主机名文件自动设置hostname和写入hosts文件
   准备一个ip_hostname文件，写入所有服务器信息，格式为`ip hostname`,每行一个
   这个文件需要下发到所有主机的某个路径

   ```yml
   ---
   - name: Set hostname from ip_hostname.txt
     hosts: k8s
     become: yes
     tasks:
       - name: Copy ip_hostname.txt file from local to remote
         copy:
           src: /root/ansible/ip_hostname.txt
           dest: /root/ip_hostname.txt

       - name: Get server's IP address
         set_fact:
           server_ip: "{{ ansible_ssh_host }}"
   
       - name: Read ip_hostname.txt file
         shell: cat /root/ip_hostname.txt
         register: ip_hostname_content
   
       - name: Set hostname from ip_hostname.txt
         lineinfile:
           dest: /etc/hostname
           regexp: '^{{ server_ip }} .*'
           line: '{{ item.split()[1] }}'
         with_items: "{{ ip_hostname_content.stdout_lines }}"
         when: server_ip is defined and server_ip in item.split()
   
       - name: Change hostname
         hostname:
           name: "{{ item.split()[1] }}"
         with_items: "{{ ip_hostname_content.stdout_lines }}"
         when: server_ip is defined and server_ip in item.split()

       - name: Write ip_hostname.txt content to /etc/hosts
         lineinfile:
           dest: /etc/hosts
           line: "{{ item }}"
           insertafter: EOF
         with_items: "{{ ip_hostname_content.stdout_lines }}"
   ```

   > 这个 playbook 中，我们使用 `ansible_ssh_host` 变量获取每个主机的 IP 地址，并将其存储在 `server_ip` 变量中。然后，我们根据 `ip_hostname.txt` 文件中的记录，匹配每个主机的 IP 地址，并将对应的主机名设置为主机的主机名。
