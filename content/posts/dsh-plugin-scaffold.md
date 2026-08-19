---
title: '别只围观 DSH：一小时写出你的第一个 DeepSeek Harness 插件'
date: 2026-08-19T17:18:00+08:00
tags: [AI, Agent, DeepSeek, 开源]
categories: [技术]
cover: /images/dsh-plugin-scaffold-cover.jpeg
---

> 全文约1800字，阅读需5分钟

<!--more-->

# 别只围观 DSH：一小时写出你的第一个 DeepSeek Harness 插件

前几天 V2EX 上有篇热帖，《体验完 DeepSeek Harness，我打算放弃开发了两年的客户端》。一位做了两年客户端的创业者，试用 DSH 之后当场决定停掉自研，全面搬过去。帖子最有洞察的一句话是——**DSH 值得关注的不是让 AI 写代码，而是把 AI 应用的全套基建——agent、工具调用、权限、记忆、存储、甚至 UI——全做成了插件化的开源底座**。

帖子末尾他说，预览版发布短短几天，全球已有开发者贡献各种插件。

但一个很现实的问题被略过了：**这些插件到底怎么写？** 官方文档埋在 monorepo 的 docs/ 目录里，教程默认你有一份源码 checkout，还在纠结 `pnpm dsh` 怎么跑。想快速入场的人，门槛其实不低。

所以我把自己踩完坑后的经验整理成了一个**开箱即用的插件脚手架**，开源在这里：

> **https://github.com/trevanzhang/dsh-plugin-template**

不用 clone DSH 仓库，不用理解它的 monorepo，一个目录就是一个标准的第三方插件。

## 插件到底是什么

三层结构，剥开看其实很简单：

**1. 插件本体**——一个导出 `apply(ctx)` 函数的 TypeScript 模块。框架加载时调用 `apply`，你通过 `ctx` 注册工具、事件监听、服务。卸载时自动清理，不用手写 removeListener。

**2. 组合包（bundle）**——一个 npm 包，`package.json` 里声明 `dsh.bundle`，指向一个 `cordis.patch.yml` 配置层。用户 `dsh plugin add` 安装的就是这玩意儿。

**3. profile**——用户侧的启动组合，dsh CLI 自己维护，插件作者完全不用管。

说白了，**写插件就是写一个普通的 npm 包**。类型来自已发布的 `@deepseek-ai/cordis` 等包，`npm install` 就有，跟 DSH 仓库没有任何关系。

## 脚手架里有什么

```
├── package.json        # dsh.bundle 声明 + peerDependencies
├── cordis.patch.yml    # 配置层，按包名引用自己
├── tsdown.config.ts    # 独立构建配置，不依赖 monorepo
├── src/index.ts        # apply(ctx) 入口，带注释示例
├── lib/                # 构建产物，随仓库提交
├── dev.cordis.yml      # 开发期 --patch overlay
├── examples/tool.ts    # 完整示例：一个带配置的 greet 工具
├── tests/index.test.ts # vitest 最小测试
├── scripts/rename.sh   # fork 后一键改名
├── scripts/verify.sh   # 标准验证，CI 也跑它
└── .github/workflows/  # GitHub Actions
```

每个文件都是我踩完坑之后攒下来的经验——哪些该有、哪些不该有、怎么组织能让别人 fork 之后最快上手。`docs/` 目录下还有一份 AGENT-GUIDE 速查表，按「你想做什么 → 用什么 API」组织，不用从头翻官方教程。

## 三个设计决策

脚手架里有几个设计决策值得单独说。官方教程没怎么强调，但如果你打算在 GitHub 上分发插件，这些就是生死线。

### lib/ 产物随仓库提交

用户从 GitHub 安装你的插件（`dsh plugin add github:you/your-plugin`）时，pnpm 拉的是**源码**。但 pnpm ≥10 默认拒绝执行 git 依赖的构建脚本——指望 `prepare` 兜底，靠不住。

我的做法是把 `lib/` 构建产物直接提交进仓库，安装就能用。代价是每次改源码都必须重建并一起提交，这事交给 `scripts/verify.sh` 把关。`prepare` 脚本仍保留作 npm 源码安装的兜底，且必须是自包含的——不能假设旁边有 monorepo checkout，不能依赖类型检查。

### 宿主依赖全部外部化

`@deepseek-ai/*` 一律走 peerDependencies，并在 tsdown 的 `external` 里排除。插件运行时由宿主提供，打进产物只会造成双实例和体积浪费。这个坑我踩过一次，排查了半天才发现加载了两份 cordis，事件注册全乱套。

### 改名和验证脚本化

包名散落在 `package.json`、`src/index.ts` 导出名、`cordis.patch.yml` 插件行、`dev.cordis.yml`……手动改必漏，漏了就加载失败。`scripts/rename.sh` 一键替换并校验包名合法；`scripts/verify.sh` 跑的是同一套：类型检查 → 构建 → 加载产物断言 `apply` 导出 → 检查 patch 层按包名引用 → 检查 `lib/` 与源码同步。CI 跑的也是这套，忘了重建 `lib/` 会在远端被拦下。改一遍名两分钟，漏掉一个地方排查两小时——这笔账不难算。

## 开发循环

启动开发环境，两步：

```sh
npm install && npm run build
dsh web --patch ./dev.cordis.yml   # 打开 127.0.0.1:3080，看启动日志
```

改完代码跑一遍验证（也可以 push 后交给 CI）：

```sh
bash scripts/verify.sh && npm test
```

想验证最终形态，直接 link 进 profile：

```sh
dsh plugin --profile demo add ~/your-plugin
dsh --profile demo
```

从 `src/index.ts` 的模板起步，注册一个工具、加一份 Schema 配置、监听几个事件——`examples/tool.ts` 是可运行的完整示例，照着改就行。

## 写在最后

回到那篇帖子。作者把 DSH 类比开源安卓：普通团队自研 agent 基建不可能追上 DeepSeek 的投入，正确姿势是基于底座做"小米、OPPO"。这个类比对插件作者同样成立——**早期生态的插件是最容易被用起来的**。deepseek-harness 组织下的 turtle-ui、社区里的 subscriptions 插件（把 ChatGPT、Claude、Grok 订阅变成 DSH 的 LLM provider）都已经跑通了这条路径。

那位 V2EX 作者想做的事——把自己的客户端能力插件化、打包成自己的发行版——正是这个脚手架的完整使用场景。核心逻辑做成插件，配置层交给 `cordis.patch.yml`，剩下的基建全部白嫖 DSH。

与其围观"杀死比赛"，不如花一小时真的写一个。Fork 它，跑一遍 `rename.sh`，删掉 template，开始写你的功能。欢迎在 issue 里告诉我你用它在做什么。

---

*脚手架参考了官方 turtle-ui 与社区 dsh-plugin-subscriptions 的实际配置；docs/ 内文档复制自 deepseek-harness 仓库（MIT）。*

**GitHub**: [trevanzhang/dsh-plugin-template](https://github.com/trevanzhang/dsh-plugin-template)