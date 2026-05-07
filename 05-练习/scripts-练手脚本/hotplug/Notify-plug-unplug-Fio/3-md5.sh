#!/bin/bash
#===============================================================================
# 创建 MD5 源文件
#===============================================================================

set -euo pipefail

SYSTEM_DISK="nvme5n1"

mount -a
sleep 5
df -h | tee -a df.txt

# 清理可能的旧 md5 目录（不再需要本地存储）
rm -rf md5
mkdir -p md5

for dev in /dev/nvme*n1; do
    [ -b "$dev" ] || continue
    name="$(basename "$dev")"
    [[ "$name" == "$SYSTEM_DISK" ]] && echo "跳过系统盘: $name" && continue

    echo "创建 ${name}p1 MD5 源文件..."
    dd if=/dev/urandom of="/mnt/${name}p1/${name}p1.bin" bs=1M count=1000 status=progress
    md5sum "/mnt/${name}p1/${name}p1.bin" | tee -a md5.txt
done

umount /mnt/nvme* || true
