import sys
from pathlib import Path

import yaml

with open(Path(__file__).parent.joinpath("dependencies.yml"), "r") as fp:
    deps: dict[str, list[str]] = yaml.load(fp, Loader=yaml.Loader)["dependencies"]

mo2_deps = sys.argv[1:]
third_party_deps = {dep for mo2_dep in mo2_deps for dep in deps.get(mo2_dep, [])}

print(" ".join(sorted(third_party_deps)))
