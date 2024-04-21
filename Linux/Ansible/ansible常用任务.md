# Ansible常用任务

## ansible -m常用命令

## ansible-playbook常用模板

1. 使用sshpass免密登录主机

    ```yml
    ---
    - name: Use sshpass no password login
      hosts: k8s
      tasks:
        - name: no password login
          shell: sshpass -p 'your_password' ssh -o StrictHostKeyChecking=no user@{{     inventory_hostname }}
    ```

2. 向 [k8s] 主机组新增 rancher 用户并设置密码为 123123

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

3. 读取服务器ip和主机名文件自动设置hostname和写入hosts文件
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
