#!/bin/bash

# 需要添加导入的文件列表
files=(
  "frontend/src/pages/ArticleList.vue"
  "frontend/src/pages/admin/ProfileSettings.vue"
  "frontend/src/pages/admin/MomentsManagement.vue"
  "frontend/src/pages/admin/ImageSearchSettings.vue"
  "frontend/src/pages/admin/ColumnsManagement.vue"
  "frontend/src/pages/admin/AttachmentManagement.vue"
  "frontend/src/components/blogHome/Columns/ColumnsContent.vue"
)

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    # 检查是否已经有导入语句
    if ! grep -q "import.*getFullUrl" "$file"; then
      # 在 <script setup> 后添加导入
      sed -i '' '/<script setup>/a\
import { getFullUrl } from '"'"'@/utils/urlUtils'"'"';
' "$file"
    fi
  fi
done

echo "导入语句添加完成"
