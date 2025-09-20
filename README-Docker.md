# AnyRouter 自动签到 Docker 部署指南

本文档说明如何使用 Docker 容器运行 AnyRouter 自动签到脚本。

## 快速开始

### 1. 构建镜像

```bash
docker build -t anyrouter-checkin .
```

### 2. 基本运行

```bash
# 运行一次签到
docker run --rm \
  -e ANYROUTER_ACCOUNTS='[{"cookies":{"session":"your_session"},"api_user":"your_api_user"}]' \
  anyrouter-checkin

# 定时运行 (每6小时)
docker run -d \
  --name anyrouter-checkin \
  -e ANYROUTER_ACCOUNTS='[{"cookies":{"session":"your_session"},"api_user":"your_api_user"}]' \
  anyrouter-checkin schedule
# 案例
docker run -d \
  --name anyrouter-checkin \
  -e ANYROUTER_ACCOUNTS='[{"cookies":{"session":"MTc1ODIwNTI5OXxEWDhFQVFMX2dBQUJFQUVRQUFEXzRfLUFBQWNHYzNSeWFXNW5EQW9BQ0hWelpYSnVZVzFsQm5OMGNtbHVad3dQQUExc2FXNTFlR1J2WHpnd016azRCbk4wY21sdVp3d0dBQVJ5YjJ4bEEybHVkQVFDQUFJR2MzUnlhVzVuREFnQUJuTjBZWFIxY3dOcGJuUUVBZ0FDQm5OMGNtbHVad3dIQUFWbmNtOTFjQVp6ZEhKcGJtY01DUUFIWkdWbVlYVnNkQVp6ZEhKcGJtY01CUUFEWVdabUJuTjBjbWx1Wnd3R0FBUndlRE5CQm5OMGNtbHVad3dOQUF0dllYVjBhRjl6ZEdGMFpRWnpkSEpwYm1jTURnQU1lRGh6UWtsQ2JEWldObVpqQm5OMGNtbHVad3dFQUFKcFpBTnBiblFFQlFEOUFuUWN8iPnE2dzX-5xawFl-fNMkv8uU79BXmBWDi1AQM7HVUkQ="},"api_user":"80398"},{"cookies":{"session":"MTc1ODIwNTczOHxEWDhFQVFMX2dBQUJFQUVRQUFEX3hQLUFBQVlHYzNSeWFXNW5EQWdBQm5OMFlYUjFjd05wYm5RRUFnQUNCbk4wY21sdVp3d0hBQVZuY205MWNBWnpkSEpwYm1jTUNRQUhaR1ZtWVhWc2RBWnpkSEpwYm1jTURRQUxiMkYxZEdoZmMzUmhkR1VHYzNSeWFXNW5EQTRBREV0QmNXVjRNamRyWWtseWN3WnpkSEpwYm1jTUJBQUNhV1FEYVc1MEJBUUFfcTE4Qm5OMGNtbHVad3dLQUFoMWMyVnlibUZ0WlFaemRISnBibWNNRGdBTVoybDBhSFZpWHpJeU1qQTJCbk4wY21sdVp3d0dBQVJ5YjJ4bEEybHVkQVFDQUFJPXwUIYQlESu96mfWYV9SSKMyj-CjNvxYKk3UFYEjha3KDA=="},"api_user":"22206"}]' \
  -e WEIXIN_WEBHOOK='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=45548262-1f73-40a9-a33f-eba95e934082' \
  wwwzhouhui569/anyrouter-checkin schedule
```

## 使用 Docker Compose

### 1. 创建环境变量文件

创建 `.env` 文件：

```bash
# 必填：账号配置
ANYROUTER_ACCOUNTS=[{"cookies":{"session":"your_session"},"api_user":"your_api_user"}]

# 可选：通知配置
DINGDING_WEBHOOK=https://oapi.dingtalk.com/robot/send?access_token=xxx
EMAIL_USER=your_email@example.com
EMAIL_PASS=your_password
EMAIL_TO=recipient@example.com
PUSHPLUS_TOKEN=your_pushplus_token
SERVERPUSHKEY=your_server_pushkey
FEISHU_WEBHOOK=https://open.feishu.cn/open-apis/bot/v2/hook/xxx
WEIXIN_WEBHOOK=https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx
```

### 2. 启动服务

```bash
# 定时运行服务
docker-compose up -d

# 运行一次签到
docker-compose --profile once up anyrouter-checkin-once

# 查看日志
docker-compose logs -f
```

## 容器运行模式

### 1. 签到模式 (默认)

```bash
# 运行一次签到
docker run --rm anyrouter-checkin checkin

# 或者 (默认行为)
docker run --rm anyrouter-checkin
```

