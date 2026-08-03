# scripts/ — 辅助脚本

> 可独立运行的 bash 脚本，用于加速常见操作。所有脚本均使用 `set -euo pipefail`。

## 脚本索引

| 脚本 | 用途 | 用法 |
|------|------|------|
| `init.sh` | 一键初始化 ai-dev-workflow/ 目录结构 | `bash init.sh [项目名] [技术栈]` |
| `check.sh` | 会话结束前检查工作流文件更新状态 | 在项目任意子目录内运行 `bash check.sh` |
| `new-demand.sh` | 创建新需求文档 + 重置 CURRENT_TASK.md | `bash new-demand.sh "需求名"` |
| `new-exec-plan.sh` | 为复杂需求创建执行计划 | `bash new-exec-plan.sh "计划名" [截止日期]` |
| `new-record.sh` | 代码变更后创建详细记录 + 追加 CHANGELOG | `bash new-record.sh "变更简述"` |

## 通用行为

- 所有脚本通过 `find_root()` 向上查找 `ai-dev-workflow/` 目录定位项目根
- 在项目的任意子目录内运行均可正确工作
- 已存在的文件不会被覆盖（`init.sh` 中带 `[ ! -f ... ]` 保护）
