#!/bin/bash
# sync-blog.sh - 从 wechatPub 同步文章到博客目录
# 用法: ./sync-blog.sh [文章文件名.md]
# 如果不指定文件名，则同步所有未发布的草稿

set -e

SOURCE_DIR="$HOME/wechatPub/drafts"
DEST_DIR="$HOME/projects/blog/content/posts"
LOG_FILE="$HOME/projects/blog/.sync.log"

# 确保目标目录存在
mkdir -p "$DEST_DIR"

# 记录同步时间
echo "=== 同步开始: $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"

SYNCED=0
SKIPPED=0

# 如果指定了文件名，只同步该文件
if [ -n "$1" ]; then
    src_file="$SOURCE_DIR/$1"
    if [ ! -f "$src_file" ]; then
        echo "错误: 文件不存在 $src_file"
        exit 1
    fi
    FILES=("$src_file")
else
    # 否则同步所有 .md 文件
    while IFS= read -r -d '' file; do
        FILES+=("$file")
    done < <(find "$SOURCE_DIR" -maxdepth 1 -name "*.md" -type f -print0)
fi

for src_file in "${FILES[@]}"; do
    # 获取文件名
    filename=$(basename "$src_file")
    dest_file="$DEST_DIR/$filename"

    # 如果目标文件已存在，跳过
    if [ -f "$dest_file" ]; then
        echo "[跳过] $filename (已存在)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # 使用 Python 处理文件 (更安全，支持特殊字符)
    python3 << PYEOF
import re
import os
from datetime import datetime

src = "$src_file"
dest = "$dest_file"

with open(src, 'r', encoding='utf-8') as f:
    content = f.read()

# 提取原 frontmatter
title_match = re.search(r"^title:\s*['\"]?(.+?)['\"]?\s*$", content, re.MULTILINE)
title = title_match.group(1) if title_match else "Untitled"

# 从文件名提取日期
filename = os.path.basename(src)
date_match = re.match(r'^(\d{4}-\d{2}-\d{2})', filename)
if date_match:
    date = date_match.group(1)
else:
    date = datetime.now().strftime('%Y-%m-%d')

# 提取正文 (去掉原 frontmatter)
body = re.sub(r'^---\s*\n.*?\n---\s*\n', '', content, flags=re.DOTALL)

# 生成新的 frontmatter (去掉 cover 字段，避免 PaperMod 报错)
new_frontmatter = f"""---
title: '{title}'
date: {date}T00:00:00+08:00
tags: []
categories: []
---"""

# 写入目标文件
with open(dest, 'w', encoding='utf-8') as f:
    f.write(new_frontmatter + '\n\n' + body)

print(f"[同步] {filename}")
PYEOF

    SYNCED=$((SYNCED + 1))
done

echo "同步完成: $SYNCED 篇已同步, $SKIPPED 篇已跳过" | tee -a "$LOG_FILE"
echo "" >> "$LOG_FILE"
