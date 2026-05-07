#!/bin/bash
#===============================================================================
# NVMe 磁盘分区（排除系统盘）
#===============================================================================

set -euo pipefail

SYSTEM_DISK="/dev/nvme5n1"

# 获取所有 NVMe 磁盘（排除系统盘）
nvme_disks=()
for disk in $(lsblk -dnp -o NAME,TYPE | awk '$2 == "disk" && $1 ~ "^/dev/nvme" {print $1}'); do
    [[ "$disk" == "$SYSTEM_DISK" ]] && continue
    nvme_disks+=("$disk")
done

if [ ${#nvme_disks[@]} -eq 0 ]; then
    echo "未找到 NVMe 硬盘（系统盘已排除）"
    exit 0
fi

echo "检测到以下 NVMe 硬盘（系统盘已排除）:"
printf "  %s\n" "${nvme_disks[@]}"
echo ""

for disk in "${nvme_disks[@]}"; do
    echo "正在处理: $disk"

    parted -s "$disk" mklabel gpt \
           mkpart primary 1MiB 10G \
           mkpart primary 10G 100% \
           set 1 boot off \
           set 2 boot off

    partprobe "$disk"
    sleep 2

    part1="${disk}p1"
    part2="${disk}p2"

    if [ ! -e "$part1" ] || [ ! -e "$part2" ]; then
        echo "错误: 分区创建失败 ($part1 或 $part2)"
        continue
    fi

    echo "正在格式化 $part1 为 ext4..."
    mkfs.ext4 -F "$part1" >/dev/null 2>&1

    echo "成功创建分区:"
    echo "  分区1 (ext4): $part1 (10G)"
    echo "  分区2: $part2 (剩余空间)"
    echo ""
done

echo "所有操作已完成!"
