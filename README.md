[toc]

---

## 免责声明

### 1. 镜像容器适配

本项目仅针对原 `docker`镜像容器运行进行针对 `1Panel`应用商店的适配。我们不对任何原始镜像的有效性做出任何明示或暗示的保证或声明，并且不对使用本仓库应用所造成的任何影响负责。用户在使用本项目时应自行承担风险。

### 2. 法律遵守

用户在使用本仓库时必须遵守所在国家与地区的法律法规。某些应用可能受到特定国家法律的限制，用户需自行了解并遵守相关法律要求。本仓库不对用户违反法律法规所产生的任何后果负责。

### 3. 免责声明接受

用户在导入本仓库并使用其中的应用时，即表示用户已经阅读、理解并同意接受本免责声明的所有条款和条件。

请注意，本免责声明仅针对本仓库的使用情况，并不包括其他第三方应用或服务。对于与本仓库链接的第三方内容，我们不对其准确性、完整性、可靠性或合法性负责。

在使用本仓库之前，请确保已经阅读、理解并接受了本免责声明的所有条款和条件。

---

## 1. 简介

**本分支主要目的是维护clash代理软件**

## 2. 使用方式

### 2.1 国际互联网络

#### 2.1.1 使用 git 命令获取应用

`1Panel`计划任务类型 `Shell 脚本`的计划任务框里，添加并执行以下命令，或者终端运行以下命令，

```shell
#!/bin/bash

# === 用户配置项 ===
USE_PROXY=false   # 是否启用代理（true/false）
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
```

然后应用商店刷新本地应用即可。

#### 2.1.2 使用压缩包方式获取应用

`1Panel`计划任务类型 `Shell 脚本`的计划任务框里，添加并执行以下命令，或者终端运行以下命令，

```shell
#!/bin/bash

# === 用户配置项 ===
USE_PROXY=false   # 是否启用代理（true/false）
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
ZIP_URL="https://github.com/baishicoke/1panel-app/archive/refs/heads/demo.zip"
ZIP_FILE="$APP_PATH/localApps.zip"
UNZIP_DIR="$APP_PATH/1panel-app-demo"

# 设置代理（如果启用）
if [[ "$USE_PROXY" == true ]]; then
  export http_proxy="$PROXY_URL"
  export https_proxy="$PROXY_URL"
  echo "🌐 已启用代理：$PROXY_URL"
else
  echo "🚫 未启用代理。"
fi

# 下载 zip 包
echo "📦 正在下载压缩包..."
wget -O "$ZIP_FILE" "$ZIP_URL"
if [ $? -ne 0 ]; then
  echo "❌ 下载失败，请检查网络、代理或链接是否正确。"
  [[ "$USE_PROXY" == true ]] && unset http_proxy https_proxy
  exit 2
fi

# 解压并覆盖原有内容
echo "📂 正在解压..."
unzip -o -d "$APP_PATH" "$ZIP_FILE"

# 拷贝 apps 目录下的内容
echo "📁 正在复制应用..."
cp -rf "$UNZIP_DIR/clash/"* "$APP_PATH/"

# 清理
echo "🧹 正在清理临时文件..."
rm -rf "$UNZIP_DIR"
rm -f "$ZIP_FILE"

# 清除代理变量
[[ "$USE_PROXY" == true ]] && unset http_proxy https_proxy

# 成功提示
echo -e "\n✅ 应用已成功复制到：$APP_PATH"
# by tomato

```

然后应用商店刷新本地应用即可。

## 3.自动更新订阅方法

**本分支主要目的是维护clash代理软件
提供自动更新订阅脚本，将该脚本放到1panel的计划任务设置每天执行达到自动更新目的**

注意！
更改自动更新脚本变量：

| 参数含义                                                                                      | 参数            |
| --------------------------------------------------------------------------------------------- | --------------- |
| 订阅地址                                                                                      | BASE_URL        |
| 请求类型一般默认不需要改                                                                      | FLAG            |
| 容器名称                                                                                      | CLASH_CONTAINER |
| 配置文件config.yaml路径<br />写到上一级文件夹即可<br />比如"./data/config.yaml"就写到"./data" | CONFIG_DIR      |

```shell

#!/bin/bash

# === 变量定义区域 ===
BASE_URL=""
FLAG="&flag=clash"
URL="${BASE_URL}${FLAG}"

CONFIG_DIR="/volume1/docker/clashpremium"
CONFIG_TMP="${CONFIG_DIR}/config.file"
CONFIG_FINAL="${CONFIG_DIR}/config.yaml"

CLASH_CONTAINER="clash-premium"

echo "开始下载配置文件... 从URL: $URL"

wget -O "$CONFIG_TMP" "$URL"

if [ ! -s "$CONFIG_TMP" ]; then
  echo "错误: 下载的配置文件为空，停止脚本执行！"
  exit 1
else
  echo "配置文件下载成功！"
fi

if grep -q "7890" "$CONFIG_TMP"; then
  echo "配置文件包含 '7890'，继续处理..."

  mv "$CONFIG_TMP" "$CONFIG_FINAL"
  echo "配置文件重命名为 config.yaml 完成。"

  # === 兼容有无引号的 external-controller 替换 ===
  sed -i "s/^[[:space:]]*external-controller:[[:space:]]*['\"]\{0,1\}.*:9090['\"]\{0,1\}/external-controller: 0.0.0.0:9090/" "$CONFIG_FINAL"
  echo "配置文件中的 external-controller 已成功修改为 0.0.0.0:9090。"

  echo "正在重启 Clash 容器（${CLASH_CONTAINER}）..."
  docker restart "$CLASH_CONTAINER"

  if [ $? -eq 0 ]; then
    echo "Clash 容器重启成功！"
  else
    echo "错误: Clash 容器重启失败！"
    exit 1
  fi
else
  echo "警告: 配置文件中没有找到匹配的内容（7890），停止脚本执行！"
  exit 1
fi

```

## 备注

安装应用准备好config.yaml配置文件，不然启动失败
