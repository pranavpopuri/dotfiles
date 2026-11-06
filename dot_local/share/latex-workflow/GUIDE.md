# LaTeX workflow: practical guide

This guide describes your installed **macOS** toolkit. Start with the daily-use
sections, keep [CHEATSHEET.md](CHEATSHEET.md) nearby, and search
[SNIPPETS.md](SNIPPETS.md) for the complete list of **115** configured snippets.

## Contents

- [Start a project](#start-a-project)
- [Understand the keys and snippet modes](#understand-the-keys-and-snippet-modes)
- [Every custom editor shortcut](#every-custom-editor-shortcut)
- [Write mathematics quickly](#write-mathematics-quickly)
- [Calculate with SymPy](#calculate-with-sympy)
- [Read rendered equations while editing](#read-rendered-equations-while-editing)
- [Course notation and theorem environments](#course-notation-and-theorem-environments)
- [Draw and insert an Inkscape figure](#draw-and-insert-an-inkscape-figure)
- [Plot functions and data](#plot-functions-and-data)
- [Build documents and use PythonTeX](#build-documents-and-use-pythontex)
- [Spell checking and completion](#spell-checking-and-completion)
- [All terminal commands](#all-terminal-commands)
- [Where files live and how to change them](#where-files-live-and-how-to-change-them)
- [Troubleshooting](#troubleshooting)

## Start a project

```sh
latex-workflow init ~/Documents/notes/calculus
latex-workflow open ~/Documents/notes/calculus
```

`init` creates `notes.tex`, `course-macros.tex`, and `figures/`. It keeps existing
files of those names. Open `notes.tex`, press `i` to enter Helix Insert mode, and
start writing. Press `Esc` for Normal mode, then Ctrl+L followed by `b` to build.
Ctrl+L followed by `v` opens the PDF.

For existing notes, just use:

```sh
latex-workflow open /path/to/your/notes
```

**Use this launcher for the complete workflow.** It opens a dedicated VSCodium
instance with the math settings and extensions. Opening the same folder in your
ordinary coding window uses your other configuration. Individual note projects
need no copy of the toolkit, virtual environment, or editor settings.

The new-project preamble loads `course-macros.tex`, which loads the shared math
macros. Existing documents can add `\input{math-macros.tex}` in their preamble.
These shared files are found by the toolkit's build tools; an unrelated external
TeX command does not automatically inherit that search path.

## Understand the keys and snippet modes

- **Ctrl+L b** means press Control+L, release, then press `b`.
  The custom chords run in **Helix Normal/visual mode** in LaTeX files.
  Your native Helix Space menu and Insert-mode keys are preserved.
- **Insert mode:** press `i` to type text and snippets. Press `Esc` to return to
  Normal mode. Helix's `a`, `o`, and `O` also enter Insert mode in useful places.
- **Automatic snippet:** expands as soon as its final trigger character is
  typed. You do not press Tab. Examples: `dm`, `xhat`, and the closing `cas`.
- **Manual snippet:** type its trigger and accept its matching HyperSnips
  completion. Use **Ctrl+Space** to request suggestions, choose the snippet, and
  accept it. Tab can accept/jump in the appropriate editor context, but typing
  a manual trigger followed by Tab alone is not a universal expansion binding.
  If macOS intercepts Ctrl+Space, run **Trigger Suggest** from the command palette.
- **Tab** and **Shift+Tab** navigate forward/backward through an active snippet's
  placeholders. If the suggestion popup is open, accepting a suggestion may
  take precedence. The complete reference marks each snippet's activation mode.
- **Math only:** most symbol snippets require a recognized math scope: `$...$`,
  `\(...\)`, `\[...\]`, or a math environment. They do not normally run in prose.
- Some snippets need a **word boundary**, and document/environment snippets
  often need the **beginning of a line**. Whitespace before that line's trigger
  is fine. These rules are documented per snippet in the full reference.
- Examples such as `xhat` are the characters to type, not commands to paste into
  your final source. Expansions insert ordinary LaTeX that stays editable.

Open the command palette with **Cmd+Shift+P**. This is the fallback for commands
when a keyboard binding conflicts with another extension or a macOS shortcut.

## Every custom editor shortcut

The dedicated editor now uses **Helix**, not VSCodeVim. All custom bindings and
TeX-aware environment/section selections are documented in
[TEX-EDITING.md](TEX-EDITING.md), including their differences from VimTeX.

| Chord | Action |
| --- | --- |
| Ctrl+L b / v / s | Build / view PDF / source-to-PDF synchronization |
| Ctrl+L m / p | Toggle source rendering / larger math preview |
| Ctrl+L f / x | Create/edit an Inkscape figure / export it |
| Ctrl+L e / a | Select environment contents / whole environment |
| Ctrl+L r / n | Select both environment names / current name |
| Ctrl+L g | Navigate matching begin/end at a tag |
| Ctrl+L w / c | Wrap selection in environment / command |
| Ctrl+L t | Display-delimiter/named-equation environment toggle |
| Ctrl+L z | Close environment |
| Ctrl+L h / o | Select section / navigate outline symbols |
| Alt+O / Alt+I | Expand/shrink selection with the LaTeX syntax provider |

Use your regular Helix movement, selection, and change commands. Do not use
Vim's operator-first sequences such as `ci{` or expect `vim.*` settings to bind
Helix. The full VimTeX surround-delete, modifier/fraction toggle, and counted
motion suite has not been implemented. Cmd+Shift+P opens the command palette.

## Write mathematics quickly

### Enter math and document structure

| Type | Activation | Result/purpose |
| --- | --- | --- |
| `mk` | Automatic, word boundary | Inline `$...$` with a placeholder |
| `dm` | Automatic, word boundary | A multiline `\[ ... \]` display |
| `ali` | Automatic, start of line | An `align*` environment |
| `beg` | Automatic, start of line | Paired begin/end environment names |
| `enum` / `item` | Automatic, start of line | Enumerate / itemize list |
| `proofenv` | Manual, start of line | Proof environment |
| `thmenv` / `lemmenv` | Manual, start of line | Theorem / lemma |
| `template` | Manual, start of line | A full standalone article template |
| `coursemacros` | Manual, start of line | Insert `\input{math-macros.tex}` |
| `fig` / `svgfig` | Manual, start of line | Image figure / Inkscape figure wrapper |
| `table` / `desc` / `pac` | Manual, start of line | Table / description list / package |

Expand `dm` or `ali` outside an existing math environment; these snippets create
their own math delimiters. Load shared macros once in the preamble before using
the proof/theorem snippets. The older `template` snippet is a standalone template,
while `latex-workflow init` is the recommended starting point for course notes.

### Fractions, scripts, accents, and matrices

The following are automatic **inside math**, unless noted:

| Type | Meaning/example |
| --- | --- |
| `//` | Empty `\frac{...}{...}`; Tab between numerator and denominator |
| `x/` | Fraction with `x` already in the numerator |
| `(x+1)/` | Fraction with the parenthesized expression as numerator |
| `x2` | `x_2`; typing another digit groups a two-digit subscript |
| `__` | Braced subscript |
| `sr` / `cb` | Square / cube postfix; e.g. `xsr` becomes `x^2` |
| `td` / `rd` | A braced exponent / parenthesized exponent |
| `sq` | Square root with a placeholder |
| `xhat` / `xbar` | `\hat{x}` / `\overline{x}` |
| `hat` / `bar` | Accent wrapper with a placeholder |
| `pmat` / `bmat` | Parenthesized / bracketed matrix |
| `case` | Cases environment |
| `norm` | Double-bar norm delimiters |
| `ceil` / `floor` | Ceiling / floor delimiters |
| `()` | Paired scalable parentheses |

Postfix hats and bars capture **one preceding letter**. They do not automatically
recognize an arbitrary expression such as `(x+y)`; use the wrapper or ordinary
LaTeX for that. Matrix and cases snippets create a skeleton, not a spreadsheet:
use `&` between columns and `\\` between rows. The full reference also lists
manual `lr...` delimiter wrappers, column vectors, and conjugation.

### Symbols, calculus, and alignment

| Type | Activation in math | Meaning |
| --- | --- | --- |
| `=>`, `=<`, `iff` | Automatic | Implication, reverse implication, equivalence |
| `<=`, `>=`, `!=` | Automatic | Comparisons |
| `->`, `<->`, `!>` | Automatic | To, leftrightarrow, mapsto |
| `AA`, `EE` | Automatic | For all, exists |
| `NN`, `RR`, `QQ`, `ZZ` | Automatic | Standard number sets (requires their macros) |
| `inn`, `notin`, `cc` | Automatic | Membership, non-membership, subset |
| `UU`, `Nn`, `OO` | Automatic | Union, intersection, empty set |
| `ooo`, `nabl`, `xx`, `**` | Automatic | Infinity, nabla, multiplication sign, centered dot |
| `dint` | Automatic, word boundary | Integral with bounds and an integrand placeholder |
| `sum`, `prod`, `lim`, `limsup`, `part`, `taylor` | Manual | Summation/product/limits/partial derivative/series |
| `==` | Manual | An alignment row with `&=` and a line break |

Use `==` only inside a suitable alignment, such as `align*`. Its `&` would be
invalid in ordinary inline/display math. Names such as `sin`, `cos`, `log`,
`pi`, and `int` receive a backslash automatically in math. This is symbol
formatting, not symbolic computation. It is deliberately suspended while typing
CAS input. [SNIPPETS.md](SNIPPETS.md) covers every additional set, sequence,
formatting, and document snippet, including inherited templates and regex rules.

## Calculate with SymPy

Inside math, type the entire expression including the closing marker:

```text
cas integrate(x*y, (y,0,1-x), (x,0,1)) cas
```

The last `s` triggers evaluation immediately. The markers and expression are
replaced by ordinary LaTeX: `\frac{1}{24}`. No Tab or document build is needed.

| Input between `cas ` and ` cas` | Purpose |
| --- | --- |
| `simplify(sin(x)**2 + cos(x)**2 - 1)` | Simplification/equivalence check: result is 0 |
| `factor(x**2 - 1)` | Factor an expression |
| `expand((x + 1)**3)` | Expand an expression |
| `diff(sin(x)**2, x)` | Differentiate |
| `integrate(x**2, (x,0,1))` | Definite integral |
| `integrate(x*y, (y,0,1-x), (x,0,1))` | Double integral, innermost limits first |
| `limit(sin(x)/x, x, 0)` | Limit |
| `solve(Eq(x**2, 1), x)` | Solve an equation |
| `N(pi, 8)` | Numerical value with eight significant digits |
| `Integral(exp(-x**2), (x,0,1))` | Insert an unevaluated integral |
| `Matrix([[1,2],[3,4]]).det()` | Matrix determinant |
| `(x**2 + 1).subs(x, 2)` | Substitute a value |

Use **SymPy syntax**, not raw LaTeX: `**` is a power, `*` is multiplication,
`oo` is infinity, and bounds use `(variable, lower, upper)`. A plain unknown name
such as `x` becomes a symbol. `pi`, `E`, and `I` are reserved mathematical
constants; `N`, `S`, and function names are also reserved. Use `Symbol('I')` if
you need a symbol with that name. Integer ratios such as `1/3` remain exact;
using decimal literals introduces floating-point values.

The evaluator accepts expressions, not assignments, import statements, arbitrary
Python, or raw LaTeX. Supported methods include `subs`, `doit`, `evalf`, `det`,
`inv`, and `transpose`. To inspect the exact function allowlist, see `tools/cas.py`.
Errors preserve the input and display a notification. A calculation taking more
than five seconds is stopped. While `cas ` remains in the current line prefix,
automatic math snippets pause so they do not rewrite Python syntax.

CAS simplifies expressions; it does not preserve every domain qualification in
the output or constitute a proof. For example, `(x**2-1)/(x-1)` simplifies to
`x+1`, but the original still excludes `x=1`.

## Read rendered equations while editing

The local **Math Source Preview** extension displays inactive equations as SVG
images inside the native editor. Place the caret or a selection in an equation
to reveal its original LaTeX, then move away to render it again. The stored file
stays LaTeX. Incomplete or unsupported formulas stay visible as source; CAS
input stays source until evaluated.

- **Ctrl+L m:** toggle in-source rendering for the dedicated editor.
- **Ctrl+L p:** open/close Workshop's larger live math preview panel below.
- Hover on source math for a Workshop equation preview.

Large fractions, matrices, and integrals should occupy a multiline display block:

```latex
\[
  \int_0^1 \frac{x^2}{1+x^2}\,\dd x
\]
```

Decorations cannot change the editor's line layout, so a tall equation squeezed
onto one source line will have a smaller preview. The renderer uses MathJax,
not a complete TeX installation: special packages or course macros can work in
the PDF while requiring explicit preview macro definitions. The built PDF is
the authoritative typeset output. The two preview systems have separate macro
configuration; maintenance locations are listed below.

## Course notation and theorem environments

Load `\input{math-macros.tex}` **once in the preamble**, or use the generated
`course-macros.tex`, which already does this. These are LaTeX commands, not
additional automatic snippet triggers:

| Command | Meaning/use |
| --- | --- |
| `\N`, `\R`, `\Q`, `\Z` | Natural, real, rational, integer numbers |
| `\E[X]` | Expectation |
| `\Prob(A)` | Probability |
| `\Var(X)`, `\Cov(X,Y)` | Variance, covariance |
| `\rank(A)`, `\diag(a,b)` | Upright operator names |
| `\grad f` | Gradient |
| `\dd x` | Upright differential with spacing |
| `\given` | Conditional separator |
| `\norm{x}`, `\abs{x}` | Scalable norm / absolute-value delimiters |
| `\ind{A}` | Indicator of an event |
| `X_n\asto X` | Almost-sure convergence |
| `X_n\pto X` | Convergence in probability |
| `X_n\dto X` | Convergence in distribution |
| `\incfig{diagram}` | Insert `figures/diagram.pdf_tex` and its PDF |

Available environments: `theorem`, `lemma`, `proposition`, `corollary`,
`definition`, `example`, and `proof`. Theorem-style counters share numbering
within sections. The corresponding manual snippets are convenience wrappers;
you can write any environment directly.

Put notation for just one class in that project's `course-macros.tex`. Change
the shared macros only for notation you want across courses. If a document
already declares theorem environments or the same operators, avoid loading
conflicting definitions twice.

## Draw and insert an Inkscape figure

1. In the LaTeX editor's Normal mode, press **Ctrl+L f**.
2. Enter a simple name such as `triangle`, without `.svg`. Names may contain
   letters, digits, hyphens, and underscores, and must start with a letter/digit.
3. Inkscape opens `figures/triangle.svg` in the current project. A blank SVG is
   created if it does not exist. Use its shape, line/Bezier, text, selection,
   and alignment tools to draw the figure.
4. For mathematical labels, enter literal LaTeX such as `$A$`, `$\alpha$`,
   or `$\vec{v}$` using the text tool. Inkscape may display the raw label text;
   LaTeX typesets it at document build time.
5. **Save the SVG in Inkscape.** Return to VSCodium, press **Ctrl+L x**, and enter
   the same figure name.
6. Export creates `figures/triangle.pdf` and `figures/triangle.pdf_tex`.
7. Insert the figure with `\incfig{triangle}`, or accept the manual `svgfig`
   snippet at the start of a line to get a figure wrapper, caption, and label.
8. Build the notes with **Ctrl+L b**.

A minimal wrapper, in a document loading the shared macros:

```latex
\begin{figure}[htbp]
  \centering
  \incfig{triangle}
  \caption{A triangle with height $h$.}
  \label{fig:triangle}
\end{figure}
```

Keep the SVG as your editable source. **Every later drawing change needs Save
and Export again.** There is no automatic watcher. Keep both exported files
because the `.pdf_tex` file references the PDF. PDF+LaTeX export uses the drawing
bounds, so stray objects can enlarge the exported figure. The current macro
uses the column width; customize a course-specific figure wrapper if you need
a different sizing policy.

Command-line equivalents:

```sh
latex-workflow figure edit triangle --project /path/to/notes
latex-workflow figure export triangle --project /path/to/notes
```

Omitting `--project` uses the current terminal directory, which is not always
the folder containing the file you are editing. The editor tasks use the opened
workspace folder. In a multi-root workspace, choose/run the task in the intended
folder or use an explicit `--project` path.

## Plot functions and data

**PGFPlots** defines a graph in your `.tex` file. Add these in the preamble:

```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
```

Then use the manual `plot` snippet outside math, or write:

```latex
\begin{tikzpicture}
\begin{axis}[axis lines=middle, xlabel=$x$, ylabel=$f(x)$]
  \addplot[domain=-2:2,samples=101]{x^2};
\end{axis}
\end{tikzpicture}
```

**Python/Matplotlib** generates a vector PDF:

```sh
latex-workflow plot --project /path/to/notes
```

Or run **Tasks: Run Task → Plot: generate normal distribution**. This runs the
included normal-distribution example and writes `figures/normal.pdf`. Insert it
using `\includegraphics[width=\linewidth]{figures/normal.pdf}` in a document
loading `graphicx` (the shared macros already load it).

The current plot command is an example, not an arbitrary function prompt. It
replaces `figures/normal.pdf` on each run. For a course-specific graph, save a
standalone `plot.py` in that notes folder, for example:

```python
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

x = [-2 + i / 50 for i in range(201)]
y = [value**2 for value in x]
fig, ax = plt.subplots()
ax.plot(x, y)
ax.set(xlabel=r"$x$", ylabel=r"$x^2$")
output = Path(__file__).resolve().parent / "figures" / "curve.pdf"
output.parent.mkdir(exist_ok=True)
fig.savefig(output)
plt.close(fig)
```

Run it with the toolkit Python so Matplotlib is available:

```sh
"$HOME/.local/share/latex-workflow/.venv/bin/python" /path/to/notes/plot.py
```

This writes beside that script in `figures/curve.pdf`; insert it with
`\includegraphics[width=\linewidth]{figures/curve.pdf}`.

Keep generated figures on separate paragraphs/figure environments to avoid
placing two wide plots on one line; an `Overfull \hbox` is a layout warning.

## Build documents and use PythonTeX

The default recipe is **latexmk**, suitable for ordinary notes. It handles the
needed TeX passes and writes build products beside the document. The toolkit
wrapper supplies shared macros and its writable TeX package tree. Source/PDF
synchronization is enabled.

For embedded calculations, select **LaTeX Workshop: Build with recipe →
PythonTeX (trusted documents)**. This runs TeX, PythonTeX using the permanent
Python environment, and TeX again. Use the explicit recipe or CLI option for
PythonTeX documents; the default recipe remains latexmk.

```latex
\documentclass{article}
\usepackage{amsmath,amssymb,pythontex}
\begin{document}
\begin{sympycode}
x, y = symbols('x y')
I = Integral(x*y, (y,0,1-x), (x,0,1))
result = I.doit()
\end{sympycode}
\[
  \sympy{I} = \sympy{result} \approx \sympy{N(result,8)}
\]
\end{document}
```

`\sympy` turns SymPy results into LaTeX. Change the calculation and rebuild to
refresh the result. Initial "missing autoprint" messages on the first TeX pass
can be expected before PythonTeX generates its outputs; check the final passes
and errors. PythonTeX executes document code, so use it with documents you trust.

**CAS snippets** calculate once and insert ordinary LaTeX. **PythonTeX** retains
the calculation in the document and recalculates it during its build recipe.
Rendered source previews are separate from both and do not execute Python.

## Spell checking and completion

Code Spell Checker checks prose and skips configured math blocks, LaTeX command
names, calculation environments, and runtime directories. It is a spelling aid,
not a mathematical or grammar verifier. Add shared mathematical vocabulary to
`config/cspell.json` through chezmoi; add course-specific words locally, for
example with a `% cSpell:words ...` directive in your notes.

LaTeX Workshop provides package/command completion and reads macros from source.
Its extra completion packages include amsmath, amssymb, amsthm, and pgfplots.
Use **Trigger Suggest** if a completion does not appear automatically. Not every
custom package command will have a completion or MathJax preview.

## All terminal commands

| Command | Purpose |
| --- | --- |
| `latex-workflow init [PROJECT]` | Create a minimal project; defaults to the current directory |
| `latex-workflow open [PROJECT]` | Open the dedicated math editor; defaults to the current directory |
| `latex-workflow build DOCUMENT` | Build an ordinary document with latexmk |
| `latex-workflow build --pythontex DOCUMENT` | Run the PythonTeX build sequence |
| `latex-workflow figure edit NAME [--project DIR]` | Create/open a named SVG |
| `latex-workflow figure export NAME [--project DIR]` | Export a saved SVG as PDF+LaTeX |
| `latex-workflow plot [--project DIR]` | Generate the normal-distribution example PDF |
| `latex-workflow doctor` | Report toolkit paths, tools, and key TeX files |
| `latex-workflow setup` | Rerun macOS dependency/setup checks and smoke builds |
| `latex-workflow editor-links` | Repair/create the dedicated editor's config links |
| `latex-workflow --help` | Display command help; subcommands also accept `--help` |

Quote paths with spaces. `build` takes a filename; `open` and `init` take a
folder. `setup` may download packages and install dependencies; it is not the
normal command for compiling notes. `doctor` reports missing tools and files,
but it does not replace a full end-to-end build or visual preview check.

## Where files live and how to change them

The installed toolkit root is `~/.local/share/latex-workflow`. Paths below are
relative to that root unless marked otherwise.

| Path | What it controls |
| --- | --- |
| `GUIDE.md`, `CHEATSHEET.md`, `SNIPPETS.md`, `TEX-EDITING.md` | Main guide, daily reference, snippets, and TeX-aware Helix commands |
| `hsnips/latex.hsnips` | All snippet triggers, bodies, contexts, and CAS integration |
| `config/settings.json` | Math editor settings, preview macros, and build recipes |
| `config/keybindings.json` | TeX-specific Helix-mode shortcuts |
| `config/tasks.json` | Inkscape and Python plot task definitions |
| `config/cspell.json` | Shared spelling vocabulary and exclusions |
| `tex/latex/latex-workflow/math-macros.tex` | Shared actual-LaTeX notation and theorem definitions |
| `tex/latex/latex-workflow/math-preview-macros.tex` | Workshop's preview-only macros |
| `config/settings.json` → `mathSourcePreview.macros` | The local in-source renderer's preview macros |
| `templates/` | New-project defaults |
| `examples/` | Calculations, plotting, theorem, and drawing examples |
| `tools/cas.py` | Allowed CAS expressions/functions |
| `editor/math-source-preview/` | Source of the custom native-editor preview extension |
| `extensions.txt` | Tested extension versions |
| `config/Brewfile`, `bootstrap-macos.sh` | macOS dependencies and setup |
| `~/.local/state/latex-workflow/vscodium/` | Dedicated VSCodium state; its User settings/tasks link to managed config |
| `~/.local/bin/latex-workflow`, `~/bin/latex-workflow` | Launcher and link already on your shell PATH |

To sync changes between Macs, edit **chezmoi source**, then apply. For example:

```sh
chezmoi edit ~/.local/share/latex-workflow/hsnips/latex.hsnips
chezmoi apply
```

The source counterpart of a deployed file is available with:

```sh
chezmoi source-path ~/.local/share/latex-workflow/config/settings.json
```

The editor settings/tasks sources are `.tmpl` files: chezmoi supplies the home
directory for each device. Preserve those template expressions when editing
paths. Changes made through the editor UI modify the deployed config; use your
chezmoi workflow to reconcile/save them to source if you want them synced.

After snippet edits, run **HyperSnips: Reload Snippets**. A full **Developer:
Reload Window** can refresh extension state. Runtime changes to the custom
preview extension need its VSIX rebuilt/reinstalled via `latex-workflow setup`;
editing extension source alone does not replace the installed extension.

The macOS chezmoi hook may rerun setup when tracked toolkit source changes.
Extension auto-updates are disabled in this dedicated instance; intentionally
update `extensions.txt` and rerun setup when upgrading. The custom renderer uses
Workshop's bundled MathJax, so verify previews after a Workshop upgrade.

Do not commit `.venv/`, `texmf/`, `extensions/`, `cache/`, or editor state.
Chezmoi excludes these runtime files; they are recreated per device. Only the
source, settings, templates, requirements, docs, and installer are tracked.
Your ordinary coding editor and Linux shell files are separate. The installer
currently supports macOS; Linux support would need its own explicit integration.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| None of the math shortcuts work | Open the project with `latex-workflow open`; check Helix mode and that the file language is LaTeX. |
| A symbol snippet does nothing | Put the cursor inside recognized math; check its boundary rule and whether it is manual. |
| Tab just indents | For manual snippets, request/accept the matching suggestion first; Tab navigation requires an active snippet. |
| Snippets rewrite normal typing | Check automatic triggers and boundaries; undo the expansion if needed. |
| CAS does nothing | Include both markers and spaces: `cas EXPRESSION cas`. It triggers on the closing `s`, not on Tab. |
| CAS reports an error | Use SymPy syntax, explicit `*` and `**`, supported functions, and balanced parentheses. Check the notification. |
| A CAS calculation disappears or times out | The five-second limit stops lengthy evaluations; simplify the calculation or use a separate script/PythonTeX. Failed input should be preserved. |
| Math no longer renders in source | Toggle Ctrl+L m; move the caret out of the equation. Incomplete/unsupported math remains source. Check Output → Math Source Preview. |
| Previews are small or overlap awkwardly | Give display equations several source lines, or use Ctrl+L p / the PDF viewer. |
| A custom command works in PDF but not preview | Define it separately for Workshop and the local source renderer's MathJax macros. |
| `\Var` or theorem/proof is undefined | Load the shared macros once in the preamble and build through the toolkit. |
| A figure is stale | Save in Inkscape and export again; opening/editing is not export. |
| `diagram.pdf_tex` is missing | Export the same named SVG in the intended project; keep the matching PDF too. |
| A task writes to the wrong course folder | Check the opened workspace, or use the CLI with explicit `--project`. |
| PythonTeX results are missing | Use its explicit recipe/`--pythontex`, then inspect the final build log. |
| A matrix/cases preview fails | Check `&` column separators, `\\` row separators, balanced braces, and environment boundaries. |
| A table snippet produces an odd row | The inherited `table` template has a complex row transform; inspect it and write column separators manually if necessary. |
| `latex-workflow` is not found | Use `~/bin/latex-workflow`; your chezmoi shell config puts `~/bin` on PATH. Open a new shell if needed. |
| A tool/package is missing | Run `latex-workflow doctor`; use `latex-workflow setup` to rebuild the runtime. |

The mathematical content, domain restrictions, and explanatory reasoning remain
yours to check. The workflow speeds up writing, calculation, and feedback.
