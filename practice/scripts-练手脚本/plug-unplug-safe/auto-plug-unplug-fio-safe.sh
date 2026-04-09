#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
cd "$SCRIPT_DIR"

CYCLES="${CYCLES:-10}"
PULL_WAIT_SECONDS="${PULL_WAIT_SECONDS:-30}"
INSERT_WAIT_SECONDS="${INSERT_WAIT_SECONDS:-6}"
ROUND_NAME="${1:-$(date '+%F_%H%M%S')}"
LOG_ROOT="${LOG_ROOT:-$SCRIPT_DIR/runs}"
ROUND_DIR="${LOG_ROOT}/${ROUND_NAME}"

mkdir -p "$ROUND_DIR"
cd "$ROUND_DIR"

step_run() {
    local title="$1"
    local script_path="$2"
    local log_file="$3"
    echo
    echo "===== ${title} ====="
    echo "script: ${script_path}"
    bash "$script_path" | tee -a "$log_file"
}

pause_enter() {
    local prompt="$1"
    echo
    echo "$prompt"
    read -r -p "Press Enter to continue... " _
}

countdown() {
    local seconds="$1"
    local label="$2"
    while (( seconds > 0 )); do
        printf '\r%s: %2ds ' "$label" "$seconds"
        sleep 1
        ((seconds--))
    done
    printf '\r%s: done   \n' "$label"
}

record_manual_state() {
    local note="$1"
    printf '[%s] %s\n' "$(date '+%F %T')" "$note" | tee -a loop-record.txt
}

echo "round_name=${ROUND_NAME}" > round-meta.txt
echo "cycles=${CYCLES}" >> round-meta.txt
echo "pull_wait_seconds=${PULL_WAIT_SECONDS}" >> round-meta.txt
echo "insert_wait_seconds=${INSERT_WAIT_SECONDS}" >> round-meta.txt
echo "system_disk=$(get_system_disk || true)" >> round-meta.txt
echo "test_nvme_disks=$(list_test_nvme_disks | xargs)" >> round-meta.txt

echo "Round directory: ${ROUND_DIR}"
echo "System disk excluded: $(get_system_disk || true)"
echo "Test disks: $(list_test_nvme_disks | xargs)"

pause_enter "Confirm the test environment is ready and /etc/fstab does not contain stale DUT entries."

step_run "Step 1: partition disks" "${SCRIPT_DIR}/1-fenqu-safe.sh" "01-fenqu.log"
step_run "Step 2: bind UUID and prepare mount points" "${SCRIPT_DIR}/UUID-safe.sh" "02-uuid.log"

echo
echo "Running mount -a to verify /etc/fstab..."
mount -a | tee -a "02-uuid.log"

step_run "Step 3: collect start logs" "${SCRIPT_DIR}/2-check-start-safe.sh" "03-check-start.log"
step_run "Step 4: create md5 source files and copy to p1" "${SCRIPT_DIR}/3-md5-safe.sh" "04-md5-create.log"
step_run "Step 5: start fio pressure on p2" "${SCRIPT_DIR}/fio-safe.sh" "05-fio-start.log"

for ((loop=1; loop<=CYCLES; loop++)); do
    echo
    echo "===== Hotplug loop ${loop}/${CYCLES} ====="
    record_manual_state "loop ${loop} start"

    pause_enter "Now you may PULL OUT the target disk."
    record_manual_state "loop ${loop} operator pulled disk"
    countdown "${PULL_WAIT_SECONDS}" "Pull wait"

    pause_enter "Now you may INSERT the target disk slowly."
    record_manual_state "loop ${loop} operator inserted disk"
    countdown "${INSERT_WAIT_SECONDS}" "Insert settle"

    step_run "Step 6: md5 check after reinsert (loop ${loop})" "${SCRIPT_DIR}/4-check-md5-safe.sh" "06-check-md5-loop${loop}.log"
    record_manual_state "loop ${loop} md5 check finished"
done

step_run "Step 7: final log check" "${SCRIPT_DIR}/5-check-log-safe.sh" "07-check-log.log"

echo
echo "All loops finished."
echo "Round logs saved in: ${ROUND_DIR}"
