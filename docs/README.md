# docs/ — 执行指令集

> 以下文档由 SKILL.md 按需加载，不是独立阅读材料。AI 按场景触发，人类不需要手动翻阅。

## 文件索引

| 文件 | 触发场景 | 说明 |
|------|----------|------|
| `init-guide.md` | 全新项目初始化（CURRENT_TASK.md 不存在） | 从零创建 ai-dev-workflow/ 目录结构 |
| `workflows.md` | 实现需求 / 修复 / 重构 | 开发流程执行指令，含 exec plan 模板和模块文档硬触发规则 |
| `tweaks-guide.md` | 用户纠正 AI / AI 自查到理解偏差 | 纠偏机制执行指令，TWEAKS.md 写入规则 |
| `reference.md` | 每次工作前（核心约束） + 查阅模板/判断标准 | 规则、模板、判断标准集中存放 |

## 加载关系

```
SKILL.md §3（按需加载表）
  ├── 全新项目 → init-guide.md
  │     └── 引用 reference.md（CURRENT_TASK 模板）
  ├── 实现需求 → workflows.md
  │     └── 引用 reference.md（模块文档模板）
  ├── 用户纠正 → tweaks-guide.md
  │     └── 引用 DECISIONS.md / TWEAKS.md（目标文件）
  └── 模板查询 → reference.md
```

## 维护注意

- 四个文件保持纯执行指令风格，不写叙事性说明
- 模板变更时需要同步检查 `scripts/init.sh` 是否受影响
- 规则编号保持连续一致
