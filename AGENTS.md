# AGENTS.md - 傲来说博客 AI 助手指南

> 个人博客项目：Hugo + LoveIt 主题，自动从微信公众号草稿同步文章

---

## 📋 项目概览

| 项目 | 信息 |
|------|------|
| **域名** | `https://aolaishuo.cc` |
| **框架** | Hugo v0.147.7 (extended) |
| **主题** | LoveIt |
| **部署** | GitHub Pages (trevanzhang/trevanzhang.github.io) |
| **源码** | ~/projects/blog/ |
| **文章来源** | ~/wechatPub/drafts/ (微信公众号草稿) |

---

## 📁 目录结构

```
~/projects/blog/
├── .github/workflows/
│   └── deploy.yml          # GitHub Actions 部署配置
├── archetypes/
│   └── default.md          # 新文章模板
├── content/
│   └── posts/              # 博客文章 (Markdown)
├── static/
│   └── images/             # 静态资源 (头像、图片等)
├── themes/
│   └── LoveIt/             # 主题 (git submodule)
├── public/                 # 构建输出 (gitignore)
├── hugo.toml               # 站点配置
├── sync-blog.sh            # 微信草稿同步脚本
└── add-summary-divider.sh  # 添加摘要分隔符脚本
```

---

## ⚙️ 核心配置 (hugo.toml)

### 关键配置项

```toml
baseURL = 'https://aolaishuo.cc/'
title = '傲来说的博客'
theme = 'LoveIt'

[params.header.title]
  name = '傲来说'  # 导航栏标题

[params.home.profile]
  title = '你好，我是傲来说 👋'
  subtitle = 'AI Agent 开发者 | 投资爱好者 | 技术思考者'
```

### ⚠️ 主题配置注意事项

LoveIt 主题的标题配置**必须**使用嵌套结构：

```toml
# ✅ 正确
[params.header.title]
  name = '傲来说'

# ❌ 错误 (不会被主题识别)
headerTitle = '傲来说'
```

---

## 🔄 工作流

### 1. 文章发布流程

```
Obsidian 撰写
    ↓
保存到 ~/wechatPub/drafts/
    ↓
运行 ./sync-blog.sh 同步到博客
    ↓
git commit & push
    ↓
GitHub Actions 自动构建部署
```

### 2. 常用命令

```bash
# 同步所有未发布的草稿
./sync-blog.sh

# 同步指定文章
./sync-blog.sh "2026-05-09-文章标题.md"

# 本地预览
hugo server --buildDrafts

# 构建生产版本
hugo --minify

# 查看同步日志
cat .sync.log
```

---

## 🤖 AI 助手任务指南

### ✅ 可以执行的操作

#### 1. 发布新文章

```bash
# 1. 确认草稿已存在于 ~/wechatPub/drafts/
ls ~/wechatPub/drafts/*.md

# 2. 同步到博客
cd ~/projects/blog && ./sync-blog.sh

# 3. 检查同步结果
ls content/posts/

# 4. 提交并推送
git add -A
git commit -m "new post: 文章标题"
git push origin-user main
```

#### 2. 修改配置

- 修改 `hugo.toml` 后，**必须**重新构建验证：

```bash
hugo --minify && grep -r "My cool site" public/ | wc -l
# 应返回 0，确保主题默认值被正确覆盖
```

#### 3. 添加新页面/自定义布局

- 在 `layouts/` 目录下添加自定义模板
- 在 `content/` 目录下添加新页面 (如 `about.md`)

### ❌ 禁止执行的操作

1. **不要直接修改 `public/` 目录** - 这是构建输出，会被覆盖
2. **不要手动编辑 `content/posts/` 中已同步的文章** - 应从源目录修改后重新同步
3. **不要更改主题 submodule 版本** - 除非用户明确要求
4. **不要修改 GitHub Actions 配置** - 除非用户要求更改部署流程

---

## 🔧 故障排查

### 问题：网站显示 "My cool site"

**原因**: LoveIt 主题默认值未被覆盖

**解决**:
```toml
# 确保 hugo.toml 中有正确的嵌套配置
[params.header.title]
  name = '傲来说'
```

然后重新构建：
```bash
hugo --minify
git add -A && git commit -m "fix: 标题配置"
git push
```

### 问题：GitHub Pages 未更新

**检查**:
1. GitHub Actions 是否成功运行：https://github.com/trevanzhang/trevanzhang.github.io/actions
2. 确认推送到了正确的远程仓库 (`origin-user` → trevanzhang.github.io)

### 问题：同步脚本报错

**检查**:
1. 源文件是否存在：`ls ~/wechatPub/drafts/`
2. 查看同步日志：`cat .sync.log`
3. 确保脚本有执行权限：`chmod +x sync-blog.sh`

---

## 📝 文章格式规范

### Frontmatter 模板

```yaml
---
title: '文章标题'
date: 2026-05-09T00:00:00+08:00
tags: [AI, Agent]
categories: [技术]
---
```

### 摘要分隔

使用 `<!--more-->` 分隔摘要和正文：

```markdown
这是摘要内容，会显示在首页...

<!--more-->

这是正文内容...
```

---

## 🔐 远程仓库配置

```bash
# 查看远程仓库
git remote -v

# origin: 备用仓库 (trevanzhang/blog)
# origin-user: 主仓库 (trevanzhang/trevanzhang.github.io)

# 推送到主仓库
git push origin-user main
```

---

## 📊 部署状态

- **构建命令**: `hugo --minify`
- **构建时间**: ~30 秒
- **部署环境**: GitHub Pages (ubuntu-latest)
- **Hugo 版本**: 0.147.7 (extended)

查看部署状态：https://github.com/trevanzhang/trevanzhang.github.io/actions

---

## 🎨 主题定制

LoveIt 主题配置文档：https://hugoloveit.com/zh-cn/categories/configuration/

### 可定制项

- 首页 Profile 区域 (头像、标题、副标题、打字机效果)
- 导航栏菜单
- 社交链接
- 主题配色 (auto/light/dark)
- 文章布局 (目录、代码高亮、社交分享)

---

*最后更新：2026-05-09*
