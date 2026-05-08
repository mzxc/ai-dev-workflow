#!/bin/bash
# 自动勾选 CURRENT_TASK.md 中的子需求进度
# 用法: update_task.sh {project-root} {subtask-index}
# 示例: update_task.sh /path/to/project 2  → 勾选第 2 个子需求

PROJECT_ROOT="${1}"
TASK_INDEX="${2}"

if [ -z "$PROJECT_ROOT" ] || [ -z "$TASK_INDEX" ]; then
    echo "用法: update_task.sh {project-root} {subtask-index}"
    exit 1
fi

TASK_FILE="${PROJECT_ROOT}/ai-memory/context/CURRENT_TASK.md"

if [ ! -f "$TASK_FILE" ]; then
    echo "未找到 CURRENT_TASK.md: ${TASK_FILE}"
    exit 1
fi

# 将第 N 个 "- [ ]" 替换为 "- [x]"
awk -v idx="$TASK_INDEX" '
BEGIN { count = 0 }
/^- \[ \] / {
    count++
    if (count == idx) {
        sub(/^-\s*\[\s*\]/, "- [x]")
    }
}
{ print }
' "$TASK_FILE" > "${TASK_FILE}.tmp" && mv "${TASK_FILE}.tmp" "$TASK_FILE"

echo "已勾选第 ${TASK_INDEX} 个子需求"
