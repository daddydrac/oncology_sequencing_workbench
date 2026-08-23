"""Verify that Jupyter exposes both language kernels and the rpy2 extension."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path


kernel_data = json.loads(
    subprocess.check_output(["jupyter", "kernelspec", "list", "--json"], text=True)
)
kernels = kernel_data["kernelspecs"]
assert "python3" in kernels, kernels.keys()
assert "ir46-bioc323" in kernels, kernels.keys()

startup = Path.home() / ".ipython/profile_default/startup/10-rpy2.py"
assert startup.is_file(), startup

print("Jupyter kernels:")
for name in ("python3", "ir46-bioc323"):
    print(f"  {name}: {kernels[name]['spec']['display_name']}")
print(f"Python startup: {startup}")
