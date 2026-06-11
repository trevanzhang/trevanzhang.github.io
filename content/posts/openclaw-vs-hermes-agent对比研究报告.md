---
title: 'OpenClaw vs Hermes Agent：两大开源 AI Agent 项目深度对比'
date: 2026-06-11T00:00:00+08:00
tags: ['AI', 'Agent', 'OpenClaw', 'Hermes', '开源', '对比研究']
categories: ['技术思考']
cover:
  image: /images/openclaw-vs-hermes-cover.jpeg
---

# OpenClaw vs Hermes Agent：两大开源 AI Agent 项目深度对比

> 报告日期：2026-06-11 | 数据截止：2026-06-11 GitHub API 快照 | 面向读者：对 AI Agent 感兴趣的技术读者

<!--more---

## 一、引言：为什么这场对比值得关注

2026 年上半年，开源 AI Agent 领域上演了一场令人瞩目的双雄竞速。OpenClaw 以 5 个月 376K star 的速度创造了 GitHub 历史纪录，成为全球 star 数最高的开源项目；Hermes Agent 则在 12 周内冲至 160K star，同龄增速一度超过 OpenClaw。两个项目都宣称自己是"开源 AI Agent"的标杆，但在技术路线、产品哲学和社区文化上却走上了截然不同的道路。

本文基于 GitHub API 实时数据、多平台社区调研（Reddit / V2EX / 知乎 / HN / YouTube / Medium）、GitHub Issues 热点分析以及第三方对比评测，从量化指标、技术架构、社区健康度、痛点和适用场景五个维度，对两个项目进行系统性对比，并为不同需求的读者提供明确的选型建议。

> **置信度说明**：文中结论采用三级标注——[确证事实] 多独立信源交叉验证；[合理推断] 基于已有数据的逻辑推导；[待验证假设] 逻辑合理但缺乏直接证据。

---

## 二、项目概览：一表看清两项目

| 维度 | OpenClaw | Hermes Agent |
|------|----------|-------------|
| **一句话定位** | 全能型 AI Agent 操作系统：全系统访问、全平台消息、全场景覆盖 | 自学习型 AI Agent：越用越强的个人助手，强调记忆-反思-沉淀-复用的学习闭环 |
| **创建时间** [确证事实] | 2025-11-24 | 2025-07-22 |
| **公开时间** [确证事实] | 2026-01（Peter Steinberger 周末项目，1 天破 9K star） | 2026-03-12（Nous Research 去中心化 AI 实验室） |
| **创始人/团队** [确证事实] | Peter Steinberger（PSPDFKit 创始人，2026.2 加入 OpenAI）；项目移交独立基金会 | Nous Research（CEO Jeffrey Quesnelle，前以太坊 MEV 项目）；teknium1 主导 |
| **主语言** [确证事实] | TypeScript (91.4%) | Python (82.5%) |
| **代码规模** [合理推断] | ~156 MB，估算 390 万行 | ~51 MB，估算 128 万行 |
| **开源协议** [确证事实] | MIT | MIT |
| **融资/商业化** [确证事实] | OpenAI $116M 收购；有 SaaS 商业化（openclawai.io）；NVIDIA NemoClaw 企业栈 | ~$70M 融资（加密领域机构，代币计价）；纯开源，无 SaaS |
| **消息平台数** [确证事实] | 23 个（WhatsApp / Telegram / Slack / Discord / Signal / iMessage / 飞书 / LINE / 微信 / QQ 等） | 15+ 个（Telegram / Discord / Slack / WhatsApp / Signal / 飞书 / 钉钉 / 企业微信 / 微信 / QQ / 元宝 等） |
| **技能生态** [确证事实] | ClawHub 44,000+ 技能；100+ 内置 AgentSkills | 40+ 内置工具；自主技能创建机制；agentskills.io 开放标准 |

**关键差异在定位本质**：OpenClaw 追求广度（更多平台、更多技能、更多用户），Hermes Agent 追求深度（更好的记忆、更强的学习、更精的架构）。这不是简单的竞品关系，而是不同技术哲学的产物。

---

