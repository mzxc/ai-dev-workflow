#!/bin/bash
# 向 CHANGELOG.md 追加一行变更摘要
# 用法: add_changelog.sh {project-root} "{摘要}"
# 示例: add_changelog.sh /path/to/project "完成用户认证模块开发"

PROJECT_ROOT="${1}"
SUMMARY="${2}"

if [ -z "$PROJECT_ROOT" ] || [ -z "$SUMMARY" ]; then
    echo "用法: add_changelog.sh {project-root} \"{摘要}\""
    exit 1
fi

CHANGELOG="${PROJECT_ROOT}/ai-memory/changed/CHANGELOG.md"
TODAY=$(date +%Y-%m-%d)

if [ ! -f "$CHANGELOG" ]; then
    echo "# 变更日志" > "$CHANGELOG"
    echo "" >> "$CHANGELOG"
fi

# 新摘要插入到文件顶部（标题之后），保持时间倒序
TMPFILE=$(mktemp)
{
    head -n 1 "$CHANGELOG"
    echo ""
    echo "- **${TODAY}**: ${SUMMARY}"
    tail -n +2 "$CHANGELOG"
} > "$TMPFILE" && mv "$TMPFILE" "$CHANGELOG"

echo "已追加变更摘要到 CHANGELOG.md"
