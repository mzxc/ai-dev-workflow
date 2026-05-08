# ai-dev-workflow

通用 AI 辅助开发工作流 skill，适用于需要跨会话保持上下文的软件项目。通过文件持久化记忆体系，让每次新对话快速恢复项目上下文，避免重复探索和信息丢失。

## 核心能力

- **冷启动恢复** — 新对话自动加载项目上下文，无需用户重复说明背景
- **记忆体系** — 结构化的文件体系，覆盖架构文档、变更记录、纠偏日志等
- **需求管理** — 子需求拆分、进度跟踪、需求归档、变更流程
- **纠偏机制** — 记录用户对 AI 的理解偏差校正，跨会话持久化生效
- **会话结束检查** — 自动清单确保上下文不丢失

## 记忆体系结构

```
{project-root}/
├── ai-memory/
│   ├── structure/          # 工程结构文档（只读参考）
│   │   ├── ARCHITECTURE.md
│   │   ├── modules/
│   │   └── TECH_STACK.md
│   ├── changed/            # 变更记录（只写）
│   │   ├── CHANGELOG.md
│   │   └── records/
│   └── context/           # 会话上下文（频繁读写）
│       ├── CURRENT_TASK.md
│       ├── DECISIONS.md
│       └── TWEAKS.md
├── demand/                # 需求文档
│   └── done/
├── resources/             # 外部资源、接口文档
└── BOOTSTRAP.md           # 冷启动入口
```

## 快速开始

1. 在新项目根目录创建 `BOOTSTRAP.md`：
   ```markdown
   # AI 开发工作流
   新对话冷启动：请加载 ai-dev-workflow skill，按冷启动流程恢复上下文。
   当前项目：{项目名} · 技术栈：{简述} · 当前分支：{分支名}
   ```
2. 新对话时，AI 会自动加载此 skill 并按冷启动流程恢复上下文
3. 首次使用会自动初始化 `ai-memory/` 目录结构

## 触发场景

此 skill 在以下场景自动触发：

- 新对话冷启动（项目存在 `ai-memory/` 目录）
- 用户说"继续上次的工作"、"接着做"
- 用户提到需求实现、子需求拆分
- 需要了解 `CURRENT_TASK.md` / `TWEAKS.md` / `CHANGELOG.md` 等记忆文件

## 关键文件说明

| 文件 | 用途 |
|------|------|
| `CURRENT_TASK.md` | 当前需求进度、阻塞问题、下一步计划（高频更新） |
| `TWEAKS.md` | AI 理解偏差校正记录，视为硬约束 |
| `CHANGELOG.md` | 变更摘要索引 |
| `DECISIONS.md` | 技术决策日志 |
| `ARCHITECTURE.md` | 整体架构文档 |
| `TECH_STACK.md` | 技术栈速查 |

## 自动化脚本

`scripts/` 目录提供辅助脚本：

- `update_task.sh {project-root} {subtask-index}` — 更新 CURRENT_TASK.md 进度
- `add_changelog.sh {project-root} "{摘要}"` — 追加 CHANGELOG 摘要

## 纠偏机制

用户对 AI 的理解偏差进行纠正后，会自动记录到 `TWEAKS.md`。TWEAKS 中的规则优先级高于 AI 自身推断，确保同类错误不重复出现。

## 会话结束检查

每次会话结束前，AI 会自动检查：

- CURRENT_TASK.md 是否反映最新进度
- 阻塞问题是否已记录
- TWEAKS.md 是否有遗漏的纠偏记录
- CHANGELOG.md 是否更新
- 需求文档是否已归档

---

> 详细工作流程和完整规范，请参阅 [SKILL.md](./SKILL.md)。
