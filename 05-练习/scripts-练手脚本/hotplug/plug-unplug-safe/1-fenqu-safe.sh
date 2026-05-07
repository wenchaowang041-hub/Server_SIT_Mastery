#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

mapfile -t nvme_disks < <(list_dut_disks)
system_disk="$(get_system_disk || true)"

if [ ${#nvme_disks[@]} -eq 0 ]; then
    echo "No DUT NVMe disk found."
    exit 0
fi

echo "Detected DUT NVMe disks:"
printf "  %s\n" "${nvme_disks[@]}"
[ -n "${system_disk}" ] && echo "Excluded system disk: ${system_disk}"
echo

for disk in "${nvme_disks[@]}"; do
    echo "Processing: $disk"
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
        echo "Partition create failed: $part1 or $part2"
        continue
    fi
    mkfs.ext4 -F "$part1" >/dev/null 2>&1
    echo "Created p1=$part1 p2=$part2"
done
