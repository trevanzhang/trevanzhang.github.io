---
title: 'Hermes v0.12.0 的 Kanban 功能，到底解决了什么问题？'
date: 2026-05-09T00:00:00+08:00
tags: []
categories: []
---

容我先扯远一点。

<!--more-->

《庄子·秋水》里有句话："井蛙不可以语于海者，拘于虚也。"很多人第一次接触多 Agent 协作的时候，就像那只井蛙——以为 `delegate_task` 就是全部了。fork 一个子进程，等它返回，join，完事。简单，直接，顺手。

直到你遇到真正复杂的任务。

---

## 什么时候 `delegate_task` 不够用了

`delegate_task` 是个好东西。短平快的子任务，丢给子 Agent 去跑，结果拿回来接着用。就像函数调用，输入输出清清楚楚。

但它有几个致命短板：

**第一，它活不长。** 父进程结束，子进程也跟着完蛋。你不可能让一个 `delegate_task` 跑一整天——父会话超时了，孩子就白干了。

**第二，它没有身份。** 子 Agent 是匿名的，干完活就消失。下次再遇到同样的任务，它什么都记不住。没有记忆积累，没有经验传承。

**第三，人插不上手。** 任务跑着跑着，你突然想到要改个方向？不行，父进程在阻塞等待。你想中途给点反馈？没门。

**第四，出了事就全没了。** 上下文一压缩，之前的工作痕迹灰飞烟灭。你想复盘？对不起，没有审计追踪。

这些问题平时不明显。等你需要让多个 Agent 分工合作、任务要跑好几个小时、中间还需要人工介入的时候，短板就变成墙了。

Hermes v0.12.0 的 Kanban 功能，就是为了解决这堵墙而生的。

---

## Kanban 是什么

一句话：**一个持久化的任务队列，带状态机。**

任务不是存在某个 Agent 的内存里，而是写进本地 SQLite 数据库（`~/.hermes/kanban.db`）。每个任务有标题、有描述、有负责人（一个 named profile）、有状态（triage → todo → ready → running → blocked → done → archived），有父子依赖关系。

调度器（dispatcher）每隔 60 秒扫一遍数据库，把 ready 的任务认领出来，分配给对应的 profile 去执行。执行完了，写回结果。下一个依赖它的任务自动从 todo 提升到 ready。周而复始。

`delegate_task` 是函数调用。Kanban 是工作队列。

这个区别看着小，用起来的感受天差地别。

---

## 九个协作模式，一个不落

官方文档列了九种协作模式，我挑几个有意思的说。

**Fan-out + Fan-in。** 让三个 researcher 并行研究三个方向，一个 analyst 等它们全部完成后综合，一个 writer 最后出报告。三个 researcher 之间没有依赖，可以并行跑。analyst 必须等三个都完成才能开始。这种依赖关系，Kanban 自动处理——父任务 done，子任务自动 ready。

**Pipeline。** scout → editor → writer，角色链式传递。每个环节只关心自己的活，上游完成了就自动触发下游。

**Human-in-the-loop。** 这是我最喜欢的一个。worker 跑着跑着遇到拿不准的事，调用 `kanban_block(reason="需要决定用 IP 还是 user_id 做限流键")`，任务状态变成 blocked。你在 Telegram 上收到通知，回复一句"用 user_id"，任务 unblock，继续跑。中间不需要任何人工轮询。

**Fleet farming。** 一个 profile 管 50 个社交媒体账号，或者 12 个监控服务。任务批量创建，串行处理，同一个 Agent 在处理过程中积累经验。

**Triage specifier。** 你有个模糊的想法，先丢进 triage 列。等有空了，让一个 specifier profile 把它细化成具体的任务规格，再推进到 todo。从一句话到一个可执行的任务，中间有个缓冲地带。

---

## 实际用起来长什么样

先初始化：

```bash
hermes kanban init
hermes gateway start
```

然后创建任务：

```bash
hermes kanban create "研究 AI 融资现状" --assignee researcher
```

调度器看到任务，自动 spawn 一个 researcher profile 的进程去执行。worker 跑起来第一件事是调用 `kanban_show()` 读自己的任务描述，然后干活，干完调用 `kanban_complete(summary="...", metadata={...})` 交差。

