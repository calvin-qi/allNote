# Redis单机哨兵集群安装
## 单机redis

### docker方式安装redis

执行以下命令启动一个redis容器，需要挂载redis数据目录和配置文件到你选定的目录下，先准备好配置文件，然后再启动
```shell
sudo docker run \
-d \
--name redis \
-p 16379:6379 \
--privileged=true \
--restart unless-stopped \
-v ./data:/data \
-v ./conf/redis.conf:/etc/redis/redis.conf \
redis:6.0.6 redis-server /etc/redis/redis.conf --appendonly yes 
```

>`docker run`: 启动一个新的 Docker 容器。
`-d`: 以分离模式运行容器，后台运行。
`--name redis`: 为容器指定名称为 `redis`。
`-p 16379:6379`: 将主机的 16379 端口映射到容器的 6379 端口。
`--privileged=true`: 以特权模式运行容器，允许更高权限的操作。
`--restart unless-stopped`: 设置重启策略，除非手动停止，否则总是重启容器。
`-v ./redis/data:/data`: 将当前目录下的 `redis/data` 目录挂载到容器内的 `/data` 目录。
`-v ./redis/conf/redis.conf:/etc/redis/redis.conf`: 将当前目录下的 `redis/conf/redis.conf` 文件挂载到容器内的 `/etc/redis/redis.conf`。
`redis:6.0.6 redis-server /etc/redis/redis.conf --appendonly yes`: 使用 `redis:6.0.6` 镜像启动 Redis 服务器，指定配置文件路径，并启用持久化（append-only 模式）

docker-compose编排方式：
```yml
version: '3.8'

services:
  redis:
    image: redis:6.0.6
    container_name: redis
    ports:
      - "16379:6379"
    privileged: true
    restart: unless-stopped
    volumes:
      - ./redis/data:/data
      - ./redis/conf/redis.conf:/etc/redis/redis.conf
    command: redis-server /etc/redis/redis.conf --appendonly yes

```
> **version**: 使用的 Compose 文件版本。
> **services**: 定义服务。
> **redis**: 服务名称。
> **image**: 使用的 Redis 镜像。
> **container_name**: 容器名称。
> **ports**: 映射的端口。
> **privileged**: 设置为 `true`，以便使用特权模式。
> **restart**: 设置重启策略为 `unless-stopped`。
> **volumes**: 挂载的卷，将主机目录映射到容器内。
> **command**: 指定容器启动时执行的命令。

redis示例配置如下：

redis.conf:
```shell
protected-mode no
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
rdb-del-sync-files no
dir ./
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-diskless-load disabled
repl-disable-tcp-nodelay no
replica-priority 100
acllog-max-len 128
requirepass 123456
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
lazyfree-lazy-user-del no
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
jemalloc-bg-thread yes
```

### 离线安装单机redis

```bash
#下载
wget http://download.redis.io/releases/redis-4.0.6.tar.gz

#解压
tar -zxvf redis-6.0.2.tar.gz

#安装C++环境
yum install gcc -y

#进行编译安装
cd redis-6.0.2
make
make install

#复制配置文件到你指定的目录
mkdir /usr/local/redis
cp redis.conf /usr/local/redis/

#按需编辑配置文件
vim /usr/local/redis/redis.conf
#注释bind 127.0.0.1   修改daemonize yes为no 找到 protected-mode yes 将其改为protected-mode no

#创建一个systemd管理的配置文件，设置开机启动
vim /etc/systemd/system/redis.service
------redis.service
[Unit]
Description=The redis-server Process Manager
After=syslog.target network.target
 
[Service]
Type=simple
ExecStart=/usr/local/bin/redis-server /usr/local/redis/redis.conf         
## ExecStart=/software/redis-6.0.10/src/redis-server  --protected-mode no
## /software/redis-6.0.10/src/redis-server  /software/redis-6.0.10/redis.conf --protected-mode no 
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -SIGINT $MAINPID
 
[Install]
WantedBy=multi-user.target
------

#重新加载 systemd 管理器配置。这通常在更改了服务单元文件后使用，以便 systemd 重新读取这些文件并应用更改，而无需重启系统。
#启动redis
systemctl daemon-reload 
systemctl start redis

#查看redis运行状态，是否启动成功
systemctl status redis
```


