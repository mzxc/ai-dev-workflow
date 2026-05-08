# ai-dev-workflow

通用 AI 辅助开发工作流 skill，适用于需要跨会话保持上下文的软件项目。通过文件持久化记忆体系，让每次新对话快速恢复项目上下文，避免重复探索和信息丢失。

## 核心能力

- **冷启动恢复** — 新对话自动加载项目上下文，无需用户重复说明背景
- **变更即记录** — 每次代码变更完成后立即更新工作流文件，不等会话结束
- **执行计划** — 复杂需求有专属飞行日志（子任务/检查点/决策日志），跨会话无缝续接
- **纠偏机制** — 记录用户对 AI 的理解偏差校正，跨会话持久化为硬约束
- **熵管理** — 持续小增量清理代码和文档，防止技术债自我繁殖
- **辅助脚本** — 5 个开箱即用的 shell 脚本，覆盖初始化到归档全流程

## 快速开始

### 新项目初始化（最简方式）

```bash
# 复制 init.sh 到项目根目录并运行
bash ~/.claude/skills/ai-dev-workflow/scripts/init.sh "项目名称" "Java 11 / Spring Boot"
```

一键生成完整目录结构 + 所有模板文件。

### 手动初始化

1. 创建 `ai-dev-workflow/BOOTSTRAP.md`（≤100行，只作导航地图）
2. 新对话时告诉 AI：加载 `ai-dev-workflow` skill 并初始化

## 记忆体系结构

```
{project-root}/
└── ai-dev-workflow/
    ├── ai-memory/
    │   ├── structure/              # 只读参考
    │   │   ├── ARCHITECTURE.md     # 整体架构
    │   │   ├── modules/            # 各业务模块详情
    │   │   └── TECH_STACK.md       # 技术栈速查
    │   ├── changed/                # 只写
    │   │   ├── CHANGELOG.md        # 变更摘要索引
    │   │   └── records/            # 详细变更记录
    │   └── context/                # 频繁读写
    │       ├── CURRENT_TASK.md     # 当前任务进度
    │       ├── DECISIONS.md        # 技术决策 + 品味约束
    │       └── TWEAKS.md           # 纠偏硬约束（冷启动必读）
    ├── demand/
    │   ├── exec-plans/
    │   │   ├── active/             # 进行中的执行计划
    │   │   └── completed/          # 已完成归档
    │   └── done/                   # 已完成需求归档
    ├── resources/                  # 外部资源、接口文档
    ├── scripts/                    # 辅助脚本（见下方）
    └── BOOTSTRAP.md                # 冷启动入口（≤100行）
```

## 辅助脚本（scripts/）

| 脚本 | 用途 | 用法 |
|---|---|---|
| `init.sh` | 新项目一键初始化全部目录+模板 | `bash init.sh "项目名" "技术栈"` |
| `new-demand.sh` | 创建需求文档 + 更新 CURRENT_TASK.md | `bash new-demand.sh "需求名称"` |
| `new-exec-plan.sh` | 创建复杂需求执行计划（含检查点/决策日志） | `bash new-exec-plan.sh "需求名" "2026-05-20"` |
| `new-record.sh` | 代码变更后创建变更记录 + 更新 CHANGELOG | `bash new-record.sh "变更简述"` |
| `check.sh` | 会话结束前检查工作流文件更新状态 | `bash check.sh` |

> AI 可直接调用这些脚本，也可提示用户运行。

## 触发场景

此 skill 在以下场景自动触发：

- 新对话冷启动（项目存在 `ai-dev-workflow/` 目录）
- 用户说"继续上次的工作"、"接着做"
- 用户提需求实现、bug修复、代码优化、问题排查
- 需要了解 `CURRENT_TASK.md` / `TWEAKS.md` / `CHANGELOG.md` 等记忆文件

## 关键文件说明

| 文件 | 读写频率 | 用途 |
|---|---|---|
| `CURRENT_TASK.md` | 高 | 当前需求进度（**每次变更后立即更新**）|
| `TWEAKS.md` | 中 | AI 纠偏硬约束（冷启动必读）|
| `CHANGELOG.md` | 中 | 变更摘要索引（**每次变更后立即追加**）|
| `DECISIONS.md` | 中 | 技术决策 + 品味约束规则 |
| `exec-plans/active/` | 中 | 复杂需求的飞行日志 |
| `ARCHITECTURE.md` | 低 | 整体架构（代码涉及架构时同步更新）|
| `TECH_STACK.md` | 低 | 技术栈速查 |

## 核心设计原则

1. **AI 看不见的东西等于不存在** — 所有决策必须落地为文件
2. **地图优于手册** — BOOTSTRAP.md ≤100 行，只作导航
3. **变更即记录** — 完成代码变更 = 代码改完 + 工作流文件更新完
4. **持续还债** — 小增量清理 >> 集中大重构

---

> 详细工作流程和完整规范，请参阅 [SKILL.md](./SKILL.md)。
