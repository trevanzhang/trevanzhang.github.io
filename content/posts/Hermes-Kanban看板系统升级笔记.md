---
title: 'Hermes Kanban 看板系统升级笔记'
date: 2026-05-29T12:00:00+08:00
tags: ['Hermes', 'Kanban', '多智能体', 'Agent']
categories: ['产品介绍']
draft: false
---
# Hermes Kanban 看板系统升级笔记

> 整理时间：2026-05-29
> 版本：Hermes Agent v0.15.1 (2026.5.29)
> 技能版本：kanban-orchestrator v2.0.0 / kanban-worker v2.0.0

---

## 一、CLI 命令变化总览

### 新增命令（旧版没有）

| 命令 | 说明 |
|---|---|
| `swarm` | 创建 Swarm v1 任务图（并行 worker → 验证器 → 合成器） |
| `schedule` | 将任务停入计划中（等待时间，非人工输入） |
| `unblock` | 将 blocked/scheduled 任务恢复为 ready |
| `promote` | 手动将 todo/blocked 任务推进到 ready（恢复路径） |
| `specify` | 将 triage 列的任务细化为具体规格，推进到 todo |
| `decompose` | 将 triage 任务分解为子任务图，按专家 profile 路由 |
| `diagnostics` (diag) | 列出当前 board 的活跃诊断信息 |
| `notify-subscribe` | 订阅任务的终态事件推送（飞书/Telegram 等） |
| `notify-list` | 列出通知订阅 |
| `notify-unsubscribe` | 取消通知订阅 |
| `stats` | 按 status 和 assignee 的统计计数 + 最老的 ready 任务年龄 |
| `heartbeat` | Worker 存活信号（长时间操作时发出） |
| `assignees` | 列出已知 profile + 每个 profile 的任务计数 |
| `context` | 打印 worker 看到的完整上下文 |
| `gc` | 垃圾回收（归档任务的工作空间、旧事件、旧日志） |
| `boards` | 多看板管理（一个 board 对应一个项目/工作流） |
| `log` | 查看 worker 日志（从 kanban/logs/ 读取） |
| `runs` | 查看任务的尝试历史（每次尝试一行） |
| `reclaim` | 释放 worker 对运行中任务的认领 |
| `reassign` | 将任务转派给不同 profile（可选先释放） |
| `block` | 将一个或多个任务标记为阻塞 |

### 变化的命令

| 命令 | 变化说明 |
|---|---|
| `daemon` | **已废弃** —— 调度器现在内置在 gateway 中，使用 `hermes gateway start` |
| `create` | 新增 `--skill`（附加额外 skill）、`--max-runtime`、`--max-retries`、`--triage`、`--idempotency-key` 参数 |
| `complete` | 支持多 id 批量完成（不带 summary 时） |
| `archive` | 支持多 id 批量归档 |

---

## 二、核心新功能详解

### 2.1 Swarm v1 —— 蜂群拓扑模式

**解决的问题**：需要多个专家并行工作，然后统一验证和合成。

**拓扑结构**：
```
planning root（完成后立即关闭，作为共享黑板）
    ├─ 并行专家 worker 1（就绪，同时运行）
    ├─ 并行专家 worker 2（就绪，同时运行）
    ├─ 并行专家 worker N（就绪，同时运行）
    └─ verifier（等所有 worker 完成后启动）
         └─ synthesizer（等 verifier 通过后启动）
```

**核心机制**：
- **共享黑板（Blackboard）**：通过在 root task 上追加结构化 JSON 评论实现跨 worker 通信，零额外基础设施，所有状态都在现有的 `task_comments` / `task_events` 表中
- **验证门控**：verifier 必须在 metadata 中返回 `{"gate": "pass"}` 才能让 synthesizer 开始，否则 block 并说明缺失的工作
- **幂等创建**：支持 `--idempotency-key`，相同 key 不会重复创建

**CLI 用法**：
```bash
hermes kanban swarm \
  --goal "调研并撰写AI Agent市场分析报告" \
  --worker researcher:"调研海外Agent市场" \
  --worker analyst:"调研国内Agent市场" \
  --verifier reviewer \
  --synthesizer writer \
  --assignee orchestrator
```

