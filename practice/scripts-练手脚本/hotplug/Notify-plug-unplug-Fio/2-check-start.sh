#!/bin/bash
#===============================================================================
# 测试前预采集日志 + 清空
#===============================================================================

set -euo pipefail

SYSTEM_DISK="/dev/nvme5n1"

# 1. 保存并清空 dmesg
dmesg > dmesg-before.log 2>/dev/null || true
dmesg -c &> /dev/null

# 2. 保存并清空 SEL
ipmitool sel list > sel-before.log 2>/dev/null || true
ipmitool sel clear &> /dev/null || true

# 3. 磁盘拓扑快照
echo "=== lsblk ===" > topology-before.log
lsblk >> topology-before.log 2>/dev/null || true

echo "" >> topology-before.log
echo "=== lsscsi ===" >> topology-before.log
lsscsi >> topology-before.log 2>/dev/null || true

echo "" >> topology-before.log
echo "=== nvme list ===" >> topology-before.log
nvme list >> topology-before.log 2>/dev/null || true

echo "" >> topology-before.log
echo "=== lspci -tv ===" >> topology-before.log
lspci -tv >> topology-before.log 2>/dev/null || true

echo "" >> topology-before.log
echo "=== fdisk -l ===" >> topology-before.log
fdisk -l >> topology-before.log 2>/dev/null || true

echo "" >> topology-before.log
echo "=== mount points ===" >> topology-before.log
mount | grep nvme >> topology-before.log 2>/dev/null || true

# 4. SMART 健康检查
for dev in /dev/nvme*n1; do
    [ -b "$dev" ] || continue
    [[ "$dev" == "$SYSTEM_DISK" ]] && continue
    smartctl -a "$dev" | tee -a check-smart-start.txt
    smartctl -H "$dev" | tee -a check-smart-start.txt
done
