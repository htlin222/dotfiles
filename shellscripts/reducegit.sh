#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "reducegit"
# Date: "2023-12-31"
# Version: 1.0.0
# Notes: 幫branch 破壞式瘦身
#
# 獲取當前分支名稱並儲存到變量 branchName
branchName=$(git rev-parse --abbrev-ref HEAD)

# 創建一個新的孤立分支 tmp
git checkout --orphan tmp

# 添加所有變更
git add -A

# 提交這些變更
git commit -am "Initial commit"

# 刪除原有的分支
git branch -D "$branchName"

# 將新分支重命名為原分支名稱
git branch -m "$branchName"

# 強制推送到遠端倉庫
# git push -f origin "$branchName"
