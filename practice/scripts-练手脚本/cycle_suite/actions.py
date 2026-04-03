import subprocess
import time

from .logging_utils import log
from .system_utils import parse_command, run_command


def perform_reboot(command_text: str) -> int:
    log(f"Running reboot command: {command_text}")
    subprocess.Popen(parse_command(command_text))
    return 0


def perform_dc(command_text: str) -> int:
    log(f"Running DC cycle command: {command_text}")
    result = run_command(parse_command(command_text), timeout=120)
    if result.returncode != 0:
        log(f"DC cycle failed: {result.stderr}", "ERROR")
        return result.returncode
    log("DC cycle command completed", "SUCCESS")
    return 0


def perform_ac(off_command: str, on_command: str, off_wait: int) -> int:
    log(f"Running AC OFF command: {off_command}")
    result_off = run_command(off_command, timeout=120, shell=True)
    if result_off.returncode != 0:
        log(f"AC OFF failed: {result_off.stderr}", "ERROR")
        return result_off.returncode

    log(f"Waiting {off_wait} seconds before AC ON")
    time.sleep(off_wait)

    log(f"Running AC ON command: {on_command}")
    result_on = run_command(on_command, timeout=120, shell=True)
    if result_on.returncode != 0:
        log(f"AC ON failed: {result_on.stderr}", "ERROR")
        return result_on.returncode

    log("AC cycle commands completed", "SUCCESS")
    return 0
