# Calculate from written LaTeX

Choose **PythonTeX (trusted documents)** or run
`latex-workflow build --pythontex document.tex`.
Include `\usepackage{pythontex}` in the preamble.

Paste the mathematical expression into a `sympycode` assignment. Use standard
SymPy operations on the saved value, then insert the result using `\sympy`:

```tex
\begin{sympycode}
  answer = \left(\frac{6}{\sum_{i=1}^{n} x_i^6}\right)^{\frac{1}{5}}
  result = simplify(answer)
  polynomial = x^3+x^2+1
  second_derivative = diff(polynomial, Symbol('x'), 2)
\end{sympycode}

\[ \sympy{result},\qquad \sympy{second_derivative} \]
```

You can also paste a multiline display into an assignment:

```tex
\begin{sympycode}
  area = \[
    \int_0^1 x^2\,dx
  \]
  decimal = N(area, 8)
\end{sympycode}
\[ \sympy{area} \approx \sympy{decimal} \]
```

Both inline calculations and named LaTeX operations are supported:

```tex
\begin{sympycode}
  factored = factor: x^2-1
  roots = solve x: x^2=1
  integral = \int_0^1 x^2\,dx
\end{sympycode}
\[ \sympy{factored},\quad \sympy{roots},\quad \sympy{integral} \]
```

`evaluate:`, `simplify:`, `expand:`, `factor:`, `solve x:`, `numeric 8:` and
`hold:` prefixes are available. Native SymPy code remains available for
substitutions, differentiation variables, lists of observations and other
operations. Calculations refresh when building with the PythonTeX recipe.

The conversion backend is the upstream `latex2sympy2_extended` library rather
than SymPy's experimental LaTeX parser. A binding adapter represents subscripts
as indexed SymPy values so `\sum_{i=1}^n x_i^6` preserves its dependence on `i`.
For finite limits, the sum expands into the individual indexed observations.
For a numerical answer, supply numerical observations and bounds.

A barred variable is a distinct constant symbol unless given an explicit
functional dependence. The sample expression above contains no free scalar
`x`, so differentiating it with respect to scalar `x` gives zero. To
calculate a different derivative, specify the variable or indexed observation.

The backend supports a mathematical LaTeX grammar, not arbitrary TeX programs.
Preamble macros do not automatically have computational meanings; existing
aliases in `config/latex-macros.json` still apply. Unsupported input produces a
build error. Use braces around compound exponents: `^{\frac{1}{5}}`.

Installation is provided by `tools/install_latex_cas.py`. It installs the
packaged dependency, runs regression tests, backs up previous toolkit files,
and restores those files if the installed tests fail.