**Worker 参数格式**：`profile:title` 或 `profile:title:skill1,skill2`

**自动附加的 skill**：
- verifier：`requesting-code-review`
- synthesizer：`humanizer`
- root：`kanban-orchestrator`

---

### 2.2 Triage 列 + 自动分解（Auto-Decompose）

**解决的问题**：从"手动创建每个任务"进化为"丢一句话，系统自动规划任务图"。

**工作流程**：
1. 你往 **Triage 列**丢一个粗略想法（一句话描述）
2. 调度器**自动**（或你手动点击 Decompose）调用辅助 LLM
3. LLM 看你的 profile 名册 + 描述，生成 JSON 任务图
4. 系统原子性地创建子任务、链接依赖、将原始任务从 triage 推进到 todo

**两种模式**：

| 模式 | 配置 | 行为 |
|---|---|---|
| **Auto（默认）** | `kanban.auto_decompose: true` | 每个调度器 tick 自动分解（上限 `auto_decompose_per_tick: 3`） |
| **Manual** | `kanban.auto_decompose: false` | 手动点击 Dashboard 上的 ⚗ Decompose，或 `hermes kanban decompose <id>` |

**相关配置项**（`~/.hermes/config.yaml` 的 `kanban:` 下）：

| 键 | 默认值 | 用途 |
|---|---|---|
| `auto_decompose` | `true` | 调度器每 tick 自动运行分解器 |
| `auto_decompose_per_tick` | `3` | 每个 tick 的分解上限 |
| `orchestrator_profile` | `""` | 拥有分解权的 profile（空 = 默认 profile） |
| `default_assignee` | `""` | LLM 选择未知 profile 时的兜底 |

**辅助 LLM 配置**：

| 键 | 用途 |
|---|---|
| `auxiliary.kanban_decomposer` | 生成任务图的模型 |
| `auxiliary.triage_specifier` | 单任务规格重写的模型 |
| `auxiliary.profile_describer` | 自动生成 profile 描述的模型 |

**Specify 命令**：对于不需要扇出的单任务，做一次性规格重写（补充目标、方法、验收标准），triage → todo：
```bash
hermes kanban specify <id>                    # 单个任务
hermes kanban specify --all --tenant engineering  # 批量处理某租户的所有 triage 任务
```

**Decompose vs Specify**：Decompose 是 Specify 的严格超集。当 LLM 判断任务不需要扇出时，Decompose 会自动回退到类似 Specify 的单任务推进。

**Profile 描述**：分解器依赖 profile 描述来决定路由：
```bash
hermes profile describe <name> --text "负责客观冷静的分析工作"  # 手动
hermes profile describe <name> --auto                          # LLM 自动生成
```
没有描述的 profile 仍可按名称路由，但精度较低。

---

### 2.3 Dashboard（GUI 看板）

**位置**：`plugins/kanban/dashboard/`，通过 `hermes dashboard` 打开，导航栏出现 "Kanban" 标签页。

**布局**：Linear / Fusion 风格，深色主题，六列看板：

```
Triage → Todo → Ready → Running (泳道) → Blocked → Done
```

**核心功能**：

| 功能 | 说明 |
|---|---|
| **拖放** | 卡片在列之间移动，破坏性操作有确认提示 |
| **泳道分组** | Running 列按 profile 分组，一眼看出每个 worker 在做什么 |
| **WebSocket 实时更新** | 所有 CLI / 斜杠命令操作立即反映，防抖处理 |
| **侧边抽屉** | 可编辑标题/描述、依赖编辑器、状态操作行、评论线程、运行历史 |
| **内联创建** | 点击列标题的 `+`，输入标题/受让人/优先级，可选父任务 |
| **多选批量操作** | shift/ctrl 点选，批量状态转换、归档、重新分配 |
| **Markdown 渲染** | 描述区域支持标题/粗体/斜体/代码/链接/列表（防 XSS） |
| **推动调度器** | 顶部按钮立即触发调度 tick，不等 60 秒 |
| **过滤器** | 搜索框、租户下拉、负责人下拉、显示已归档切换 |
| **看板切换器** | 多 board 时顶部出现下拉菜单，选择活动看板 |

