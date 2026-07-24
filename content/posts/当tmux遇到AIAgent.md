---
title: '当 tmux 遇上 AI Agent'
date: 2026-07-24T09:00:00+08:00
tags: [AI, Agent, tmux, Orca]
categories: [技术]
cover: /images/orca-cover.jpg
description: 'Orca 就是 AI Agent 时代的 tmux——多路复用终端会话变成了多路复用 AI Agent。'
---

> 全文约1700字，阅读需4分钟

## 当 tmux 遇上 AI Agent

我重度使用 tmux 大概有七八年了。屏幕一劈四，左边跑服务，右边看日志，上面写代码，下面跑测试——这种分裂式的工作节奏，用过就回不去了。

去年开始用 AI 编程工具，情况变了。Claude Code 在一个终端里跑，Codex 在另一个，有时候还想让 Gemini 写一版对比。三个终端窗口并排打开，跟十年前同时开五六个 SSH 会话一样狼狈。上下文切换的成本不是时间，是注意力——你刚看完 Claude 的输出转头去审 Codex 的改动，脑子得重新加载一遍需求上下文。

上周发现一个叫 Orca 的开源工具，MIT 协议，GitHub 上四个月攒了两万颗星。它的定位不是「AI 编辑器」，是「AI 编排台」——ADE，Agent Development Environment。

但真正让我眼前一亮的，不是功能列表，是一个更朴素的类比：**Orca 就是 tmux，只不过管理的不是终端会话，而是 AI Agent。**

## 处处是 tmux 的影子

这个类比经得起推敲。

tmux 把一个终端窗口切成多个 pane，每个 pane 跑一个独立的 shell 会话。Orca 把一个项目仓库切成多个 worktree，每个 worktree 跑一个独立的 Agent。tmux 有 session 管理，Orca 有并行面板——左侧一排卡片实时显示每个 Agent 的状态：运行中、等授权、完成、出错。tmux 能 detach 再 attach，换台电脑接着干活；Orca 有手机 App，配对桌面端后，你在地铁上就能看 Agent 跑到哪了，还能远程下指令。

甚至连哲学都一样。tmux 不关心 pane 里跑的是 bash 还是 python，它只管窗口和会话；Orca 不关心 Agent 是 Claude 还是 Codex 还是 Qwen Code，它只管分派和回收。官方的说法叫「Bring Your Own Subscription」——Orca 自己不卖模型，不卖 API，你插上已有的订阅就能用。

这个定位聪明。模型越来越便宜，编排层才是稳定价值所在。就像 tmux 的价值从来不在于它自带的那个 shell，而在于它让你同时操作多个 shell 的能力。

## worktree：比 tmux 多走的一步

不过 tmux 有个老问题：多个 pane 共享同一个工作目录，两个人同时改同一个文件就炸。tmux 从来不操心这个，因为它的假设是你一个人在操作，你自己知道别踩自己。但 Agent 不是你。你让 Claude 改 `app.py` 的同时让 Codex 也改 `app.py`，谁后提交谁覆盖谁，毫无保障。

Orca 用 git worktree 解决这个问题。每个 Agent 分到一个独立的 worktree——独立目录、独立分支，文件系统层面就隔开了。共享同一个 git 对象库，磁盘不浪费；但文件物理隔离，互相碰不到。改完之后统一出 diff，你挑最好的那个合并进 main。

这是 tmux 从来没做过的，也没必要做的事。tmux 管的是人，人自己会协调。Orca 管的是 Agent，Agent 不会协调，必须靠基础设施来兜底。

## 四个人的项目

Orca 背后的公司叫 Stably AI，Y Combinator Winter 2022 批次，旧金山，四个人。CEO Jinjing Liang 前面在 Google Chrome 团队做测试和发布基础设施——就是那种面向几十亿用户的基础设施。CTO Neil Parker 之前在 Uber 管安全团队。

这个背景解释了 Orca 的几个怪癖。崩溃隔离是首要关注点——文件监听器用 fork 出的子进程池来跑，原生插件崩了不会拖垮主进程。有 CI 可靠性门控，检查不通过不允许合并。甚至有个最大行数卡尺，防止单文件膨胀。

这些全是测试基础设施思维在桌面应用上的投射。四个月，几乎每天发一版，节奏跟 Chrome 的 Canary 通道一个路子。当然，快也有快的代价——GitHub Issues 里几个严重 bug 跨版本反复出现，中文渲染模糊、Electron 的内存开销、手机 App 断连，都是客观存在的伤。

不过话说回来，tmux 刚出来那几年也不是什么省油的灯。

## 不适合所有人

说实话，如果你现在只用一个 AI 编程工具，Orca 增加的不是便利，是操作面。多一层管理就有多一层认知负担。

但如果你跟我一样，手里同时有 Claude 和 OpenAI 的订阅，一个功能想让两个 Agent 各写一版对比，或者前端后端测试并行推进——那 Orca 确实解决了真实存在的混乱。不再是一个人同时盯三个终端窗口手忙脚乱，而是一个面板里所有 Agent 的状态一目了然，diff 批注完一键打回让 Agent 重做。

《孙子兵法》说「凡治众如治寡，分数是也」。tmux 解决了「众 shell 如寡 shell」的问题，让一百个终端会话像管理一个一样。Orca 在做的事一样——让多个 Agent 像管一个一样。

只不过 tmux 的「分数」是窗口和面板，Orca 的「分数」是 worktree 和 Agent。

工具的进化往往是这样：先有人在一个领域把路子走通，然后另一个领域照着这个路子重新做一遍。tmux 走通的是「多路复用终端会话」，Orca 在照着这个路子做「多路复用 AI Agent」。至于它能不能像 tmux 一样成为一代人的肌肉记忆，四个月下结论太早。

但方向，我觉得是对的。

**GitHub**: [stablyai/orca](https://github.com/stablyai/orca)
