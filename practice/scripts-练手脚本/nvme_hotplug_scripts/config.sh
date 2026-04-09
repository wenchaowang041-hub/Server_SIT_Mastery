#!/usr/bin/env bash

set -euo pipefail

# Configure only the DUT list before running.
# Do not include the OS disk here.
DUTS=(
  "/dev/nvme2n1"
  "/dev/nvme3n1"
)

LOG_DIR="${LOG_DIR:-$(pwd)/logs}"
MOUNT_ROOT="${MOUNT_ROOT:-/mnt/nvme_hotplug}"
MD5_SRC_DIR="${MD5_SRC_DIR:-$(pwd)/md5_src}"
FIO_RUNTIME="${FIO_RUNTIME:-300}"
FIO_BS="${FIO_BS:-1M}"
FIO_RWMIXREAD="${FIO_RWMIXREAD:-50}"
PULL_WAIT_SECONDS="${PULL_WAIT_SECONDS:-30}"
REINSERT_WAIT_SECONDS="${REINSERT_WAIT_SECONDS:-6}"
LOOPS_PER_DISK="${LOOPS_PER_DISK:-15}"

mkdir -p "$LOG_DIR" "$MOUNT_ROOT" "$MD5_SRC_DIR"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing command: $1" >&2
    exit 1
  }
}

require_tools() {
  local tools=(
    lsblk nvme lspci smartctl fio md5sum blkid awk sed grep tee mount umount findmnt fdisk
  )
  local optional=(ipmitool lsscsi)
  local t
  for t in "${tools[@]}"; do
    need_cmd "$t"
  done
  for t in "${optional[@]}"; do
    command -v "$t" >/dev/null 2>&1 || echo "warning: optional command not found: $t" >&2
  done
}

ensure_root() {
  [[ "${EUID}" -eq 0 ]] || {
    echo "run as root" >&2
    exit 1
  }
}

disk_name() {
  basename "$1"
}

part1() {
  echo "${1}p1"
}

part2() {
  echo "${1}p2"
}

mount_point() {
  echo "${MOUNT_ROOT}/$(disk_name "$1")p1"
}

bdf_of_disk() {
  local disk node
  disk="$(disk_name "$1")"
  node="$(readlink -f "/sys/class/nvme/${disk}")"
  basename "$(dirname "$(dirname "$node")")"
}

rootport_of_disk() {
  local disk node
  disk="$(disk_name "$1")"
  node="$(readlink -f "/sys/class/nvme/${disk}")"
  basename "$(dirname "$(dirname "$(dirname "$(dirname "$node")")")")"
}

slot_of_disk() {
  local bdf
  bdf="$(bdf_of_disk "$1")"
  lspci -s "${bdf#0000:}" -vvv -xxx 2>/dev/null | awk '/[Ss]lot/ {print; found=1} END {if (!found) print "slot info not found"}'
}

speed_of_disk() {
  local bdf
  bdf="$(bdf_of_disk "$1")"
  lspci -s "${bdf#0000:}" -vvv 2>/dev/null | awk '/LnkSta:|Speed/ {print}'
}

capture_topology_snapshot() {
  local out="${1}"
  {
    date
    nvme list || true
    lsblk || true
    fdisk -l || true
    lspci -tv || true
    for d in "${DUTS[@]}"; do
      echo "disk: $d"
      echo "nvme_bdf: $(bdf_of_disk "$d")"
      echo "rootport: $(rootport_of_disk "$d")"
      echo "slot: $(slot_of_disk "$d")"
      speed_of_disk "$d" || true
      echo
    done
  } > "${out}"
}

system_disk() {
  local root_src parent
  root_src="$(findmnt -n -o SOURCE / || true)"
  if [[ -z "${root_src}" ]]; then
    return 0
  fi
  parent="$(lsblk -no PKNAME "${root_src}" 2>/dev/null | head -n1 || true)"
  if [[ -n "${parent}" ]]; then
    echo "/dev/${parent}"
  fi
}

is_dut_disk() {
  local disk="$1" d
  for d in "${DUTS[@]}"; do
    [[ "${d}" == "${disk}" ]] && return 0
  done
  return 1
}

list_non_dut_nvmes() {
  local sysdisk disk
  sysdisk="$(system_disk || true)"
  for disk in /dev/nvme*n1; do
    [[ -b "${disk}" ]] || continue
    is_dut_disk "${disk}" && continue
    [[ -n "${sysdisk}" && "${disk}" == "${sysdisk}" ]] && continue
    echo "${disk}"
  done
}

log_header() {
  local title="$1"
  tee -a "${LOG_DIR}/summary.log" >/dev/null <<EOF
===== ${title} =====
time: $(date '+%F %T')
EOF
}

check_duts() {
  local d
  [[ "${#DUTS[@]}" -gt 0 ]] || {
    echo "DUTS is empty in config.sh" >&2
    exit 1
  }
  for d in "${DUTS[@]}"; do
    [[ -b "$d" ]] || {
      echo "disk not found: $d" >&2
      exit 1
    }
  done
}