**架构**：GUI 是纯 DB 读取层，不做业务逻辑，所有写入走 `kanban_db`，三个界面（Dashboard/CLI/Worker 工具）永远不会偏差。

**REST API**（挂载在 `/api/plugins/kanban/`）：

| 方法 | 路径 | 用途 |
|---|---|---|
| GET | `/board` | 完整看板（按状态列分组） |
| GET | `/tasks/:id` | 任务 + 评论 + 事件 + 链接 |
| POST | `/tasks` | 创建任务 |
| PATCH | `/tasks/:id` | 状态/受让人/优先级/标题/正文 |
| POST | `/tasks/bulk` | 批量操作 |
| POST | `/tasks/:id/comments` | 追加评论 |
| POST | `/tasks/:id/specify` | 运行分诊规格器 |
| POST | `/tasks/:id/decompose` | 运行分解器 |
| POST | `/dispatch` | 推动调度器 |
| WS | `/events` | 实时事件流 |

**Dashboard 配置**（`config.yaml` → `dashboard.kanban`）：

```yaml
dashboard:
  kanban:
    default_tenant: acme              # 预选租户过滤器
    lane_by_profile: true             # 泳道分组默认值
    include_archived_by_default: false
    render_markdown: true             # false 则用 <pre>
```

---

### 2.4 通知订阅系统

**解决的问题**：任务完成后不用手动检查，自动推送通知到飞书/Telegram 等平台。

**三种订阅方式**：

```bash
# 1. CLI 手动订阅
hermes kanban notify-subscribe t_abcd \
    --platform feishu --chat-id oc_22db58403de06a3d0c0741d0afe04bed

# 2. Gateway 自动订阅（/kanban create 时自动触发）
#    在 gateway 中使用 /kanban create 创建任务，创建者自动订阅
#    任务到达 done 或 archived 后自动取消订阅

# 3. Orchestrator 批量订阅
for task_id in $T1 $T2 $T3; do
    hermes kanban notify-subscribe $task_id --platform feishu --chat-id <chat_id>
done
```

**通知的事件类型**：`completed`、`blocked`、`gave_up`、`crashed`、`timed_out`

**通知内容**：completed 事件附带 worker summary 的第一行（400 字符上限），无需打开看板就能看到结果。

---

### 2.5 多看板（Boards）

**解决的问题**：不同项目/仓库/领域的工作流隔离。

**隔离机制**：
- 每个 board 有独立的 SQLite DB（`~/.hermes/kanban/boards/<slug>/kanban.db`）
- 独立的 `workspaces/` 和 `logs/` 目录
- Worker 只能看到所在 board 的任务（`HERMES_KANBAN_BOARD` 环境变量）
- 不允许跨 board 链接任务

**看板解析优先级**（从高到低）：
1. CLI 显式 `--board <slug>`
2. `HERMES_KANBAN_BOARD` 环境变量
3. `~/.hermes/kanban/current`（`boards switch` 持久化）
4. `default`

**管理命令**：
```bash
hermes kanban boards list                          # 列出所有看板
hermes kanban boards create atm10-server \          # 创建看板
    --name "ATM10 Server" \
    --description "Minecraft modded server ops" \
    --icon 🎮 --switch
hermes kanban boards switch atm10-server            # 切换活动看板
hermes kanban boards rename atm10-server "ATM10"   # 重命名
hermes kanban boards rm atm10-server               # 归档
hermes kanban boards rm atm10-server --delete      # 硬删除
```

---

## 三、Worker 与看板交互方式（核心变化）

**Worker 不再 shell 执行 `hermes kanban`。** 当调度器启动 worker 时，通过环境变量 `HERMES_KANBAN_TASK=t_abcd` 注入，启用专用的 `kanban_*` 工具集。

| 工具 | 用途 |
|---|---|
| `kanban_show` | 读取当前任务（标题/正文/父级交接/评论/worker_context） |
| `kanban_list` | 列出任务摘要（供 orchestrator 发现工作） |
| `kanban_complete` | 以 summary + metadata 完成任务 |
| `kanban_block` | 上报需要人工输入 |
| `kanban_heartbeat` | 长时间操作期间的存活信号 |
| `kanban_comment` | 向任务线程追加备注 |
| `kanban_create` |（orchestrator）扇出子任务 |
| `kanban_link` |（orchestrator）添加依赖边 |
| `kanban_unblock` |（orchestrator）解除阻塞 |

