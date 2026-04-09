#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

mkdir -p md5
mount -a
sleep 10
df -h | tee -a df.txt

for disk in $(list_test_nvme_disks); do
    idx="$(disk_index "$disk")"
    dd if=/dev/urandom of="./md5/nvme${idx}n1p1.bin" bs=1M count=1000
    sleep 10
    md5sum "./md5/nvme${idx}n1p1.bin" | tee -a md5.txt
    sleep 5
    cp "./md5/nvme${idx}n1p1.bin" "/mnt/nvme${idx}n1p1"
done

umount /mnt/nvme* || true
