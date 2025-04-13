#!/bin/bash

# 设置变量  本地仓库地址很重要！！！
APP_PATH="/opt/1panel/resource/apps/local"
# 拉不下来就使用代理，记得修改代理地址
REPO_URL="https://github.com/baishicoke/1panel-app"
PROXY_URL="http://192.168.1.12:7777"

# 可选：为 git 等命令临时设置代理
export http_proxy=$PROXY_URL
export https_proxy=$PROXY_URL

# 克隆 demo 分支
git clone -b demo "$REPO_URL" "$APP_PATH/appstore-localApps"

# 拷贝 clash 应用
cp -rf "$APP_PATH/appstore-localApps/clash/"* "$APP_PATH/"

# 删除克隆的临时 appstore-localApps 目录
rm -rf "$APP_PATH/appstore-localApps"

# 取消代理（如果不想后续命令再使用）
unset http_proxy
unset https_proxy

echo "Clash 应用更新完成，代理已使用 $PROXY_URL"
