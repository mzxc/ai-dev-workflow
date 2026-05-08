#!/usr/bin/env bash
# =============================================================================
# init.sh — 在任意新项目中一键初始化 ai-dev-workflow 目录结构
# 用法：bash init.sh [项目名] [技术栈简述]
# 示例：bash init.sh "my-service" "Java 11 / Spring Boot"
# =============================================================================
set -euo pipefail

# ── 参数 ──────────────────────────────────────────────────────────────────────
PROJECT_NAME="${1:-$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")}"
TECH_STACK="${2:-（待填写）}"
BRANCH="$(git branch --show-current 2>/dev/null || echo 'main')"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WF="$ROOT/ai-dev-workflow"
TODAY="$(date +%Y-%m-%d)"

echo "📁 初始化 ai-dev-workflow"
echo "   项目根目录: $ROOT"
echo "   项目名称:   $PROJECT_NAME"
echo "   技术栈:     $TECH_STACK"
echo "   当前分支:   $BRANCH"
echo ""

# ── 创建目录结构 ──────────────────────────────────────────────────────────────
mkdir -p \
  "$WF/ai-memory/structure/modules" \
  "$WF/ai-memory/changed/records/archive" \
  "$WF/ai-memory/context" \
  "$WF/demand/exec-plans/active" \
  "$WF/demand/exec-plans/completed" \
  "$WF/demand/done/archive" \
  "$WF/resources" \
  "$WF/scripts"

# ── BOOTSTRAP.md ──────────────────────────────────────────────────────────────
cat > "$WF/BOOTSTRAP.md" << EOF
# AI 开发工作流

新对话冷启动：请加载 \`ai-dev-workflow\` skill，按冷启动流程恢复上下文。

- **当前项目**：$PROJECT_NAME
- **技术栈**：$TECH_STACK
- **当前分支**：\`$BRANCH\`

## 导航地图

| 文件 | 用途 |
|---|---|
| \`ai-memory/context/CURRENT_TASK.md\` | 当前任务状态、进度、下一步 |
| \`ai-memory/context/TWEAKS.md\` | **硬约束规则**（冷启动必读）|
| \`ai-memory/context/DECISIONS.md\` | 技术决策记录、品味约束 |
| \`ai-memory/structure/ARCHITECTURE.md\` | 工程架构全貌 |
| \`ai-memory/structure/TECH_STACK.md\` | 技术栈速查 |
| \`ai-memory/changed/CHANGELOG.md\` | 变更记录索引 |
| \`demand/\` | 需求文档 |
| \`demand/exec-plans/active/\` | 进行中的复杂需求执行计划 |

## 冷启动顺序

1. 读 \`TWEAKS.md\`（硬约束，必须最先读）
2. 读 \`CURRENT_TASK.md\`（当前状态）
3. 按需读 \`ARCHITECTURE.md\` / \`TECH_STACK.md\`
4. 检查 \`demand/exec-plans/active/\` 是否有进行中计划
EOF

# ── CURRENT_TASK.md ───────────────────────────────────────────────────────────
cat > "$WF/ai-memory/context/CURRENT_TASK.md" << EOF
# 当前任务

**项目**: $PROJECT_NAME
**当前需求**: 无（初始化完成，等待新需求）
**状态**: 空闲

## 进度

> 暂无进行中的需求

## 断点快照（上次停在哪里）

> 会话中断时更新此区域，方便下次续接。

**最后修改的文件**：无
**做到一半的事**：无
**未验证的变更**：无

## 阻塞问题

> 无

## 下一步

1. 等待用户提出新需求
2. 收到需求后，在 \`ai-dev-workflow/demand/\` 下创建需求文档，更新此文件

## 备注

- 工作流于 $TODAY 完成初始化
- 项目路径：\`$ROOT\`
EOF

# ── TWEAKS.md ─────────────────────────────────────────────────────────────────
cat > "$WF/ai-memory/context/TWEAKS.md" << EOF
# 纠偏记录（TWEAKS）

> AI 理解偏差校正，跨会话持久化。冷启动时必读，其中「规则」字段视为硬约束。

<!-- 格式：
## T{序号} | {简述}

**时间**: YYYY-MM-DD
**类型**: 需求理解偏差 / 编码风格偏差 / 业务规则遗漏 / 架构约定 / 流程执行遗漏
**场景**: AI 当时是怎么理解的
**校正**: 正确的理解是什么
**规则**: 一句可复用的硬约束
-->
EOF

# ── DECISIONS.md ──────────────────────────────────────────────────────────────
cat > "$WF/ai-memory/context/DECISIONS.md" << EOF
# 技术决策日志（DECISIONS）

> 记录重大技术选型决策及品味约束，供后续 AI 和人类参考。

<!-- 格式：
## D{序号} | {决策标题}

**时间**: YYYY-MM-DD
**背景**: 为什么需要做这个决策
**方案选项**: A / B / C
**选择**: A
**原因**: 为什么选 A
**影响**: 影响哪些模块
-->
EOF

# ── CHANGELOG.md ──────────────────────────────────────────────────────────────
cat > "$WF/ai-memory/changed/CHANGELOG.md" << EOF
# 变更日志（CHANGELOG）

> 变更摘要索引，按时间倒序排列。
> 格式：\`- YYYY-MM-DD: {摘要} → [详情](records/YYYY-MM-DD_{feature}.md)\`

EOF

# ── ARCHITECTURE.md（占位）────────────────────────────────────────────────────
if [ ! -f "$WF/ai-memory/structure/ARCHITECTURE.md" ]; then
  cat > "$WF/ai-memory/structure/ARCHITECTURE.md" << EOF
# 架构文档（ARCHITECTURE）

> 整体架构概览：目录结构、模块职责、数据流转、外部依赖
> ⚠️  请根据项目实际情况填写或让 AI 根据代码库自动生成

## 一、项目概述

**项目名称**：$PROJECT_NAME
**描述**：（待填写）

## 二、工程结构

（待填写）

## 三、数据流转

（待填写）

## 四、外部依赖服务

（待填写）
EOF
fi

# ── TECH_STACK.md（占位）─────────────────────────────────────────────────────
if [ ! -f "$WF/ai-memory/structure/TECH_STACK.md" ]; then
  cat > "$WF/ai-memory/structure/TECH_STACK.md" << EOF
# 技术栈速查（TECH_STACK）

> ⚠️  请根据项目实际情况填写或让 AI 根据依赖文件自动生成

## 核心依赖

| 分类 | 框架/库 | 版本 |
|---|---|---|
| （待填写）| — | — |
EOF
fi

echo "✅ 初始化完成！目录结构："
find "$WF" -type f | sort | sed "s|$ROOT/||"
echo ""
echo "💡 提示：ARCHITECTURE.md 和 TECH_STACK.md 需要手动填写或让 AI 根据项目代码自动生成"