### 2. 定时模式

```bash
# 每6小时运行一次 (默认)
docker run -d anyrouter-checkin schedule

# 自定义间隔 (秒)
docker run -d anyrouter-checkin schedule 3600  # 每小时
```

### 3. 通知模式

```bash
# 发送测试通知
docker run --rm \
  -e EMAIL_USER=your_email@example.com \
  -e EMAIL_PASS=your_password \
  -e EMAIL_TO=recipient@example.com \
  anyrouter-checkin notify "测试标题" "测试内容" text
```

### 4. 测试模式

```bash
# 健康检查
docker run --rm anyrouter-checkin test
```

### 5. 交互模式

```bash
# 进入容器 shell
docker run -it anyrouter-checkin shell
```

## 环境变量配置

### 必填变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `ANYROUTER_ACCOUNTS` | 账号配置 (JSON数组) | `[{"cookies":{"session":"xxx"},"api_user":"12345"}]` |

### 可选通知变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `EMAIL_USER` | 发件人邮箱 | `sender@example.com` |
| `EMAIL_PASS` | 邮箱密码/授权码 | `your_password` |
| `EMAIL_TO` | 收件人邮箱 | `recipient@example.com` |
| `DINGDING_WEBHOOK` | 钉钉机器人 Webhook | `https://oapi.dingtalk.com/robot/send?access_token=xxx` |
| `FEISHU_WEBHOOK` | 飞书机器人 Webhook | `https://open.feishu.cn/open-apis/bot/v2/hook/xxx` |
| `WEIXIN_WEBHOOK` | 企业微信机器人 Webhook | `https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx` |
| `PUSHPLUS_TOKEN` | PushPlus Token | `your_pushplus_token` |
| `SERVERPUSHKEY` | Server酱 SendKey | `your_server_pushkey` |

## 多账号配置示例

```json
[
  {
    "cookies": {
      "session": "account1_session_value"
    },
    "api_user": "account1_api_user_id"
  },
  {
    "cookies": {
      "session": "account2_session_value"
    },
    "api_user": "account2_api_user_id"
  }
]
```

## 日志查看

```bash
# 查看容器日志
docker logs anyrouter-checkin

# 实时跟踪日志
docker logs -f anyrouter-checkin

# 使用 docker-compose
docker-compose logs -f
```

## 故障排除

### 1. 容器健康检查

```bash
# 检查容器状态
docker ps

# 运行健康检查
docker run --rm anyrouter-checkin test
```

### 2. 调试模式

```bash
# 进入容器调试
docker run -it anyrouter-checkin shell

# 在容器内手动运行
uv run python checkin.py
```

### 3. 常见问题

**问题1**: Playwright 浏览器下载失败
```bash
# 重新构建镜像
docker build --no-cache -t anyrouter-checkin .
```

**问题2**: 权限问题
```bash
# 检查文件权限
docker run --rm anyrouter-checkin shell -c "ls -la"
```

**问题3**: 环境变量未生效
```bash
# 检查环境变量
docker run --rm anyrouter-checkin shell -c "env | grep ANYROUTER"
```

## 生产环境部署

### 1. 使用 Docker Compose

```yaml
version: '3.8'
services:
  anyrouter-checkin:
    image: anyrouter-checkin:latest
    container_name: anyrouter-checkin
    restart: unless-stopped
    environment:
      - ANYROUTER_ACCOUNTS=${ANYROUTER_ACCOUNTS}
      # 添加其他通知配置...
    command: schedule 21600  # 6小时间隔
    healthcheck:
      test: ["CMD", "./entrypoint.sh", "test"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
```

### 2. 使用 Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: anyrouter-checkin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: anyrouter-checkin
  template:
    metadata:
      labels:
        app: anyrouter-checkin
    spec:
      containers:
      - name: anyrouter-checkin
        image: anyrouter-checkin:latest
        command: ["./entrypoint.sh", "schedule", "21600"]
        env:
        - name: ANYROUTER_ACCOUNTS
          valueFrom:
            secretKeyRef:
              name: anyrouter-config
              key: accounts
        # 添加其他环境变量...
```

## 安全注意事项

1. **环境变量安全**: 账号信息包含敏感数据，建议使用 Docker secrets 或 Kubernetes secrets
2. **网络安全**: 容器不需要暴露端口，确保网络配置正确
3. **镜像安全**: 定期更新基础镜像，扫描安全漏洞
4. **用户权限**: 容器内使用非 root 用户运行

## 更新和维护

```bash
# 更新镜像
docker build -t anyrouter-checkin:latest .

# 重启服务
docker-compose down && docker-compose up -d

# 清理旧镜像
docker image prune -f
```