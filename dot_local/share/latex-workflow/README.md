## VS Code profiles

Chezmoi tracks Default, Dev, and LaTeX separately, including their settings,
keybindings, tasks, and extension lists. Profile names and stable locations are
in `.chezmoitemplates/vscode-profiles.json`; global storage and sign-ins remain
local. Restart VS Code after restoring profiles on a fresh machine.

`latex-workflow open` selects LaTeX. The toolkit installer and `editor-config`
update only LaTeX, preserving Default and Dev preferences.

# Permanent LaTeX toolkit (macOS)

Math input update: CAS and PythonTeX now accept mathematical LaTeX directly. See [Calculate using LaTeX](LATEX-MATH.md) for the current syntax, examples and supported notation. Existing SymPy examples remain compatible.

**Start here:** [Practical guide](GUIDE.md) · [Cheat sheet](CHEATSHEET.md) ·
[All 115 snippets](SNIPPETS.md). These describe the actual configured shortcuts,
activation rules, calculations, previews, figures, plotting, and troubleshooting.

This folder is deployed from chezmoi to `~/.local/share/latex-workflow`. Source,
settings, snippets, extension code, templates, and requirements are tracked.
Extension versions are listed in `extensions.txt`; the ordinary editor's extension-update preferences are retained. Update that file and reapply chezmoi
when intentionally changing the setup versions. Python environments, downloaded TeX packages, VS Code-installed extensions, caches,
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

`open` now reuses your **normal VS Code window**. You can also open notes
normally from VS Code or Finder; a separate editor instance is no longer needed.
Your existing theme, layout, font, general preferences, and other extensions are
retained. Only LaTeX feature settings, TeX-scoped shortcuts, tasks, and the
required math extensions are added. Normal VS Code now offers both
**LaTeX toolkit (latexmk)** and **PythonTeX (trusted documents)** build recipes.

The feature defaults live in `config/`. Chezmoi combines them with your ordinary
preferences in `private_Library/private_Application Support/private_Code/User/profiles/4cb85cd0/settings.json.tmpl` to render the normal
VS Code User settings. Tasks and keybindings use the same composition pattern.
`latex-workflow setup` also merges the feature additions into the live normal
editor config, preserving unrelated values. Runtime data and installed extensions
use VS Code's standard locations. The old isolated instance's files are unused.
Projects need no toolkit copies, Python environment, or `.vscode` setup.

## Where to put configs and templates

Paths below are relative to `~/.local/share/latex-workflow/` unless stated
otherwise. For changes that should survive chezmoi updates and sync to another
Mac, edit the corresponding tracked file with `chezmoi edit` or in the chezmoi
source directory, then run `chezmoi apply`.

| Location | What belongs here |
| --- | --- |
| `templates/` | Starter documents: `notes.tex` and `course-macros.tex`. `latex-workflow init` copies these two files into a project, keeping any existing files. Template edits affect future projects; additional template files are not copied automatically. |
| `hsnips/latex.hsnips` | Your LaTeX HyperSnips expansions and automatic math snippets. See [the snippet catalog](SNIPPETS.md). |
| `config/settings.json` | Shared LaTeX editor settings, build recipes, and source-preview settings. |
| `config/keybindings.json` | LaTeX keyboard shortcuts. |
| `config/tasks.json` | Editor tasks for builds, figures, and plotting. |
| `config/cspell.json` | Spell-check settings and custom words. |
| `config/latex-macros.json` | Computational aliases for custom LaTeX commands used in CAS and PythonTeX calculations. |
| `tex/latex/latex-workflow/` | Shared TeX files, including `math-macros.tex` and `math-preview-macros.tex`, available through the toolkit build environment. |
| `config/Brewfile` | macOS dependencies installed by the toolkit setup. |
| Your project folder | Project-specific `course-macros.tex`, document sources, bibliography files, and a `figures/` folder for that project's artwork. |

Your ordinary VS Code settings live in
`~/Library/Application Support/Code/User/`. Keep general editor preferences
in the chezmoi source template `private_Library/private_Application Support/private_Code/User/profiles/4cb85cd0/settings.json.tmpl`;
the toolkit's `config/` files supply the LaTeX additions. After changing those
additions, `latex-workflow editor-config` merges them into the live editor config.

The `.venv/`, `texmf/`, `cache/`, and `extensions/` folders contain generated or
installed runtime files; put your own shared TeX sources in `tex/`.

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
