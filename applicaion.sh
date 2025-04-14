#!/bin/bash

# === 用户配置项 ===
USE_PROXY=true   # 是否启用代理（true/false）
PROXY_URL="http://192.168.1.12:7777"

# === 获取 1Panel 安装路径 ===
BASE_DIR=$(which 1pctl | xargs grep '^BASE_DIR=' | cut -d'=' -f2)

# 检查 BASE_DIR 是否有效
if [[ -z "$BASE_DIR" || ! -d "$BASE_DIR" ]]; then
  echo "❌ 无法获取 1Panel 安装路径，退出。"
  exit 1
fi

# 设置路径和仓库
APP_PATH="$BASE_DIR/1panel/resource/apps/local"
REPO_URL="https://github.com/baishicoke/1panel-app"
BRANCH_NAME="demo"
TMP_DIR="$APP_PATH/appstore-localApps"

# 代理设置
if [[ "$USE_PROXY" == true ]]; then
  export http_proxy="$PROXY_URL"
  export https_proxy="$PROXY_URL"
  echo "🌐 已启用代理：$PROXY_URL"
else
  echo "🚫 未启用代理。"
fi

# 清理旧的临时目录（如果存在）
[ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"

# 克隆指定分支
echo "🚀 正在克隆 $BRANCH_NAME 分支..."
git clone -b "$BRANCH_NAME" "$REPO_URL" "$TMP_DIR"
if [ $? -ne 0 ]; then
  echo "❌ 克隆失败，请检查网络、代理或仓库地址是否正确。"
  [[ "$USE_PROXY" == true ]] && unset http_proxy https_proxy
  exit 2
fi

# 拷贝 Clash 应用到目标目录
echo "📂 正在复制 Clash 应用到 $APP_PATH ..."
cp -rf "$TMP_DIR/clash/"* "$APP_PATH/"

# 删除临时目录
rm -rf "$TMP_DIR"

# 清除代理变量
[[ "$USE_PROXY" == true ]] && unset http_proxy https_proxy

# 成功提示
echo -e "\n✅ Clash 应用已成功复制到：$APP_PATH"
# by tomato