#!/usr/bin/env bash
set -e

REPO="juewuy/ShellCrash"
ASSET="ShellCrash.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${ASSET}"

TARGET_DIR="/root/ShellCrash"
TMP_FILE="/tmp/${ASSET}"

# 清理函数：确保临时文件被删除
cleanup() {
    if [ -f "$TMP_FILE" ]; then
        rm -f "$TMP_FILE"
    fi
}
trap cleanup EXIT ERR

# 检查必要依赖
check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v tar &> /dev/null; then
        missing_deps+=("tar")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "❌ 错误：缺少必要依赖: ${missing_deps[*]}"
        echo "请先安装: apt-get install -y ${missing_deps[*]}"
        exit 1
    fi
}

# 检查依赖
check_dependencies

echo "[1] 下载最新版本: $DOWNLOAD_URL"
if ! curl -L -f -o "$TMP_FILE" "$DOWNLOAD_URL"; then
    echo "❌ 错误：下载失败，请检查网络连接或 URL 是否有效"
    exit 1
fi

# 验证下载的文件
if [ ! -s "$TMP_FILE" ]; then
    echo "❌ 错误：下载的文件为空或不存在"
    exit 1
fi

echo "[2] 清理旧目录（如果存在）..."
rm -rf "$TARGET_DIR"

echo "[3] 解压到 $TARGET_DIR ..."
mkdir -p "$TARGET_DIR"
if ! tar -xzf "$TMP_FILE" -C "$TARGET_DIR"; then
    echo "❌ 错误：解压失败，文件可能已损坏"
    exit 1
fi

echo "✅ 完成！文件已保存到: $TARGET_DIR/ShellCrash"
