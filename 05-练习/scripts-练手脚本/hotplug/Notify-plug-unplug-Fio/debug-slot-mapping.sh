#!/bin/bash
#===============================================================================
# 调试脚本: 收集 NVMe 磁盘 -> PCI Slot 映射信息
#===============================================================================

echo "=== PCI Slots ==="
for s in /sys/bus/pci/slots/*/; do
    [ -d "$s" ] || continue
    name="$(basename "$s")"
    addr="$(cat "${s}address" 2>/dev/null || echo 'N/A')"
    power="$(cat "${s}power" 2>/dev/null || echo 'N/A')"
    echo "Slot: $name | Address: $addr | Power: $power"
done

echo ""
echo "=== NVMe Disks -> PCI Path ==="
for dev in /dev/nvme*n1; do
    [ -b "$dev" ] || continue
    disk_name="$(basename "$dev")"
    nvme_ctrl_name="${disk_name%n1}"

    # 路径1: device/nvmeX
    path1="/sys/block/${disk_name}/device/${nvme_ctrl_name}"
    resolved1="$(readlink -f "$path1" 2>/dev/null || echo 'NOT_FOUND')"

    # 路径2: device (symlink without -f)
    path2="/sys/block/${disk_name}/device"
    resolved2="$(readlink "$path2" 2>/dev/null || echo 'NOT_FOUND')"
    resolved2f="$(readlink -f "$path2" 2>/dev/null || echo 'NOT_FOUND')"

    # 路径3: uevent (看 PCI 信息)
    uevent="/sys/block/${disk_name}/device/uevent"

    echo ""
    echo "--- ${disk_name} (${nvme_ctrl_name}) ---"
    echo "  Path1 (device/${nvme_ctrl_name}): $path1 -> $resolved1"
    echo "  Path2 (device symlink):        $path2 -> $resolved2"
    echo "  Path2 (device resolved):        $path2 -> $resolved2f"
    if [ -f "$uevent" ]; then
        echo "  uevent: $(cat "$uevent" 2>/dev/null)"
    fi
done
