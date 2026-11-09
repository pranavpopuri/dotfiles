"""Keep one Zathura window per PDF; let Zathura reload changed files itself."""
import argparse
import ctypes
import fcntl
import hashlib
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent.parent


def activate_window(pid):
    """Use macOS application activation without Accessibility automation."""
    if sys.platform != 'darwin':
        return False
    ctypes.CDLL('/System/Library/Frameworks/AppKit.framework/AppKit')
    objc = ctypes.CDLL('/usr/lib/libobjc.A.dylib')
    objc.objc_getClass.argtypes = [ctypes.c_char_p]
    objc.objc_getClass.restype = ctypes.c_void_p
    objc.sel_registerName.argtypes = [ctypes.c_char_p]
    objc.sel_registerName.restype = ctypes.c_void_p
    lookup = ctypes.CFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int)(('objc_msgSend', objc))
    activate = ctypes.CFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_ulong)(('objc_msgSend', objc))
    app = lookup(objc.objc_getClass(b'NSRunningApplication'),
                 objc.sel_registerName(b'runningApplicationWithProcessIdentifier:'), pid)
    if not app:
        return False
    activate(app, objc.sel_registerName(b'activateWithOptions:'), 3)
    # GTK's unbundled macOS process can need the native process-front API too.
    class ProcessSerialNumber(ctypes.Structure):
        _fields_ = [('high', ctypes.c_uint32), ('low', ctypes.c_uint32)]
    services = ctypes.CDLL('/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices')
    services.GetProcessForPID.argtypes = [ctypes.c_int, ctypes.POINTER(ProcessSerialNumber)]
    services.GetProcessForPID.restype = ctypes.c_int32
    services.SetFrontProcessWithOptions.argtypes = [ctypes.POINTER(ProcessSerialNumber), ctypes.c_uint32]
    services.SetFrontProcessWithOptions.restype = ctypes.c_int32
    serial = ProcessSerialNumber()
    if services.GetProcessForPID(pid, ctypes.byref(serial)) == 0:
        services.SetFrontProcessWithOptions(ctypes.byref(serial), 1)
    time.sleep(0.05)
    active = ctypes.CFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)(('objc_msgSend', objc))
    return bool(active(app, objc.sel_registerName(b'isActive')))


def foreground(pidfile, pdf):
    for _ in range(30):
        pid = None
        try:
            pid = int(pidfile.read_text())
        except (OSError, ValueError):
            # Compatibility with a viewer started by the previous helper.
            processes = subprocess.run(['/bin/ps', '-axo', 'pid=,comm=,args='], capture_output=True, text=True)
            for line in processes.stdout.splitlines():
                parts = line.split(None, 2)
                if len(parts) == 3 and Path(parts[1]).name == 'zathura' and str(pdf) in parts[2]:
                    pid = int(parts[0])
                    break
        if pid and activate_window(pid):
            return
        time.sleep(0.1)
    print('Could not bring Zathura forward; check the PDF viewer window.', file=sys.stderr)


def has_synctex(binary):
    # --help advertises the options even when SyncTeX was compiled out.
    if sys.platform == 'darwin':
        result = subprocess.run(['/usr/bin/otool', '-L', binary], capture_output=True, text=True)
        return result.returncode == 0 and 'libsynctex' in result.stdout
    return True


def editor_command(editor):
    binary = shutil.which(editor)
    if not binary:
        app = "Visual Studio Code" if editor == "code" else "VSCodium"
        binary = f"/Applications/{app}.app/Contents/Resources/app/bin/{editor}"
    return shlex.quote(binary) + ' --reuse-window --goto "%{input}:%{line}"'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["view", "ensure", "sync", "serve", "focus"])
    parser.add_argument("pdf", type=Path)
    parser.add_argument("--editor", choices=["code", "codium"], default="code")
    parser.add_argument("--line", type=int, default=1)
    parser.add_argument("--tex", type=Path)
    args = parser.parse_args()
    pdf = args.pdf.expanduser().resolve()
    if not pdf.is_file():
        raise SystemExit(f"Build the document first: {pdf}")
    zathura = shutil.which("zathura") or next(
        (str(path) for path in (Path("/opt/homebrew/bin/zathura"), Path("/usr/local/bin/zathura"))
         if path.is_file()), None)
    if not zathura:
        raise SystemExit("Zathura is missing. Run tools/setup_zathura.sh.")
    synctex = has_synctex(zathura)
    cache = ROOT / "cache/pdf-preview"
    cache.mkdir(parents=True, exist_ok=True)
    key = hashlib.sha256(str(pdf).encode()).hexdigest()
    if args.mode == 'focus':
        # Let the editor finish handling View PDF before changing applications.
        time.sleep(0.3)
        foreground(cache / (key + '.pid'), pdf)
        return
    if args.mode == "sync":
        if not synctex:
            raise SystemExit('This Homebrew Zathura was built without SyncTeX. PDF viewing works, but source/PDF navigation needs a repaired build.')
        if not args.tex:
            parser.error("sync requires --tex")
        subprocess.run([zathura, "--synctex-editor-command", editor_command(args.editor),
                        f"--synctex-forward={args.line}:0:{args.tex.resolve()}", str(pdf)], check=True)
        return
    if args.mode != "serve":
        # The supervisor holds a per-PDF lock for the lifetime of the viewer.
        # Redirect streams so a background window cannot hold up the build task.
        with (cache / (key + ".log")).open("ab") as log:
            subprocess.Popen([sys.executable, str(Path(__file__).resolve()), "serve", str(pdf),
                              "--editor", args.editor], stdin=subprocess.DEVNULL,
                             stdout=log, stderr=log, start_new_session=True)
            if args.mode == 'view':
                subprocess.Popen([sys.executable, str(Path(__file__).resolve()), 'focus', str(pdf)],
                                 stdin=subprocess.DEVNULL, stdout=log, stderr=log,
                                 start_new_session=True)
        return
    with (cache / (key + ".lock")).open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        env = os.environ.copy()
        options = ["--synctex-editor-command", editor_command(args.editor)] if synctex else []
        if not synctex:
            print('SyncTeX unavailable in this Zathura build; opening PDF without navigation.', flush=True)
        child = subprocess.Popen([zathura, *options, str(pdf)], env=env)
        pidfile = cache / (key + '.pid')
        pidfile.write_text(str(child.pid))
        try:
            result = child.wait()
            if result:
                raise subprocess.CalledProcessError(result, child.args)
        finally:
            pidfile.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
