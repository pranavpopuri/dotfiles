"""Create/edit an SVG or export PDF+LaTeX with Inkscape."""
import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('action', choices=['edit', 'export'])
parser.add_argument('name', help='Figure name without extension')
parser.add_argument('--project', type=Path, default=Path.cwd(), help='Note project directory (defaults to the current directory)')
args = parser.parse_args()
if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_-]*', args.name):
    parser.error('Use letters, digits, underscores, or hyphens for figure names.')
inkscape = os.environ.get('INKSCAPE_BINARY') or shutil.which('inkscape')
if not inkscape:
    candidate = Path('/Applications/Inkscape.app/Contents/MacOS/inkscape')
    inkscape = str(candidate) if candidate.exists() else None
if not inkscape:
    parser.exit(1, 'Install Inkscape first: brew install --cask inkscape\n')
directory = args.project.expanduser().resolve() / 'figures'
directory.mkdir(exist_ok=True)
svg = directory / f'{args.name}.svg'
if args.action == 'edit':
    if not svg.exists():
        svg.write_text('<svg xmlns="http://www.w3.org/2000/svg" width="160mm" height="100mm" viewBox="0 0 160 100"></svg>\n')
    subprocess.Popen([inkscape, str(svg)], cwd=directory, start_new_session=True)
else:
    if not svg.exists():
        parser.error(f'Create {svg.name} with the edit action first.')
    subprocess.run([inkscape, str(svg), '--export-area-drawing', '--export-type=pdf',
                    '--export-latex', f'--export-filename={directory / (args.name + ".pdf")}'],
                   cwd=directory, check=True)
    print('Insert in LaTeX: \\incfig{' + args.name + '}')
