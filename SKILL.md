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

> 核心思路：用文件持久化记忆，让每次新对话快速恢复上下文。
> 详细内容按需加载：`docs/init-guide.md` / `docs/workflows.md` / `docs/tweaks-guide.md` / `docs/reference.md`

---

## ⚡ 最高优先级规则：变更即记录

> **每次完成任何代码修改后，必须立即执行记录，不得推迟到会话结束。**

```
完成代码变更
    ↓
① 更新 CURRENT_TASK.md（勾选进度 / 记录完成状态）
② 在 CHANGELOG.md 追加一行摘要
③ 在 records/ 创建详细变更记录文件
    ↓
然后才能告知用户"已完成"
```

**违反此规则的典型表现**（AI 自查）：
- 回复"修改完成"后，没有更新任何工作流文件
- 说"等会话结束再统一更新"
- 只更新了 CURRENT_TASK.md，忘记写 CHANGELOG.md 和 records/

---


## 一、记忆体系结构

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
    │       ├── CURRENT_TASK.md     # 当前进度、阻塞、下一步（高频读写）
    │       ├── TWEAKS.md           # 纠偏规则（冷启动必读，硬约束）
    │       └── DECISIONS.md        # 技术决策 + 品味约束
    ├── demand/
    │   ├── exec-plans/active/      # 进行中的执行计划
    │   ├── exec-plans/completed/
    │   └── done/
    ├── resources/                  # 外部资源：数据库连接、API 文档、第三方接口信息等
    └── BOOTSTRAP.md                # 导航地图（≤100行）
```

| 文件 | 何时更新 |
|------|---------|
| `CURRENT_TASK.md` | **每次代码变更完成后立即更新** |
| `TWEAKS.md` | 每次用户纠正 AI 时立即追加 |
| `CHANGELOG.md` | **每次代码变更完成后立即追加** |
| `DECISIONS.md` | 有重大技术选型或品味规则时 |
| `ARCHITECTURE.md` | 架构变更时同步更新 |
| `modules/*.md` | 满足硬触发条件时（见 `docs/workflows.md` § 4.8）|

---

## 二、冷启动流程

```
CURRENT_TASK.md 是否存在？
├── 否 → 全新项目：读本 skill 的 docs/init-guide.md，按步骤初始化
└── 是 → 续接项目：
    ├── 先读 TWEAKS.md（硬约束，无论何时都必须最先读）
    ├── 再读 CURRENT_TASK.md
    │   ├── 有进行中任务 → 快速续接模式：
    │   │   1. 读 CHANGELOG.md 最近 3 条，了解近期上下文
    │   │   2. 如有 exec-plan（见 CURRENT_TASK.md 中的引用），读其最新检查点
    │   │   3. 开工
    │   └── 无进行中任务 → 完整冷启动：
    │       1. 已读 TWEAKS.md ✓
    │       2. 读 ARCHITECTURE.md
    │       3. 读 TECH_STACK.md
    │       4. 按需读 modules/*.md
    │       5. 检查 exec-plans/active/ 有无进行中计划
    │       6. 按需读 resources/（数据库、API、第三方接口等配置信息）
    │       7. 开始实现
```

**TWEAKS.md 无论何时都必须最先读，其中「规则」字段是硬约束。**

> **遇到困难时的第一反应**：不是重试，而是问"是什么信息/工具/文档缺失导致我卡住？"——立即把答案写进仓库，再继续实现。详见本 skill 的 `docs/workflows.md` § 4.7。

---

## 三、按需加载文档

> 以下 `docs/` 路径均相对于本 skill 安装目录（非项目目录），AI 应从 skill 文件中读取。

| 场景 | 需要读取 |
|---|---|
| 全新项目初始化 | `docs/init-guide.md` |
| 实现需求 / 修复 / 重构 | `docs/workflows.md` |
| 处理用户纠正 / 补充隐含规则 | `docs/tweaks-guide.md` |
| 查阅设计原则 / 模板 / 脚本说明 | `docs/reference.md` |

---

## 四、会话内实时检查点

> 每完成一个代码变更动作，立即检查：

| 检查项 | 触发时机 |
|---|---|
| `CURRENT_TASK.md` 进度已勾选 | 每完成一个子任务/修复动作 |
| `CHANGELOG.md` 已追加摘要 | 每次代码文件被修改后 |
| `records/` 已创建变更记录 | 每次代码文件被修改后 |
| `TWEAKS.md` 已追加纠偏 | 用户纠正了 AI 的理解或执行 |
| `DECISIONS.md` 已追加 | 做出重大技术选型或发现可复用规则 |
| `ARCHITECTURE.md` 已同步 | 变更涉及架构调整 |
| 执行计划已更新检查点 | 复杂需求完成一个阶段 |

---

## 五、会话结束检查清单

- [ ] **CURRENT_TASK.md** 是否反映了最新进度？
- [ ] **断点快照** 是否更新了"最后修改的文件"和"做到一半的事"？（方便下次续接）
- [ ] **CHANGELOG.md** 是否每次变更都追加了？
- [ ] **records/** 是否每次变更都有对应记录文件？
- [ ] **TWEAKS.md** 本次会话中用户是否纠正过 AI？是否已记录？
- [ ] **DECISIONS.md** 是否有技术选型或品味约束遗漏？
- [ ] **ARCHITECTURE.md** 是否因本次变更需要更新？
- [ ] **modules/*.md** 本次是否命中模块文档硬触发条件？若命中，是否已更新？
- [ ] **执行计划** 是否更新了进度检查点？
- [ ] **需求文档** 已完成的需求是否已归档到 `demand/done/`？

> 如果发现有遗漏，立即补写。此清单只是兜底，不要等到会话结束才更新。

