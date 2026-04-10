#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

lsblk | tee -a lsblk-Finish.log >> /dev/null
command -v lsscsi >/dev/null 2>&1 && lsscsi | tee -a lsscsi-Finish.log >> /dev/null
dmesg | tee -a dmesg-Finish.log >> /dev/null
dmesg | grep -i "err\\|failed" || true
ipmitool sel list | grep -i "err\\|failed" || true
ipmitool sel list | tee -a bmc-Finish.log >> /dev/null || true

for disk in $(list_dut_disks); do
    smartctl -a "$disk" | tee -a smartctl-Begin.log >> /dev/null
    smartctl -H "$disk" | tee -a smartctl-H-Begin.log >> /dev/null
    smartctl -H "$disk" | grep overall-health | grep -v "PASSED" || true
done

mount -a || true
rm -rf /mnt/nvme*/* 2>/dev/null || true
umount /mnt/nvme* 2>/dev/null || true