## 哨兵redis


## Redis问题排查和调优

### 单机节点

在 Redis 的单机节点上，我们可以使用 `redis-cli` 来查看 Redis 的状态信息。Redis 提供了 `INFO` 命令，它会返回大量的状态信息，涵盖服务器、内存、持久化、客户端连接、复制、CPU 使用情况等多个方面。

假设 Redis 服务器有密码，下面是如何使用 `redis-cli` 一行命令查询 Redis 单机节点的状态，并详细解释返回的信息。

#### 1. 使用 `INFO` 命令查看 Redis 状态

假设 Redis 服务器的 IP 地址是 `127.0.0.1`，端口是 `6379`，密码是 `your_password`，我们可以使用以下命令查询 Redis 的状态：

```bash
redis-cli -h 127.0.0.1 -p 6379 -a your_password INFO
```

`INFO` 命令返回的信息按不同的部分划分，每个部分都提供了 Redis 的不同方面的详细状态。下面是每个部分的详细解释。

#### 2. `INFO` 命令的输出和详细解释

##### 1. `# Server` 部分

```bash
# Server
redis_version:6.2.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:0c1f6f9a8c4f6a92
redis_mode:standalone
os:Linux 4.15.0-142-generic x86_64
arch_bits:64
multiplexing_api:epoll
gcc_version:7.5.0
process_id:12345
run_id:3c5ae2b1f2b6c4a1c1b6f2a3f8e2b3e1c1c6e4b1
tcp_port:6379
uptime_in_seconds:86400
uptime_in_days:1
hz:10
configured_hz:10
lru_clock:1234567
executable:/usr/local/bin/redis-server
config_file:/etc/redis/redis.conf
```

解释：
- `redis_version`: 当前 Redis 服务器的版本号。
- `redis_mode`: Redis 的运行模式，`standalone` 表示单机模式。
- `os`: 运行 Redis 的操作系统信息。
- `arch_bits`: Redis 运行在 32 位还是 64 位系统上。
- `process_id`: Redis 服务器进程的 PID。
- `run_id`: Redis 实例的唯一运行 ID，通常用于复制和集群。
- `tcp_port`: Redis 正在监听的端口号。
- `uptime_in_seconds`: Redis 服务器已运行的秒数。
- `uptime_in_days`: Redis 服务器已运行的天数。
- `hz`: Redis 内部事件循环的频率，默认是 10 Hz。
- `config_file`: Redis 使用的配置文件路径。

##### 2. `# Clients` 部分

```bash
# Clients
connected_clients:10
cluster_connections:0
maxclients:10000
client_recent_max_input_buffer:2
client_recent_max_output_buffer:0
blocked_clients:0
```

解释：
- `connected_clients`: 当前连接到 Redis 服务器的客户端数量（不包括监控客户端）。
- `maxclients`: Redis 配置中允许的最大客户端连接数。
- `blocked_clients`: 正在等待阻塞命令（如 `BLPOP`、`BRPOP`）的客户端数量。

##### 3. `# Memory` 部分

```bash
# Memory
used_memory:1024000
used_memory_human:1000.00K
used_memory_rss:2048000
used_memory_peak:3072000
used_memory_peak_human:3.00M
used_memory_lua:37888
mem_fragmentation_ratio:2.00
mem_allocator:jemalloc-5.1.0
```

解释：
- `used_memory`: Redis 使用的总内存量（以字节为单位）。
- `used_memory_human`: 以人类可读的格式显示 Redis 使用的内存量（如 KB、MB）。
- `used_memory_rss`: Redis 从操作系统获取的内存总量（以字节为单位），通常比 `used_memory` 大。
- `used_memory_peak`: Redis 运行以来使用的最大内存量。
- `mem_fragmentation_ratio`: 内存碎片率，`used_memory_rss / used_memory`。如果该值大于 1，表示有内存碎片。

