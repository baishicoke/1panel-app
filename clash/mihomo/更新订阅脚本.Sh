#!/bin/bash

# === 可配置变量区域 ===
BASE_URL="https://s.jb/06417fda9305ca8458a79cadba8348e6"
FLAG="&flag=meta"
URL="${BASE_URL}${FLAG}"

CONFIG_DIR="/opt/1panel/apps/local/clashmeta/Mihomo/data"
CONFIG_TMP="${CONFIG_DIR}/config.file"
CONFIG_FINAL="${CONFIG_DIR}/config.yaml"
CONFIG_BAK="${CONFIG_DIR}/config.bak.yaml"

CLASH_CONTAINER="Mihomo"
EXTERNAL_UI_PATH="/root/.config/mihomo/ui"   # ← 可修改的 external-ui 路径

# 如果有代理，填写代理地址，否则留空
PROXY_URL="http://192.168.50.211:7890"  # 例如: http://192.168.1.4:7890

echo "开始下载配置文件... 从URL: $URL"

# 使用 curl 下载，支持代理（如果配置了）
if [ -z "$PROXY_URL" ]; then
  curl -L --retry 3 --connect-timeout 10 -o "$CONFIG_TMP" "$URL"
else
  curl -L --proxy "$PROXY_URL" --retry 3 --connect-timeout 10 -o "$CONFIG_TMP" "$URL"
fi

if [ $? -ne 0 ]; then
  echo "❌ 错误: curl 下载失败！"
  exit 1
fi

if [ ! -s "$CONFIG_TMP" ]; then
  echo "❌ 错误: 下载文件为空！"
  exit 1
fi

echo "✅ 配置文件下载成功！"

if grep -q "7890" "$CONFIG_TMP"; then
  echo "🔍 检测到配置文件包含端口 '7890'，继续处理..."

  # 备份旧配置
  if [ -f "$CONFIG_FINAL" ]; then
    cp "$CONFIG_FINAL" "$CONFIG_BAK"
    echo "📦 旧配置文件已备份为 config.bak.yaml"
  fi

  mv "$CONFIG_TMP" "$CONFIG_FINAL"
  echo "📄 配置文件保存为 config.yaml"

  # external-ui 处理
  if head -n 20 "$CONFIG_FINAL" | grep -q "^[[:space:]]*external-ui:"; then
    echo "🛠️ 发现 external-ui 项，修改为 ${EXTERNAL_UI_PATH}..."
    sed -i "1,20s|^\([[:space:]]*external-ui:\)[[:space:]]*.*|\1 ${EXTERNAL_UI_PATH}|" "$CONFIG_FINAL"
  else
    echo "➕ 未找到 external-ui 项，插入到文件首行..."
    sed -i "1i external-ui: ${EXTERNAL_UI_PATH}" "$CONFIG_FINAL"
  fi

  # external-controller 替换
  sed -i "s/^[[:space:]]*external-controller:[[:space:]]*['\"]\{0,1\}.*:9090['\"]\{0,1\}/external-controller: 0.0.0.0:9090/" "$CONFIG_FINAL"
  echo "✅ external-controller 项已替换为 0.0.0.0:9090"

  # 重启容器
  echo "🚀 正在重启 Clash 容器（${CLASH_CONTAINER}）..."
  docker restart "$CLASH_CONTAINER"
  if [ $? -eq 0 ]; then
    echo "🎉 Clash 容器重启成功！"
  else
    echo "❌ 错误: Clash 容器重启失败！"
    exit 1
  fi

else
  echo "⚠️ 警告: 配置文件中未检测到端口 '7890'，停止执行。"
  exit 1
fi
