#!/usr/bin/env python3
import sys
from pathlib import Path


CURRENT_DIR = Path(__file__).resolve().parent
if str(CURRENT_DIR) not in sys.path:
    sys.path.insert(0, str(CURRENT_DIR))

from cycle_suite.manager import main


if __name__ == "__main__":
    sys.exit(main())
