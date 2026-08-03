---
name: ai-dev-workflow
description: >
  通用 AI 辅助开发工作流引导。适用于有持久化记忆体系的多会话协作项目。
  当 AI 需要跨会话保持项目上下文、跟踪需求进度、记录纠偏信息时触发。
  务必在以下场景使用此 skill：新对话冷启动、用户说"继续上次的工作"、"接着做"、
  项目涉及 ai-dev-workflow/ 目录、需要了解 CURRENT_TASK.md / TWEAKS.md / CHANGELOG.md 等记忆文件、
  或用户提到需求实现、子需求拆分、跨会话开发续接、代码优化、问题排查、bug修复。
  即使用户只是说"帮我做XX功能"或"帮我看看这个问题"，但项目根目录存在 ai-dev-workflow/ 目录，
  也应先加载此 skill 检查上下文再开始工作。不要跳过冷启动流程直接开始编码。
---

# AI 开发工作流

> 详细执行指令按需加载：`docs/init-guide.md` / `docs/workflows.md` / `docs/tweaks-guide.md` / `docs/reference.md`

---

## ⚡ 最高优先级：变更即记录

**每次完成任何代码修改后，必须按以下顺序执行，不得跳过，不得推迟：**

```
① 更新 CURRENT_TASK.md（勾选进度 / 记录完成状态）
② 在 CHANGELOG.md 追加一行摘要
③ 在 records/ 创建详细变更记录文件
④ 然后才能告知用户"已完成"
```

**AI 自查——以下行为即为违规，立即纠正：**
- 说"修改完成"后没有更新任何工作流文件
- 说"等会话结束再统一更新"
- 只更新了 CURRENT_TASK.md，忘记写 CHANGELOG.md 和 records/

---

## 一、文件体系与更新时机

```
{project-root}/
└── ai-dev-workflow/
    ├── ai-memory/
    │   ├── structure/
    │   │   ├── ARCHITECTURE.md     # 整体架构
    │   │   ├── TECH_STACK.md       # 技术栈速查
    │   │   └── modules/            # 各业务模块详细设计
    │   ├── changed/
    │   │   ├── CHANGELOG.md        # 变更摘要索引（时间倒序）
    │   │   └── records/            # 详细变更记录（一需求/修复一文件）
    │   └── context/
    │       ├── CURRENT_TASK.md     # 当前进度、断点快照、下一步（高频读写）
    │       ├── TWEAKS.md           # 纠偏规则（冷启动必读，硬约束）
    │       └── DECISIONS.md        # 技术决策 + Golden Principles
    ├── demand/
    │   ├── exec-plans/active/      # 进行中的执行计划
    │   ├── exec-plans/completed/
    │   └── done/
    ├── resources/                  # 外部资源：数据库连接、API 文档、第三方接口信息
    └── BOOTSTRAP.md                # 导航地图（≤100行）
```

| 文件 | 更新时机（硬规则） |
|------|---------|
| `CURRENT_TASK.md` | 每次代码变更完成后**立即**更新 |
| `TWEAKS.md` | 用户纠正 AI 后**立即**追加 |
| `CHANGELOG.md` | 每次代码变更完成后**立即**追加 |
| `DECISIONS.md` | 发现可复用规则、重大技术选型时 |
| `ARCHITECTURE.md` | 架构变更时**同步**更新 |
| `modules/*.md` | 命中硬触发条件时（见 `docs/workflows.md` § 4.8），与代码变更**同步**完成 |

---

## 二、冷启动执行流程

```
CURRENT_TASK.md 是否存在？
├── 否 → 读 docs/init-guide.md，按步骤初始化，完成后回到此流程
└── 是 → 续接项目：
    ├── 第一步（必须）：读 TWEAKS.md —— 其中「规则」字段是硬约束，不得跳过
    ├── 第二步（必须）：读 docs/reference.md 第一节「核心执行约束」—— 每次工作前默认激活，不得跳过
    ├── 第三步（必须）：读 DECISIONS.md —— Golden Principles 是所有代码变更的硬约束
    ├── 第四步：读 CURRENT_TASK.md
    │   ├── 有进行中任务 → 快速续接：
    │   │   1. 读 CHANGELOG.md 最近 3 条（了解近期上下文）
    │   │   2. 读 exec-plan 最新检查点（若 CURRENT_TASK 有引用）
    │   │   3. 开工
    └── 无进行中任务 → 完整冷启动：
        1. 读 ARCHITECTURE.md
        2. 读 TECH_STACK.md
        3. 按需读 modules/*.md
        4. 检查 exec-plans/active/ 有无进行中计划
        5. 列出 resources/ 目录内容；如有文件则逐一读取（外部服务连接、API 文档、第三方接口规范等关键上下文，不得跳过）
        6. 开始实现
```

> **遇到困难时**：不是重试，而是问"什么文档/工具/信息缺失导致我卡住？"——写进仓库，再继续。详见 `docs/workflows.md` § 4.7。

---

## 三、按需加载（路径相对于本 skill 安装目录）

| 触发场景 | 读取文件 |
|---|---|
| 全新项目初始化 | `docs/init-guide.md` |
| 实现需求 / 修复 / 重构 | `docs/workflows.md` |
| 处理用户纠正 / 补充隐含规则 | `docs/tweaks-guide.md` |
| 查阅模板 / 判断标准（第二节起） | `docs/reference.md` |

---

## 四、每次代码变更后的实时检查

完成任意代码变更动作后，立即对照以下清单逐项确认——未完成的立即补：

| 检查项 | 触发条件 |
|---|---|
| `CURRENT_TASK.md` 进度已勾选 | 每完成一个子任务/修复动作 |
| `CHANGELOG.md` 已追加摘要 | 每次代码文件被修改后 |
| `records/` 已创建变更记录 | 每次代码文件被修改后 |
| `TWEAKS.md` 已追加纠偏 | 用户纠正了 AI 的理解或执行 |
| `DECISIONS.md` 已追加 | 发现可复用规则或重大技术选型 |
| `ARCHITECTURE.md` 已同步 | 架构调整 / 新增模块 / 删除模块 / 模块边界变化 |
| `modules/*.md` 已更新 | 命中 § 4.8 任意触发条件 |
| 执行计划检查点已更新 | 复杂需求完成一个阶段 |

---

## 五、会话结束前的最终确认

> 此清单是兜底。每项都应在变更发生时就已完成，而不是等到这里才填。

- [ ] `CURRENT_TASK.md` 反映了最新进度，**断点快照**已更新？
- [ ] `CHANGELOG.md` 本次所有变更都追加了？
- [ ] `records/` 每次变更都有对应记录文件？
- [ ] `TWEAKS.md` 本次用户纠正已记录？
- [ ] `DECISIONS.md` 有无遗漏的选型或可复用规则？
- [ ] `ARCHITECTURE.md` 是否需要同步？
- [ ] `modules/*.md` 是否命中硬触发条件？已更新？
- [ ] 执行计划检查点已更新？
- [ ] 完成的需求已归档到 `demand/done/`？

