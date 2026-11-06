# LaTeX workflow cheat sheet

Full explanations: [GUIDE.md](GUIDE.md). Every configured snippet:
[SNIPPETS.md](SNIPPETS.md).

## Open and build

```sh
latex-workflow init ~/Documents/notes/calculus
latex-workflow open ~/Documents/notes/calculus
```

Use the dedicated editor. **Esc** → Helix Normal mode; **i** → Insert mode.
Custom shortcuts use **Control+L**, release, then the final key, in Normal/visual
mode in LaTeX files. Native Helix Space-menu bindings remain available.

| Chord | Action |
| --- | --- |
| Ctrl+L b / v / s | Build / view PDF / source-to-PDF SyncTeX |
| Ctrl+L m / p | Toggle source equations / larger math preview |
| Ctrl+L f / x | Create/edit named SVG / export named SVG |
| Ctrl+L e / a / r | Select environment contents / whole environment / paired names |
| Ctrl+L g / w / c | Matching tag / wrap environment / wrap command |
| Ctrl+L t / z | Display/named-equation toggle / close environment |
| Ctrl+L h / o | Select section / navigate outline |
| Alt+O / Alt+I | Expand/shrink LaTeX-aware selection |
| Cmd+Shift+P | Command palette and fallback commands |

See [TEX-EDITING.md](TEX-EDITING.md) for command details and VimTeX differences.
VimTeX's `dse`/`dsc`/`dsd`, delimiter/fraction toggles, and counted motions are
not installed. Selection-based Helix editing remains available.

## Type in Insert mode

**Auto** expands immediately. **Manual** needs accepting its matching suggestion
(Ctrl+Space / Trigger Suggest); Tab alone may indent. Once in a snippet,
**Tab / Shift+Tab** move between placeholders.

| Type | Mode | Effect |
| --- | --- | --- |
| `mk`, `dm` | Auto, boundary | Inline / display math |
| `ali`, `beg`, `enum`, `item` | Auto, start of line | Align / paired environment / numbered / bullet list |
| `//`, `x/`, `(x+1)/` | Auto, math | Fraction / prefilled numerator |
| `xhat`, `xbar` | Auto, math | Hat / bar on one letter |
| `x2`, `__`, `sr`, `cb`, `td`, `sq` | Auto, math | Subscript / braced subscript / square / cube / power / root |
| `pmat`, `bmat`, `case` | Auto, math | Matrix/cases skeleton |
| `<=`, `>=`, `!=`, `=>`, `iff`, `->` | Auto, math | Comparisons, logic, arrow |
| `NN`, `RR`, `QQ`, `ZZ`, `AA`, `EE`, `ooo` | Auto, math | Number sets, forall, exists, infinity |
| `sum`, `prod`, `lim`, `part` | Manual, math | Calculus structures |
| `==` | Manual, alignment only | `&=` row plus line break |
| `proofenv`, `thmenv`, `lemmenv` | Manual, start of line | Proof / theorem / lemma |
| `svgfig`, `fig`, `plot`, `template` | Manual; see full reference for boundaries | Figure / image / PGFPlots / document |

Create `dm` and `ali` **outside** existing math. Matrix columns use `&`; rows
use `\\`. Load shared macros before theorem/proof snippets.

## Calculate: no Tab needed

```text
cas integrate(x*y, (y,0,1-x), (x,0,1)) cas
cas diff(sin(x)**2, x) cas
cas simplify(sin(x)**2 + cos(x)**2 - 1) cas
cas solve(Eq(x**2,1), x) cas
cas N(pi, 8) cas
```

Type inside math; finishing the closing `cas` inserts LaTeX. Use `*`, `**`,
`oo`, and innermost bounds first. Five-second timeout; errors preserve input.

## Macros and figures

Load `\input{math-macros.tex}` once in the preamble; `init` already arranges this
through `course-macros.tex`. Common notation: `\E`, `\Prob`, `\Var`, `\Cov`,
`\grad`, `\dd`, `\norm{x}`, `\abs{x}`, `\asto`, `\pto`, `\dto`.

**Inkscape:** Ctrl+L f → name → draw → labels like `$\alpha$` → **Save** →
Ctrl+L x → same name → `\incfig{name}` → build. Keep `.svg`, `.pdf`, and
`.pdf_tex`. Repeat Save+Export after edits; there is no automatic export watcher.

**Python plots:** `latex-workflow plot --project /path/to/notes` generates
`figures/normal.pdf`; insert with `\includegraphics`. The command is a fixed
normal-distribution example, not a function prompt. PGFPlots uses the `plot`
snippet and requires `\usepackage{pgfplots}`.

## Preview and troubleshoot

Move into an equation to edit source; move out to render it. Tall equations
need multiline display blocks. Special macros may need preview definitions.
For embedded code, choose **PythonTeX (trusted documents)** explicitly.

```sh
latex-workflow build /path/to/notes.tex
latex-workflow build --pythontex /path/to/calculations.tex
latex-workflow doctor
```

Shared docs/config: `~/.local/share/latex-workflow/`. Change shared files through
chezmoi and run **HyperSnips: Reload Snippets** after snippet edits.
