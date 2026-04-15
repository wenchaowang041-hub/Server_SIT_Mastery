import difflib
from pathlib import Path

from .logging_utils import now


def compare_snapshots(previous_dir: Path, current_dir: Path, output_file: Path) -> int:
    files = sorted({item.name for item in previous_dir.glob("*")} | {item.name for item in current_dir.glob("*")})
    diff_count = 0
    lines: list[str] = [
        "# snapshot compare",
        f"# prev={previous_dir}",
        f"# curr={current_dir}",
        f"# time={now()}",
        "",
    ]

    for name in files:
        previous_file = previous_dir / name
        current_file = current_dir / name

        if not previous_file.exists():
            lines.append(f"### {name}: only exists in current snapshot")
            diff_count += 1
            continue

        if not current_file.exists():
            lines.append(f"### {name}: missing in current snapshot")
            diff_count += 1
            continue

        previous_lines = previous_file.read_text(encoding="utf-8", errors="ignore").splitlines()
        current_lines = current_file.read_text(encoding="utf-8", errors="ignore").splitlines()
        previous_lines = [line for line in previous_lines if not line.startswith("# time:")]
        current_lines = [line for line in current_lines if not line.startswith("# time:")]

        diff = list(difflib.unified_diff(previous_lines, current_lines, fromfile=name, tofile=name, lineterm=""))
        if diff:
            diff_count += 1
            lines.append(f"### {name}: changed")
            lines.extend(diff)
            lines.append("")

    output_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return diff_count

