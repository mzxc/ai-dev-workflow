---
name: ai-dev-workflow
description: >
  通用 AI 辅助开发工作流引导。适用于有持久化记忆体系的多会话协作项目。
  当 AI 需要跨会话保持项目上下文、跟踪需求进度、记录纠偏信息时触发。
  务必在以下场景使用此 skill：新对话冷启动、用户说"继续上次的工作"、"接着做"、
  项目涉及 ai-dev-workflow/ 目录、需要了解 CURRENT_TASK.md / TWEAKS.md / CHANGELOG.md 等记忆文件、
  或用户提到需求实现、子需求拆分、跨会话开发续接。
  即使用户只是说"帮我做XX功能"但项目根目录存在 ai-dev-workflow/ 目录，也应先加载此 skill
  检查上下文再开始工作。不要跳过冷启动流程直接开始编码。
---

# AI 开发工作流

> 适用于需要跨会话保持上下文的软件项目。核心思路：用文件持久化记忆，让每次新对话快速恢复上下文。

## 一、记忆体系结构

```
{project-root}/
└── ai-dev-workflow/                # 工作流根目录
    ├── ai-memory/
    │   ├── structure/                   # 工程结构文档（只读参考）
    │   │   ├── ARCHITECTURE.md         # 整体架构：目录结构、模块职责、数据流转、外部依赖
    │   │   ├── modules/                 # 各业务模块的详细设计（按需创建）
    │   │   │   └── {module-name}.md
    │   │   └── TECH_STACK.md           # 技术栈、核心依赖、数据字典速查
    │   │
    │   ├── changed/                     # 变更记录（只写）
    │   │   ├── CHANGELOG.md            # 变更索引：摘要 + 记录文件路径，按时间倒序
    │   │   └── records/                # 详细变更记录（一个需求一个文件）
    │   │       └── YYYY-MM-DD_{feature}.md
    │   │
    │   └── context/                    # 会话上下文（频繁读写）
    │       ├── CURRENT_TASK.md         # 当前需求进度、阻塞问题、下一步计划
    │       ├── DECISIONS.md            # 技术决策日志（含背景与原因）
    │       └── TWEAKS.md               # 纠偏记录：AI 理解偏差校正，跨会话持久化
    │
    ├── demand/                         # 需求文档（一个文件对应一个独立需求）
    │   └── done/                       # 已完成需求归档
    │
    ├── resources/                      # 外部资源、接口文档、参考资料
    │
    └── BOOTSTRAP.md                    # 冷启动文件（本 skill 的入口，每次新对话首先加载）
```

### 文件用途速查

| 文件 | 读写频率 | 用途 | 何时更新 |
|------|---------|------|---------|
| `CURRENT_TASK.md` | 高 | 当前在做什么、卡在哪里、下一步是什么 | 每完成一个子需求 |
| `TWEAKS.md` | 中 | AI 犯过的错、用户的校正 | 每次用户纠正 AI 时立即追加 |
| `CHANGELOG.md` | 中 | 变更摘要索引 | 每完成一个需求 |
| `DECISIONS.md` | 低 | 技术决策及原因 | 有重大技术选型时 |
| `ARCHITECTURE.md` | 低 | 工程全貌 | 架构变更时 |
| `TECH_STACK.md` | 低 | 技术栈速查 | 依赖变更时 |

---

## 二、冷启动流程

根据会话状态选择启动模式：

```
会话是否已有 CURRENT_TASK.md？
├── 否 → 全新项目初始化（见第三节）
└── 是 → 已有项目续接
    ├── CURRENT_TASK.md 中是否有进行中的任务？
    │   ├── 是 → 快速续接模式（只读 CURRENT_TASK.md + TWEAKS.md）
    │   └── 否 → 新需求开始，走完整冷启动：
    │       1. 读 CURRENT_TASK.md（了解上次状态）
    │       2. 读 TWEAKS.md（硬约束规则）
    │       3. 读 ARCHITECTURE.md（工程结构）
    │       4. 读 TECH_STACK.md（技术栈）
    │       5. 按需读 modules/*.md（业务模块）
    │       6. 开始实现
```

**原则**：能少读就少读。如果 CURRENT_TASK.md 显示当前任务明确且无阻塞，只读 TWEAKS.md 确认约束即可开工。

---

## 三、新项目初始化

如果 `ai-dev-workflow/ai-memory/` 目录不存在，按顺序创建：

