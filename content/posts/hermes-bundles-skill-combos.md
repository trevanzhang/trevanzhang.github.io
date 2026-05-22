---
title: 'Hermes Bundles：把技能打包成"大招组合"，一句指令召唤全部火力'
author: Trevan
published: 2026-05-22
created: 2026-05-22
cover: /images/hermes-bundles-cover.jpg
description: 深入解析 Hermes Agent 的 Skill Bundles 功能，从原理到实战，教你如何用 YAML 文件打造专属的 AI 技能组合。
tags:
  - Hermes
  - AI-Agent
  - 技能管理
  - 效率工具
---

# Hermes Bundles：把技能打包成"大招组合"，一句指令召唤全部火力

## 一、问题：技能多了，管理成了负担

Hermes Agent 的技能系统非常强大。你可以安装各种技能——代码审查、测试驱动开发、PR 工作流、SEO 优化、小红书文案……技能越多，AI 能帮你做的事就越多。

但问题来了：**当你需要同时使用多个技能时，该怎么办？**

手动一个个加载？在聊天里反复输入 `/skill xxx`？这显然不现实。

Hermes 给出的答案是 **Skill Bundles（技能组合）**——把多个技能打包成一个命名组合，通过一条 `/bundle-name` 指令瞬间全部加载。

## 二、核心原理：YAML 驱动的"技能预制菜"

Bundle 的本质是一个 YAML 配置文件，存放在 `~/.hermes/skill-bundles/` 目录下。

官方文档的定义很简洁：

> Skill bundles group several skills under one `/<bundle-name>` slash command. Invoking the bundle loads every referenced skill into a single combined user message.

翻译过来就是：**把多个技能绑定到一个斜杠命令上，调用时一次性全部加载。**

一个典型的 Bundle YAML 文件长这样：

```yaml
name: "backend-dev"
description: "后端功能开发工作流"
instruction: "你是一个后端开发专家。请始终使用 TypeScript 编写代码，严格遵守最佳实践，保持代码简洁。"
skills:
  - github-code-review
  - test-driven-development
  - github-pr-workflow
```

结构一目了然：
- `name`：组合名称，对应 `/backend-dev` 指令
- `description`：人读的描述，方便你记住这是干嘛的
- `instruction`：可选的系统级提示词，给 AI 定调
- `skills`：技能列表，按顺序加载

## 三、创建 Bundle：命令行一键创建

```bash
hermes bundles create backend-dev \
  --skill github-code-review \
  --skill test-driven-development \
  --skill github-pr-workflow \
  -d "后端功能开发工作流"
```

参数说明：
- `create <name>`：创建新组合
- `--skill`：可重复，指定要包含的技能
- `-d` / `--description`：组合描述
- `--instruction`：可选，植入系统级提示词

如果你嫌命令行太长，也可以先创建空 Bundle，再直接编辑 YAML 文件：

```bash
hermes bundles create my-bundle -d "我的自定义组合"
vim ~/.hermes/skill-bundles/my-bundle.yaml
hermes bundles reload
```

## 四、使用 Bundle：聊天中的"大招"

创建好 Bundle 后，在 Hermes 聊天会话中输入：

```
/backend-dev
```

AI 就会同时加载 `github-code-review`、`test-driven-development`、`github-pr-workflow` 三个技能，加上你预设的 instruction，直接进入"后端开发专家"模式。

查看所有已安装的 Bundle：

```
/bundles
```

## 五、实战场景

### 场景 1：全栈开发工作流

```bash
hermes bundles create fullstack-agent \
  --skill nextjs-app-router \
  --skill tailwind-css-expert \
  --skill prisma-orm-helper \
  --skill postgres-db-designer \
  --instruction "你是一个全栈开发专家。请始终使用 TypeScript 编写代码，严格遵守 Next.js 14+ 的最佳实践，保持代码简洁，不写废话。" \
  -d "用于快速构建和调试 Next.js + Prisma 全栈应用的专家组合"
```

### 场景 2：自媒体内容矩阵

```bash
hermes bundles create content-marketing \
  --skill xiaohongshu-copywriting \
  --skill SEO-keyword-optimizer \
  --skill twitter-thread-craftsman \
  --skill translation-localization \
  -d "一键将核心观点转化为小红书、Twitter 及 SEO 友好的多平台文案"
```

## 六、管理 Bundle

| 命令 | 作用 |
|------|------|
| `hermes bundles list` | 列出所有已安装的 Bundle |
| `hermes bundles show <name>` | 查看某个 Bundle 的详细信息 |
| `hermes bundles create <name>` | 创建新 Bundle |
| `hermes bundles delete <name>` | 删除指定 Bundle |
| `hermes bundles reload` | 重新扫描目录，刷新配置 |

## 七、为什么 Bundle 比手动加载更聪明？

1. **一次加载，全局生效**：Bundle 会把所有技能合并到一条用户消息中，AI 一次性获得全部上下文，不需要反复切换。
2. **预设 instruction**：可以给整个组合定制系统提示词，让 AI 从一开始就进入"专家模式"。
3. **可复用、可分享**：YAML 文件天然适合版本控制和分享，团队可以统一 Bundle 配置。
4. **零运行时开销**：Bundle 只是 YAML 文件，加载时直接读取，没有任何额外性能损耗。

## 八、进阶技巧

### 技巧 1：用 `--instruction` 给 AI 定调

这是 Bundle 最强大的功能之一。通过 `--instruction`，你可以：
- 指定代码风格（"始终使用 TypeScript"）
- 设定角色（"你是一个安全审计专家"）
- 约束输出格式（"返回 JSON 格式"）

### 技巧 2：配合 Cron Job 自动化

Bundle 可以配合 Hermes 的 Cron Job 功能，定时加载特定技能组合执行任务。比如每天早上加载 `content-marketing` Bundle，自动生成多平台文案草稿。

## 九、总结

Hermes Bundles 是一个看似简单却极其强大的功能。它把"技能管理"从手动操作升级到了"预制组合"的维度，让你可以用一条指令召唤全部火力。

核心就三句话：
1. **YAML 文件定义组合**——`~/.hermes/skill-bundles/` 目录下
2. **命令行创建**——`hermes bundles create` 一键搞定
3. **聊天中 `/bundle-name` 调用**——一键加载全部技能

技能再多，也不怕管理混乱。这就是 Bundle 的价值。
