# Calculate using LaTeX

The normal VSCodium workflow accepts the same mathematical LaTeX in CAS snippets and embedded PythonTeX calculations. Existing explicit SymPy code still works.

## Calculate once

Inside math mode, type the whole trigger, including the closing `cas`:

```tex
cas \int_0^1 x^2\,dx cas
```

The CAS snippet inserts `\frac{1}{3}`. That result becomes ordinary document text.

## Recalculate when building

Choose **PythonTeX (trusted documents)**. Include `\usepackage{pythontex}` in the preamble.

```tex
\[
  \int_0^1 x^2\,dx = \sympy{\int_0^1 x^2\,dx}
\]
```

The expression is written in LaTeX; `\sympy` prints its calculated result.

Named calculations work too; no symbol declarations are needed:

```tex
\begin{sympycode}
  answer2 = \int_0^1 x^2\,dx
  a = 2
  area = \int_0^a x\,dx
  f(x) = x^2 + 1
  value = f(3)
\end{sympycode}

\[ \sympy{answer2},\quad \sympy{area},\quad \sympy{value} \]
```

Use `value = f(3)` as native Python after defining `f`; the mathematical definition creates a callable SymPy Lambda. Keep one mathematical assignment per line. Uniform block indentation is accepted; multiline Python remains Python. For long LaTeX expressions, keep the assignment on one source line.

## Operations

These prefixes work in both CAS and `\sympy{...}` or assignment input:

| Input | Meaning |
|---|---|
| `factor: x^2-1` | Factor |
| `expand: (x+1)^3` | Expand |
| `simplify: \sin^2(x)+\cos^2(x)` | Simplify |
| `solve x: x^2=1` | Solve for x |
| `numeric 8: \pi` | Eight significant digits |
| `hold: \int_0^1 x^2\,dx` | Keep the unevaluated integral |

Ordinary input is evaluated and simplified. Standard fractions, powers, Greek variables, integrals, derivatives, limits, sums and products use SymPy's supported LaTeX grammar. Standalone `matrix`, `pmatrix`, `bmatrix`, and `smallmatrix` are supported, along with `\det{...}`, `\operatorname{trace}{...}` and `\operatorname{rank}{...}` on a matrix or previously named matrix.

## Meaning and limits

LaTeX describes appearance, so not every LaTeX document has a unique computational interpretation. This is a mathematical-input layer, not a full TeX engine. Unsupported commands and ambiguous undefined `f(x)` raise errors. Write `x\cdot(y+1)` for multiplication. Define functions before calling them. Use `\pi` for the constant, `\mathrm{e}` for Euler's constant, and `\mathrm{i}` for the imaginary unit; plain e and i are variables.

Named calculation values can be used in later expressions. Integration variables remain bound even if the same name has a saved value. Displaying a named stored result preserves its saved form, so an existing native `Integral(...)` output does not suddenly evaluate itself.

TeX `\newcommand` definitions are not automatically executed by the parser. Register computational aliases in `config/latex-macros.json`, in the permanent toolkit and chezmoi source. Entries are strings or `{ "args": 1, "body": "...#1..." }` objects. `\dd` and `\abs{...}` are supplied. Arbitrary TeX formatting, custom semantic operators, and matrix arithmetic embedded inside scalar expressions need explicit support; errors leave CAS input intact.

Legacy `integrate(...)`, `Matrix(...)`, `.subs(...)`, and other existing supported SymPy calls remain available. CAS also accepts `python:` to explicitly choose its existing restricted SymPy syntax. In external Python scripts, import `evaluate_latex` from the toolkit's `tools/latex_math.py`; this integration does not modify SymPy globally.

Only run PythonTeX for trusted documents: its blocks execute Python.
