#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

cp /etc/fstab /etc/fstab.bak
mkdir -p /mnt/nvme{0..11}n1p1
system_disk="$(get_system_disk || true)"

blkid | grep -E '^/dev/nvme[0-9]+n1p1:' | while read -r line; do
    device="$(echo "$line" | awk -F: '{print $1}' | sed 's|/dev/||')"
    base_dev="$(echo "$line" | awk -F: '{print $1}' | sed 's#p1$##')"
    [ -n "${system_disk}" ] && [ "${base_dev}" = "${system_disk}" ] && continue
    if ! printf '%s\n' "$(list_dut_disks)" | grep -Fxq "${base_dev}"; then
        continue
    fi
    uuid="$(echo "$line" | grep -oE 'UUID=\"[^\"]+\"' | head -1 | cut -d'"' -f2)"
    fstype="$(echo "$line" | grep -oE 'TYPE=\"[^\"]+\"' | head -1 | cut -d'"' -f2)"
    [ -z "${uuid}" ] && continue
    [ -z "${fstype}" ] && continue
    mount_point="/mnt/${device}"
    mkdir -p "${mount_point}"
    if ! grep -Fq "UUID=${uuid}" /etc/fstab; then
        echo "UUID=${uuid} ${mount_point} ${fstype} defaults,nofail 0 2" >> /etc/fstab
    fi
done
