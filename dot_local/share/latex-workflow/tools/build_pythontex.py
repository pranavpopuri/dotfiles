"""Build a trusted document using the permanent toolkit's Python environment."""
from pathlib import Path
import shutil
import subprocess
import sys
from tex_environment import ROOT, tex_environment

source = Path(sys.argv[1]).expanduser().resolve()
python = ROOT / '.venv/bin/python'
environment = tex_environment()
pdflatex = shutil.which('pdflatex', path=environment['PATH'])
if not python.exists() or not pdflatex:
    sys.exit('Run latex-workflow setup first.')
driver = ROOT / 'texmf/scripts/pythontex/pythontex.py'
if not driver.exists():
    sys.exit('PythonTeX is missing. Run latex-workflow setup.')
command = [pdflatex, '-interaction=nonstopmode', '-halt-on-error', '-file-line-error', '-synctex=1', source.name]
for arguments in (command, [str(python), str(driver), '--interpreter', 'python:python', source.name], command):
    subprocess.run(arguments, cwd=source.parent, env=environment, check=True)