如果你在 Telegram 上操作，更简单：

```
/kanban create "研究 AI 融资现状" --assignee researcher
```

创建完之后你自动订阅了这个任务。等它完成了，Telegram 上会收到一条通知：

> ✓ t_9fc1a3 completed by transcriber
> transcribed 42 minutes, saved to podcast/2026-05-04.md

不需要你去轮询，不需要你记着任务 ID。

---

## 关于 Dashboard

Hermes 还内置了一个 Dashboard GUI。跑 `hermes dashboard`，在 Kanban 标签页里你能看到完整的看板：triage、todo、ready、running、blocked、done 各占一列。

卡片上显示任务 ID、标题、优先级、负责人、进度（N/M 个子任务完成）、创建时间。支持拖拽改状态、内联创建、多选中批量操作、点击卡片看详情和评论线程。

视觉风格是 Linear/Fusion 那种暗色主题，看着舒服。

最实用的是 WebSocket 实时刷新。任何地方（CLI、gateway、Dashboard）对任务的操作，看板秒级更新。你不需要手动刷新。

---

## 几个值得注意的设计细节

**Workspace 三种模式。** scratch 是临时目录，任务结束就 GC。dir: 是共享持久目录，比如你的 Obsidian vault 或者某个 ops 脚本仓库。worktree 是 git worktree，写代码的时候用，每个 worker 有自己的独立工作区，互不干扰。

**Tenant 隔离。** 同一个 Agent 团队可以为多个业务服务。创建任务时加 `--tenant business-a`，worker 收到的环境变量里带 `HERMES_TENANT=business-a`，记忆和文件都按租户前缀隔离。看板是共享的，数据是隔离的。

**Run 机制。** 一个 task 可以有多个 run——每次执行算一次 run。失败了、超时了、崩溃了，run 关闭，task 回到 ready 状态重新被调度。下次执行的 worker 能看到之前所有 run 的结果和错误，不会重复踩坑。

**Circuit breaker。** 同一个任务连续 spawn 失败 5 次，调度器自动把它 block 掉，不再浪费资源。你可以手动排查原因后 unblock。

**Gateway 嵌入调度器。** 调度器运行在 gateway 进程内部，不需要单独启动一个 daemon。gateway 在，调度器就在。`hermes kanban daemon` 已经 deprecated 了。

---

## 适合什么场景

回到开头的问题——什么时候该用 Kanban 而不是 `delegate_task`？

我的判断标准很简单：

- 任务要跑超过几分钟？用 Kanban。
- 任务需要人工介入？用 Kanban。
- 任务的结果需要被后续任务消费？用 Kanban。
- 任务需要审计追踪？用 Kanban。
- 多个 Agent 需要协作？用 Kanban。
- 就是个小问题，几秒钟就回答完了？`delegate_task` 就行。

具体到你的工作场景：

**研究某个投资标的。** 让三个 researcher 并行收集基本面、技术面、宏观面信息，一个 analyst 综合出推荐报告，一个 writer 润色成可读的备忘录。中间你可以随时介入，给点方向性的提示。

**贸易合规审查。** 把复杂的合规审查拆成多个子任务——合同审查、金额核实、流程合规、文档完整性——分配给不同角色并行处理，最后汇总。

**长期监控。** cron + kanban 组合，每天自动执行某个研究任务，结果积累在共享目录里。几周下来就是一份完整的跟踪报告。

---

## 写在最后

《资治通鉴》里讲制度设计，核心逻辑就一条：好制度让普通人也能把事情做对，坏制度让聪明人处处碰壁。

Kanban 之于多 Agent 协作，就是这个意思。它不要求你设计多精妙的 Agent 架构，不要求你写多复杂的调度逻辑。你只需要把任务拆清楚， assign 给合适的角色，剩下的——依赖调度、崩溃恢复、人工介入、审计追踪——系统替你兜底。

`delegate_task` 是利器，但利器只适合短兵相接。真要打持久战，你得有阵地。

Kanban 就是你的阵地。

---

*Hermes Kanban 是单主机设计，`~/.hermes/kanban.db` 是本地 SQLite 文件。跨主机协作目前不支持——如果你需要，每个主机跑独立的 board，用 `delegate_task` 或消息队列桥接。*
