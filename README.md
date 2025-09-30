# Any Router 多账号自动签到

推荐搭配使用[Auo](https://github.com/millylee/auo)，支持任意 Claude Code Token 切换的工具。

**维护开源不易，如果本项目帮助到了你，请帮忙点个 Star，谢谢!**

用于 Claude Code 中转站 Any Router 多账号每日签到，一次 $25，限时注册即送 100 美金，[点击这里注册](https://anyrouter.top/register?aff=6M0B)。业界良心，支持 Claude Code 百万上下文（使用 `/model sonnet[1m]` 开启），`gemini-2.5-pro` 模型。

另外还有一个公告中转站新户注册送200美金。[点击这里](https://anyrouter.top/register?aff=6M0B)

## 功能特性

- ✅ 单个/多账号自动签到
- ✅ 多种机器人通知（可选）
- ✅ 绕过 WAF 限制

## 使用方法

### 1. Fork 本仓库

点击右上角的 "Fork" 按钮，将本仓库 fork 到你的账户。

### 2. 获取账号信息

对于每个需要签到的账号，你需要获取：
1. **Cookies**: 用于身份验证
2. **API User**: 用于请求头的 new-api-user 参数

#### 获取 Cookies：
1. 打开浏览器，访问 https://anyrouter.top/
2. 登录你的账户
3. 打开开发者工具 (F12)
4. 切换到 "Application" 或 "存储" 选项卡
5. 找到 "Cookies" 选项
6. 复制所有 cookies

#### 获取 API User：
通常在网站的用户设置或 API 设置中可以找到，每个账号都有唯一的标识。

### 3. 设置 GitHub Environment Secret

1. 在你 fork 的仓库中，点击 "Settings" 选项卡
2. 在左侧菜单中找到 "Environments" -> "New environment"
3. 新建一个名为 `production` 的环境
4. 点击新建的 `production` 环境进入环境配置页
5. 点击 "Add environment secret" 创建 secret：
   - Name: `ANYROUTER_ACCOUNTS`
   - Value: 你的多账号配置数据

### 4. 多账号配置格式

支持单个与多个

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

接下来获取 cookies 与 api_user 的值。

通过 F12 工具，切到 Application 面板，拿到 session 的值，最好重新登录下，该值 1 个月有效期，但有可能提前失效，失效后报 401 错误，到时请再重新获取。

![获取 cookies](./assets/request-session.png)

通过 F12 工具，切到 Network 面板，可以过滤下，只要 Fetch/XHR，找到带 `New-Api-User`，这个值正常是 5 位数，如果是负数或者个位数，正常是未登录。

![获取 api_user](./assets/request-api-user.png)

### 5. 启用 GitHub Actions

1. 在你的仓库中，点击 "Actions" 选项卡
2. 如果提示启用 Actions，请点击启用
3. 找到 "AnyRouter 自动签到" workflow
4. 点击 "Enable workflow"

### 6. 测试运行

你可以手动触发一次签到来测试：

1. 在 "Actions" 选项卡中，点击 "AnyRouter 自动签到"
2. 点击 "Run workflow" 按钮
3. 确认运行

![运行结果](./assets/check-in.png)

## Docker 部署方式

除了使用 GitHub Actions，你也可以使用 Docker 在本地或服务器上运行签到脚本。

### 方式一：使用预构建镜像（推荐）

直接使用我上传到 Docker Hub 的镜像：

```bash
# 一次性运行签到
docker run --rm \
  -e ANYROUTER_ACCOUNTS='[{"cookies":{"session":"your_session"},"api_user":"your_api_user"}]' \
  wwwzhouhui569/anyrouter-checkin:latest

# 定时运行（每6小时执行一次）
docker run -d \
  --name anyrouter-checkin \
  -e ANYROUTER_ACCOUNTS='[{"cookies":{"session":"your_session"},"api_user":"your_api_user"}]' \
  --restart unless-stopped \
  wwwzhouhui569/anyrouter-checkin:latest schedule 21600
```

### 方式二：自己构建镜像

```bash
# 克隆项目
git clone https://github.com/your-username/anyrouter-check-in.git
cd anyrouter-check-in

# 构建镜像
docker build -t anyrouter-checkin .

# 运行容器
docker run --rm \
  -e ANYROUTER_ACCOUNTS='[{"cookies":{"session":"your_session"},"api_user":"your_api_user"}]' \
  anyrouter-checkin
```

### 方式三：使用 Docker Compose（推荐）

1. 创建 `.env` 文件：

```bash
cp .env.example .env
```

2. 编辑 `.env` 文件，配置你的账号信息：

```bash
# 必填：账号配置
ANYROUTER_ACCOUNTS=[{"cookies":{"session":"your_session"},"api_user":"your_api_user"}]

# 可选：通知配置
EMAIL_USER=your_email@example.com
EMAIL_PASS=your_email_password
EMAIL_TO=recipient@example.com
DINGDING_WEBHOOK=https://oapi.dingtalk.com/robot/send?access_token=xxx
```

3. 启动服务：

```bash
# 定时运行（每6小时执行一次）
docker-compose up -d

# 一次性运行
docker-compose --profile once up anyrouter-checkin-once
```

### Docker 命令说明

容器支持以下运行模式：

- `checkin`：执行一次签到（默认）
- `schedule <间隔秒数>`：定时执行签到，默认21600秒（6小时）
- `notify <标题> <内容> [类型]`：发送测试通知
- `test`：健康检查测试
- `shell`：进入容器交互式shell

### 环境变量配置

| 变量名 | 必填 | 说明 | 示例 |
|--------|------|------|------|
| `ANYROUTER_ACCOUNTS` | ✅ | 账号配置（JSON格式） | `[{"cookies":{"session":"xxx"},"api_user":"xxx"}]` |
| `EMAIL_USER` | ❌ | 邮箱通知-发件人 | `your_email@example.com` |
| `EMAIL_PASS` | ❌ | 邮箱通知-密码/授权码 | `your_password` |
| `EMAIL_TO` | ❌ | 邮箱通知-收件人 | `recipient@example.com` |
| `DINGDING_WEBHOOK` | ❌ | 钉钉机器人webhook | `https://oapi.dingtalk.com/robot/send?access_token=xxx` |
| `FEISHU_WEBHOOK` | ❌ | 飞书机器人webhook | `https://open.feishu.cn/open-apis/bot/v2/hook/xxx` |
| `WEIXIN_WEBHOOK` | ❌ | 企业微信机器人webhook | `https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx` |
| `PUSHPLUS_TOKEN` | ❌ | PushPlus推送token | `your_pushplus_token` |
| `SERVERPUSHKEY` | ❌ | Server酱SendKey | `your_server_push_key` |

### 查看运行日志

```bash
# 查看实时日志
docker logs -f anyrouter-checkin

# 查看最近100行日志
docker logs --tail 100 anyrouter-checkin
```

### 停止和清理

```bash
# 停止容器
docker-compose down

# 停止并删除镜像
docker-compose down --rmi all
```

详细的 Docker 部署说明请参考 [README-Docker.md](./README-Docker.md)。

## 执行时间

- 脚本每6小时执行一次（1. action 无法准确触发，基本延时 1~1.5h；2. 目前观测到 anyrouter 的签到是每 24h 而不是零点就可签到）
- 你也可以随时手动触发签到

## 注意事项

- 请确保每个账号的 cookies 和 API User 都是正确的
- 可以在 Actions 页面查看详细的运行日志
- 支持部分账号失败，只要有账号成功签到，整个任务就不会失败
- 报 401 错误，请重新获取 cookies，理论 1 个月失效，但有 Bug，详见 [#6](https://github.com/millylee/anyrouter-check-in/issues/6)
- 请求 200，但出现 Error 1040（08004）：Too many connections，官方数据库问题，目前已修复，但遇到几次了，详见 [#7](https://github.com/millylee/anyrouter-check-in/issues/7)

## 配置示例

假设你有两个账号需要签到：

```json
[
  {
    "cookies": {
      "session": "abc123session"
    },
    "api_user": "user123"
  },
  {
    "cookies": {
      "session": "xyz789session"
    },
    "api_user": "user456"
  }
]
```

## 开启通知

脚本支持多种通知方式，可以通过配置以下环境变量开启，如果 `webhook` 有要求安全设置，例如钉钉，可以在新建机器人时选择自定义关键词，填写 `AnyRouter`。

### 邮箱通知
- `EMAIL_USER`: 发件人邮箱地址
- `EMAIL_PASS`: 发件人邮箱密码/授权码
- `EMAIL_TO`: 收件人邮箱地址

### 钉钉机器人
- `DINGDING_WEBHOOK`: 钉钉机器人的 Webhook 地址

### 飞书机器人
- `FEISHU_WEBHOOK`: 飞书机器人的 Webhook 地址

### 企业微信机器人
- `WEIXIN_WEBHOOK`: 企业微信机器人的 Webhook 地址

### PushPlus 推送
- `PUSHPLUS_TOKEN`: PushPlus 的 Token

### Server酱
- `SERVERPUSHKEY`: Server酱的 SendKey

配置步骤：
1. 在仓库的 Settings -> Environments -> production -> Environment secrets 中添加上述环境变量
2. 每个通知方式都是独立的，可以只配置你需要的推送方式
3. 如果某个通知方式配置不正确或未配置，脚本会自动跳过该通知方式

## 故障排除

如果签到失败，请检查：

1. 账号配置格式是否正确
2. cookies 是否过期
3. API User 是否正确
4. 网站是否更改了签到接口
5. 查看 Actions 运行日志获取详细错误信息

## 本地开发环境设置

如果你需要在本地测试或开发，请按照以下步骤设置：

```bash
# 安装所有依赖
uv sync --dev

# 安装 Playwright 浏览器
playwright install chromium

# 按 .env.example 创建 .env
uv run checkin.py
```

## 测试

```bash
uv sync --dev

# 安装 Playwright 浏览器
playwright install chromium

# 运行测试
uv run pytest tests/
```

## 免责声明

本脚本仅用于学习和研究目的，使用前请确保遵守相关网站的使用条款.
