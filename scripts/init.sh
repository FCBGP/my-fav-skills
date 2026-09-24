#!/usr/bin/env bash
# Author:      basilguo@163.com
# Date:        2026-09-21 11:31:23
# File Name:   scripts/init.sh
# Version:     0.0.1
# Description:

set -eu

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

for f in codex-auto codex-todo-init; do
    src="$SCRIPT_DIR/$f"
    dst="$BIN_DIR/$f"

    [ -f "$src" ] || { echo "❌ 缺少 $src" >&2; exit 1; }

    # 如果 dst 已经是存在的普通文件，先删；如果是软链，-f 会覆盖
    rm -f "$dst"
    ln -sf "$src" "$dst"
    echo "✅ 已链接 $dst -> $src"
done

