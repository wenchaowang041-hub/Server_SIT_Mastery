from .paths import COUNT_DIR


def read_count(mode: str) -> int:
    count_file = COUNT_DIR / f"{mode}.count"
    if not count_file.exists():
        return 0
    try:
        return int(count_file.read_text(encoding="utf-8").strip() or "0")
    except ValueError:
        return 0


def write_count(mode: str, value: int) -> None:
    count_file = COUNT_DIR / f"{mode}.count"
    count_file.write_text(str(value), encoding="utf-8")

