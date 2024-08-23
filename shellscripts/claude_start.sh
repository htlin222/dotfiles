#!/bin/bash
# title: "claude_start"
# author: Hsieh-Ting Lin
# date: "2024-08-24"
# version: 1.0.0
# description:
# --END-- #
set -ue
set -o pipefail
trap "echo 'END'" EXIT

# 檢查是否有提供專案名稱
if [ -z "$1" ]; then
  echo "請提供專案名稱作為參數。"
  exit 1
fi

PROJECT_NAME=$1

# 移除已有的專案目錄
rm -rf $PROJECT_NAME

# 使用非互動模式創建新的 React app
npm create vite@latest $PROJECT_NAME -- --template react
cd $PROJECT_NAME
npm install

# 安裝 TailwindCSS 和其他依賴
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# 更新 vite.config.js
cat <<EOL >vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
EOL

# 創建 jsconfig.json
cat <<EOL >jsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*"]
}
EOL

# 顯示配置提示
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "
✔ Would you like to use TypeScript (recommended)? ${GREEN}no${NC}
✔ Which style would you like to use? › ${GREEN}Default${NC}
✔ Which color would you like to use as base color? › ${GREEN}Slate${NC}
✔ Where is your global CSS file? … ${GREEN}src/index.css${NC}
✔ Would you like to use CSS variables for colors? … ${GREEN}yes${NC}
✔ Are you using a custom tailwind prefix eg. tw-? (Leave blank if not) …
✔ Where is your tailwind.config.js located? … ${GREEN}tailwind.config.js${NC}
✔ Configure the import alias for components: … ${GREEN}@/components${NC}
✔ Configure the import alias for utils: … ${GREEN}@/lib/utils${NC}
✔ Are you using React Server Components? … ${GREEN}no${NC}
✔ Write configuration to components.json. Proceed? … ${GREEN}yes${NC}
"

# 初始化 shadcn-ui（會觸發互動式配置）
npx shadcn-ui@latest init

# 添加所有 shadcn-ui 組件
npx shadcn-ui@latest add all -y

# 安裝其他依賴
npm install lucide-react

echo " 🎉 Project '${GREEN}$PROJECT_NAME${NC}' is ready to go! 🎉"
