---
title: 'Cherry Studio 口碑与测评综合报告'
date: 2026-05-24
tags: ['AI', '工具测评', '开源', '客户端']
categories: ['技术思考']
---

# Cherry Studio 口碑与测评综合报告

> 报告日期：2026-05-24  
> 数据来源：GitHub Issues、知乎、CSDN、阿里云开发者社区、LINUX DO、B站测评、各技术博客

---

## 一、产品概况

Cherry Studio 是一款开源、免费的跨平台 AI 对话客户端，由 Cherry HQ 团队开发。支持 Windows、macOS、Linux，核心定位是"多模型聚合 AI 生产力工具"。主要特性包括：

- **多模型支持**：兼容 OpenAI、Claude、Gemini、DeepSeek、Mistral 等主流 LLM 服务商，内置 300+ 预配置 AI 助手
- **本地模型接入**：深度支持 Ollama、LM Studio 等本地大模型
- **知识库与 RAG**：支持多种文件格式的本地知识库构建和检索增强生成
- **思考过程可视化**：展示 AI 推理步骤
- **AI 绘画、翻译**等多功能集成
- **高度自定义**：支持本地按需开发

GitHub 仓库：`CherryHQ/cherry-studio`，约 1.8k Stars，Issues 活跃（10+ open issues）。

---

## 二、正面评价汇总

### 2.1 UI/UX 设计获广泛认可

多个测评文章一致称赞 Cherry Studio 的界面设计：

> "Cherry Studio 在设计上明显更加精致，有着类似高端应用的质感，界面更为美观。" —— Apiyi 对比测评

> "优雅精致，注重视觉美感。柔和舒适，护眼配色。空间感强，层次分明。" —— 阿里云开发者社区横评

### 2.2 知识库与 RAG 功能突出

> "Cherry Studio 在本地知识库构建和 RAG 功能上表现突出，支持多种文件格式，对需要处理大量本地文档的用户非常实用。" —— 2025 年跨平台桌面 AI 客户端评测报告

### 2.3 多模型横向评测能力

> "Cherry Studio 对本地大模型（Ollama/LM Studio）的支持更加深度，且其内置的 Prompt 优化工具和多模型横向评测功能对于模型调试非常友好。" —— cnblogs 技术调研

### 2.4 可视化功能受好评

> "Cherry Studio 通过消息生命周期可视化，展示从用户提问到最终回答的完整流程，包括网络搜索、知识库检索等步骤。" —— GitCode 文章

> "思考过程可视化功能对理解 AI 推理有帮助，特别适合学习和教育场景。" —— 多家测评一致观点

### 2.5 开源免费，社区活跃

GitHub Issues 活跃，用户反馈积极，功能迭代速度快。被多次列入 GitHub 热门 AI 项目推荐。

---

## 三、负面评价与问题汇总

### 3.1 PDF 解析 Bug 引发强烈不满（2026-03）

> "从 v1.7.19 版本开始，软件在处理多模态 PDF 时出现严重倒退（Regression），包括强制剔除 PDF 内图片、超过 10MB 文件无法上传等 P1 级 Bug。尽管官方已在 GitHub Issues 承认问题，但在随后更新的多个版本中，团队似乎优先开发 Agents 等新功能而未修复基础体验，这种'重营销轻稳定'的开发策略遭到用户猛烈吐槽。" —— 80aj.com 报道

这是目前社区反映最强烈的质量问题。

### 3.2 自动更新导致数据丢失

> GitHub Issue #4076：自动更新后，列表所有的助手及话题全都消失。用户反馈更新后配置和会话历史丢失。

### 3.3 中文用户名兼容性问题

> LINUX DO 社区讨论：Windows 中文用户名导致 MCP 功能无法正常工作，目前无完美解决方案。

### 3.4 图片/文件上传问题

> GitHub Issue #2732：通过 Aihubmix 接入的 API 大部分不能读取图片或文件，添加的 API 模型权限一致（已打开图片），且回答文字问题全部正常。

### 3.5 性能与资源占用

对比 Chatbox，Cherry Studio 被多次指出性能偏弱：

| 维度 | Cherry Studio | Chatbox |
|------|--------------|---------|
| 响应速度 | 流畅但偶有卡顿 | 响应更快，轻量高效 |
| 内存占用 | 建议 4GB+ | 建议 2GB+ |
| 存储空间 | 约 200MB | 约 100MB |
| CPU 要求 | 中等 | 较低 |

> "Cherry Studio 虽然设计精美，但可能在某些复杂操作时显得略微迟缓。" —— Apiyi 对比测评

### 3.6 缺乏移动端支持