1. **创建目录结构**（见第一节的树形结构）
2. **创建最小可用文件**（均在 `ai-dev-workflow/` 目录下）：
   - `ai-dev-workflow/ai-memory/context/CURRENT_TASK.md` — 初始状态（见模板）
   - `ai-dev-workflow/ai-memory/context/TWEAKS.md` — 空文件，仅含标题和格式说明
   - `ai-dev-workflow/ai-memory/context/DECISIONS.md` — 空文件，仅含标题
   - `ai-dev-workflow/ai-memory/changed/CHANGELOG.md` — 空文件，仅含标题
   - `ai-dev-workflow/ai-memory/structure/ARCHITECTURE.md` — 从项目实际结构生成
   - `ai-dev-workflow/ai-memory/structure/TECH_STACK.md` — 从项目依赖生成
   - `ai-dev-workflow/BOOTSTRAP.md` — 指向本 skill 的简短入口文件
3. **初始化 ai-dev-workflow/BOOTSTRAP.md**（项目根目录）：
   ```markdown
   # AI 开发工作流
   新对话冷启动：请加载 ai-dev-workflow skill，按冷启动流程恢复上下文。
   当前项目：{项目名} · 技术栈：{简述} · 当前分支：{分支名}
   ```

---

## 四、开发原则

### 4.1 需求实现流程

1. 从 `ai-dev-workflow/demand/` 读取需求文档
2. 按子需求逐步实施
3. **每完成一个子需求后**，按顺序执行：
   - 更新 `CURRENT_TASK.md`（勾选进度、更新遗留问题）
   - 迁移需求文档至 `ai-dev-workflow/demand/done/`
   - 在 `ai-dev-workflow/ai-memory/changed/CHANGELOG.md` 追加一行摘要（`- YYYY-MM-DD: {摘要} → [详情](ai-dev-workflow/ai-memory/changed/records/...)`）
   - 如有新技术决策，追加到 `DECISIONS.md`
4. 全部完成后，更新 `CURRENT_TASK.md` 标记任务完成

### 4.2 文档编写规范

- **代码引用必须用完整限定路径**：
  - 后端：`org.example.project.service.impl.XxxServiceImpl`
  - 前端：`src/views/xxx/components/XxxDialog.vue`
  - 目的：AI 可直接定位，无需 grep
- **变更记录摘要**不超过 80 字，详情另存文件

### 4.3 新增需求流程

当用户提出新需求时，按顺序执行：

1. **创建需求文档** — 在 `ai-dev-workflow/demand/` 下创建 `{YYYY-MM-DD}_{简短描述}.md`，内容包含：
   - 需求背景与目标
   - 功能点拆解（子需求列表）
   - 涉及模块/文件（初步判断）
   - 验收标准
2. **更新 CURRENT_TASK.md**：
   - 将"当前需求"改为新需求名称
   - 重置进度列表（根据新需求的子需求）
   - 清空"阻塞问题"，更新"下一步"
3. **如果旧需求未完成** — 在旧需求的 CURRENT_TASK.md 中标记"暂停"，不要直接覆盖

> 原则：一个需求一个文件，不要多个需求混在一个文档里。

### 4.4 已交付需求变更流程

当已归档的需求（位于 `ai-dev-workflow/demand/done/`）需要变更时：

1. **定位原需求** — 在 `ai-dev-workflow/demand/done/` 找到对应需求文档，同时在 `ai-dev-workflow/ai-memory/changed/records/` 查找当时的变更记录
2. **创建变更需求文档** — 在 `ai-dev-workflow/demand/` 下创建 `{YYYY-MM-DD}_{原需求名}_变更.md`，内容包含：
   - 关联原需求：`见 ai-dev-workflow/demand/done/{原需求文件}`
   - 变更内容（新增/修改/删除哪些功能点）
   - 影响范围分析（涉及哪些模块、可能牵连的功能）
3. **更新 CURRENT_TASK.md** — 同 4.3 步骤 2
4. **完成后**：
   - 将原需求文档从 `ai-dev-workflow/demand/done/` 移到 `ai-dev-workflow/demand/done/archive/`（如果变更较大，原文档已过时）
   - 或将变更说明追加到原需求文档末尾，保留在 `ai-dev-workflow/demand/done/`（如果变更较小）
   - 变更需求文档移至 `ai-dev-workflow/demand/done/`
   - 在 `ai-dev-workflow/ai-memory/changed/records/` 追加变更记录，关联原记录

> 关键判断：变更是否改变了原需求的本质？
> - 小调整（改文案、修边界 bug）→ 在原需求文档追加变更说明，不新建变更需求
> - 功能变更/新增 → 走完整变更流程

### 4.5 容错与标记

