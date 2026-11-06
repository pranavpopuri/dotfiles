"""Build ordinary notes with access to project-local TeX packages."""
import subprocess
import sys
from pathlib import Path
from tex_environment import tex_environment

source = Path(sys.argv[1]).resolve()
subprocess.run(['latexmk', '-pdf', '-synctex=1', '-interaction=nonstopmode',
                '-halt-on-error', '-file-line-error', source.name],
               cwd=source.parent, env=tex_environment(), check=True)
