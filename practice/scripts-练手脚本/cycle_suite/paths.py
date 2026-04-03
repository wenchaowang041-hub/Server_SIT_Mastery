from pathlib import Path


LOG_ROOT = Path("/root/cycle_logs")
SNAPSHOT_DIR = LOG_ROOT / "snapshots"
ARCHIVE_DIR = LOG_ROOT / "archive"
COMPARE_DIR = LOG_ROOT / "compare"
COUNT_DIR = LOG_ROOT / "counts"


def ensure_dirs() -> None:
    for path in [LOG_ROOT, SNAPSHOT_DIR, ARCHIVE_DIR, COMPARE_DIR, COUNT_DIR]:
        path.mkdir(parents=True, exist_ok=True)