- 不确定但非阻塞的点：用 `//todo (AI) <原因> -- YYYY-MM-DD` 标记
- 无法找到的接口/方法：记录到 `TWEAKS.md`，提醒用户确认
- 需要用户澄清的需求：暂停实现，先提问

---

## 五、纠偏机制（TWEAKS）

用户对 AI 的理解偏差进行纠正后，**必须立即**追加到 `ai-dev-workflow/ai-memory/context/TWEAKS.md`。

### 5.1 触发时机（AI 自行判断）

| 场景 | 示例 |
|------|------|
| 用户纠正性反馈 | "不是这样"、"理解错了"、"应该是…" |
| 代码被要求修改方向 | 非 bug 修复，而是理解偏差 |
| 用户补充隐含规则 | 需求文档未明确但项目约定的规则 |

### 5.2 记录格式

```markdown
## T{序号} | {简述}

**时间**: YYYY-MM-DD
**类型**: 需求理解偏差 / 编码风格偏差 / 业务规则遗漏 / 架构约定
**场景**: AI 当时是怎么理解的
**校正**: 正确的理解是什么
**规则**: 一句可复用的硬约束（后续遇到类似情况直接套用）
```

### 5.3 运作机制

- **冷启动时读取 `ai-dev-workflow/ai-memory/context/TWEAKS.md`，其中的「规则」字段视为硬约束**
- 同类校正累计 ≥3 次 → 提炼为通用规则写入 `ai-dev-workflow/ai-memory/context/DECISIONS.md`
- TWEAKS 规则优先级高于 AI 自身推断 —— 即使 AI 认为另一种方式更合理，也应遵循校正记录

### 5.4 常见纠偏模式（AI 自查清单）

在实现过程中，如果符合以下模式，应主动检查 TWEAKS.md 或询问用户：

- 发现自己在猜测文件位置 → 应该用完整路径，检查是否有命名约定
- 发现自己在重复某段逻辑 → 检查是否有抽取公共方法的约定
- 发现用户多次纠正同类问题 → 立即记录到 TWEAKS.md

---

## 六、CURRENT_TASK.md 模板

```markdown
# 当前任务

**项目**: {项目名}
**当前需求**: {需求名}
**状态**: 进行中 / 阻塞 / 已完成

## 进度

- [ ] 子需求 1
- [x] 子需求 2（已完成）
- [ ] 子需求 3

## 阻塞问题

> 无 / 列出当前卡点

## 下一步

1. {具体要做的第一件事}
2. {第二件事}

## 备注

{其他上下文}
```

---

## 七、自动化辅助

以下脚本位于 `scripts/` 目录，可辅助完成重复性操作。

### 7.1 更新 CURRENT_TASK.md 进度

当完成子需求时，调用 `scripts/update_task.sh {project-root} {subtask-index}` 自动勾选进度。

### 7.2 追加 CHANGELOG 摘要

完成需求后，调用 `scripts/add_changelog.sh {project-root} "{摘要}"` 追加一行到 CHANGELOG.md。

---

## 八、跨会话记忆原则

1. **不要重复探索**：已经探索过的目录结构、模块关系，应写入 `ai-dev-workflow/ai-memory/structure/ARCHITECTURE.md`
2. **不要重复犯错**：每次被纠正，立即写 `ai-dev-workflow/ai-memory/context/TWEAKS.md`
3. **定期归档**：`ai-dev-workflow/ai-memory/changed/records/` 中超过 3 个月且已上线的需求记录可归档至 `ai-dev-workflow/ai-memory/changed/records/archive/`
4. **保持精简**：CURRENT_TASK.md 只保留当前任务相关信息，已完成任务及时清理

---

## 九、会话结束检查清单

每次会话结束前（用户说"结束"、"就到这"、"下次继续"等），必须完成：

- [ ] **CURRENT_TASK.md** 是否反映了最新进度？勾选已完成的子需求，更新"下一步"
- [ ] **阻塞问题** 是否记录？如果卡住了，写在 CURRENT_TASK.md 的"阻塞问题"节
- [ ] **TWEAKS.md** 是否有遗漏？本次会话中用户是否纠正过你的理解？
- [ ] **CHANGELOG.md** 是否更新？如果有子需求或需求完成，追加摘要
- [ ] **DECISIONS.md** 是否有遗漏？如果有技术选型决策，记录下来
- [ ] **需求文档** 是否已归档？已完成的需求从 `ai-dev-workflow/demand/` 移到 `ai-dev-workflow/demand/done/`

> 提示：不要让用户提醒你做这些。会话即将结束时主动检查并完成。
