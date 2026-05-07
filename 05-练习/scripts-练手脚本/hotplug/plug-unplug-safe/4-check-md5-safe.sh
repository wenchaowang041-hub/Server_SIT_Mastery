#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

sleep 15
mount -a

for disk in $(list_dut_disks); do
    idx="$(disk_index "$disk")"
    md5sum "/mnt/nvme${idx}n1p1/nvme${idx}n1p1.bin" | tee -a check-md5.txt
done

umount /mnt/nvme* || true
