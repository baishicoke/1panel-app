#!/bin/bash
git clone https://github.moeyy.xyz/https://github.com/MetaCubeX/Yacd-meta.git -b gh-pages ./data/ui

wget -O ./data/country.mmdb https://github.moeyy.xyz/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb

wget -O ./data/geoip.metadb https://github.moeyy.xyz/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb

wget -O ./data/geosite.db https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.db


# 检查 index.html 是否存在
if [ ! -f ./data/ui/index.html ]; then
  echo "错误：未找到 ./data/ui/index.html，git clone 可能失败或目录结构异常。"
  exit 1
fi

# 读取 .env 中的变量
source .env

# 构造新的 URL
NEW_URL="http://${MIHOMO_HOSTNAME}:${PANEL_APP_PORT_9090}"

# 替换 ./data/ui/index.html 中的 data-base-url 内容
sed -i "s|data-base-url=\"[^\"]*\"|data-base-url=\"${NEW_URL}\"|" ./data/ui/index.html

echo "data-base-url 已成功替换为：${NEW_URL}"