**为什么用工具而非 CLI**：
1. **后端可移植性**：Docker/Modal 等远程后端没有安装 hermes CLI
2. **无 shell 引用脆弱性**：`--metadata '{"files": [...]}'` 的 shlex 解析隐患
3. **更好的错误处理**：结构化 JSON vs stderr 字符串

---

## 四、结构化交接（summary + metadata）

这是看板工作流中**最核心的数据传递机制**。下游 worker 在 `kanban_show()` 时自动看到：
- **先前尝试**（outcome / summary / error / metadata）—— 重试 worker 不会重蹈失败路径
- **父任务结果**（最近一次完成的 summary + metadata）—— 下游无需重新阅读上游文档

**推荐的 metadata 格式**：
```json
{
  "changed_files": ["path/to/file.py"],
  "verification": ["pytest tests/ -q"],
  "dependencies": ["parent task id"],
  "decisions": ["bcrypt for hashing", "JWT for tokens"],
  "tests_run": 14,
  "tests_passed": 14,
  "residual_risk": ["untested edge case X"]
}
```

**批量关闭限制**：`hermes kanban complete a b c --summary X` 会被拒绝（相同 summary 复制到多个任务几乎总是错误的）。不带 `--summary` 的批量关闭仍可用于"我完成了一堆行政任务"场景。

---

## 五、运行记录（Runs）

任务是一次逻辑工作单元；**运行（Run）** 是执行它的一次尝试。

- 每次调度器认领一个就绪任务时，在 `task_runs` 中创建一行
- 尝试结束时（完成/阻塞/崩溃/超时/启动失败），运行行以 `outcome` 关闭
- 被尝试三次的任务有三行 `task_runs`

**Run 的 outcome 类型**：

| Outcome | 说明 |
|---|---|
| `completed` | Worker 正常完成 |
| `blocked` | Worker 请求人工输入 |
| `crashed` | Worker PID 消失（OOM / 段错误） |
| `timed_out` | 超过 `max_runtime_seconds` |
| `spawn_failed` | 启动失败（PATH 缺失 / 工作区无法挂载） |
| `reclaimed` | 认领 TTL 过期或手动回收 |
| `gave_up` | 连续 N 次失败后熔断器触发 |
| `protocol_violation` | Worker 成功退出但未调用 complete/block |

**熔断器**：连续 `kanban.failure_limit`（默认 2）次失败后自动阻塞任务，防止无限抖动。

---

## 六、任务状态全貌

```
triage → todo → ready → running → done
                ↑          │
                │          ↓
                └── blocked
                │
                ↓
              archived
```

新增 `triage`（分类）和 `scheduled`（计划中）状态。

---

## 七、事件参考（task_events）

每次状态变化追加一行到 `task_events` 表，分为三组：

**生命周期**：`created`、`promoted`、`claimed`、`completed`、`blocked`、`unblocked`、`archived`

**编辑**：`assigned`、`edited`、`reprioritized`、`status`

**Worker 遥测**：`spawned`、`heartbeat`、`reclaimed`、`crashed`、`timed_out`、`stale`、`respawn_guarded`、`spawn_failed`、`protocol_violation`、`gave_up`

**新增事件**：`stale`（长时间运行且无心跳，调度器回收）、`respawn_guarded`（调度器拒绝在本次 tick 重新启动，附带原因：`blocker_auth` / `recent_success` / `active_pr`）

---

## 八、八种协作模式

| 模式 | 形态 | 示例 |
|---|---|---|
| **P1 扇出** | N 个同级，相同角色 | "并行研究 5 个角度" |
| **P2 流水线** | 角色链：侦察 → 编辑 → 写作 | 每日简报组装 |
| **P3 投票/法定人数** | N 个同级 + 1 个聚合器 | 3 个研究员 → 1 个审查者选择 |
| **P4 长期运行日志** | 同一 profile + 共享目录 + cron | Obsidian vault |
| **P5 人工介入** | worker 阻塞 → 用户评论 → 解除阻塞 | 模糊决策 |
| **P6 @mention** | 从文本内联路由 | `@reviewer look at this` |
| **P7 线程范围工作区** | 线程中的 `/kanban here` | 每项目 gateway 线程 |
| **P8 批量任务** | 一个 profile，N 个对象 | 50 个社交账号 |
| **P9 分诊规格器** | 粗略想法 → triage → specify → todo | "将这个描述变成规格化任务" |

