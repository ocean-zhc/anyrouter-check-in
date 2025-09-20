# AnyRouter 自动签到 Docker镜像
FROM python:3.11-slim

# 设置维护者信息
LABEL maintainer="anyrouter-checkin"
LABEL version="1.0.0"
LABEL description="AnyRouter 多账号自动签到脚本 - 支持通知推送"

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DEBIAN_FRONTEND=noninteractive

# 安装系统依赖 (Playwright 需要的浏览器依赖)
RUN apt-get update && apt-get install -y \
    # 基础工具
    curl \
    wget \
    git \
    # Playwright/Chromium 依赖
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxss1 \
    libasound2 \
    # 错误提示中的依赖
    libxfixes3 \
    libcairo2 \
    libpango-1.0-0 \
    # 其他 Chromium 运行依赖
    libgtk-3-0 \
    libgdk-pixbuf-2.0-0 \
    libxcursor1 \
    libxi6 \
    libxtst6 \
    libatspi2.0-0 \
    # 字体支持
    fonts-liberation \
    fonts-noto-color-emoji \
    # 清理缓存
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 安装 uv (Python 包管理器)
RUN pip install uv

# 复制项目配置文件
COPY pyproject.toml uv.lock ./

# 创建非root用户运行应用
RUN useradd -m -u 1000 checker && \
    chown -R checker:checker /app

# 切换到非root用户
USER checker

# 使用 uv 安装Python依赖
RUN uv sync --frozen

# 安装 Playwright 浏览器 (作为非root用户)
RUN uv run playwright install chromium

# 安装 Playwright 系统依赖 (使用 sudo 暂时提升权限)
USER root
RUN uv run playwright install-deps chromium
USER checker

# 复制应用代码
COPY --chown=checker:checker checkin.py notify.py ./

# 复制环境变量示例文件和启动脚本
COPY --chown=checker:checker .env.example entrypoint.sh ./

# 设置启动脚本权限
RUN chmod +x entrypoint.sh

# 设置默认环境变量 (可以通过 docker run -e 覆盖)
ENV ANYROUTER_ACCOUNTS='[]'

# 健康检查 - 检查Python脚本是否可以正常导入
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD uv run python -c "import checkin, notify; print('Health check passed')" || exit 1

# 设置入口点
ENTRYPOINT ["./entrypoint.sh"]

# 默认运行签到脚本
CMD ["checkin"]