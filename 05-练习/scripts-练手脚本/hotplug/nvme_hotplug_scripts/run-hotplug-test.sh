#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

ensure_root
require_tools
check_duts

ROUND_NAME="${1:-$(date '+%F_%H%M%S')}"
ROUND_DIR="${2:-$(pwd)/${ROUND_NAME}}"
mkdir -p "${ROUND_DIR}"
cd "${ROUND_DIR}"

log_note() {
  local msg="$1"
  printf '[%s] %s\n' "$(date '+%F %T')" "$msg" | tee -a loop_record.txt
}

wait_enter() {
  local prompt="$1"
  read -r -p "${prompt} Press Enter to continue... " _
}

countdown() {
  local sec="$1"
  local label="$2"
  while (( sec > 0 )); do
    printf '\r%s 剩余 %2ds' "$label" "$sec"
    sleep 1
    ((sec--))
  done
  printf '\r%s 完成            \n' "$label"
}

run_in_round() {
  LOG_DIR="${ROUND_DIR}/logs" \
  MD5_SRC_DIR="${ROUND_DIR}/md5_src" \
  MOUNT_ROOT="${MOUNT_ROOT}" \
  bash "$1"
}

{
  echo "round_name=${ROUND_NAME}"
  echo "round_dir=${ROUND_DIR}"
  echo "DUTS=${DUTS[*]}"
  echo "loops_per_disk=${LOOPS_PER_DISK}"
  echo "pull_wait=${PULL_WAIT_SECONDS}"
  echo "reinsert_wait=${REINSERT_WAIT_SECONDS}"
} > round_meta.txt

capture_topology_snapshot topology_begin.txt

echo "Round dir: ${ROUND_DIR}"
echo "DUTS: ${DUTS[*]}"
wait_enter "Confirm both DUTs are inserted. Prepare to initialize."
run_in_round "${SCRIPT_DIR}/0-prepare-nvme.sh"
run_in_round "${SCRIPT_DIR}/1-check-Begin.sh"
run_in_round "${SCRIPT_DIR}/2-md5.sh"
run_in_round "${SCRIPT_DIR}/fio.sh"

for (( i=1; i<=LOOPS_PER_DISK; i++ )); do
  for disk in "${DUTS[@]}"; do
    name="$(disk_name "$disk")"
    log_note "loop ${i} disk ${name} start"
    wait_enter "Pull out ${disk} now."
    countdown "${PULL_WAIT_SECONDS}" "Pull wait"
    wait_enter "Slowly reinsert ${disk} now."
    countdown "${REINSERT_WAIT_SECONDS}" "Reinsert settle"
    if run_in_round "${SCRIPT_DIR}/3-check-md5.sh"; then
      log_note "loop ${i} disk ${name} PASS"
    else
      log_note "loop ${i} disk ${name} FAIL"
      echo "Check failed. Preserve the current state. Logs: ${ROUND_DIR}/logs"
      exit 1
    fi
  done
done

run_in_round "${SCRIPT_DIR}/4-check-Finish.sh"
capture_topology_snapshot topology_finish.txt
tar -czf "${ROUND_NAME}.tar.gz" -C "${ROUND_DIR}" .
echo "Round complete. Logs: ${ROUND_DIR}"
echo "Archive: ${ROUND_DIR}/${ROUND_NAME}.tar.gz"