## 三、量化数据对比：从数字看差距与趋势

### 3.1 核心指标

| 指标 | OpenClaw | Hermes Agent | 倍数/差异 |
|------|----------|-------------|----------|
| **GitHub Stars** [确证事实] | 364,667 | 145,970 | 2.5x |
| **Forks** [确证事实] | 74,680 | 22,839 | 3.3x |
| **Open Issues** [确证事实] | 4,305（不含 PR） | 6,509（不含 PR） | Hermes 更多 |
| **Closed Issues** [确证事实] | 35,239 | 4,058 | 8.7x |
| **Issue 闭环比** [确证事实] | 1:8.2（每 1 个 Open 对应 8.2 个 Closed） | 1.6:1（Open 超过 Closed） | OpenClaw 处理效率显著更高 |
| **贡献者** [确证事实] | 2,343（README）/ 1,200+（统计文章） | 1,387（README） | 1.7x |
| **总 Commits** [确证事实] | 58,433 | 11,182 | 5.2x |
| **总 Releases** [确证事实] | 204（含大量 alpha/beta） | 15+ stable tag | — |
| **月访问量（2026.4）** | 38M | 未获取 | — |
| **月活用户（2026.4）** | 3.2M | 未获取 | — |

### 3.2 Star 增长曲线对比

**OpenClaw 增长时间线** [确证事实]：
- 2025.11：0 star
- 2026.01.29（公开第 2 天）：106K ⚡
- 2026.03.03：250K（超越 React，史上最多 star 项目）
- 2026.04：346K
- 2026.06.11：~376.7K（star-history.com 全球排名 #6）

**Hermes Agent 增长时间线** [确证事实]：
- 2025.07：0 star
- 2026.03.12（公开发布）：起步
- 2026.04 中旬：100K+（10 周破 10 万）
- 2026.05.21：160K（12 周，同龄增速超过 OpenClaw 同期）
- 2026.06.11：~189K（README 声称）/ 145,970（API 快照）

**增速对比的关键洞察** [合理推断]：OpenClaw 早期爆发力惊人（48 小时涨 34K star），但增速在 3 月后明显放缓。Hermes 虽然起步基数小，但 12 周 160K 的增速在绝对值和增长率上都优于 OpenClaw 同期表现。Medium 的 AI Agent Star Race 数据分析也确认了这一趋势。

> **注意** [确证事实]：Hermes Agent 的 star 数在不同来源间存在 14K-44K 的差异（145K API vs 160K 第三方 vs 189K README），可能源于 star 清洗、fork 去重或缓存延迟。本文在趋势判断上使用多源交叉验证，不依赖单一数据点。

### 3.3 语言构成

| 维度 | OpenClaw | Hermes Agent |
|------|----------|-------------|
| 主导语言 | TypeScript (91.4%) | Python (82.5%) |
| 次要语言 | Swift (3.5%)、JavaScript (2.7%)、Kotlin (1.0%) | TypeScript (13.5%)、JavaScript (1.2%) |
| 语言多样性 | 集中于 TypeScript 生态 | Python 主 + TS 辅，含 Rust/Nix/TeX 等 |

技术栈差异直接影响目标开发者群体：OpenClaw 吸引全栈/前端开发者，Hermes 吸引 AI/ML/后端工程师。

---

## 四、技术架构深度对比

### 4.1 核心架构

| 组件 | OpenClaw | Hermes Agent |
|------|----------|-------------|
| 架构模式 | Hub-and-Spoke：Central Gateway Daemon（WebSocket） | CLI-First 模块化：Gateway 为可选扩展 |
| 运行时 | Node.js 24 | Python 3.11+，uv 包管理 |
| 进程模型 | 长驻 daemon（`ws://127.0.0.1:18789`） | 按需启动（非 daemon） |
| Session 存储 | JSONL 文件 | SQLite |
| 安装方式 | `npm install -g openclaw@latest` | curl 安装脚本 / PowerShell |
| 容器后端 | Docker | Docker / Singularity / Modal / Daytona（6 种终端后端） [确证事实] |

### 4.2 Memory 系统：共同的阿喀琉斯之踵

