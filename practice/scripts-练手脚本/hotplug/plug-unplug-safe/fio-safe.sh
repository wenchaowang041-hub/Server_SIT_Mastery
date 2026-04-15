#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# FIO 运行时长（秒），默认60，可通过环境变量 FIO_RUNTIME 覆盖
FIO_RUNTIME="${FIO_RUNTIME:-60}"

job=1
for disk in $(list_dut_disks); do
    fio --name="seq_mixed${job}" --filename="${disk}p2" --ioengine=libaio --direct=1 --rw=readwrite --bs=1M \
        --numjobs=1 --runtime="${FIO_RUNTIME}" --time_based --rwmixread=50 --group_reporting &
    job=$((job + 1))
done

for disk in $(list_non_dut_nvmes); do
    fio --name="seq_mixed${job}" --filename="${disk}" --ioengine=libaio --direct=1 --rw=readwrite --bs=1M \
        --numjobs=1 --runtime="${FIO_RUNTIME}" --time_based --rwmixread=50 --group_reporting &
    job=$((job + 1))
done

sleep 10
