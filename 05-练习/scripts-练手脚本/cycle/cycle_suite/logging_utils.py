import datetime
from pathlib import Path

from .paths import LOG_ROOT


def now() -> str:
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def log(message: str, level: str = "INFO") -> None:
    line = f"[{now()}] [{level}] {message}"
    print(line)
    with open(LOG_ROOT / "cycle_manager.log", "a", encoding="utf-8") as handle:
        handle.write(line + "\n")