Cherry Studio 目前仅支持桌面端（Windows/macOS/Linux），不支持 iOS/Android/Web，这是与 Chatbox 相比的明显短板。

---

## 四、竞品对比

### 4.1 vs Chatbox

| 维度 | Cherry Studio | Chatbox |
|------|--------------|---------|
| UI 设计 | ★★★★★ 精致美观 | ★★★☆☆ 简洁实用 |
| 响应速度 | ★★★☆☆ 偶有卡顿 | ★★★★★ 轻量快速 |
| 移动端 | ❌ 不支持 | ✅ iOS/Android/Web |
| 知识库/RAG | ★★★★★ 功能强大 | ★★☆☆☆ 基础支持 |
| 思考可视化 | ✅ 支持 | ❌ 不支持 |
| 开源定制 | ✅ 开源 | ✅ 开源 |
| 上手难度 | 低（适合非技术用户） | 低-中（部分高级功能需学习） |

**适用场景**：
- Cherry Studio：注重视觉体验、需要知识库/RAG、桌面端使用
- Chatbox：需要移动端、追求效率、频繁切换模型对比

### 4.2 vs AnythingLLM

| 维度 | Cherry Studio | AnythingLLM |
|------|--------------|-------------|
| 定位 | 多模态内容创作 | 企业级知识管理 |
| 部署 | 桌面客户端 | 支持 Docker 服务端部署 |
| RAG 能力 | 强（多文件格式） | 极强（全栈知识管理） |
| 安全性 | 本地存储 | 安全合规导向 |
| 易用性 | 高 | 中（需一定技术背景） |

### 4.3 vs LM Studio

| 维度 | Cherry Studio | LM Studio |
|------|--------------|-----------|
| 定位 | 多模型聚合客户端 | 本地模型运行平台 |
| 云端模型 | ✅ 支持 | ❌ 仅本地 |
| 本地模型 | ✅ 深度支持 | ✅ 核心功能 |
| Prompt 优化 | ✅ 内置工具 | 基础支持 |
| 模型评测 | ✅ 多模型横向对比 | 单模型测试 |

---

## 五、社区声音摘要

### 正面

- "最强 AI 客户端：Cherry Studio，开源，免费，强大！！" —— 火山引擎文章
- "用了 Cherry Studio，我第一次意识到：AI 工具不该只是聊天框" —— 腾讯云开发者社区
- "试了一下 cherry studio 和 chatbox，感觉前者更好用" —— LINUX DO 社区
- "Cherry Studio 提供了超过 300 个预配置的 AI 助手，覆盖了从编程开发到创意写作的各个领域" —— chawfoo.com

### 负面

- "只卷 Agent 忽视核心体验，多模态 PDF 解析 Bug 数版未修" —— 80aj.com
- "自动更新后列表所有的助手及话题全都消失" —— GitHub Issue #4076
- "Win 中文用户名害人啊" —— LINUX DO 社区（MCP 功能兼容性问题）
- "API 无法识别图片" —— GitHub Issue #2732

---

## 六、综合评估

### 优势

1. **UI/UX 设计**在同类产品中领先，视觉体验优秀
2. **知识库与 RAG**功能强大，适合需要处理本地文档的用户
3. **多模型聚合**能力全面，云端+本地模型均支持
4. **思考可视化**功能有教育价值
5. **开源免费**，社区活跃，迭代快

### 劣势

1. **稳定性问题**：PDF 解析 Bug 多版本未修，自动更新丢数据
2. **性能偏弱**：相比 Chatbox 更重，响应稍慢
3. **无移动端**：仅限桌面端
4. **兼容性**：中文用户名等边缘场景支持不足
5. **开发策略争议**：社区质疑"重新功能轻基础体验"

### 适合人群

- ✅ 注重视觉体验和交互设计的用户
- ✅ 需要知识库/RAG 功能的知识工作者
- ✅ 需要多模型横向对比的研究者
- ✅ 非技术背景但想使用多模型的用户
- ✅ 教育/学习场景（思考可视化）

### 不适合人群

- ❌ 需要移动端随时使用的用户
- ❌ 对稳定性要求极高的生产环境
- ❌ 低配置设备用户
- ❌ 需要处理大量 PDF 文档且依赖图片的用户（当前版本）

---

## 七、结论

Cherry Studio 是一款**功能丰富但稳定性有待提升**的 AI 客户端。它在 UI 设计、知识库/RAG、多模型聚合方面表现突出，适合注重视觉体验和功能多样性的用户。然而，PDF 解析 Bug、自动更新数据丢失、性能偏弱等问题也值得警惕。