##### 4. `# Persistence` 部分

```bash
# Persistence
loading:0
rdb_changes_since_last_save:100
rdb_bgsave_in_progress:0
rdb_last_save_time:1620000000
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:1
rdb_current_bgsave_time_sec:-1
aof_enabled:0
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:-1
aof_current_rewrite_time_sec:-1
aof_last_bgrewrite_status:ok
aof_last_write_status:ok
```

解释：
- `loading`: 如果 Redis 正在从磁盘加载数据，`1` 表示正在加载，`0` 表示未加载。
- `rdb_changes_since_last_save`: 自上次 RDB 保存以来发生的写操作数量。
- `rdb_bgsave_in_progress`: 当前是否有 RDB 后台保存操作正在进行，`1` 表示有，`0` 表示没有。
- `rdb_last_save_time`: 上次成功保存 RDB 文件的时间戳（UNIX 时间戳）。
- `aof_enabled`: 是否启用了 AOF（Append Only File）持久化，`1` 表示启用，`0` 表示未启用。
- `aof_rewrite_in_progress`: 当前是否有 AOF 重写操作正在进行。

##### 5. `# Stats` 部分

```bash
# Stats
total_connections_received:2000
total_commands_processed:50000
instantaneous_ops_per_sec:100
total_net_input_bytes:1000000
total_net_output_bytes:2000000
rejected_connections:0
sync_full:0
sync_partial_ok:0
sync_partial_err:0
expired_keys:100
evicted_keys:10
keyspace_hits:1000
keyspace_misses:100
pubsub_channels:0
pubsub_patterns:0
latest_fork_usec:100
```

解释：
- `total_connections_received`: Redis 服务器启动以来接收的连接总数。
- `total_commands_processed`: Redis 服务器启动以来处理的命令总数。
- `instantaneous_ops_per_sec`: 每秒处理的命令数（当前）。
- `total_net_input_bytes`: Redis 服务器启动以来接收到的网络字节总数。
- `rejected_connections`: 因为客户端数量超过 `maxclients` 而被拒绝的连接数。
- `expired_keys`: 自 Redis 启动以来过期的键的数量。
- `evicted_keys`: 因为内存不足而被驱逐的键的数量。
- `keyspace_hits`: 成功查找到键的次数。
- `keyspace_misses`: 未找到键的次数。
- `latest_fork_usec`: 最近一次 fork 操作（通常用于 RDB 保存或 AOF 重写）的耗时（微秒）。

##### 6. `# Replication` 部分

对于单机 Redis 节点，`Replication` 部分的输出会显示该节点的角色和复制状态。

```bash
# Replication
role:master
connected_slaves:0
master_replid:3c5ae2b1f2b6c4a1c1b6f2a3f8e2b3e1c1c6e4b1
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```

解释：
- `role`: 当前节点的角色，`master` 表示它是主节点；如果它是从节点，则会显示 `slave`。
- `connected_slaves`: 当前连接到该节点的从节点数量。
- `master_replid`: 主节点的复制 ID。
- `repl_backlog_active`: 复制积压缓冲区是否激活。
- `repl_backlog_size`: 复制积压缓冲区的大小。
- `repl_backlog_histlen`: 复制积压缓冲区中保存的历史数据长度。

##### 7. `# CPU` 部分

```bash
# CPU
used_cpu_sys:100.50
used_cpu_user:200.50
used_cpu_sys_children:50.00
used_cpu_user_children:100.00
```

解释：
- `used_cpu_sys`: Redis 进程在内核态消耗的 CPU 时间（秒）。
- `used_cpu_user`: Redis 进程在用户态消耗的 CPU 时间（秒）。
- `used_cpu_sys_children`: Redis 后台子进程在内核态消耗的 CPU 时间（秒）。
- `used_cpu_user_children`: Redis 后台子进程在用户态消耗的 CPU 时间（秒）。

