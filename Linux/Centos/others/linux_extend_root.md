# 在 CentOS 7 中将新磁盘格式化为 LVM 并用于扩大根分区

## 步骤

1. **查看新磁盘**

    使用 `lsblk` 或 `fdisk -l` 命令查看所有的磁盘和分区：

    ```bash
    lsblk
    ```

    或

    ```bash
    fdisk -l
    ```

    假设新磁盘是 `/dev/sdb`。

2. **创建物理卷**

    使用 `pvcreate` 命令将新磁盘格式化为 LVM 可以使用的物理卷：

    ```bash
    sudo pvcreate /dev/sdb
    ```

3. **查看现有的卷组**

    使用 `vgdisplay` 命令查看现有的卷组：

    ```bash
    sudo vgdisplay
    ```

    假设卷组名为 `centos`。

4. **将物理卷添加到卷组**

    使用 `vgextend` 命令将物理卷加入到现有的卷组：

    ```bash
    sudo vgextend centos /dev/sdb
    ```

5. **查看扩容情况**

    使用 `vgdisplay` 命令查看卷组现在是否有更多的可用空间：

    ```bash
    sudo vgdisplay
    ```

6. **查看逻辑卷**

    使用 `lvdisplay` 命令查看逻辑卷，找到你想要扩大的逻辑卷的名称：

    ```bash
    sudo lvdisplay
    ```

    假设逻辑卷是 `/dev/centos/root`。

7. **扩大逻辑卷**

    使用 `lvextend` 命令扩大逻辑卷。例如，如果你想要使用所有的剩余空间：

    ```bash
    sudo lvextend -l +100%FREE /dev/centos/root
    ```

8. **调整文件系统大小**

    最后，你需要调整文件系统的大小，以便它可以使用新的空间。这取决于你的文件系统类型：

    - 对于 XFS 文件系统（CentOS 7 默认），使用 `xfs_growfs` 命令：

        ```bash
        sudo xfs_growfs /dev/centos/root
        ```

    - 对于 EXT4 文件系统，使用 `resize2fs` 命令：

        ```bash
        sudo resize2fs /dev/centos/root
        ```

9. **确认扩容成功**

    使用 `df -h` 命令，你可以看到 `/` 分区现在有更多的可用空间：
