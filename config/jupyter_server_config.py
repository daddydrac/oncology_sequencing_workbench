"""Local, authenticated JupyterLab configuration for the sequencing workbench."""

import os
from pathlib import Path

token = os.environ.get("JUPYTER_TOKEN", "")
if len(token) < 24 or token == "REPLACE_ME":
    raise RuntimeError("JUPYTER_TOKEN is missing or too short; run ./scripts/setup.sh")

workspace = Path("/workspace")

c = get_config()  # noqa: F821 - supplied by Jupyter's config loader
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 8888
c.ServerApp.port_retries = 0
c.ServerApp.open_browser = False
c.ServerApp.root_dir = str(workspace)
c.ServerApp.default_url = "/lab"
c.ServerApp.token = token
c.ServerApp.password = ""
c.ServerApp.allow_remote_access = True
c.ServerApp.allow_origin = ""
c.ServerApp.disable_check_xsrf = False
c.ServerApp.quit_button = True
c.ServerApp.terminals_enabled = True
c.ServerApp.shutdown_no_activity_timeout = 0
c.ServerApp.max_body_size = 10 * 1024**3
c.ServerApp.max_buffer_size = 10 * 1024**3

# Sequencing jobs can run for hours; never kill an idle-but-computing kernel.
c.MappingKernelManager.cull_idle_timeout = 0
c.MappingKernelManager.cull_busy = False
c.MappingKernelManager.autorestart = True

c.ContentsManager.allow_hidden = False
c.ContentsManager.delete_to_trash = True
c.FileContentsManager.preferred_dir = "/workspace"
c.FileContentsManager.use_atomic_writing = True

# Let Jupytext pair notebooks and Python percent-format files in one mounted tree.
c.Jupytext.formats = "ipynb,py:percent"
c.Jupytext.notebook_metadata_filter = "kernelspec,jupytext"
c.Jupytext.cell_metadata_filter = "-all"
