"""Copy PythonTeX's installed source into the permanent writable TeX tree."""
from pathlib import Path
import shutil
import sys
from tex_environment import ROOT

system = Path(sys.argv[1])
for relative in ('tex/latex/pythontex', 'scripts/pythontex'):
    source = system / relative
    if not source.exists():
        raise SystemExit(f'Missing {source}; install pythontex in TinyTeX first.')
    shutil.copytree(source, ROOT / 'texmf' / relative, dirs_exist_ok=True)
