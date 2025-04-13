#!/bin/bash

# 获取 1Panel 安装路径（BASE_DIR）
BASE_DIR=$(which 1pctl | xargs grep '^BASE_DIR=' | cut -d'=' -f2)

# 设置变量
APP_PATH="$BASE_DIR/1panel/resource/apps/local"
REPO_URL="https://github.com/baishicoke/1panel-app"
PROXY_URL="http://192.168.1.12:7777"

# 设置 git 代理环境变量（临时）
export http_proxy=$PROXY_URL
export https_proxy=$PROXY_URL

# 克隆 demo 分支
git clone -b demo "$REPO_URL" "$APP_PATH/appstore-localApps"

# 拷贝 clash 应用
cp -rf "$APP_PATH/appstore-localApps/clash/"* "$APP_PATH/"

# 删除临时目录
rm -rf "$APP_PATH/appstore-localApps"

# 清除代理
unset http_proxy
unset https_proxy

echo -e "\n✅ Clash 应用已复制到 $APP_PATH"
echo "🌐 使用的代理为：$PROXY_URL"