##### 8. `# Keyspace` 部分

```bash
# Keyspace
db0:keys=1000,expires=500,avg_ttl=3600
```

解释：
- `db0`: 表示数据库 0 的信息。
  - `keys`: 数据库 0 中的键的总数。
  - `expires`: 设置了过期时间的键的数量。
  - `avg_ttl`: 数据库 0 中键的平均 TTL（生存时间，毫秒）。

#### 3. 总结

通过 `INFO` 命令，你可以查看 Redis 单机节点的详细状态信息，涵盖了服务器的运行时间、内存使用情况、客户端连接数、持久化状态、复制状态、命令处理统计、CPU 使用情况和键空间状态等多个方面。

如果你有任何其他问题或需要进一步的解释，请告诉我！

### 哨兵集群   
#### 一、查询 Redis 哨兵集群的状态

Redis 哨兵集群用于监控 Redis 主从节点、执行自动故障转移和通知。为了查询 Redis 哨兵的状态，我们可以使用 `redis-cli` 连接到哨兵节点，并执行相关命令。

##### 1. 连接到哨兵节点并查询主节点信息

假设哨兵节点的 IP 是 `127.0.0.1`，端口是 `26379`，哨兵的密码是 `sentinel_password`，主节点的名称是 `mymaster`。我们可以使用以下命令查询主节点的状态：

```bash
redis-cli -h 127.0.0.1 -p 26379 -a sentinel_password SENTINEL MASTER mymaster
```

示例输出：

```bash
 1) "name"
 2) "mymaster"
 3) "ip"
 4) "192.168.0.10"
 5) "port"
 6) "6379"
 7) "runid"
 8) "3c5ae2b1f2b6c4a1c1b6f2a3f8e2b3e1c1c6e4b1"
 9) "flags"
10) "master"
11) "link-pending-commands"
12) "0"
13) "link-refcount"
14) "1"
15) "last-ping-sent"
16) "0"
17) "last-ok-ping-reply"
18) "10"
19) "last-ping-reply"
20) "10"
21) "down-after-milliseconds"
22) "5000"
23) "info-refresh"
24) "1000"
25) "role-reported"
26) "master"
27) "role-reported-time"
28) "123456789"
29) "config-epoch"
30) "1"
31) "num-slaves"
32) "2"
33) "num-other-sentinels"
34) "3"
35) "quorum"
36) "2"
37) "failover-timeout"
38) "180000"
39) "parallel-syncs"
40) "1"
```

解释：
- `name`: 主节点名称。
- `ip` 和 `port`: 主节点的 IP 地址和端口。
- `runid`: 主节点的唯一运行 ID。
- `flags`: 主节点的状态标志，`master` 表示它是主节点。
- `num-slaves`: 当前主节点的从节点数量。
- `num-other-sentinels`: 监控该主节点的其他哨兵数量。
- `quorum`: 哨兵仲裁票数，决定是否进行故障转移。
- `failover-timeout`: 故障转移的超时时间（毫秒）。

##### 2. 查询主节点的从节点信息

使用 `SENTINEL SLAVES` 命令可以查询主节点的从节点信息：

```bash
redis-cli -h 127.0.0.1 -p 26379 -a sentinel_password SENTINEL SLAVES mymaster
```

示例输出：

```bash
 1)  1) "name"
     2) "192.168.0.11:6379"
     3) "ip"
     4) "192.168.0.11"
     5) "port"
     6) "6379"
     7) "runid"
     8) "4f5ae2b1f2b6c4a1c1b6f2a3f8e2b3e1c1c6e4b1"
     9) "flags"
    10) "slave"
    11) "link-pending-commands"
    12) "0"
    13) "last-ping-sent"
    14) "0"
    15) "last-ok-ping-reply"
    16) "10"
    17) "down-after-milliseconds"
    18) "5000"
    19) "master-link-status"
    20) "ok"
    21) "master-host"
    22) "192.168.0.10"
    23) "master-port"
    24) "6379"
    25) "slave-priority"
    26) "100"
    27) "slave-repl-offset"
    28) "1234567"
```

