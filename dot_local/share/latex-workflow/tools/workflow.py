"""Entry point for the permanent LaTeX toolkit."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
from tex_environment import ROOT, tex_environment

def editor_links():
    # Legacy command name retained for compatibility: merge, never replace UI settings.
    from apply_editor_config import install
    install()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    actions = parser.add_subparsers(dest='action', required=True)
    for name in ['open', 'init']:
        action = actions.add_parser(name)
        action.add_argument('project', type=Path, nargs='?', default=Path.cwd())
    build = actions.add_parser('build')
    build.add_argument('document', type=Path)
    build.add_argument('--pythontex', action='store_true')
    figure = actions.add_parser('figure')
    figure.add_argument('mode', choices=['edit', 'export'])
    figure.add_argument('name')
    figure.add_argument('--project', type=Path, default=Path.cwd())
    plot = actions.add_parser('plot')
    plot.add_argument('--project', type=Path, default=Path.cwd())
    actions.add_parser('setup')
    actions.add_parser('doctor')
    actions.add_parser('editor-config')
    actions.add_parser('editor-links')
    args = parser.parse_args()
    environment = tex_environment()
    python = ROOT / '.venv/bin/python'
    if args.action == 'setup':
        subprocess.run(['bash', str(ROOT / 'bootstrap-macos.sh')], check=True)
    elif args.action in ('editor-config', 'editor-links'):
        editor_links()
    elif args.action == 'open':
        editor = shutil.which(os.environ.get('LATEX_WORKFLOW_EDITOR', 'code'), path=environment['PATH'])
        if not editor:
            sys.exit('VS Code is missing. Run latex-workflow setup.')
        subprocess.run([editor, '--reuse-window', str(args.project.expanduser().resolve())], check=True, env=environment)
    elif args.action == 'init':
        project = args.project.expanduser().resolve()
        project.mkdir(parents=True, exist_ok=True)
        (project / 'figures').mkdir(exist_ok=True)
        for name in ['notes.tex', 'course-macros.tex']:
            target = project / name
            if target.exists():
                print(f'Keeping existing {target.name}')
            else:
                shutil.copy2(ROOT / 'templates' / name, target)
        print(f'Open with: latex-workflow open "{project}"')
    elif args.action == 'build':
        helper = 'build_pythontex.py' if args.pythontex else 'build_latex.py'
        subprocess.run([str(python), str(ROOT / 'tools' / helper), str(args.document)], check=True, env=environment)
    elif args.action == 'figure':
        subprocess.run([str(python), str(ROOT / 'tools/figure.py'), args.mode, args.name,
                        '--project', str(args.project)], check=True, env=environment)
    elif args.action == 'plot':
        subprocess.run([str(python), str(ROOT / 'tools/plot_example.py'), '--project', str(args.project)], check=True, env=environment)
    elif args.action == 'doctor':
        checks = {}
        for command in ['pdflatex', 'latexmk', 'code', 'inkscape']:
            checks[command] = shutil.which(command, path=environment['PATH']) or 'MISSING'
        for package in ['pythontex.sty', 'pgfplots.sty', 'math-macros.tex']:
            checks[package] = subprocess.run(['kpsewhich', package], env=environment, text=True, capture_output=True).stdout.strip() or 'MISSING'
        checks['toolkit'] = str(ROOT)
        checks['python'] = str(python)
        print(json.dumps(checks, indent=2))
        if 'MISSING' in checks.values():
            sys.exit(1)


if __name__ == '__main__':
    main()
