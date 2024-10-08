# Helm常用教程

## 1. Helm常用命令

### 1.1. 初始化 Helm

在 Helm 3 中，不再需要 `helm init` 命令。Helm 3 默认使用 Kubernetes 配置文件（通常位于 `~/.kube/config`）。

### 1.2. 添加 Helm 仓库

Helm 仓库（Repository）存储了 Helm Chart。你可以添加官方的稳定仓库或自定义的仓库。

```bash
# 添加官方稳定仓库
helm repo add stable https://charts.helm.sh/stable

# 添加其他仓库，例如 Bitnami
helm repo add bitnami https://charts.bitnami.com/bitnami

# 更新仓库
helm repo update
```

### 1.3. 搜索 Chart

你可以在已添加的仓库中搜索 Chart。

```bash
helm search repo <chart-name>
# 例如，搜索 nginx
helm search repo nginx
```

### 1.4. 安装 Chart

使用 `helm install` 命令可以安装 Chart。

```bash
# 安装一个名为 my-release 的 nginx Chart
helm install my-release bitnami/nginx
```

### 1.5. 查看已安装的 Chart

使用 `helm list` 命令可以查看已安装的 Chart。

```bash
helm list
```

### 1.6. 升级 Chart

使用 `helm upgrade` 命令可以升级已安装的 Chart。

```bash
# 升级 my-release
helm upgrade my-release bitnami/nginx
```

### 1.7. 回滚 Chart

使用 `helm rollback` 命令可以回滚到之前的版本。

```bash
# 回滚 my-release 到上一个版本
helm rollback my-release 1
```

### 1.8. 删除 Chart

使用 `helm uninstall` 命令可以删除已安装的 Chart。

```bash
# 删除 my-release
helm uninstall my-release
```

### 1.9. 查看 Chart 详情

使用 `helm show` 命令可以查看 Chart 的详细信息。

```bash
# 查看 Chart 的所有信息
helm show all bitnami/nginx

# 查看 Chart 的详细信息
helm show chart bitnami/nginx

# 查看 Chart 的 README
helm show readme bitnami/nginx

# 查看 Chart 的 values 文件
helm show values bitnami/nginx
```

### 1.10. 自定义安装

在安装 Chart 时，可以通过 `--values` 或 `-f` 参数指定自定义的 values 文件，或者使用 `--set` 参数直接设置值。

```bash
# 使用自定义的 values 文件
helm install my-release -f custom-values.yaml bitnami/nginx

# 直接设置值
helm install my-release bitnami/nginx --set service.type=NodePort
```

### 1.11. 创建自己的 Chart

使用 `helm create` 命令可以创建一个新的 Chart。

```bash
# 创建一个名为 mychart 的 Chart
helm create mychart
```

### 1.12. 打包和发布 Chart

你可以打包自己的 Chart 并发布到 Helm 仓库。

```bash
# 打包 Chart
helm package mychart

# 发布到仓库（假设你已经配置好了仓库）
helm repo index ./ --url https://your-repo-url
```

### 1.13. 调试 Chart

使用 `helm lint` 命令可以检查 Chart 的语法和结构。

```bash
# 检查 Chart
helm lint mychart
```

使用 `helm template` 命令可以渲染 Chart 模板并查看生成的 Kubernetes 资源清单。

```bash
# 渲染模板并输出结果
helm template my-release mychart
```

### 1.14. 查看 Helm 帮助

使用 `helm help` 命令可以查看 Helm 的帮助信息。

```bash
helm help
```

### 1.15. 使用 Helm 插件

Helm 支持插件，你可以使用 `helm plugin` 命令来管理插件。

```bash
# 安装插件
helm plugin install <plugin-url>

# 查看已安装的插件
helm plugin list

# 卸载插件
helm plugin uninstall <plugin-name>
```

这些是 Helm 的一些基本使用教程和常用命令。通过这些命令，你可以轻松地管理 Kubernetes 应用程序。
