"""Shared TeX packages and macros, independent of the note project's location."""
from pathlib import Path
import os

ROOT = Path(__file__).resolve().parent.parent


def tex_environment():
    env = os.environ.copy()
    env['TEXMFHOME'] = str(ROOT / 'texmf')
    env['TEXINPUTS'] = f".:{ROOT}/tex//:{ROOT}/texmf/tex//:" + env.get('TEXINPUTS', '')
    env['PATH'] = f"{ROOT / '.venv/bin'}:{Path.home() / 'Library/TinyTeX/bin/universal-darwin'}:/Library/TeX/texbin:/opt/homebrew/bin:/usr/local/bin:{env.get('PATH', '')}"
    env['MPLCONFIGDIR'] = str(ROOT / 'cache/matplotlib')
    return env
