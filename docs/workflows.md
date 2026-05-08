# 开发工作流详情

> 实现需求 / 处理修复 / 管理需求文档时读此文件。

---

## 4.1 正式需求实现流程

1. 从 `ai-dev-workflow/demand/` 读取需求文档
2. **判断需求复杂度**：
   - 简单需求（1-3个子任务，半天内可完成）→ 直接用 CURRENT_TASK.md 跟踪
   - 复杂需求（多个子任务、跨多天、涉及多模块）→ 先创建执行计划（见 4.2）
3. 按子需求逐步实施
4. **每完成一个子需求后，立即按顺序执行**：
   - 更新 `CURRENT_TASK.md`（勾选进度、更新遗留问题）
   - 在 `ai-dev-workflow/ai-memory/changed/CHANGELOG.md` 追加一行摘要
   - 在 `ai-dev-workflow/ai-memory/changed/records/` 创建详细变更记录文件
   - 如有新技术决策或品味约束，追加到 `DECISIONS.md`
   - **如果变更涉及架构调整，同步更新 `ARCHITECTURE.md` 对应章节**
5. 全部子需求完成后：
   - 更新 `CURRENT_TASK.md` 标记任务完成
   - 迁移需求文档至 `ai-dev-workflow/demand/done/`
   - 将执行计划从 `exec-plans/active/` 移至 `exec-plans/completed/`

---

## 4.2 复杂需求执行计划（Exec Plan）

> 适用于：子任务超过 3 个、预期跨多天、涉及多个模块的需求。

在 `demand/exec-plans/active/` 下创建 `YYYY-MM-DD_{需求名}.md`，也可运行：

```bash
bash ai-dev-workflow/scripts/new-exec-plan.sh "需求名" "2026-05-20"
```

**执行计划模板**：

```markdown
# 执行计划：{需求名}

**关联需求**: 见 demand/{需求文档文件}
**创建时间**: YYYY-MM-DD
**预期完成**: YYYY-MM-DD

## 子任务清单

- [ ] 子任务 1：{描述} — 涉及文件：{完整路径}
- [ ] 子任务 2：{描述}
- [x] 子任务 3：{描述}（完成于 YYYY-MM-DD）

## 进度检查点

### YYYY-MM-DD
完成了：{做了什么}
发现了：{遇到什么问题/决策}
下一步：{接下来做什么}

## 决策日志

### D1 | {决策简述} — YYYY-MM-DD
背景：{为什么需要决策}
方案：A/B/C
选择：A
原因：{为什么}
```

> 执行计划是 AI 的"飞行日志"，让下次接手时不需要从头重建上下文。

---

## 4.3 临时修复 / 优化 / 问题排查流程

**轻量流程（完成代码变更后立即执行）**：

1. **更新 CURRENT_TASK.md**：将"当前需求"改为简短描述，状态标为"已完成"
2. **在 CHANGELOG.md 追加摘要**（一行）
3. **在 records/ 创建变更记录文件**（`YYYY-MM-DD_{简短描述}.md`）：问题描述、根因、修改的文件、验证方式
4. **如果变更揭示了新的架构约定**，追加到 `DECISIONS.md`

> 无需创建 demand/ 需求文档，但变更记录必须写。

---

## 4.4 文档编写规范

- **代码引用必须用完整限定路径**：
  - 后端：`cn.net.hylink.clue.service.impl.StabilityClueServiceImpl`
  - 前端：`src/views/xxx/components/XxxDialog.vue`
  - 目的：AI 可直接定位，无需 grep
- **变更记录摘要**不超过 80 字，详情另存文件
- **BOOTSTRAP.md 保持 ≤100 行**，只作导航地图，细节下沉到子文件

---

## 4.5 新增需求流程

1. **创建需求文档** — `ai-dev-workflow/demand/{YYYY-MM-DD}_{简短描述}.md`，包含：
   - 需求背景与目标、功能点拆解、涉及模块/文件、验收标准
2. **更新 CURRENT_TASK.md**：更换需求名称，重置进度列表
3. **如果旧需求未完成** — 在旧 CURRENT_TASK.md 中标记"暂停"，不要直接覆盖

也可运行：`bash ai-dev-workflow/scripts/new-demand.sh "需求名称"`

---

## 4.6 已交付需求变更流程

1. **定位原需求** — `demand/done/` 找需求文档，`ai-memory/changed/records/` 找变更记录
2. **创建变更需求文档** — `demand/{YYYY-MM-DD}_{原需求名}_变更.md`，包含：
   - 关联原需求路径、变更内容、影响范围分析
3. **更新 CURRENT_TASK.md**
4. **完成后**按变更大小处理原文档：
   - 小调整（改文案、修边界 bug）→ 追加变更说明到原文档末尾
   - 功能变更/新增 → 原文档移至 `demand/done/archive/`，新文档归档至 `demand/done/`

---

## 4.7 容错与标记

- 不确定但非阻塞的点：用 `//todo (AI) <原因> -- YYYY-MM-DD` 标记
- 无法找到的接口/方法：记录到 `TWEAKS.md`，提醒用户确认
- 需要用户澄清的需求：暂停实现，先提问