Memory 是两个项目共同的最薄弱环节，但问题性质不同：

| 子维度 | OpenClaw | Hermes Agent |
|--------|----------|-------------|
| 存储方式 | 文件驱动（MEMORY.md），完全可审计 | AI 策展的 Honcho 用户建模 + FTS5 会话搜索 |
| 跨会话记忆 | 有，但实践中常被吐槽"形同虚设"（尤其国内模型） | 有，V2EX 用户确认第 4-5 天开始记住项目结构和代码风格习惯 [确证事实] |
| 当前痛点 [确证事实] | FTS5 trigram tokenizer 对 **CJK 文本搜索完全失效**（textScore=0）；short-term-recall.json 无限增长致死锁；Active Memory 溢出 | Memory 仅 **2,200 字符上限**；无多层级管理；"啥都往 memory 里塞"（V2EX 用户原话） |
| 改进方向 | Issues 指向 memory-core 架构需要重构 | Honcho 用户建模 + 自主 Curator 持续迭代 |

**分析** [合理推断]：OpenClaw 的 Memory 问题是工程债务（快速增长导致架构未跟上），Hermes 的 Memory 问题是设计取舍（2,200 字符上限是策略选择）。对中文用户而言，OpenClaw 的 CJK 搜索失效是致命短板——这意味着你的中文记忆几乎检索不到。

### 4.3 消息通道层：多平台接入的代价

两者在通道层都面临稳定性挑战，这是"全平台接入"的固有代价：

| 维度 | OpenClaw | Hermes Agent |
|------|----------|-------------|
| 接入平台数 [确证事实] | 23 个 | 15+ 个 |
| 今日 P1 问题 [确证事实] | Telegram 外发消息泄露内部 continuation 文本；WhatsApp auth 未持久化；NO_REPLY 静默回复触发送代级联失败 | macOS 自更新导致服务永久卸载 |
| 通道层问题密度 [确证事实] | 高——跨会话回声循环、DM 挂死、重复投递 | 高——Telegram 双消息、WhatsApp 消息丢弃+CVE、Discord 消息遮挡 |
| 安全事件 [确证事实] | **CVE-2026-25253**（CVSS 8.8）：单次点击获完整机器控制；另有 8 个 CVE | **CVE-2026-48063**（Baileys 供应链漏洞）：影响 WhatsApp；截至 2026-05 无自身 CVE |

### 4.4 Provider / 模型兼容

| 维度 | OpenClaw | Hermes Agent |
|------|----------|-------------|
| 默认模型 [确证事实] | google/gemini-3.1-pro-preview（2026.6.5 版本失败） | 无统一默认（用户自选） |
| Reasoning Token 处理 [确证事实] | thinkingSignature 膨胀至 134KB，Anthropic 拒绝回放 | MiniMax 中文推理标签泄漏到用户输出；Gemma 4 标准化需求 |
| 本地模型支持 | 有（但国内模型多步骤任务跑偏） | 有（V2EX 用户成功跑 Qwen3.6-35B、Gemma4-26B [确证事实]） |
| 容器后端 [确证事实] | Docker | Docker / Singularity / Modal / Daytona——**6 种终端后端，是显著差异化优势** |

---

## 五、社区健康度评估

### 5.1 贡献者集中度：共同的 Bus Factor 风险

| 维度 | OpenClaw | Hermes Agent |
|------|----------|-------------|
| 核心维护者占比 [确证事实] | steipete 占 55%（32,383/58,433） | teknium1 占 48%（5,318/11,182） |
| Top 5 占比 [确证事实] | ~77% | ~62% |
| Bus Factor 评估 | **极低（1 人）** — Peter 加入 OpenAI 后移交基金会 | **偏低（1-2 人）** — 优于 OpenClaw 但仍脆弱 |
| 社区认可的核心人物 [确证事实] | Vincent Koc（Comet ML 首席 AI 工程师，MIT 讲师）；Michael Galpert（ClawCon 发起人） | teknium1（22 万 X 粉丝）；Jeffrey Quesnelle（CEO） |

### 5.2 Issue 处理效率：被低估的风险信号

