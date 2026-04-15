#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_BIN="${PYTHON_BIN:-python3}"
MODE="${CYCLE_MODE:-dc}"
MAX_CYCLES="${MAX_CYCLES:-0}"
WAIT_BEFORE_ACTION="${WAIT_BEFORE_ACTION:-10}"
REBOOT_CMD="${REBOOT_CMD:-reboot}"
DC_CMD="${DC_CMD:-ipmitool power cycle}"
AC_OFF_CMD="${AC_OFF_CMD:-}"
AC_ON_CMD="${AC_ON_CMD:-}"
AC_OFF_WAIT="${AC_OFF_WAIT:-15}"

CMD=(
  "$PYTHON_BIN"
  "$SCRIPT_DIR/cycle_manager.py"
  --mode "$MODE"
  --wait-before-action "$WAIT_BEFORE_ACTION"
  --max-cycles "$MAX_CYCLES"
)

if [[ "$MODE" == "reboot" ]]; then
  CMD+=(--reboot-cmd "$REBOOT_CMD")
elif [[ "$MODE" == "dc" ]]; then
  CMD+=(--dc-cmd "$DC_CMD")
elif [[ "$MODE" == "ac" ]]; then
  if [[ -z "$AC_OFF_CMD" || -z "$AC_ON_CMD" ]]; then
    echo "AC mode requires AC_OFF_CMD and AC_ON_CMD" >&2
    exit 2
  fi
  CMD+=(--ac-off-cmd "$AC_OFF_CMD" --ac-on-cmd "$AC_ON_CMD" --ac-off-wait "$AC_OFF_WAIT")
fi

exec "${CMD[@]}"
