#!/usr/bin/env bash
# check.sh — 会话结束前检查工作流文件更新状态
# 用法：在项目任意子目录内运行
#   bash ~/.claude/skills/ai-dev-workflow/scripts/check.sh
set -euo pipefail
find_root() {
  local d="$PWD"
  while [[ "$d" != "/" && "$d" != "." ]]; do
    [[ -d "$d/ai-dev-workflow" ]] && echo "$d" && return 0
    d="$(dirname "$d")"
  done
  echo "❌ 找不到 ai-dev-workflow/ 目录，请在项目目录内运行" >&2; return 1
}
get_date() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    stat -f "%Sm" -t "%Y-%m-%d" "$1" 2>/dev/null || echo "unknown"
  elif command -v stat &>/dev/null; then
    stat -c "%y" "$1" 2>/dev/null | cut -d' ' -f1 || echo "unknown"
  else
    python3 -c "import os,datetime; print(datetime.date.fromtimestamp(os.path.getmtime('$1')))" 2>/dev/null || echo "unknown"
  fi
}
ROOT=$(find_root) || exit 1
WF="$ROOT/ai-dev-workflow"
TODAY="$(date +%Y-%m-%d)"
PASS=true
echo "🔍 ai-dev-workflow 会话结束检查"
echo "   项目: $ROOT"
echo "   时间: $TODAY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TASK="$WF/ai-memory/context/CURRENT_TASK.md"
if [[ -f "$TASK" ]]; then
  MOD=$(get_date "$TASK")
  [[ "$MOD" == "$TODAY" ]] && echo "✅ CURRENT_TASK.md — 今日已更新" \
    || { echo "⚠️  CURRENT_TASK.md — 最后更新: $MOD"; PASS=false; }
else
  echo "❌ CURRENT_TASK.md — 不存在"; PASS=false
fi
CL="$WF/ai-memory/changed/CHANGELOG.md"
if [[ -f "$CL" ]]; then
  CNT=$(grep -c "^- $TODAY:" "$CL" 2>/dev/null || echo 0)
  [[ "$CNT" -gt 0 ]] && echo "✅ CHANGELOG.md — 今日 $CNT 条记录" \
    || echo "⚠️  CHANGELOG.md — 今日无新条目"
else
  echo "❌ CHANGELOG.md — 不存在"; PASS=false
fi
RD="$WF/ai-memory/changed/records"
if [[ -d "$RD" ]]; then
  N=$(find "$RD" -maxdepth 1 -name "${TODAY}_*.md" 2>/dev/null | wc -l | tr -d ' ')
  [[ "$N" -gt 0 ]] && echo "✅ records/ — 今日 $N 个变更文件" \
    || echo "⚠️  records/ — 今日无新变更记录"
fi
TW="$WF/ai-memory/context/TWEAKS.md"
if [[ -f "$TW" ]]; then
  TC=$(grep -c "^## T[0-9]" "$TW" 2>/dev/null || echo 0)
  [[ "$TC" -gt 0 ]] && echo "✅ TWEAKS.md — 共 $TC 条规则" || echo "ℹ️  TWEAKS.md — 暂无纠偏记录"
fi
AP="$WF/demand/exec-plans/active"
if [[ -d "$AP" ]]; then
  APN=$(find "$AP" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  [[ "$APN" -gt 0 ]] && echo "ℹ️  执行计划 active: $APN 个" && \
    find "$AP" -name "*.md" | sed 's|.*/||;s/^/     📋 /'
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[[ "$PASS" == true ]] && echo "🎉 检查通过！" || echo "⚡ 有待处理项，请补充更新工作流文件"
echo "📍 $WF"
