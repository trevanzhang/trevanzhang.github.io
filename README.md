# Trevan 的博客

基于 Hugo + PaperMod 主题的个人博客，自动从微信公众号草稿同步文章。

## 工作流

```
微信公众号草稿 (Obsidian/Syncthing)
        ↓
   sync-blog.sh (同步脚本)
        ↓
   Hugo 构建
        ↓
   GitHub Pages (https://trevan.github.io)
```

## 使用方法

### 同步文章

```bash
# 同步所有草稿
./sync-blog.sh

# 同步指定文章
./sync-blog.sh "文章文件名.md"
```

### 本地预览

```bash
hugo server --buildDrafts
```

### 部署

推送到 GitHub 后，GitHub Actions 会自动构建并部署到 GitHub Pages。

```bash
git add .
git commit -m "new post"
git push origin main
```

## 技术栈

- **Hugo** - 静态站点生成器
- **PaperMod** - 简洁现代的主题
- **GitHub Actions** - 自动构建和部署
- **GitHub Pages** - 免费托管

## 目录结构

```
├── content/posts/    # 博客文章
├── static/assets/    # 静态资源 (图片)
├── themes/PaperMod/  # 主题
├── hugo.toml         # 站点配置
└── sync-blog.sh      # 同步脚本
```
