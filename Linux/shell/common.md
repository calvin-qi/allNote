# 常用脚本和命令

## vim系列

1. 在vim编辑器中替换字符

```bash
### vim替换字符，在命令状态下输入
%s/replicas: 2/replicas: 1/g
```
2. 脚本匹配文件中字符串，然后替换
```bash
#!/bin/bash
# 先匹配nginx.conf中的conf.d-A或者conf.d-B
if grep -q "conf\.d-A" nginx.conf; then
  # 匹配到conf.d-A，输出一条信息
  echo "当前使用的是a环境"
elif grep -q "conf\.d-B" nginx.conf; then
  # 匹配到conf.d-B，输出一条信息
  echo "当前使用的是b环境"
else
  # 没有匹配到任何一个，退出脚本
  echo "脚本出bug了，没有检测出来是哪个环境，请联系管理员"
  exit 1
fi

# 读取用户输入
read -p "请输入a按回车切换到b环境，输入b切换到b环境: " input
# 判断输入是否合法
if [ "$input" != "a" ] && [ "$input" != "b" ]; then
  echo "输入错误，请重新运行脚本。"
  exit 1
fi

# 根据输入执行替换操作
if [ "$input" == "a" ]; then
  # 用conf.d-A替换匹配到的conf.d-B
  sed -i 's/conf\.d-B/conf\.d-A/g' nginx.conf
  echo "已切换到a环境"
elif [ "$input" == "b" ]; then
  # 用conf.d-B替换匹配到的conf.d-A
  sed -i 's/conf\.d-A/conf\.d-B/g' nginx.conf
  echo "已切换到b环境"
fi

# 输出替换结果
#echo "环境切换完成"

```
3. 保留目录下设定时长的文件
```shell

```