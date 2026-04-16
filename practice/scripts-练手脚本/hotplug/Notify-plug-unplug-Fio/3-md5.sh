#!/bin/bash
#===============================================================================
# 创建 MD5 源文件
#===============================================================================

set -euo pipefail

SYSTEM_DISK="nvme5n1"

mkdir -p md5
mount -a
sleep 10
df -h | tee -a df.txt

for dev in /dev/nvme*n1; do
    [ -b "$dev" ] || continue
    name="$(basename "$dev")"
    [[ "$name" == "$SYSTEM_DISK" ]] && echo "跳过系统盘: $name" && continue

    echo "创建 ${name}p1 MD5 源文件..."
    dd if=/dev/urandom of="./md5/${name}p1.bin" bs=1M count=1000 status=progress
    md5sum "./md5/${name}p1.bin" | tee -a md5.txt
    cp "./md5/${name}p1.bin" "/mnt/${name}p1"
done

umount /mnt/nvme* || true
