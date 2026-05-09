#!/bin/bash
# add-summary-divider.sh - 给文章添加摘要分隔符
# 在标题后第一段结束处插入 <!--more-->

POSTS_DIR="$HOME/projects/blog/content/posts"

for file in "$POSTS_DIR"/*.md; do
    # 检查是否已有 <!--more-->
    if grep -q "<!--more-->" "$file"; then
        echo "[跳过] $(basename $file) - 已有分隔符"
        continue
    fi
    
    # 在第一个 ## 标题后的第一段末尾插入 <!--more-->
    # 或者在第一个空行后插入
    python3 << PYEOF
import re

with open('$file', 'r', encoding='utf-8') as f:
    content = f.read()

# 找到 frontmatter 结束后的第一个段落
# 在第一个完整的段落后插入 <!--more-->
lines = content.split('\n')
insert_idx = None

for i, line in enumerate(lines):
    # 跳过 frontmatter
    if i < 5:
        continue
    # 找到第一个非空行后的第一个空行
    if line.strip() and i > 5:
        # 继续找下一行
        if i+1 < len(lines) and lines[i+1].strip() == '':
            insert_idx = i + 1
            break

if insert_idx:
    lines.insert(insert_idx, '<!--more-->')
    lines.insert(insert_idx, '')
    with open('$file', 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print(f"[已添加] $(basename $file)")
else:
    print(f"[跳过] $(basename $file) - 未找到合适位置")
PYEOF
done

echo "完成！"
