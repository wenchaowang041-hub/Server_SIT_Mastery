#!/bin/bash

set -euo pipefail

resolve_base_disk() {
    local dev="$1" parent
    while true; do
        parent="$(lsblk -no PKNAME "${dev}" 2>/dev/null | head -n1 || true)"
        if [ -z "${parent}" ]; then
            echo "${dev}"
            return 0
        fi
        dev="/dev/${parent}"
    done
}

get_system_disks() {
    local target src base
    for target in / /boot /boot/efi; do
        src="$(findmnt -n -o SOURCE "${target}" 2>/dev/null || true)"
        [ -z "${src}" ] && continue
        base="$(resolve_base_disk "${src}")"
        [ -n "${base}" ] && echo "${base}"
    done | sort -u
}

get_system_disk() {
    get_system_disks | head -n1 || true
}

list_test_nvme_disks() {
    local disk sysdisks
    sysdisks="$(get_system_disks || true)"
    for disk in /dev/nvme*n1; do
        [ -b "${disk}" ] || continue
        if printf '%s\n' "${sysdisks}" | grep -Fxq "${disk}"; then
            continue
        fi
        echo "${disk}"
    done
}

disk_index() {
    local disk="$1"
    basename "${disk}" | sed -E 's#^nvme([0-9]+)n1$#\1#'
}