OpenClaw 的 Issue 闭环比（1:8.2）远优于 Hermes（1.6:1），说明 OpenClaw 的社区维护力量更充足。而 Hermes 的 Open issues 首次超过了 Closed issues——这是项目维护能力跟不上增长的危险信号 [合理推断]。如果这个趋势持续，可能导致贡献者流失和用户信任下降。

### 5.3 社区讨论质量对比

| 平台 | OpenClaw | Hermes Agent |
|------|----------|-------------|
| Reddit | r/AI_Agents 等多版块活跃，"How is OpenClaw actually useful?" 成热帖 | r/hermesagent 独立子版块；Nous Research 官方 AMA |
| V2EX | 有专版 | 6 篇深度帖文（含完整实测内容，信息量极丰富） |
| 知乎 | 6+ 篇长文，情绪化讨论多——"鸡肋""卸载""伪需求" [确证事实] | 3 篇文章（反爬限制仅获摘要） |
| HN | 讨论重心从"安不安全"转向"怎么用" | 抄袭争议帖（8 分）+ 创业者转型帖（"so underrated"） |
| 整体调性 [合理推断] | 更偏情绪化——搜索热度跌至高峰期 3%，大量负面 | 更偏理性技术讨论——但绝对声量小 |

---

## 六、各自独特优劣势

### 6.1 OpenClaw：规模王者，安全跛脚

**独特优势** [确证事实]：
- 生态规模无可匹敌：376K stars、44K+ 技能、23 个消息平台、500K+ 运行实例
- 技能市场即装即用，信息收集类场景（Reddit 摘要、行业监控）被广泛认可
- 企业化路径清晰：NVIDIA NemoClaw 企业安全栈和 SaaS 商业化
- 品牌认知度全球最高：GitHub 史上 star 最多项目

**独特短板** [确证事实]：
- **安全债务最重**：9 个 CVE（最高 CVSS 8.8）、800 恶意技能包、30,000+ 无认证公网暴露实例
- **Token 成本失控**：heartbeat 每 30 分钟空转唤醒烧 token，月花费 $150-600
- **CJK 中文支持严重缺陷**：FTS5 trigram tokenizer 对中文字符 textScore=0，搜索完全失效
- **代码修改不透明**："黑盒改黑盒"，腾讯云开发者实测吐槽看不到完整变更上下文
- **创始人离场风险**：Peter 加入 OpenAI 后日常维护交接给基金会
- **中文社区口碑下坠**：微信搜索热度跌至高峰期 3%；知乎/V2EX 上"鸡肋""伪需求"成高频词

### 6.2 Hermes Agent：后起之秀，隐患暗藏

**独特优势** [确证事实/合理推断]：
- **学习闭环**：记忆-反思-沉淀-复用的自学习机制，V2EX 用户确认第 4-5 天效果质变
- **技能自动生成**：Agent 自主创建和复用 skill，用户无需手动配置
- **安全架构领先**：设计阶段内置 7 层安全，截至 2026-05 无自身 CVE
- **6 种容器后端**：Docker / Singularity / Modal / Daytona 等，本地模型/异构计算场景最强
- **多入口接续**：电脑开头 Telegram 手机接上，跨设备体验流畅
- **代码透明度高**：Python 技术栈、模块化、SQLite session 可审计
- **同龄增速记录更好**：12 周 160K 星，同龄增速超过 OpenClaw

**独特短板** [确证事实]：
- **Issue 积压最严重**：Open/Closed 1.6:1，维护能力跟不上增速
- **Memory 容量限制**：仅 2,200 字符，对重度用户远远不够
- **抄袭争议未解决**：EvoMap/Evolver 指控 Hermes 抄袭，官方以编辑 issue + 删除评论 + 封禁账号回应，未做正式声明
- **Web3 信任危机**：团队加密背景，融资以代币计价，链上出现非官方 NOUS 代币
- **企业化路径缺失**：无 SaaS、无商业支持方案
- **自改进风险**：自动生成的 skill 可能固化错误假设——V2EX 用户实测发现自动 skill 漏掉了"只在 develop 分支操作"的前提条件，把半成品合入了 main 分支

