#!/bin/bash
#===============================================================================
# UUID 绑定到 fstab（排除系统盘）
#===============================================================================

set -euo pipefail

SYSTEM_DISK="nvme5n1"

# 备份原始 fstab
cp /etc/fstab /etc/fstab.bak

# 创建挂载点（排除系统盘）
mkdir -p /mnt/nvme{0..11}n1p1

while IFS= read -r line; do
    # 提取设备名
    device=$(echo "$line" | awk -F: '{print $1}' | sed 's|/dev/||')

    # 跳过系统盘
    [[ "$device" == "$SYSTEM_DISK" ]] && echo "跳过系统盘: $device" && continue

    # 提取 UUID
    uuid=$(echo "$line" | grep -oE 'UUID="[^"]+"' | head -1 | cut -d'"' -f2)
    fstype=$(echo "$line" | grep -oE 'TYPE="[^"]+"' | head -1 | cut -d'"' -f2)

    if [ -z "$uuid" ] || [ -z "$fstype" ]; then
        echo "警告: 跳过无效条目: $line" >&2
        continue
    fi

    mount_point="/mnt/$device"
    mkdir -p "$mount_point"

    if grep -Fq "UUID=$uuid" /etc/fstab; then
        echo "条目已存在: UUID=$uuid"
    else
        entry="UUID=$uuid $mount_point $fstype defaults,nofail 0 2"
        echo -e "$entry" >> /etc/fstab
        echo "已添加: $entry"
    fi
done < <(blkid | grep -E '^/dev/nvme[0-9]+n1p1:')

echo "操作完成！请运行 'mount -a' 测试配置"
