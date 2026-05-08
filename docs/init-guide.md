# 新项目初始化指南

> 仅在全新项目（无 `CURRENT_TASK.md`）时需要读此文件。

---

## 步骤 0：确定项目根目录

在创建任何文件之前，**必须先确定正确的项目根目录**，按以下优先级判断：

1. **如果已存在 BOOTSTRAP.md**：项目根目录 = BOOTSTRAP.md 所在目录（用 `dirname $(find . -name BOOTSTRAP.md | head -1)` 定位）
2. **如果存在 .git/**：项目根目录 = git 仓库根目录（用 `git rev-parse --show-toplevel` 获取）
3. **以上都不存在**：以当前工作目录作为项目根目录，**但必须先向用户确认**："检测到项目根目录为：{路径}，是否正确？"

> **关键**：所有相对路径（如 `ai-dev-workflow/`）都是相对于项目根目录的。不要假设当前 shell 工作目录就是项目根目录。

---

## 步骤 1：创建目录结构

```
{project-root}/ai-dev-workflow/
├── ai-memory/
│   ├── structure/modules/
│   ├── changed/records/archive/
│   └── context/
├── demand/
│   ├── exec-plans/active/
│   ├── exec-plans/completed/
│   └── done/archive/
├── resources/
└── scripts/
```

可直接运行初始化脚本（macOS / Linux / Git Bash）：

```bash
bash ai-dev-workflow/scripts/init.sh "项目名" "技术栈简述"
```

---

## 步骤 2：创建最小可用文件

均在 `ai-dev-workflow/` 目录下：

| 文件 | 内容 |
|---|---|
| `ai-memory/context/CURRENT_TASK.md` | 初始状态（见 reference.md 中的模板）|
| `ai-memory/context/TWEAKS.md` | 空文件，仅含标题和格式说明 |
| `ai-memory/context/DECISIONS.md` | 空文件，仅含标题 |
| `ai-memory/changed/CHANGELOG.md` | 空文件，仅含标题 |
| `ai-memory/structure/ARCHITECTURE.md` | 从项目实际结构生成 |
| `ai-memory/structure/TECH_STACK.md` | 从项目依赖生成 |
| `BOOTSTRAP.md` | 导航地图入口（≤100行）|

---

## 步骤 3：初始化 BOOTSTRAP.md

```markdown
# AI 开发工作流

新对话冷启动：请加载 `ai-dev-workflow` skill，按冷启动流程恢复上下文。

- **当前项目**：{项目名}
- **技术栈**：{简述}
- **当前分支**：`{分支名}`

## 导航地图

| 文件 | 用途 |
|---|---|
| `ai-memory/context/CURRENT_TASK.md` | 当前任务状态、进度、下一步 |
| `ai-memory/context/TWEAKS.md` | **硬约束规则**（冷启动必读）|
| `ai-memory/context/DECISIONS.md` | 技术决策记录、品味约束 |
| `ai-memory/structure/ARCHITECTURE.md` | 工程架构全貌 |
| `ai-memory/structure/TECH_STACK.md` | 技术栈速查 |
| `ai-memory/changed/CHANGELOG.md` | 变更记录索引 |
| `demand/` | 需求文档 |
| `demand/exec-plans/active/` | 进行中的复杂需求执行计划 |

## 冷启动顺序

1. 读 `TWEAKS.md`（硬约束，必须最先读）
2. 读 `CURRENT_TASK.md`（当前状态）
3. 按需读 `ARCHITECTURE.md` / `TECH_STACK.md`
4. 检查 `demand/exec-plans/active/` 是否有进行中计划
```

