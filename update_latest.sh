#!/bin/bash
# update_latest.sh
# 自动查找最新的日期 HTML 文件并更新 vercel.json 中的重写目标
# 用法: 每次添加新的 HTML 页面后运行 ./update_latest.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 查找所有符合 "月.日.html" 格式的文件，并按日期排序找到最新的
LATEST_FILE=""
LATEST_SORT_KEY=""

for f in *.html; do
    # 跳过 index.html
    [[ "$f" == "index.html" ]] && continue

    # 提取文件名（不含扩展名）
    basename="${f%.html}"

    # 解析月和日（支持 "月.日" 格式）
    month=$(echo "$basename" | cut -d'.' -f1)
    day=$(echo "$basename" | cut -d'.' -f2)

    # 验证月和日是数字
    if [[ "$month" =~ ^[0-9]+$ ]] && [[ "$day" =~ ^[0-9]+$ ]]; then
        # 生成排序键 (月*100+日)，用于比较大小
        sort_key=$((month * 100 + day))

        if [[ -z "$LATEST_SORT_KEY" ]] || [[ "$sort_key" -gt "$LATEST_SORT_KEY" ]]; then
            LATEST_SORT_KEY="$sort_key"
            LATEST_FILE="$f"
        fi
    fi
done

if [[ -z "$LATEST_FILE" ]]; then
    echo "错误: 未找到符合格式的 HTML 文件"
    exit 1
fi

echo "检测到最新页面: $LATEST_FILE"

# 生成新的 vercel.json
cat > vercel.json << EOF
{
  "rewrites": [
    {
      "source": "/",
      "destination": "/$LATEST_FILE"
    }
  ]
}
EOF

echo "已更新 vercel.json，根路径将跳转到: /$LATEST_FILE"
