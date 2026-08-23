"""Load the rpy2 IPython extension for every Python notebook kernel."""

from IPython import get_ipython


shell = get_ipython()
if shell is not None:
    shell.run_line_magic("load_ext", "rpy2.ipython")
