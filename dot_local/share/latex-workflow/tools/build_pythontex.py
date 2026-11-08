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
transcript = source.with_suffix('.pythontex-build.log')


def run_phase(arguments, log, publish=False):
    result = subprocess.run(arguments, cwd=source.parent, env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            text=True)
    log.write(result.stdout)
    log.flush()
    # Workshop parses all stdout as one TeX log. Intermediate passes can
    # legitimately lack PythonTeX output, so publish only the final pass.
    # Failures remain visible and stop the build immediately.
    if publish or result.returncode:
        print(result.stdout, end='')
    if result.returncode:
        sys.exit(result.returncode)


with (locks/(hashlib.sha256(str(source).encode()).hexdigest()+'.lock')).open('w') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX)
    with transcript.open('w') as log:
        run_phase(command, log)
        code=source.with_suffix('.pytxcode')
        code.write_text(transform(code.read_text()))
        run_phase([str(python),str(driver),'--interpreter','python:python',source.name], log)
        run_phase(command, log, publish=True)
