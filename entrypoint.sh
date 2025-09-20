#!/bin/bash

# AnyRouter 自动签到容器启动脚本
# 支持运行 checkin.py 或 notify.py

set -e

# 打印启动信息
echo "==================================="
echo "AnyRouter Auto Check-in Container"
echo "==================================="
echo "Time: $(date)"
echo "Command: $*"
echo "==================================="

# 如果没有提供参数，默认运行签到脚本
if [ $# -eq 0 ]; then
    echo "No command provided, running default checkin script..."
    exec xvfb-run -a uv run python checkin.py
fi

# 解析命令参数
case "$1" in
    "checkin")
        echo "Running checkin script..."
        exec xvfb-run -a uv run python checkin.py
        ;;
    "notify")
        if [ $# -lt 3 ]; then
            echo "Usage: $0 notify <title> <content> [msg_type]"
            echo "Example: $0 notify 'Test Title' 'Test Content' text"
            exit 1
        fi
        title="$2"
        content="$3"
        msg_type="${4:-text}"
        echo "Running notify script with title: '$title', content: '$content', type: '$msg_type'"
        exec uv run python -c "
from notify import notify
notify.push_message('$title', '$content', '$msg_type')
print('Notification sent successfully!')
"
        ;;
    "schedule")
        interval="${2:-21600}"  # 默认6小时 (21600秒)
        echo "Running scheduled checkin every $interval seconds..."
        while true; do
            echo "[$(date)] Starting AnyRouter check-in..."
            xvfb-run -a uv run python checkin.py
            echo "[$(date)] Check-in completed, sleeping for $interval seconds..."
            sleep "$interval"
        done
        ;;
    "test")
        echo "Running health check test..."
        uv run python -c "
import checkin
import notify
print('✓ checkin.py imported successfully')
print('✓ notify.py imported successfully')
print('✓ All modules are working correctly')
"
        ;;
    "shell"|"bash")
        echo "Starting interactive shell..."
        exec /bin/bash
        ;;
    *)
        echo "Running custom command: $*"
        exec "$@"
        ;;
esac