解释：
- `name`: 从节点的名称（IP:Port）。
- `ip` 和 `port`: 从节点的 IP 和端口。
- `runid`: 从节点的唯一运行 ID。
- `flags`: 节点状态，`slave` 表示它是从节点。
- `master-link-status`: 从节点与主节点的连接状态，`ok` 表示连接正常。
- `slave-priority`: 从节点的优先级，用于故障转移时决定从节点是否有资格成为主节点。
- `slave-repl-offset`: 从节点的复制偏移量。

##### 3. 查询监控主节点的哨兵节点信息

使用 `SENTINEL SENTINELS` 命令可以查询监控主节点的其他哨兵节点的信息：

```bash
redis-cli -h 127.0.0.1 -p 26379 -a sentinel_password SENTINEL SENTINELS mymaster
```

示例输出：

```bash
 1)  1) "name"
     2) "sentinel1"
     3) "ip"
     4) "192.168.0.12"
     5) "port"
     6) "26379"
     7) "runid"
     8) "5f6ae2b1f2b6c4a1c1b6f2a3f8e2b3e1c1c6e4b1"
     9) "flags"
    10) "sentinel"
```

解释：
- `name`: 哨兵名称。
- `ip` 和 `port`: 哨兵节点的 IP 和端口。
- `runid`: 哨兵的唯一运行 ID。
- `flags`: 节点状态，`sentinel` 表示它是哨兵节点。

---

#### 二、查询 Redis 主从集群的状态

Redis 主从集群通常用于高可用性，主节点负责写操作，从节点负责读操作，并且从节点会异步复制主节点的数据。

##### 1. 查询主节点的复制状态

假设主节点的 IP 是 `127.0.0.1`，端口是 `6379`，密码是 `master_password`，我们可以使用以下命令查询主节点的复制状态：

```bash
redis-cli -h 127.0.0.1 -p 6379 -a master_password INFO replication
```

示例输出（主节点）：

```bash
# Replication
role:master
connected_slaves:2
slave0:ip=192.168.0.11,port=6379,state=online,offset=1234567,lag=0
slave1:ip=192.168.0.12,port=6379,state=online,offset=1234567,lag=0
master_replid:3c5ae2b1f2b6c4a1c1b6f2a3f8e2b3e1c1c6e4b1
master_repl_offset:1234567
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1234567
repl_backlog_histlen:0
```

解释：
- `role`: 当前节点的角色，`master` 表示它是主节点。
- `connected_slaves`: 当前连接的从节点数量。
- `slave0` 和 `slave1`: 每个从节点的 IP、端口、状态、复制偏移量和延迟（lag）。
- `master_repl_offset`: 主节点的复制偏移量。
- `repl_backlog_active`: 复制积压缓冲区是否激活。
- `repl_backlog_size`: 复制积压缓冲区的大小。
- `repl_backlog_histlen`: 复制积压缓冲区中保存的历史数据长度。

##### 2. 查询从节点的复制状态

假设从节点的 IP 是 `192.168.0.11`，端口是 `6379`，密码是 `slave_password`，我们可以使用以下命令查询从节点的复制状态：

```bash
redis-cli -h 192.168.0.11 -p 6379 -a slave_password INFO replication
```

示例输出（从节点）：

```bash
# Replication
role:slave
master_host:192.168.0.10
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:1234567
master_link_down_since_seconds:0
slave_priority:100
slave_read_only:1
connected_slaves:0
```

解释：
- `role`: 当前节点的角色，`slave` 表示它是从节点。
- `master_host` 和 `master_port`: 主节点的 IP 和端口。
- `master_link_status`: 从节点与主节点的连接状态，`up` 表示连接正常。
- `slave_repl_offset`: 从节点的复制偏移量。
- `slave_priority`: 从节点的优先级，较低的值表示在故障转移时优先成为主节点。
- `slave_read_only`: 从节点是否为只读模式，1 表示只读。

---