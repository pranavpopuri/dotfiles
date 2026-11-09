"""Build notes with shared packages and optional persistent PDF preview."""
import argparse
import fcntl
import gzip
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from tex_environment import tex_environment

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("document", type=Path)
parser.add_argument("--preview", action="store_true")
parser.add_argument("--editor", choices=["code", "codium"], default="code")
args = parser.parse_args()
source = args.document.expanduser().resolve()
build = source.parent / '.latex-build' / source.stem
build.mkdir(parents=True, exist_ok=True)


def publish(path, destination):
    # An unchanged output should not trigger another viewer reload.
    if destination.is_file() and hashlib.sha256(destination.read_bytes()).digest() == hashlib.sha256(path.read_bytes()).digest():
        return
    fd, temporary = tempfile.mkstemp(prefix='.' + destination.name, dir=destination.parent)
    try:
        with os.fdopen(fd, 'wb') as output, path.open('rb') as incoming:
            shutil.copyfileobj(incoming, output)
        os.replace(temporary, destination)
    finally:
        Path(temporary).unlink(missing_ok=True)


with (build / 'build.lock').open('w') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    # Keep the main input stable while latexmk resolves its required passes.
    # Live edits are picked up by the editor's next queued build instead.
    snapshot_dir = build / '.source'
    snapshot_dir.mkdir(exist_ok=True)
    snapshot = snapshot_dir / source.name
    content = source.read_bytes()
    if not snapshot.exists() or snapshot.read_bytes() != content:
        snapshot.write_bytes(content)
    subprocess.run(["latexmk", "-pdf", "-synctex=1", "-interaction=nonstopmode",
                    "-halt-on-error", "-file-line-error", '-outdir=' + str(build), str(snapshot)],
                   cwd=source.parent, env=tex_environment(), check=True)
    # SyncTeX must lead back to the editable file, not the compilation snapshot.
    sync = build / (source.stem + '.synctex.gz')
    data = gzip.decompress(sync.read_bytes())
    data = data.replace(str(snapshot).encode(), str(source).encode())
    data = data.replace(str(snapshot.relative_to(source.parent)).encode(), str(source).encode())
    sync.write_bytes(gzip.compress(data, mtime=0))
    # Publish synchronization data first, then replace the PDF in one operation.
    for suffix in ('.synctex.gz', '.pdf'):
        publish(build / (source.stem + suffix), source.with_suffix(suffix))
if args.preview:
    subprocess.run([sys.executable, str(Path(__file__).with_name("pdf_preview.py")),
                    "ensure", str(source.with_suffix(".pdf")), "--editor", args.editor],
                   env=tex_environment(), check=True)
