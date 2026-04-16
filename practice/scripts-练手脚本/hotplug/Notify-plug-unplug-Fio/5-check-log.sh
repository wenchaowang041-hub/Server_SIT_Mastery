#!/bin/bash
#===============================================================================
# 测试后日志采集
#===============================================================================

set -euo pipefail

SYSTEM_DISK="/dev/nvme5n1"

# 1. 拓扑快照（和 before 对比）
echo "=== lsscsi ===" > topology-after.log
lsscsi >> topology-after.log 2>/dev/null || true

echo "" >> topology-after.log
echo "=== nvme list ===" >> topology-after.log
nvme list >> topology-after.log 2>/dev/null || true

echo "" >> topology-after.log
echo "=== lspci -tv ===" >> topology-after.log
lspci -tv >> topology-after.log 2>/dev/null || true

echo "" >> topology-after.log
echo "=== lsblk ===" >> topology-after.log
lsblk >> topology-after.log 2>/dev/null || true

echo "" >> topology-after.log
echo "=== mount points ===" >> topology-after.log
mount | grep nvme >> topology-after.log 2>/dev/null || true

# 2. dmesg 采集 + 错误提取
dmesg > dmesg-Finish.log 2>/dev/null || true
echo "=== dmesg errors ==="
dmesg | grep -iE "error|fail|aer|fatal" || true

# 3. SEL 采集 + 错误提取
echo "=== SEL errors ==="
ipmitool sel list | grep -iE "err|failed|fault|critical" || true
ipmitool sel list > bmc-Finish.log 2>/dev/null || true

# 4. SMART 健康检查
for dev in /dev/nvme*n1; do
    [ -b "$dev" ] || continue
    [[ "$dev" == "$SYSTEM_DISK" ]] && continue
    smartctl -a "$dev" | tee -a smartctl-Finish.log >> /dev/null
    smartctl -H "$dev" | tee -a smartctl-H-Finish.log >> /dev/null
    smartctl -H "$dev" | grep overall-health | grep -v "PASSED" || true
done

mount -a || true
rm -rf /mnt/nvme*/* 2>/dev/null || true
umount /mnt/nvme* 2>/dev/null || true
