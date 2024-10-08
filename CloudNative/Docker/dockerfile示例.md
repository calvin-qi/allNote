# Dockerfile示例

## Java springboot项目dockerfile
```dockerfile
FROM registry.bsoft.com.cn/ssdev/openjdk:1.8.362
MAINTAINER bsoft
# 将jar包添加到容器中并更名为app.jar
ARG APP_NAME
ADD ./target/$APP_NAME.jar /app.jar

# JAVA参数，如-Xmx8g
ENV JAVA_OPTS="-Xmx4g"d

# OPS参数，如 -Dskywalking.agent.service_name=hhis-core-app  -Dskywalking.collector.backend_service=0.0.0.0:80 \
ENV OPS_OPTS=""

# SPRING-BOOT参数，如--spring.config.location=/config/ --spring.config.additional-location=/global-config/
ENV BOOT_OPTS=""
# profile
#ENV profile=""

# 运行jar包
CMD ["/bin/sh",\
            "-c",\
            "java \
 ${JAVA_OPTS} \
 ${OPS_OPTS} \
 -jar /app.jar \
 --spring.profiles.active=${profile:-dev} \
 ${BOOT_OPTS}"]
```
```dockerfile
# 使用 JDK8 作为基础镜像
FROM openjdk:8-jdk

# 设置工作目录
WORKDIR /app

# 将本地的 JAR 文件复制到容器中的 /app 目录
COPY ./target/ruoyi-admin.jar /app/app.jar

# 暴露 Spring Boot 应用的端口
EXPOSE 8080

# 容器启动时运行的命令
CMD ["java", "-jar", "app.jar"]

```