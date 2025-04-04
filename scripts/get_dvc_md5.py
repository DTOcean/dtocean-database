import argparse
import sys

from yaml import load

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader


from pathlib import Path
from typing import Union

StrOrPath = Union[str, Path]


def get_dvc_md5(dvc_name: StrOrPath, entry_idx: int = 0):
    dvc_path = Path(dvc_name)
    with open(dvc_path, "r") as stream:
        data = load(stream, Loader=Loader)

    return data["outs"][entry_idx]["md5"]


def _cli():
    parser = argparse.ArgumentParser(prog="get_dvc_md5")
    parser.add_argument("filename")
    parser.add_argument(
        "-i",
        "--index",
        help="Entry index to return",
        type=int,
        default=0,
    )

    args = parser.parse_args()
    result = get_dvc_md5(args.filename, args.index)

    sys.stdout.write(result)


if __name__ == "__main__":
    _cli()