---

## 九、Kanban vs delegate_task 对比

| | delegate_task | Kanban |
|---|---|---|
| **形态** | RPC 调用（fork → join） | 持久化消息队列 + 状态机 |
| **父级** | 阻塞直到子级返回 | create 后即发即忘 |
| **子级身份** | 匿名子 agent | 具有持久记忆的具名 profile |
| **可恢复性** | 无 | 阻塞→解除阻塞→重新运行；崩溃→回收 |
| **人工介入** | 不支持 | 随时可评论/解除阻塞 |
| **审计追踪** | 上下文压缩后丢失 | 永久保存在 SQLite 中 |
| **协调方式** | 层级式 | 对等式 |

**一句话**：delegate_task 是函数调用；Kanban 是工作队列。

---

## 十、官方教程四个场景

### 场景一：独立开发者交付功能
- 模式：父→子依赖链（schema → API → 测试）
- 关键：只有无父依赖的任务从 ready 开始，子任务等父任务完成后自动提升
- 学习点：结构化交接让下游 worker 在 `kanban_show()` 时直接看到上游的 summary + metadata

### 场景二：集群并行处理
- 模式：同角色批量（3 个专家并行处理 12 个任务）
- 关键：泳道视图一眼看出每个 worker 的当前任务，dispatcher 在当前任务完成后立即分配下一个
- 学习点：批量创建 + 租户过滤 + 并行消费

### 场景三：角色流水线与重试
- 模式：PM → 工程师 → 审查者（含阻塞和重试）
- 关键：工程师第一次被审查者 block，unblock 后第二次重试，worker 在 context 中看到第一次被阻塞的原因
- 学习点：重试 worker 通过 run history 避免重蹈失败路径

### 场景四：熔断器与崩溃恢复
- 模式：错误处理（spawn_failed → gave_up / crashed → completed）
- 关键：连续失败自动阻塞（gave_up），OOM 崩溃自动回收并重试
- 学习点：熔断器防止无限抖动，stale 检测回收僵尸 worker

---

## 十一、Profile 系统（SOUL.md）

**核心要点**：
- Profile 克隆后默认配置都一样，**真正区分角色的是 SOUL.md**
- SOUL.md 位于 `~/.hermes/profiles/<name>/SOUL.md`
- 包含：身份、风格、默认行为、行为准则、绝对禁区

**创建新 Profile 流程**：
```bash
# 1. 克隆创建
hermes profile create pm --clone default

# 2. 编写 SOUL.md（最关键！）
# 编辑 ~/.hermes/profiles/pm/SOUL.md

# 3. 可选：设置模型
hermes -p pm config set model.default qwen3.5-plus

# 4. 可选：设置默认加载的 skills
hermes -p pm config set agent.skills "kanban-worker,official-document-writer"
```

**Profile 描述**：分解器路由依赖此描述
```bash
hermes profile describe <name> --text "负责客观冷静的分析工作"
hermes profile describe <name> --auto   # LLM 自动生成
```

---

## 十二、为任务附加额外 Skill

当单个任务需要受让人 profile 默认不携带的专业 skill 时：

```bash
# CLI
hermes kanban create "audit auth flow" \
    --assignee reviewer \
    --skill security-pr-audit \
    --skill github-code-review

# Orchestrator 工具
kanban_create(
    title="audit auth flow",
    assignee="reviewer",
    skills=["security-pr-audit", "github-code-review"],
)
```

这些 skill 是对内置 `kanban-worker` 的**补充**。

---

## 十三、Gateway 内嵌调度器

**变化**：调度器不再需要单独的 `hermes kanban daemon`，现在**内置在 gateway 中**。

