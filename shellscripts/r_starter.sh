#!/bin/bash
# title: "r_starter"
# author: Hsieh-Ting Lin
# date: "2025-03-11"
# version: 1.0.0
# description:
# --END-- #

# 提示使用者輸入專案名稱
echo "Enter your project name: "
read PROJECT_NAME

# 若未輸入名稱，則使用預設值
PROJECT_NAME=${PROJECT_NAME:-my_project}

# 建立目錄結構
mkdir -p $PROJECT_NAME/{data/raw,data/processed,scripts,R,reports,figures,output}

# 建立 spreadsheet_link_published.txt，填入示範 Google Sheets 連結
echo "https://docs.google.com/spreadsheets/d/e/2PACX-1vTW5h6IUkWYbRoY6hmCmEoTDyBJ08SWSdrADG_Kb3dKBQJDqfykJDakUev8KaKbLoc_hR7eToC6xX58/pub?gid=0&single=true&output=csv" > $PROJECT_NAME/data/raw/spreadsheet_link_published.txt

# 建立 00_get_csv_raw.R
cat <<EOL > $PROJECT_NAME/scripts/00_get_csv_raw.R
# This script reads a Google Sheets CSV link from a text file and downloads the data

# 讀取 Google Sheets 連結
link_file <- "data/raw/spreadsheet_link_published.txt"
if (file.exists(link_file)) {
  google_sheet_link <- readLines(link_file, warn = FALSE)
} else {
  stop("Error: Link file not found.")
}

# 檢查是否正確讀取
if (length(google_sheet_link) == 0) {
  stop("Error: No link found in the file.")
}

# 下載 CSV
csv_data <- read.csv(google_sheet_link, stringsAsFactors = FALSE)

# 存入 processed 資料夾
write.csv(csv_data, "data/processed/data.csv", row.names = FALSE)

print("CSV file successfully downloaded and saved.")
EOL

# 建立 README
cat <<EOL > $PROJECT_NAME/README.md
# $PROJECT_NAME

This is an R project.

## Project Structure
- **data/**: Stores raw and processed data.
- **scripts/**: Contains R scripts for data processing and analysis.
- **R/**: Functions and custom packages (if applicable).
- **reports/**: Output reports and documentation.
- **figures/**: Stores visualizations and plots.
- **output/**: Stores model outputs and results.

## Getting Started
To set up your environment and install dependencies, follow these steps:

1. Open R and set your working directory to the project folder:
   ```r
   setwd("$(pwd)")
   ```

2. Initialize `renv` for dependency management:
   ```r
   install.packages("renv")
   renv::init()
   ```

3. To install packages used in this project:
   ```r
   renv::restore()
   ```
   This will install all required packages recorded in `renv.lock`.

4. To add new packages:
   ```r
   install.packages("<package-name>")
   renv::snapshot()
   ```
   This ensures your dependencies are saved for reproducibility.

## Running the Data Import Script
To fetch the latest data from the Google Spreadsheet:
```r
source("scripts/00_get_csv_raw.R")
```
This script reads the spreadsheet link from `data/raw/spreadsheet_link_published.txt`, downloads the CSV, and saves it in `data/processed/`.

## Version Control
This project is managed with Git. To start tracking changes:
```sh
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin <your-repository-url>
git push -u origin main
```

EOL

# 建立 .gitignore
cat <<EOL > $PROJECT_NAME/.gitignore
# R 產生的暫存檔案
*.RData
*.Rhistory
*.Rproj.user/
*.Rproj
.Renviron
.Rprofile

# renv 相關
renv/library/
renv/staging/

# 資料檔案（如果不希望提交）
data/raw/
data/processed/

# 輸出檔案
output/
figures/
reports/

# Mac 和 Windows 產生的系統檔案
.DS_Store
Thumbs.db
EOL

# 切換到專案目錄並初始化 Git
cd $PROJECT_NAME
git init

echo "R project structure created successfully in $PROJECT_NAME/"
