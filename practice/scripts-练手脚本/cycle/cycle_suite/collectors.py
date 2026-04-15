from pathlib import Path

from .logging_utils import now
from .system_utils import has_command, run_command


BASE_COMMANDS: dict[str, list[str]] = {
    "lscpu.txt": ["lscpu"],
    "free.txt": ["free", "-h"],
    "lsblk.txt": ["lsblk"],
    "mount.txt": ["findmnt"],
    "ip_link.txt": ["ip", "link"],
    "pci.txt": ["lspci", "-nn"],
    "dmesg_warn_err.txt": ["dmesg", "-T", "--level=warn,err,crit,alert,emerg"],
}

OPTIONAL_COMMANDS: dict[str, list[str]] = {
    "nvme_list.txt": ["nvme", "list"],
    "ipmi_sensor.txt": ["ipmitool", "sensor", "list"],
    "ipmi_sel.txt": ["ipmitool", "sel", "elist"],
    "ipmi_fru.txt": ["ipmitool", "fru"],
    "dmidecode_memory.txt": ["dmidecode", "-t", "memory"],
    "ethtool_summary.txt": ["bash", "-lc", "for nic in $(ls /sys/class/net | grep -v lo); do echo ==== $nic ====; ethtool $nic 2>/dev/null; done"],
}


def _write_snapshot_file(output_path: Path, command: list[str]) -> None:
    result = run_command(command, timeout=120)
    content = f"# command: {' '.join(command)}\n# time: {now()}\n\n{result.stdout}"
    if result.stderr:
        content += f"\n# stderr\n{result.stderr}"
    output_path.write_text(content, encoding="utf-8", errors="ignore")


def collect_snapshot(snapshot_dir: Path) -> None:
    snapshot_dir.mkdir(parents=True, exist_ok=True)

    for filename, command in BASE_COMMANDS.items():
        _write_snapshot_file(snapshot_dir / filename, command)

    for filename, command in OPTIONAL_COMMANDS.items():
        if not has_command(command[0]):
            continue
        _write_snapshot_file(snapshot_dir / filename, command)

