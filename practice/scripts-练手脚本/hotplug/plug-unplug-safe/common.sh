#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "${SCRIPT_DIR}/config.sh" ] && source "${SCRIPT_DIR}/config.sh"

get_system_disks() {
    echo /dev/nvme5n1
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

list_dut_disks() {
    local disk sysdisks
    sysdisks="$(get_system_disks || true)"

    if [ ${#DUTS[@]} -eq 0 ]; then
        list_test_nvme_disks
        return 0
    fi

    for disk in "${DUTS[@]}"; do
        [ -b "${disk}" ] || continue
        if printf '%s\n' "${sysdisks}" | grep -Fxq "${disk}"; then
            echo "Refusing to use system disk as DUT: ${disk}" >&2
            exit 1
        fi
        echo "${disk}"
    done
}

list_non_dut_nvmes() {
    local disk dut_disks
    dut_disks="$(list_dut_disks)"
    for disk in $(list_test_nvme_disks); do
        if printf '%s\n' "${dut_disks}" | grep -Fxq "${disk}"; then
            continue
        fi
        echo "${disk}"
    done
}

disk_index() {
    local disk="$1"
    basename "${disk}" | sed -E 's#^nvme([0-9]+)n1$#\1#'
}
