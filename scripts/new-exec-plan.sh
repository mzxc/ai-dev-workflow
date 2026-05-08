#!/usr/bin/env bash
# new-exec-plan.sh — 创建复杂需求执行计划
# 用法：bash ~/.claude/skills/ai-dev-workflow/scripts/new-exec-plan.sh "需求名" [预期完成日期]
set -euo pipefail
find_root() {
  local d="$PWD"
  while [[ "$d" != "/" && "$d" != "." ]]; do
    [[ -d "$d/ai-dev-workflow" ]] && echo "$d" && return 0
    d="$(dirname "$d")"
  done
  echo "❌ 找不到 ai-dev-workflow/ 目录" >&2; return 1
}
[[ $# -eq 0 ]] && echo "用法：bash new-exec-plan.sh \"需求名称\" [预期完成日期]" && exit 1
NAME="$1"
TODAY="$(date +%Y-%m-%d)"
DUE="${2:-（待定）}"
ROOT=$(find_root) || exit 1
WF="$ROOT/ai-dev-workflow"
DIR="$WF/demand/exec-plans/active"
SLUG=$(echo "$NAME" | sed 's/[[:space:]]/-/g;s/[^[:alnum:]-]//g')
FILE="$DIR/${TODAY}_${SLUG}.md"
mkdir -p "$DIR"
cat > "$FILE" << TMPL
# 执行计划：$NAME
**关联需求**: 见 demand/（需求文档文件名）
**创建时间**: $TODAY
**预期完成**: $DUE
## 子任务清单
- [ ] 子任务 1：（描述）— 涉及文件：（完整路径）
- [ ] 子任务 2：（描述）
- [ ] 子任务 3：（描述）
## 进度检查点
### $TODAY（初始）
完成了：创建执行计划
发现了：（初步分析的关键点）
下一步：开始子任务 1
## 决策日志
<!-- 格式：
### D1 | 决策简述 — YYYY-MM-DD
背景：为什么需要决策
方案：A / B / C
选择：A
原因：为什么
-->
## 阻塞与风险
> 无
TMPL
echo "✅ 已创建执行计划：$FILE"
echo "📝 请在 CURRENT_TASK.md 中引用：**执行计划**: 见 demand/exec-plans/active/${TODAY}_${SLUG}.md"
