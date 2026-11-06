# Permanent LaTeX toolkit (macOS)

**Start here:** [Practical guide](GUIDE.md) · [Cheat sheet](CHEATSHEET.md) ·
[All 115 snippets](SNIPPETS.md). These describe the actual configured shortcuts,
activation rules, calculations, previews, figures, plotting, and troubleshooting.

This folder is deployed from chezmoi to `~/.local/share/latex-workflow`. Source,
settings, snippets, extension code, templates, and requirements are tracked.
Extension versions are listed in `extensions.txt`; the ordinary editor's extension-update preferences are retained. Update that file and reapply chezmoi
when intentionally changing the setup versions. Python environments, downloaded TeX packages, VSCodium-installed extensions, caches,
PDFs, and editor state are rebuilt on each device and are not committed.

## Use

```sh
latex-workflow init ~/Documents/notes/calculus
latex-workflow open ~/Documents/notes/calculus
latex-workflow build ~/Documents/notes/calculus/notes.tex
latex-workflow build --pythontex /path/to/trusted-calculations.tex
latex-workflow figure edit diagram --project /path/to/notes
latex-workflow figure export diagram --project /path/to/notes
latex-workflow plot --project /path/to/notes
latex-workflow doctor
```

The launcher is at `~/.local/bin/latex-workflow`, also linked from `~/bin`,
which your existing chezmoi shell configuration already puts on PATH.
`latex-workflow setup` reruns the macOS bootstrap.

`open` now reuses your **normal VSCodium window**. You can also open notes
normally from VSCodium or Finder; a separate editor instance is no longer needed.
Your existing theme, layout, font, general preferences, and other extensions are
retained. Only LaTeX feature settings, TeX-scoped shortcuts, tasks, and the
required math extensions are added. Normal VSCodium now offers both
**LaTeX toolkit (latexmk)** and **PythonTeX (trusted documents)** build recipes.

The feature defaults live in `config/`. Chezmoi combines them with your ordinary
preferences in `.chezmoitemplates/vscodium-preferences.json` to render the normal
VSCodium User settings. Tasks and keybindings use the same composition pattern.
`latex-workflow setup` also merges the feature additions into the live normal
editor config, preserving unrelated values. Runtime data and installed extensions
use VSCodium's standard locations. The old isolated instance's files are unused.
Projects need no toolkit copies, Python environment, or `.vscode` setup.

## Features

- HyperSnips: type `cas integrate(x*y,(y,0,1-x),(x,0,1)) cas` inside math;
  it evaluates automatically on the closing `cas`. Uses permanent SymPy.
  Native SymPy syntax is required, with innermost limits first.
- Existing math snippets, postfix hats/bars, matrices, cases, and alignments.
  `proofenv`, `thmenv`, `lemmenv`, and `svgfig` are manual snippets; accept
  the matching completion if Tab alone does not expand them.
- `\input{math-macros.tex}` loads shared course macros through the toolkit
  build tools. New projects load it via `course-macros.tex`, which is yours
  to customize. A project's own file of the same name takes precedence.
- Math Source Preview renders inactive equations in the native editor and
  reveals source around the cursor. Large formulas should use multiline
  display blocks. MathJax previews do not replace final PDF verification.
- Spell checking skips math and TeX commands; package completion is enabled.
- Inkscape figure tasks edit SVGs and export PDF+LaTeX. Put math labels such
  as `$\alpha$` in the SVG, save, export, and insert `\incfig{diagram}`.
  Export is explicit, not an automatic watcher.
- PGFPlots and Python plotting; the generated Python plot is a vector PDF.
- Optional PythonTeX recipe runs TeX/PythonTeX/TeX for trusted documents.
  PythonTeX executes embedded code; source previews do not execute it.

In Helix Normal/visual mode, use Control+L then the final key:

| Chord | Action |
| --- | --- |
| Ctrl+L b / v / s | Build / PDF / SyncTeX |
| Ctrl+L m / p | Source rendering / larger math preview |
| Ctrl+L f / x | Edit SVG / export |
| Ctrl+L e / a / r | Select environment contents / whole environment / paired names |
| Ctrl+L g / w / c | Matching tag / wrap environment / wrap command |
| Ctrl+L t / z / h / o | Display/named math toggle / close environment / select section / outline |
| Alt+O / Alt+I | Expand/shrink LaTeX-aware selection |

See [TEX-EDITING.md](TEX-EDITING.md) for the native Workshop operations and the
VimTeX features that are not implemented. Native Helix Space bindings remain
intact. Helix supplies the keyboard controls; the conflicting VSCodeVim extension
introduced during earlier setup is removed from the normal extension install.

## Maintain and reproduce

Edit tracked files using `chezmoi edit` or in the chezmoi source directory.
The toolkit has its own `config/Brewfile` for macOS dependencies. Existing shared
package lists and Linux installer checksums stay unchanged. The macOS
`run_onchange_after_zz-latex-workflow.sh.tmpl` hook rebuilds the
runtime when tracked toolkit sources change. The hook and ignore rules exclude
this toolkit on Linux; no Linux shell files are changed. Another Mac only needs
your usual `chezmoi init/apply`, Homebrew, and network access. TinyTeX is installed
if missing, and its upstream installer may request standard macOS PATH setup.
PythonTeX is copied into the writable toolkit TeX tree from the system TeX
installation because its TeX Live package is not relocatable in user mode.

Do not commit `.venv/`, `texmf/`, `cache/`, or editor state from the deployed
folder. They are deliberately absent from chezmoi source. Source files for the
preview extension remain tracked; the VSIX is rebuilt during setup. Its MathJax
renderer uses LaTeX Workshop's bundled library, so a future Workshop change to
that dependency could require updating the extension.

No file in the testing repository is needed after successful migration.