**建议**：
- 如果是**个人学习和日常使用**，Cherry Studio 是优秀选择
- 如果是**生产环境或关键工作流**，建议等待 PDF 等核心 Bug 修复后再考虑
- 如果需要**移动端支持**，Chatbox 是更合适的选择
- 如果主要需求是**企业级知识管理**，AnythingLLM 更专业

---

*报告完毕。数据来源已标注，可自行点击链接查看原文。*

---

## 八、参考资料

### 测评与横评文章

| # | 标题 | 来源 | 链接 |
|---|------|------|------|
| 1 | 2025年跨平台桌面AI客户端评测报告：普通用户视角 | javalover123 | https://www.890808.xyz/ai-desktop-client-compare/ |
| 2 | AnythingLLM vs Cherry Studio vs Chatbox：三大AI工具深度横评 | 阿里云开发者社区 | https://developer.aliyun.com/article/1691986 |
| 3 | 最强AI 客户端：Cherry Studio，开源，免费，强大！！ | 火山引擎 | https://developer.volcengine.com/articles/7535763436589105215 |
| 4 | Chatbox AI vs Cherry Studio：两款免费个人知识库工具如何选？深度横评 | XMSUMI | https://www.xmsumi.com/detail/1148 |
| 5 | Cherry Studio：是你所期望的最棒的AI 对话客户端 | quick-rss #70 | https://github.com/jaywcjlove/quick-rss/issues/70 |
| 6 | 大语言模型客户端工具--Cherry Studio | 知乎专栏 | https://zhuanlan.zhihu.com/p/10585626732 |
| 7 | [技术调研/AI] 开源软件调研(AI客户端应用)：ChatBox / Cherry Studio | cnblogs | https://www.cnblogs.com/know-data/p/19803951 |
| 8 | Cherry Studio：让AI交互看得见摸得着的可视化革命 | GitCode | https://blog.gitcode.com/f25bdd7a3422330d93b1e6663890926f.html |
| 9 | 用了Cherry Studio，我第一次意识到：AI工具不该只是聊天框 | 腾讯云开发者社区 | https://cloud.tencent.com/developer/article/2609497 |
| 10 | Cherry Studio：AI桌面客户端的优选 | chawfoo | https://www.chawfoo.com/posts/ai4/ |
| 11 | Cherry Studio 与 Chatbox 全面对比：选择最适合你的AI 对话客户端 | Apiyi Blog | https://help.apiyi.com/cherry-studio-vs-chatbox-comparison.html |
| 12 | 国产开源AI平台Cherry Studio详解：联网搜索升级与ChatBox对比指南 | 知乎专栏 | https://zhuanlan.zhihu.com/p/27467823353 |
| 13 | [已审核]2025年AI大模型管理工具选型指南：Cherry Studio、Chatbox | cencrack | http://cencrack.com/?post=23 |
| 14 | 试了一下cherry studio和chatbox，感觉前者更好用 | LINUX DO | https://linux.do/t/topic/324484 |
| 15 | 打编程之024：免费本地AI客户端-Chatbox和CherryStudio | 博客园 | https://www.cnblogs.com/boyogala/p/19033962 |
| 16 | 【测评】对比三大主流LLM交互平台Chat Box、Cherry Studio、Page Assist | B站 | https://www.bilibili.com/video/BV1f3AYesERV/ |

### 问题与负面反馈

| # | 标题 | 来源 | 链接 |
|---|------|------|------|
| 17 | Cherry Studio 遭用户质疑：只卷Agent 忽视核心体验，多模态PDF 解析Bug 数版未修 | 80aj.com | https://www.80aj.com/2026/03/19/cherry-studio-pdf-bug/ |
| 18 | [讨论] cherry-studio 自动更新后，列表所有的助手及话题全都消失 | GitHub #4076 | https://github.com/CherryHQ/cherry-studio/issues/4076 |
| 19 | [错误] api無法識別圖片 | GitHub #2732 | https://github.com/CherryHQ/cherry-studio/issues/2732 |
| 20 | 【win中文用户名害人啊！】求cherry-studio用mcp但... | LINUX DO | https://linux.do/t/topic/743905 |
| 21 | [错误] 本地知识库上传PDF预处理失败 | GitHub #9068 | https://github.com/CherryHQ/cherry-studio/issues/9068 |
| 22 | [错误] pdf 上传后无法读取且一直报错 | GitHub #8753 | https://github.com/CherryHQ/cherry-studio/issues/8753 |
| 23 | [错误] 无法使用知识库（API和本地模型都无法调用） | GitHub #9490 | https://github.com/CherryHQ/cherry-studio/issues/9490 |
