#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

dmesg -c &> /dev/null
ipmitool sel clear &> /dev/null || true
fdisk -l | tee -a fdisk.txt

for disk in $(list_dut_disks); do
    smartctl -a "$disk" | tee -a check-smart-start.txt
    smartctl -H "$disk" | tee -a check-smart-start.txt
done
