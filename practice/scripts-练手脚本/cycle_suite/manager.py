import argparse
import sys
import time

from .actions import perform_ac, perform_dc, perform_reboot
from .collectors import collect_snapshot
from .counters import read_count, write_count
from .diffing import compare_snapshots
from .logging_utils import log
from .paths import COMPARE_DIR, SNAPSHOT_DIR, ensure_dirs


def execute_cycle(args: argparse.Namespace) -> int:
    mode = args.mode
    current_count = read_count(mode)

    if args.max_cycles and current_count >= args.max_cycles:
        log(f"Max cycles reached for {mode}: {current_count}/{args.max_cycles}", "SUCCESS")
        return 0

    count = current_count + 1
    tag = f"{mode}_{count:03d}"
    snapshot_dir = SNAPSHOT_DIR / tag

    log(f"Starting {mode} cycle round {count}")
    log("Collecting current system snapshot")
    collect_snapshot(snapshot_dir)

    previous_dir = SNAPSHOT_DIR / f"{mode}_{count - 1:03d}"
    if previous_dir.exists():
        diff_file = COMPARE_DIR / f"{mode}_{count - 1:03d}_to_{count:03d}.log"
        diff_count = compare_snapshots(previous_dir, snapshot_dir, diff_file)
        if diff_count > 0:
            log(f"Detected changes in {diff_count} snapshot files, details: {diff_file}", "WARNING")
        else:
            log("No snapshot differences compared with previous round", "SUCCESS")
    else:
        log("This is the first round, no previous snapshot to compare")

    write_count(mode, count)
    log(f"Recorded {mode} counter: {count}")

    if args.health_only:
        log("Health-only mode, no cycle action will be executed")
        return 0

    time.sleep(args.wait_before_action)

    if mode == "reboot":
        return perform_reboot(args.reboot_cmd)
    if mode == "dc":
        return perform_dc(args.dc_cmd)
    if mode == "ac":
        if not args.ac_off_cmd or not args.ac_on_cmd:
            log("AC mode requires both --ac-off-cmd and --ac-on-cmd", "ERROR")
            return 2
        return perform_ac(args.ac_off_cmd, args.ac_on_cmd, args.ac_off_wait)

    log(f"Unknown mode: {mode}", "ERROR")
    return 2


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Unified AC / DC / reboot cycle runner")
    parser.add_argument("--mode", required=True, choices=["reboot", "dc", "ac"], help="Cycle mode")
    parser.add_argument("--health-only", action="store_true", help="Collect snapshot only, do not execute action")
    parser.add_argument("--wait-before-action", type=int, default=10, help="Seconds to wait before the cycle action")
    parser.add_argument("--max-cycles", type=int, default=0, help="Stop automatically when the mode count reaches this value; 0 means unlimited")

    parser.add_argument("--reboot-cmd", default="reboot", help="Command used in reboot mode")
    parser.add_argument("--dc-cmd", default="ipmitool power cycle", help="Command used in DC mode")
    parser.add_argument("--ac-off-cmd", help="Command used to power off in AC mode")
    parser.add_argument("--ac-on-cmd", help="Command used to power on in AC mode")
    parser.add_argument("--ac-off-wait", type=int, default=15, help="Seconds to wait between AC off and AC on")
    return parser


def main() -> int:
    ensure_dirs()
    parser = build_parser()
    args = parser.parse_args()
    return execute_cycle(args)


if __name__ == "__main__":
    sys.exit(main())
