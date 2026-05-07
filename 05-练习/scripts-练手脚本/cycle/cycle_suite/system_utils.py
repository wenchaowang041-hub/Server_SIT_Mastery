import shlex
import subprocess
from shutil import which
from typing import Sequence, Union


def has_command(name: str) -> bool:
    return which(name) is not None


def parse_command(command_text: str) -> list:
    return shlex.split(command_text)


def run_command(command: Union[Sequence[str], str], timeout: int = 120, shell: bool = False):
    return subprocess.run(
        command,
        shell=shell,
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
    )
