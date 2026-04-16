#!/bin/bash
#===============================================================================
# 插盘后 MD5 校验
#===============================================================================

set -euo pipefail

SYSTEM_DISK="/dev/nvme5n1"

sleep 15
mount -a

# 对所有非系统盘做 MD5 校验
for dev in /dev/nvme*n1; do
    [ -b "$dev" ] || continue
    [[ "$dev" == "$SYSTEM_DISK" ]] && continue
    name="$(basename "$dev")"
    md5sum "/mnt/${name}p1/${name}p1.bin" | tee -a check-md5.txt
done

umount /mnt/nvme* || true
