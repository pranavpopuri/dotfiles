"""Build a trusted document, translating mathematical LaTeX for PythonTeX."""
from pathlib import Path
import fcntl
import hashlib
import os
import shutil
import subprocess
import sys
from tex_environment import ROOT, tex_environment
from latex_pythontex import transform

source = Path(sys.argv[1]).expanduser().resolve()
python = ROOT / '.venv/bin/python'
environment = tex_environment()
environment['PYTHONPATH'] = str(ROOT/'tools') + os.pathsep + environment.get('PYTHONPATH','')
pdflatex = shutil.which('pdflatex', path=environment['PATH'])
if not python.exists() or not pdflatex:
    sys.exit('Run latex-workflow setup first.')
driver = ROOT / 'texmf/scripts/pythontex/pythontex.py'
if not driver.exists():
    sys.exit('PythonTeX is missing. Run latex-workflow setup.')
command = [pdflatex, '-interaction=nonstopmode', '-halt-on-error', '-file-line-error', '-synctex=1', source.name]
locks=ROOT/'cache/pythontex-locks'
locks.mkdir(parents=True,exist_ok=True)
with (locks/(hashlib.sha256(str(source).encode()).hexdigest()+'.lock')).open('w') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX)
    subprocess.run(command,cwd=source.parent,env=environment,check=True)
    code=source.with_suffix('.pytxcode')
    code.write_text(transform(code.read_text()))
    subprocess.run([str(python),str(driver),'--interpreter','python:python',source.name],cwd=source.parent,env=environment,check=True)
    subprocess.run(command,cwd=source.parent,env=environment,check=True)
