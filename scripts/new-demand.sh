#!/usr/bin/env bash
# new-demand.sh — 创建需求文档 + 更新 CURRENT_TASK.md
# 用法：bash ~/.claude/skills/ai-dev-workflow/scripts/new-demand.sh "需求名称"
set -euo pipefail
find_root() {
  local d="$PWD"
  while [[ "$d" != "/" && "$d" != "." ]]; do
    [[ -d "$d/ai-dev-workflow" ]] && echo "$d" && return 0
    d="$(dirname "$d")"
  done
  echo "❌ 找不到 ai-dev-workflow/ 目录" >&2; return 1
}
[[ $# -eq 0 ]] && echo "用法：bash new-demand.sh \"需求名称\"" && exit 1
NAME="$1"
TODAY="$(date +%Y-%m-%d)"
ROOT=$(find_root) || exit 1
WF="$ROOT/ai-dev-workflow"
SLUG=$(echo "$NAME" | sed 's/[[:space:]]/-/g;s/[^[:alnum:]-]//g')
DFILE="$WF/demand/${TODAY}_${SLUG}.md"
TFILE="$WF/ai-memory/context/CURRENT_TASK.md"
cat > "$DFILE" << TMPL
# 需求：$NAME
**创建时间**: $TODAY
**状态**: 进行中
## 背景与目标
（描述需求背景，为什么要做，预期效果）
## 功能点拆解
- [ ] 子需求 1：（描述）
- [ ] 子需求 2：（描述）
- [ ] 子需求 3：（描述）
## 涉及模块/文件（初步判断）
| 模块 | 文件（完整路径）| 变更类型 |
|---|---|---|
| （待分析）| — | 新增/修改/删除 |
## 验收标准
1. （验收条件 1）
TMPL
cat > "$TFILE" << TMPL
# 当前任务
**项目**: $(basename "$ROOT")
**当前需求**: $NAME
**状态**: 进行中
**需求文档**: 见 demand/${TODAY}_${SLUG}.md
## 进度
- [ ] 子需求 1：（描述）
- [ ] 子需求 2：（描述）
## 阻塞问题
> 无
## 下一步
1. 分析涉及的模块和文件
2. 开始实现子需求 1
## 备注
- 需求于 $TODAY 开始
TMPL
echo "✅ 已创建需求文档：$DFILE"
echo "✅ 已更新 CURRENT_TASK.md"
echo ""
echo "💡 复杂需求（>3子任务）请运行："
echo "   bash ~/.claude/skills/ai-dev-workflow/scripts/new-exec-plan.sh \"$NAME\""