```yaml
# config.yaml
kanban:
  dispatch_in_gateway: true        # 默认
  dispatch_interval_seconds: 60    # 默认
```

**行为**：只要 gateway 运行，就绪任务会在下一个 tick（默认 60 秒）被认领和启动。没有运行中的 gateway 时，ready 任务保持原状直到 gateway 启动。

---

## 十四、/kanban 斜杠命令

每个 `hermes kanban <action>` 都可以作为 `/kanban <action>` 在聊天中使用：

```
/kanban list
/kanban show t_abcd
/kanban create "write launch post" --assignee writer --parent t_research
/kanban comment t_abcd "looks good, ship it"
/kanban unblock t_abcd
/kanban specify t_abcd
/kanban decompose <id>
```

**绕过运行中保护**：`/kanban` 被豁免于 gateway 的"agent 运行中时不处理新消息"保护，因此可以随时操作看板。

**自动订阅**：从 gateway 使用 `/kanban create` 时自动订阅创建者。

---

## 十五、已知 Pitfalls（实战经验）

1. **CLI `--parent` 不是 `--parents`**：flag 是单数，多个父任务要重复：`--parent "$T1" --parent "$T2"`
2. **CLI JSON 输出字段是 `id`**：`hermes kanban create --json` 返回 `{id: "t_xxx"}`，工具返回 `{task_id: "t_xxx"}`
3. **`--body` 多行内容导致 JSON 解析失败**：bash 中 `--body` 含换行会破坏 `--json` 输出，用 Python subprocess 方式或压缩为单行
4. **Shell pipe 到解释器被阻止**：`hermes kanban create ... --json | python3 -c "..."` 被安全扫描阻止，用 `subprocess.run()`
5. **取消任务用 `archive` 而非 update**：没有 `hermes kanban update --status cancelled`，用 `hermes kanban archive <id>`
6. **`notify-subscribe` 可能超时**：某些环境下超时 >30s，当前 workaround 是增加超时或后续单独补订
7. **确认产品理解再创建任务**：用户说的 "Codex" 可能是 CLI / 桌面端 / 模型，先确认再创建整条任务链
8. **Worker 写文件用绝对路径**：`~` 在隔离 session 中可能解析错误，用 `/home/trevan/output/` 而非 `~/output/`
9. **kanban_complete 不稳定**：任务可能回退到 ready，需要监控并在回退时手动处理
10. **Kanban DB schema drift**：升级后 `hermes kanban create` 可能报 `no such column`，需 `ALTER TABLE` 添加缺失列

---

## 十六、Python 创建任务的推荐模式

```python
import subprocess, json

def create_task(title, assignee, body, parents=None, workspace="scratch"):
    cmd = ["hermes", "kanban", "create", title, "--assignee", assignee,
           "--body", body, "--workspace", workspace, "--json"]
    if parents:
        for p in parents:
            cmd.extend(["--parent", p])
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
    data = json.loads(result.stdout)
    return data.get('id', data.get('task_id', ''))
```

注意：`--body` 必须为单行字符串，不可包含换行符。

---

## 十七、配置项速查

### kanban 相关（`config.yaml` → `kanban:`）

```yaml
kanban:
  dispatch_in_gateway: true          # 调度器内置 gateway（默认）
  dispatch_interval_seconds: 60     # 调度间隔（默认）
  failure_limit: 2                   # 连续失败几次后熔断（默认）
  dispatch_stale_timeout_seconds: 14400  # 4小时无心跳回收（默认）
  auto_decompose: true               # 自动分解 triage 任务（默认）
  auto_decompose_per_tick: 3         # 每 tick 分解上限（默认）
  orchestrator_profile: ""           # 编排器 profile
  default_assignee: ""               # 未知 profile 的兜底
```

### auxiliary 相关

```yaml
auxiliary:
  kanban_decomposer:                  # 分解器 LLM
    provider: ""
    model: ""
  triage_specifier:                   # 规格器 LLM
    provider: ""
    model: ""
  profile_describer:                 # Profile 描述生成 LLM
    provider: ""
    model: ""
```

### dashboard 相关

```yaml
dashboard:
  kanban:
    default_tenant: ""
    lane_by_profile: true
    include_archived_by_default: false
    render_markdown: true
```