---

## 七、场景化推荐矩阵

基于技术特性和社区反馈，我们为不同使用场景给出了明确推荐：

| 使用场景 | 推荐 | 核心理由 |
|----------|------|----------|
| 信息自动化收集（新闻摘要、竞品监控） | **OpenClaw** | 44K 技能中此类场景覆盖最广，Reddit/X 技能成熟 [合理推断] |
| 编程辅助 / 代码开发 | **Hermes Agent** | Function Calling 优化更深、代码透明度高、Python 对开发者友好 [合理推断] |
| 个人知识管理 / 学习助手 | **Hermes Agent** | 学习闭环是核心差异化，跨会话记忆实践效果更好 [合理推断] |
| 多平台消息统一网关 | 两者均可 | OpenClaw 平台更多（23 vs 15+），Hermes 通道层相对更稳定 [合理推断] |
| 本地模型 / 隐私优先 | **Hermes Agent** | 6 种容器后端、本地模型成功案例更多（Qwen3.6-35B、Gemma4-26B）[确证事实] |
| 企业部署 / 安全合规 | **OpenClaw（NemoClaw）** | 有企业安全栈和商业化支持；Hermes 无企业方案 [确证事实] |
| 快速尝鲜 / 学习 Agent 概念 | **OpenClaw** | 技能市场即装即用，上手体验更直观 [合理推断] |
| 深度定制 / 研究实验 | **Hermes Agent** | 模块化架构、Python 生态、可审计 [合理推断] |
| 中文用户 | **优先考虑 Hermes** | OpenClaw 的 CJK 搜索失效是硬伤 [确证事实] |

### 决策树

```
你的核心诉求是什么？
├── 即装即用的丰富技能 → OpenClaw
├── 越用越强的自学习能力 → Hermes Agent
├── 企业安全合规 → OpenClaw (NemoClaw)
├── 本地模型/隐私优先 → Hermes Agent
├── 编程辅助 → Hermes Agent
├── 信息收集自动化 → OpenClaw
├── 成本敏感 → Hermes Agent（token 消耗取决于模型选择，但无 OpenClaw 的 heartbeat 空转问题）
├── 中文场景为主 → Hermes Agent（OpenClaw CJK 搜索完全失效）
└── 不确定 → 先试 Hermes（安装更轻量），再按需叠加 OpenClaw
```

社区也提出了**混合部署方案** [合理推断]：用 OpenClaw 做前端 Agent 层（消息接入 + 技能市场），Hermes Agent 做后端专家（学习闭环 + 记忆管理）。Reddit 社区和第三方文章（petronellatech.com）都有类似讨论。

---

## 八、未来趋势判断

### 8.1 短期（2026 Q3-Q4）[待验证假设]

| 趋势 | 概率 | 依据 |
|------|------|------|
| OpenClaw 桌面客户端将发布 | 高（70%） | #75 issue 109 评论、置顶状态、Windows 版已有迹象 |
| Hermes issue 积压将持续恶化 | 高（80%） | 增速快但修复资源有限，结构性矛盾非短期可解 |
| 两者都将大力加强 Memory 系统 | 极高（90%） | Memory 是社区最集中投诉的技术痛点 |
| OpenClaw 将有新的安全事件 | 高（75%） | 800 恶意技能包仅是冰山一角 |

### 8.2 中期（2027 年）[待验证假设]

- **国内大厂竞品挤压空间**：腾讯 QClaw、阿里 JVS Claw、联想天禧 Claw 等已发布产品，OpenClaw 中文市场将进一步被蚕食（概率 70%）
- **Agent 间通信标准化**：OpenClaw 的 ACP 和 Hermes 的 MCP OAuth 2.1 联邦 mesh 是两条并行路线，市场将选择其一或融合（概率 65%）
- **Hermes star 数可能逼近 OpenClaw**：基于"同龄增速更快"的趋势外推，但概率中等（45%）——取决于 OpenClaw 的第二波增长动力

### 8.3 关键风险因素

