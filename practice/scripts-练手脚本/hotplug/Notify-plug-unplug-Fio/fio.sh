#!/bin/bash
#===============================================================================
# FIO 压力测试
# 参数可通过环境变量配置：
#   FIO_RUNTIME  - 运行时长（秒），默认 300
#===============================================================================

set -euo pipefail

SYSTEM_DISK="/dev/nvme5n1"
FIO_RUNTIME="${FIO_RUNTIME:-300}"

# 对所有非系统盘的 p2 分区做 FIO
for dev in /dev/nvme*n1; do
    [ -b "$dev" ] || continue
    [[ "$dev" == "$SYSTEM_DISK" ]] && continue
    name="$(basename "$dev")"
    p2="${dev}p2"
    [ -b "$p2" ] || continue

    echo "[FIO] 启动 ${name}p2 压力测试..."
    fio --name="${name}_seq_mixed" \
        --filename="$p2" \
        --ioengine=libaio \
        --direct=1 \
        --rw=readwrite \
        --bs=1M \
        --numjobs=1 \
        --runtime="${FIO_RUNTIME}" \
        --time_based \
        --rwmixread=50 \
        --group_reporting \
        --eta=never &
done

sleep 10
