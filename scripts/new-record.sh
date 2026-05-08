#!/usr/bin/env bash
# new-record.sh — 代码变更后创建变更记录 + 更新 CHANGELOG
# 用法：bash ~/.claude/skills/ai-dev-workflow/scripts/new-record.sh "变更简述"
set -euo pipefail
find_root() {
  local d="$PWD"
  while [[ "$d" != "/" && "$d" != "." ]]; do
    [[ -d "$d/ai-dev-workflow" ]] && echo "$d" && return 0
    d="$(dirname "$d")"
  done
  echo "❌ 找不到 ai-dev-workflow/ 目录" >&2; return 1
}
[[ $# -eq 0 ]] && echo "用法：bash new-record.sh \"变更简述\"" && exit 1
SUMMARY="$1"
TODAY="$(date +%Y-%m-%d)"
ROOT=$(find_root) || exit 1
WF="$ROOT/ai-dev-workflow"
RECORDS="$WF/ai-memory/changed/records"
CL="$WF/ai-memory/changed/CHANGELOG.md"
SLUG=$(echo "$SUMMARY" | sed 's/[[:space:]]/-/g;s/[^[:alnum:]-]//g')
FILE="$RECORDS/${TODAY}_${SLUG}.md"
REL="records/${TODAY}_${SLUG}.md"
cat > "$FILE" << TMPL
# $SUMMARY
**时间**: $TODAY
**类型**: 临时修复 / 性能优化 / 需求实现（请修改）
## 问题描述
（描述触发变更的问题或需求背景）
## 根因 / 背景
（说明问题根因或需求来源）
## 修改内容
| 文件（完整路径）| 修改说明 |
|---|---|
| （待填写）| — |
## 验证方式
（如何确认变更生效）
TMPL
echo "✅ 已创建变更记录：$FILE"
ENTRY="- $TODAY: $SUMMARY → [详情]($REL)"
if grep -q "^- " "$CL" 2>/dev/null; then
  # 用 awk 在第一条 "^- " 之前插入新条目，兼容 macOS BSD sed 和 GNU sed
  awk -v entry="$ENTRY" 'inserted==0 && /^- /{print entry; inserted=1} {print}' "$CL" > "$CL.tmp" && mv "$CL.tmp" "$CL"
else
  printf "\n%s\n" "$ENTRY" >> "$CL"
fi
echo "✅ 已更新 CHANGELOG"
echo "📝 请编辑变更记录文件并更新 CURRENT_TASK.md"