| 风险 | 影响对象 | 概率 | 破坏力 |
|------|----------|------|--------|
| OpenClaw 大规模安全事件（数据泄露/勒索） | OpenClaw | 中 | **致命** |
| Hermes 抄袭争议升级为法律诉讼 | Hermes | 低 | 高 |
| Nous Research 代币化引发用户出走 | Hermes | 中 | 高 |
| OpenAI 基金会治理失败 | OpenClaw | 中 | 高 |
| 大厂原生 Agent 功能替代独立框架 | 两者 | 中高 | **致命** |

---

## 九、综合选型建议

### 9.1 一句话结论

如果你想找一个**功能齐全、开箱即用的 AI Agent 平台**，选 OpenClaw——但要正视其安全风险和 Token 成本。如果你想找一个**越用越懂你、不断自进化的个人 AI 助手**，选 Hermes Agent——但要做好接受 issue 积压和 Web3 不确定性的心理准备。

### 9.2 分用户画像建议

- **非技术小白用户**：两者都不是最优选。建议等待国内大厂竞品（腾讯 QClaw、联想天禧 Claw）的零部署简化版。
- **个人开发者**：先试 Hermes Agent（安装轻量、学习闭环有长期价值）。如果发现能覆盖到足够多使用场景，就无需再折腾 OpenClaw 的部署门槛。需要特定即用技能时，再补 OpenClaw。
- **企业技术决策者**：OpenClaw + NemoClaw 是当前唯一可企业合规部署的选择。Hermes 的企业方案尚不存在。但建议对 OpenClaw 实施最小权限原则，审计所有安装的技能包。
- **以中文为主要工作语言的用户**：**Hermes Agent 明显更优**。OpenClaw 的中文搜索完全失效，ClawHub 曾因中文字符被标记为"乱码"而删除中文技能包。这不是可修补的小问题，而是架构层面的 CJK 适配缺失。
- **AI 研究者 / 深度定制用户**：Hermes Agent。Python 生态、模块化架构、6 种容器后端、SQLite 可审计 session，这些都是研究友好的特征。

### 9.3 核心发现回顾

| # | 核心发现 | 置信度 |
|---|----------|--------|
| 1 | OpenClaw 规模 2.5 倍于 Hermes，但增速差距在缩小 | [确证事实] |
| 2 | 安全记录是 OpenClaw 最大的差异化负面因素（9 CVE + 800 恶意包） | [确证事实] |
| 3 | 学习闭环是 Hermes 最大的差异化正向因素 | [合理推断] |
| 4 | Memory 系统和通道稳定性是两者共同的核心痛点 | [确证事实] |
| 5 | Hermes 的 issue 积压（1.6:1）是最被低估的风险信号 | [合理推断] |
| 6 | 社区共识倾向"互补而非替代"——两项目技术哲学差异过大 | [合理推断] |
| 7 | 两者都有 bus factor 极低的核心维护者集中风险 | [确证事实] |
| 8 | 中文场景下 Hermes 明显更优，OpenClaw 的 CJK 问题是结构性缺陷 | [确证事实] |

### 9.4 数据局限性

1. Reddit 和知乎的完整帖文因反爬未获取，分析基于摘要和第三方转引，可能遗漏重要观点。
2. Hermes Agent 的 star 数在不同来源间存在不一致（145K API vs 189K README），趋势判断采用多源交叉而非单一数据点。
3. 两个项目的实际活跃用户数均无法精确获取——star 和 fork 不等于用户。
4. 安全评估基于公开 CVE 和社区报告，未进行独立安全审计。Hermes "截至 2026-05 无自身 CVE" 的优势可能只是时间问题。
5. AI Agent 领域变化极快，本文所有判断基于 2026 年 6 月 11 日的快照数据，实际走势可能与预测显著偏离。

---

> **附录**：本文的数据来源包括——GitHub REST API（公开端点）、Reddit / V2EX / 知乎 / Hacker News / YouTube / Medium 社区调研、GitHub Issues 热点分析、flowtivity.ai / innfactory.ai / petronellatech.com 等第三方对比评测、star-history.com 和 openclawvps.io 统计数据。完整参考材料清单见上游分析报告。
