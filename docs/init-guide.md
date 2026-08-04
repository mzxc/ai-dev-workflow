# 新项目初始化 — 执行步骤

> 仅在 `CURRENT_TASK.md` 不存在时执行此文件。完成后返回 SKILL.md 冷启动流程继续。

---

## 步骤 0：确定项目根目录

按以下优先级判断，确定后再执行任何文件创建：

1. 已存在 `BOOTSTRAP.md` → 根目录 = BOOTSTRAP.md 所在目录
2. 存在 `.git/` → 根目录 = git 仓库根目录（`git rev-parse --show-toplevel`）
3. 以上均无 → 向用户确认："检测到项目根目录为：{路径}，是否正确？"确认后继续

**所有后续路径均相对于此根目录，不得假设当前工作目录就是根目录。**

---

## 步骤 1：创建目录结构

在项目根目录下创建：

```
ai-dev-workflow/
├── ai-memory/
│   ├── structure/modules/
│   ├── changed/records/archive/
│   └── context/
├── demand/
│   ├── exec-plans/active/
│   ├── exec-plans/completed/
│   └── done/archive/
└── resources/
```

---

## 步骤 2：创建初始文件

逐一创建以下文件（已存在则跳过，不覆盖）：

| 文件路径 | 内容来源 |
|---|---|
| `ai-memory/context/CURRENT_TASK.md` | 用 `docs/reference.md` 中的 CURRENT_TASK 模板，状态填"空闲" |
| `ai-memory/context/TWEAKS.md` | 仅含标题和格式注释（见下方模板）|
| `ai-memory/context/DECISIONS.md` | 仅含标题，顶部预留 `## Golden Principles` 专区 |
| `ai-memory/changed/CHANGELOG.md` | 仅含标题和格式说明 |
| `ai-memory/structure/ARCHITECTURE.md` | 扫描项目实际目录结构生成（见步骤 4）|
| `ai-memory/structure/TECH_STACK.md` | 读取项目依赖文件生成（见步骤 4）|
| `resources/README.md` | 说明此目录用途，列出已有文件索引 |
| `BOOTSTRAP.md` | 用步骤 5 的模板生成 |

**TWEAKS.md 初始内容**：
```markdown
# 纠偏记录（TWEAKS）

> 冷启动时必读。「规则」字段视为硬约束，优先级高于 AI 自身推断。

<!-- 格式：
## T{序号} | {简述}
**时间**: YYYY-MM-DD
**类型**: 需求理解偏差 / 编码风格偏差 / 业务规则遗漏 / 架构约定 / 流程执行遗漏
**场景**: AI 当时是怎么理解的
**校正**: 正确的理解是什么
**规则**: 一句可复用的硬约束
-->
```

---

## 步骤 3：初始化 CodeGraph 代码索引

**目的**：让 AI 用 `codegraph_explore` 一次调用获取相关符号源码与调用链，替代 grep+Read 循环；步骤 4 扫描项目结构生成 ARCHITECTURE.md 时也更高效。

**触发条件**（**全部**满足才执行，缺一即跳过）：
1. 当前 shell 中 `codegraph` 命令可用（`command -v codegraph` 成功）
2. 项目根目录不存在 `.codegraph/` 目录（尚未初始化）

**执行**：在项目根目录运行 `codegraph init`。

**注意**：
- 初始化耗时取决于代码库规模；若 Bash 工具默认超时（120s），改用后台运行或加大 timeout
- 索引建立后立即生效，无需重启会话
- `codegraph init` 失败不阻塞初始化流程，记录后继续，可稍后手动重试
- 索引建立后，日常代码查询优先使用 CodeGraph（`codegraph_explore`），而非 grep/find

---

## 步骤 4：生成 ARCHITECTURE.md 和 TECH_STACK.md

**ARCHITECTURE.md**：
- 扫描项目目录结构（排除 node_modules、.git、build 等）
- 识别主要模块/包/服务边界
- 按以下结构填写：项目概述、工程结构（目录树）、模块职责、外部依赖服务

**TECH_STACK.md**：
- 读取依赖文件（`package.json` / `pom.xml` / `requirements.txt` / `go.mod` 等）
- 提取核心框架、主要库、数据库、基础设施信息
- 若无法读取依赖文件，写"待填写"并提示用户补充

---

## 步骤 5：创建 BOOTSTRAP.md（导航地图）

```markdown
# AI 开发工作流

新对话冷启动：请加载 `ai-dev-workflow` skill，按冷启动流程恢复上下文。

- **当前项目**：{项目名}
- **技术栈**：{简述}
- **当前分支**：`{分支名}`

## 导航地图

| 文件 | 用途 |
|---|---|
| `ai-memory/context/TWEAKS.md` | **硬约束规则**（冷启动必读）|
| `ai-memory/context/DECISIONS.md` | 技术决策、Golden Principles |
| `ai-memory/context/CURRENT_TASK.md` | 当前任务状态、进度、断点快照 |
| `ai-memory/structure/ARCHITECTURE.md` | 工程架构全貌 + 模块索引 |
| `ai-memory/structure/TECH_STACK.md` | 技术栈速查 |
| `ai-memory/structure/modules/` | 各业务模块详细设计 |
| `ai-memory/changed/CHANGELOG.md` | 变更记录索引 |
| `demand/` | 需求文档 |
| `demand/exec-plans/active/` | 进行中的执行计划 |
| `resources/` | 外部资源：数据库连接、API 文档、第三方接口 |

## 冷启动顺序

1. 读 `TWEAKS.md`（硬约束，必须最先读）
2. 读 `DECISIONS.md`（Golden Principles 是代码变更的硬约束）
3. 读 `CURRENT_TASK.md`（判断是否有进行中任务）
4. 有任务 → 读 `CHANGELOG.md` 最近 3 条 → 开工
5. 无任务 → 读 `ARCHITECTURE.md` / `TECH_STACK.md` → 按需读 `modules/*.md`
6. 检查 `demand/exec-plans/active/` 是否有进行中计划
7. 列出 `resources/` 目录内容；如有文件则逐一读取（外部服务连接、API 文档等，不得跳过）
```

**BOOTSTRAP.md 必须保持 ≤100 行。超出时立即精简，不得扩充。**

---

## 步骤 6：写入 CLAUDE.md 自动钩子

**目的**：让新上下文窗口无需手动声明 skill，自动检测并启用 ai-dev-workflow。

**执行规则**：
- 在项目根目录查找 `CLAUDE.md`（注意：是项目根目录，不是 ai-dev-workflow/ 内部）
- 文件已存在 → 在**末尾追加**以下内容（不覆盖，不修改已有内容）
- 文件不存在 → 创建并写入以下内容

**追加内容**（原样写入，不得修改措辞）：

```markdown
## AI 开发工作流自动钩子

如果当前项目根目录存在 `ai-dev-workflow/` 文件夹，则：
1. 自动加载 `ai-dev-workflow` skill
2. 按 skill 中的冷启动流程恢复项目上下文，不得跳过
3. 不要等用户提醒，检测到目录即执行
4. 每次任务完成后，自动更新 `ai-dev-workflow` 中的相关文档
5. 新任务开始前, 检索必要的索引文件, 如: TWEAKS DECISIONS ARCHITECTURE 等重要资料
6. 如需访问外部资源, 如数据库和相关文档, 优先检索 resources README
7. ai-dev-workflow 为当前工程人机总记忆, 一切项目经验&记忆均在此文件夹记录
```

**验证**：追加完成后，确认 CLAUDE.md 末尾包含上述内容，且未破坏原有内容。

