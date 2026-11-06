# Complete HyperSnips reference

Practical instructions: [GUIDE.md](GUIDE.md). Daily summary: [CHEATSHEET.md](CHEATSHEET.md).

This catalog contains **all 115 snippets** from `hsnips/latex.hsnips`.
It is generated from the configured file, not a generic list of suggested shortcuts.

## How to read this reference

- **Automatic** means it expands on the final trigger character, without Tab.
- **Manual** means request/accept its matching completion (Ctrl+Space / Trigger Suggest).
  Tab alone is context-dependent; Tab/Shift+Tab navigate placeholders after expansion.
- **Math** means the snippet requires a recognized math scope. **Any** means it has no
  math-only context restriction; do not nest a snippet that creates its own math environment.
- **Start of line** permits only whitespace before a literal trigger; **word boundary**
  requires a suitable word boundary. **In-word** permits a suffix, such as `xsr`.
- Regex triggers match the current line suffix. Their displayed expression is a matching
  rule, not the text you should type. Concrete examples appear below.
- Templates show the configured body (trailing whitespace omitted). `$1`, `$2`, etc. are editable tab stops,
  `${1:default}` supplies default text, and `$0` is the final cursor position.
- Double-backtick blocks are JavaScript used by HyperSnips, not LaTeX to type yourself.
  Some backslashes are escaped for the native snippet engine. This is a source reference,
  not a claim that every inherited template produces perfect output without adjustment.

## Regex and postfix examples

| Example input in math | What the rule does |
| --- | --- |
| `x/`, `3x/` | Put a symbol/coefficient in a fraction numerator |
| `(x+1)/` | Put the parenthesized expression in a fraction numerator |
| `x2`, then a second digit | Insert a subscript; group a two-digit subscript |
| `sin`, `cos`, `pi`, `int` | Add a command backslash automatically |
| `xhat`, `xbar` | Accent one preceding letter |
| `hat`, `bar` | Insert an accent wrapper with a placeholder |
| `sts` | Insert a text subscript (with a special preceding-character rule) |
| `cas diff(x**2,x) cas` | Evaluate on the closing marker; this rule has no math-only context |

The single-letter postfix rules do not capture an entire arbitrary expression.
Math auto-expansions pause while `cas ` appears in the current line prefix.

## Complete index

| # | Trigger or regex | Description | Mode | Scope |
| --- | --- | --- | --- | --- |
| [001](#snippet-001) | `template` | Basic template (VS Code / TinyTeX safe) | Manual | Any |
| [002](#snippet-002) | `proofenv` | Proof environment | Manual | Any |
| [003](#snippet-003) | `thmenv` | Theorem environment (math-macros.tex) | Manual | Any |
| [004](#snippet-004) | `lemmenv` | Lemma environment (math-macros.tex) | Manual | Any |
| [005](#snippet-005) | `coursemacros` | Load course math macros in the preamble | Manual | Any |
| [006](#snippet-006) | `svgfig` | Insert exported Inkscape figure | Manual | Any |
| [007](#snippet-007) | `beg` | begin{} / end{} | Automatic | Any |
| [008](#snippet-008) | `...` | ldots | Automatic | Any |
| [009](#snippet-009) | `table` | Table environment | Manual | Any |
| [010](#snippet-010) | `fig` | Figure environment | Manual | Any |
| [011](#snippet-011) | `enum` | Enumerate | Automatic | Any |
| [012](#snippet-012) | `item` | Itemize | Automatic | Any |
| [013](#snippet-013) | `desc` | Description | Manual | Any |
| [014](#snippet-014) | `pac` | Package | Manual | Any |
| [015](#snippet-015) | `=>` | implies | Automatic | Math |
| [016](#snippet-016) | `=<` | implied by | Automatic | Math |
| [017](#snippet-017) | `iff` | iff | Automatic | Math |
| [018](#snippet-018) | `mk` | Math | Automatic | Any |
| [019](#snippet-019) | `dm` | Display math | Automatic | Any |
| [020](#snippet-020) | `ali` | Align | Automatic | Any |
| [021](#snippet-021) | `//` | Fraction | Automatic | Math |
| [022](#snippet-022) | Regex: `(?<![A-Za-z0-9\\])((\d+)\|(\d*)(\\)?([A-Za-z]+)((\^\|_)(\{\d+\}\|\d))*)/` | symbol frac | Automatic | Math |
| [023](#snippet-023) | Regex: `^.*\)/` | () frac | Automatic | Math |
| [024](#snippet-024) | Regex: `\b([A-Za-z])(\d)` | auto subscript | Automatic | Math |
| [025](#snippet-025) | Regex: `\b([A-Za-z])_(\d\d)` | auto subscript2 | Automatic | Math |
| [026](#snippet-026) | `==` | align equals (press Tab; avoid accidental & outside align) | Manual | Math |
| [027](#snippet-027) | `!=` | not equals | Automatic | Math |
| [028](#snippet-028) | `ceil` | ceil | Automatic | Math |
| [029](#snippet-029) | `floor` | floor | Automatic | Math |
| [030](#snippet-030) | `pmat` | pmat | Automatic | Math |
| [031](#snippet-031) | `bmat` | bmat | Automatic | Math |
| [032](#snippet-032) | `()` | left( right) | Automatic | Math |
| [033](#snippet-033) | `lr` | left( right) | Manual | Math |
| [034](#snippet-034) | `lr(` | left( right) | Manual | Math |
| [035](#snippet-035) | `lr\|` | left /  right /  | Manual | Math |
| [036](#snippet-036) | `lr{` | left{ right} | Manual | Math |
| [037](#snippet-037) | `lrb` | left{ right} | Manual | Math |
| [038](#snippet-038) | `lr[` | left[ right] | Manual | Math |
| [039](#snippet-039) | `lra` | leftangle rightangle | Automatic | Math |
| [040](#snippet-040) | `conj` | conjugate | Automatic | Math |
| [041](#snippet-041) | `sum` | sum | Manual | Math |
| [042](#snippet-042) | `taylor` | taylor | Manual | Math |
| [043](#snippet-043) | `lim` | limit | Manual | Math |
| [044](#snippet-044) | `limsup` | limsup | Manual | Math |
| [045](#snippet-045) | `prod` | product | Manual | Math |
| [046](#snippet-046) | `part` | d/dx | Manual | Math |
| [047](#snippet-047) | `sq` | sqrt | Automatic | Math |
| [048](#snippet-048) | `sr` | ^2 | Automatic | Math |
| [049](#snippet-049) | `cb` | ^3 | Automatic | Math |
| [050](#snippet-050) | `td` | to the ... power | Automatic | Math |
| [051](#snippet-051) | `rd` | to the (...) power | Automatic | Math |
| [052](#snippet-052) | `__` | subscript | Automatic | Math |
| [053](#snippet-053) | `ooo` | infty | Automatic | Math |
| [054](#snippet-054) | `rij` | sequence | Manual | Math |
| [055](#snippet-055) | `<=` | leq | Automatic | Math |
| [056](#snippet-056) | `>=` | geq | Automatic | Math |
| [057](#snippet-057) | `EE` | exists | Automatic | Math |
| [058](#snippet-058) | `AA` | forall | Automatic | Math |
| [059](#snippet-059) | `xnn` | xn | Automatic | Math |
| [060](#snippet-060) | `ynn` | yn | Automatic | Math |
| [061](#snippet-061) | `xii` | xi | Automatic | Math |
| [062](#snippet-062) | `yii` | yi | Automatic | Math |
| [063](#snippet-063) | `xjj` | xj | Automatic | Math |
| [064](#snippet-064) | `yjj` | yj | Automatic | Math |
| [065](#snippet-065) | `xp1` | x n+1 | Automatic | Math |
| [066](#snippet-066) | `xmm` | xm | Automatic | Math |
| [067](#snippet-067) | `R0+` | R0+ | Automatic | Math |
| [068](#snippet-068) | `plot` | Plot | Manual | Any |
| [069](#snippet-069) | `nn` | Tikz node | Manual | Any |
| [070](#snippet-070) | `mcal` | mathcal | Automatic | Math |
| [071](#snippet-071) | `lll` | ell | Automatic | Math |
| [072](#snippet-072) | `nabl` | nabla | Automatic | Math |
| [073](#snippet-073) | `xx` | cross | Automatic | Math |
| [074](#snippet-074) | `**` | cdot | Automatic | Math |
| [075](#snippet-075) | `norm` | norm | Automatic | Math |
| [076](#snippet-076) | Regex: `(?<!\\)\b(sin\|cos\|cot\|csc\|ln\|log\|exp\|star\|perp\|arcsin\|arccos\|arctan\|arccot\|arccsc\|arcsec\|pi\|zeta\|int)` | auto backslash | Automatic | Math |
| [077](#snippet-077) | `dint` | integral | Automatic | Math |
| [078](#snippet-078) | `<->` | leftrightarrow | Automatic | Math |
| [079](#snippet-079) | `->` | to | Automatic | Math |
| [080](#snippet-080) | `!>` | mapsto | Automatic | Math |
| [081](#snippet-081) | `invs` | inverse | Automatic | Math |
| [082](#snippet-082) | `compl` | complement | Automatic | Math |
| [083](#snippet-083) | `\\\` | setminus | Automatic | Math |
| [084](#snippet-084) | `>>` | >> | Automatic | Math |
| [085](#snippet-085) | `<<` | << | Automatic | Math |
| [086](#snippet-086) | `~~` | ~ | Automatic | Math |
| [087](#snippet-087) | `set` | set | Automatic | Math |
| [088](#snippet-088) | `\|\|` | mid | Automatic | Math |
| [089](#snippet-089) | `cc` | subset | Automatic | Math |
| [090](#snippet-090) | `notin` | not in | Automatic | Math |
| [091](#snippet-091) | `inn` | in | Automatic | Math |
| [092](#snippet-092) | `NN` | N | Automatic | Math |
| [093](#snippet-093) | `Nn` | cap | Automatic | Math |
| [094](#snippet-094) | `UU` | cup | Automatic | Math |
| [095](#snippet-095) | `uuu` | bigcup | Automatic | Math |
| [096](#snippet-096) | `nnn` | bigcap | Automatic | Math |
| [097](#snippet-097) | `OO` | emptyset | Automatic | Math |
| [098](#snippet-098) | `RR` | R | Automatic | Math |
| [099](#snippet-099) | `QQ` | Q | Automatic | Math |
| [100](#snippet-100) | `ZZ` | Z | Automatic | Math |
| [101](#snippet-101) | `<!` | normal subgroup | Automatic | Math |
| [102](#snippet-102) | `<>` | diamond | Automatic | Math |
| [103](#snippet-103) | Regex: `(?<!i)sts` | text subscript | Automatic | Math |
| [104](#snippet-104) | `tt` | text | Automatic | Math |
| [105](#snippet-105) | `case` | cases | Automatic | Math |
| [106](#snippet-106) | `SI` | SI | Automatic | Math |
| [107](#snippet-107) | `bigfun` | Big function | Automatic | Any |
| [108](#snippet-108) | `cvec` | column vector | Automatic | Math |
| [109](#snippet-109) | Regex: `(?<![A-Za-z])bar` | bar | Automatic | Math |
| [110](#snippet-110) | Regex: `([a-zA-Z])bar` | letter bar | Automatic | Math |
| [111](#snippet-111) | Regex: `(?<![A-Za-z])hat` | hat | Automatic | Math |
| [112](#snippet-112) | Regex: `([a-zA-Z])hat` | letter hat | Automatic | Math |
| [113](#snippet-113) | `HH` | H | Automatic | Math |
| [114](#snippet-114) | `DD` | D | Automatic | Math |
| [115](#snippet-115) | Regex: `\bcas (.+?) cas` | Evaluate SymPy expression as LaTeX | Automatic | Any |

## Configured templates

<a id="snippet-001"></a>

### 001. Basic template (VS Code / TinyTeX safe)

Trigger: `template`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\documentclass[a4paper]{article}

\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{textcomp}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}

% Figure support: the same packages as the original template.
\usepackage{import}
\usepackage{xifthen}
\usepackage{pdfpages}
\usepackage{transparent}
\newcommand{\incfig}[1]{%
    \def\svgwidth{\columnwidth}
    \import{./figures/}{#1.pdf_tex}
}

% Number-set shortcuts used by NN/RR/QQ/ZZ/R0+ etc.
\providecommand{\N}{\mathbb{N}}
\providecommand{\R}{\mathbb{R}}
\providecommand{\Q}{\mathbb{Q}}
\providecommand{\Z}{\mathbb{Z}}

% Load optional packages when available. Keep parameterized definitions
% OUTSIDE \IfFileExists branches to avoid "Illegal parameter number".
\IfFileExists{siunitx.sty}{\usepackage{siunitx}}{}
\providecommand{\SI}[2]{\ensuremath{#1\,\mathrm{#2}}}
\IfFileExists{pgfplots.sty}{%
    \usepackage{pgfplots}
    \pgfplotsset{compat=1.18}
}{}

\begin{document}
\section{Math Notes}

$0
\end{document}
```

</details>

<a id="snippet-002"></a>

### 002. Proof environment

Trigger: `proofenv`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{proof}
    $1
\end{proof}
$0
```

</details>

<a id="snippet-003"></a>

### 003. Theorem environment (math-macros.tex)

Trigger: `thmenv`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{theorem}[${1:Title}]
    $2
\end{theorem}
$0
```

</details>

<a id="snippet-004"></a>

### 004. Lemma environment (math-macros.tex)

Trigger: `lemmenv`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{lemma}
    $1
\end{lemma}
$0
```

</details>

<a id="snippet-005"></a>

### 005. Load course math macros in the preamble

Trigger: `coursemacros`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\input{math-macros.tex}
```

</details>

<a id="snippet-006"></a>

### 006. Insert exported Inkscape figure

Trigger: `svgfig`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{figure}[htbp]
    \centering
    \incfig{${1:diagram}}
    \caption{${2:Caption}}
    \label{fig:$1}
\end{figure}
$0
```

</details>

<a id="snippet-007"></a>

### 007. begin{} / end{}

Trigger: `beg`

**Automatic · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{$1}
	$0
\end{$1}
```

</details>

<a id="snippet-008"></a>

### 008. ldots

Trigger: `...`

**Automatic · No math-only restriction · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\ldots
```

</details>

<a id="snippet-009"></a>

### 009. Table environment

Trigger: `table`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{table}[${1:htpb}]
	\centering
	\caption{${2:caption}}
	\label{tab:${3:label}}
	\begin{tabular}{${5:c}}
	$0${5/((?<=.)c|l|r)|./(?1: & )/g}
	\end{tabular}
\end{table}
```

</details>

<a id="snippet-010"></a>

### 010. Figure environment

Trigger: `fig`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{figure}[${1:htbp}]
    \centering
    \includegraphics[width=0.8\textwidth]{${2:filename}}
    \caption{${3:caption}}
    \label{fig:${4:label}}
\end{figure}
$0
```

</details>

<a id="snippet-011"></a>

### 011. Enumerate

Trigger: `enum`

**Automatic · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{enumerate}
	\item $0
\end{enumerate}
```

</details>

<a id="snippet-012"></a>

### 012. Itemize

Trigger: `item`

**Automatic · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{itemize}
	\item $0
\end{itemize}
```

</details>

<a id="snippet-013"></a>

### 013. Description

Trigger: `desc`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{description}
	\item[$1] $0
\end{description}
```

</details>

<a id="snippet-014"></a>

### 014. Package

Trigger: `pac`

**Manual completion · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\usepackage[${1:options}]{${2:package}}$0
```

</details>

<a id="snippet-015"></a>

### 015. implies

Trigger: `=>`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\implies
```

</details>

<a id="snippet-016"></a>

### 016. implied by

Trigger: `=<`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\impliedby
```

</details>

<a id="snippet-017"></a>

### 017. iff

Trigger: `iff`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\iff
```

</details>

<a id="snippet-018"></a>

### 018. Math

Trigger: `mk`

**Automatic · No math-only restriction · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\$${1}\$$0
```

</details>

<a id="snippet-019"></a>

### 019. Display math

Trigger: `dm`

**Automatic · No math-only restriction · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\[
	$1
\] $0
```

</details>

<a id="snippet-020"></a>

### 020. Align

Trigger: `ali`

**Automatic · No math-only restriction · Start of line**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{align*}
	$1
\end{align*}
```

</details>

<a id="snippet-021"></a>

### 021. Fraction

Trigger: `//`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\frac{$1}{$2}$0
```

</details>

<a id="snippet-022"></a>

### 022. symbol frac

Trigger: `(?<![A-Za-z0-9\\])((\d+)\|(\d*)(\\)?([A-Za-z]+)((\^\|_)(\{\d+\}\|\d))*)/` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
\frac{``rv = m[1]``}{$1}$0
```

</details>

<a id="snippet-023"></a>

### 023. () frac

Trigger: `^.*\)/` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
``rv = parenFrac(m[0])``{$1}$0
```

</details>

<a id="snippet-024"></a>

### 024. auto subscript

Trigger: `\b([A-Za-z])(\d)` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
``rv = m[1]``_``rv = m[2]``
```

</details>

<a id="snippet-025"></a>

### 025. auto subscript2

Trigger: `\b([A-Za-z])_(\d\d)` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
``rv = m[1]``_{``rv = m[2]``}
```

</details>

<a id="snippet-026"></a>

### 026. align equals (press Tab; avoid accidental & outside align)

Trigger: `==`

**Manual completion · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
&= $1 \\\\
```

</details>

<a id="snippet-027"></a>

### 027. not equals

Trigger: `!=`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\neq
```

</details>

<a id="snippet-028"></a>

### 028. ceil

Trigger: `ceil`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left\lceil $1 \right\rceil $0
```

</details>

<a id="snippet-029"></a>

### 029. floor

Trigger: `floor`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left\lfloor $1 \right\rfloor$0
```

</details>

<a id="snippet-030"></a>

### 030. pmat

Trigger: `pmat`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{pmatrix} $1 \end{pmatrix} $0
```

</details>

<a id="snippet-031"></a>

### 031. bmat

Trigger: `bmat`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{bmatrix} $1 \end{bmatrix} $0
```

</details>

<a id="snippet-032"></a>

### 032. left( right)

Trigger: `()`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left( $1 \right) $0
```

</details>

<a id="snippet-033"></a>

### 033. left( right)

Trigger: `lr`

**Manual completion · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left( $1 \right) $0
```

</details>

<a id="snippet-034"></a>

### 034. left( right)

Trigger: `lr(`

**Manual completion · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left( $1 \right) $0
```

</details>

<a id="snippet-035"></a>

### 035. left| right|

Trigger: `lr\|`

**Manual completion · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left| $1 \right| $0
```

</details>

<a id="snippet-036"></a>

### 036. left{ right}

Trigger: `lr{`

**Manual completion · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left\\{ $1 \right\\} $0
```

</details>

<a id="snippet-037"></a>

### 037. left{ right}

Trigger: `lrb`

**Manual completion · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left\\{ $1 \right\\} $0
```

</details>

<a id="snippet-038"></a>

### 038. left[ right]

Trigger: `lr[`

**Manual completion · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left[ $1 \right] $0
```

</details>

<a id="snippet-039"></a>

### 039. leftangle rightangle

Trigger: `lra`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\left<$1 \right>$0
```

</details>

<a id="snippet-040"></a>

### 040. conjugate

Trigger: `conj`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\overline{$1}$0
```

</details>

<a id="snippet-041"></a>

### 041. sum

Trigger: `sum`

**Manual completion · Math only · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\sum_{n=${1:1}}^{${2:\infty}} ${3:a_n z^n}
```

</details>

<a id="snippet-042"></a>

### 042. taylor

Trigger: `taylor`

**Manual completion · Math only · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\sum_{${1:k}=${2:0}}^{${3:\infty}} ${4:c_$1} (x-a)^$1 $0
```

</details>

<a id="snippet-043"></a>

### 043. limit

Trigger: `lim`

**Manual completion · Math only · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\lim_{${1:n} \to ${2:\infty}}
```

</details>

<a id="snippet-044"></a>

### 044. limsup

Trigger: `limsup`

**Manual completion · Math only · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\limsup_{${1:n} \to ${2:\infty}}
```

</details>

<a id="snippet-045"></a>

### 045. product

Trigger: `prod`

**Manual completion · Math only · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\prod_{${1:n=${2:1}}}^{${3:\infty}} $4 $0
```

</details>

<a id="snippet-046"></a>

### 046. d/dx

Trigger: `part`

**Manual completion · Math only · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\frac{\partial ${1:V}}{\partial ${2:x}} $0
```

</details>

<a id="snippet-047"></a>

### 047. sqrt

Trigger: `sq`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\sqrt{$1} $0
```

</details>

<a id="snippet-048"></a>

### 048. ^2

Trigger: `sr`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
^2
```

</details>

<a id="snippet-049"></a>

### 049. ^3

Trigger: `cb`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
^3
```

</details>

<a id="snippet-050"></a>

### 050. to the ... power

Trigger: `td`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
^{$1}$0
```

</details>

<a id="snippet-051"></a>

### 051. to the (...) power

Trigger: `rd`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
^{($1)}$0
```

</details>

<a id="snippet-052"></a>

### 052. subscript

Trigger: `__`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
_{$1}$0
```

</details>

<a id="snippet-053"></a>

### 053. infty

Trigger: `ooo`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\infty
```

</details>

<a id="snippet-054"></a>

### 054. sequence

Trigger: `rij`

**Manual completion · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
(${1:x}_${2:n})_{${3:$2}\in${4:\N}}$0
```

</details>

<a id="snippet-055"></a>

### 055. leq

Trigger: `<=`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\le
```

</details>

<a id="snippet-056"></a>

### 056. geq

Trigger: `>=`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\ge
```

</details>

<a id="snippet-057"></a>

### 057. exists

Trigger: `EE`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\exists
```

</details>

<a id="snippet-058"></a>

### 058. forall

Trigger: `AA`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\forall
```

</details>

<a id="snippet-059"></a>

### 059. xn

Trigger: `xnn`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
x_{n}
```

</details>

<a id="snippet-060"></a>

### 060. yn

Trigger: `ynn`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
y_{n}
```

</details>

<a id="snippet-061"></a>

### 061. xi

Trigger: `xii`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
x_{i}
```

</details>

<a id="snippet-062"></a>

### 062. yi

Trigger: `yii`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
y_{i}
```

</details>

<a id="snippet-063"></a>

### 063. xj

Trigger: `xjj`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
x_{j}
```

</details>

<a id="snippet-064"></a>

### 064. yj

Trigger: `yjj`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
y_{j}
```

</details>

<a id="snippet-065"></a>

### 065. x n+1

Trigger: `xp1`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
x_{n+1}
```

</details>

<a id="snippet-066"></a>

### 066. xm

Trigger: `xmm`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
x_{m}
```

</details>

<a id="snippet-067"></a>

### 067. R0+

Trigger: `R0+`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\R_0^+
```

</details>

<a id="snippet-068"></a>

### 068. Plot

Trigger: `plot`

**Manual completion · No math-only restriction · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{figure}[$1]
	\centering
	\begin{tikzpicture}
		\begin{axis}[
			xmin= ${2:-10}, xmax= ${3:10},
			ymin= ${4:-10}, ymax = ${5:10},
			axis lines = middle,
		]
			\addplot[domain=$2:$3, samples=${6:100}]{$7};
		\end{axis}
	\end{tikzpicture}
	\caption{$8}
	\label{${9:$8}}
\end{figure}
```

</details>

<a id="snippet-069"></a>

### 069. Tikz node

Trigger: `nn`

**Manual completion · No math-only restriction · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\node[$4] (${1}) at (${2:0,0}) {\$${3:$1}\$};
$0
```

</details>

<a id="snippet-070"></a>

### 070. mathcal

Trigger: `mcal`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\mathcal{$1}$0
```

</details>

<a id="snippet-071"></a>

### 071. ell

Trigger: `lll`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\ell
```

</details>

<a id="snippet-072"></a>

### 072. nabla

Trigger: `nabl`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\nabla
```

</details>

<a id="snippet-073"></a>

### 073. cross

Trigger: `xx`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\times
```

</details>

<a id="snippet-074"></a>

### 074. cdot

Trigger: `**`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\cdot
```

</details>

<a id="snippet-075"></a>

### 075. norm

Trigger: `norm`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\|$1\|$0
```

</details>

<a id="snippet-076"></a>

### 076. auto backslash

Trigger: `(?<!\\)\b(sin\|cos\|cot\|csc\|ln\|log\|exp\|star\|perp\|arcsin\|arccos\|arctan\|arccot\|arccsc\|arcsec\|pi\|zeta\|int)` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
``rv = '\\' + m[1]``
```

</details>

<a id="snippet-077"></a>

### 077. integral

Trigger: `dint`

**Automatic · Math only · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\int_{${1:-\infty}}^{${2:\infty}} $3 $0
```

</details>

<a id="snippet-078"></a>

### 078. leftrightarrow

Trigger: `<->`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\leftrightarrow
```

</details>

<a id="snippet-079"></a>

### 079. to

Trigger: `->`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\to
```

</details>

<a id="snippet-080"></a>

### 080. mapsto

Trigger: `!>`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\mapsto
```

</details>

<a id="snippet-081"></a>

### 081. inverse

Trigger: `invs`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
^{-1}
```

</details>

<a id="snippet-082"></a>

### 082. complement

Trigger: `compl`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
^{c}
```

</details>

<a id="snippet-083"></a>

### 083. setminus

Trigger: `\\\`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\setminus
```

</details>

<a id="snippet-084"></a>

### 084. >>

Trigger: `>>`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\gg
```

</details>

<a id="snippet-085"></a>

### 085. <<

Trigger: `<<`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\ll
```

</details>

<a id="snippet-086"></a>

### 086. ~

Trigger: `~~`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\sim
```

</details>

<a id="snippet-087"></a>

### 087. set

Trigger: `set`

**Automatic · Math only · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\\{$1\\} $0
```

</details>

<a id="snippet-088"></a>

### 088. mid

Trigger: `\|\|`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
 \mid
```

</details>

<a id="snippet-089"></a>

### 089. subset

Trigger: `cc`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\subset
```

</details>

<a id="snippet-090"></a>

### 090. not in

Trigger: `notin`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\not\in
```

</details>

<a id="snippet-091"></a>

### 091. in

Trigger: `inn`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\in
```

</details>

<a id="snippet-092"></a>

### 092. N

Trigger: `NN`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\N
```

</details>

<a id="snippet-093"></a>

### 093. cap

Trigger: `Nn`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\cap
```

</details>

<a id="snippet-094"></a>

### 094. cup

Trigger: `UU`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\cup
```

</details>

<a id="snippet-095"></a>

### 095. bigcup

Trigger: `uuu`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\bigcup_{${1:i \in ${2: I}}} $0
```

</details>

<a id="snippet-096"></a>

### 096. bigcap

Trigger: `nnn`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\bigcap_{${1:i \in ${2: I}}} $0
```

</details>

<a id="snippet-097"></a>

### 097. emptyset

Trigger: `OO`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\varnothing
```

</details>

<a id="snippet-098"></a>

### 098. R

Trigger: `RR`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\R
```

</details>

<a id="snippet-099"></a>

### 099. Q

Trigger: `QQ`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\Q
```

</details>

<a id="snippet-100"></a>

### 100. Z

Trigger: `ZZ`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\Z
```

</details>

<a id="snippet-101"></a>

### 101. normal subgroup

Trigger: `<!`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\triangleleft
```

</details>

<a id="snippet-102"></a>

### 102. diamond

Trigger: `<>`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\diamond
```

</details>

<a id="snippet-103"></a>

### 103. text subscript

Trigger: `(?<!i)sts` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
_\text{$1} $0
```

</details>

<a id="snippet-104"></a>

### 104. text

Trigger: `tt`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\text{$1}$0
```

</details>

<a id="snippet-105"></a>

### 105. cases

Trigger: `case`

**Automatic · Math only · Word boundary**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{cases}
	$1
\end{cases}
```

</details>

<a id="snippet-106"></a>

### 106. SI

Trigger: `SI`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\SI{$1}{$2}
```

</details>

<a id="snippet-107"></a>

### 107. Big function

Trigger: `bigfun`

**Automatic · No math-only restriction · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{align*}
	$1: $2 &\longrightarrow $3 \\\\
	$4 &\longmapsto $1($4) = $0
\end{align*}
```

</details>

<a id="snippet-108"></a>

### 108. column vector

Trigger: `cvec`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\begin{pmatrix} ${1:x}_${2:1}\\\\ \vdots\\\\ $1_$2 \end{pmatrix}
```

</details>

<a id="snippet-109"></a>

### 109. bar

Trigger: `(?<![A-Za-z])bar` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
\overline{$1}$0
```

</details>

<a id="snippet-110"></a>

### 110. letter bar

Trigger: `([a-zA-Z])bar` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
\overline{``rv = m[1]``}
```

</details>

<a id="snippet-111"></a>

### 111. hat

Trigger: `(?<![A-Za-z])hat` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
\hat{$1}$0
```

</details>

<a id="snippet-112"></a>

### 112. letter hat

Trigger: `([a-zA-Z])hat` (regular expression)

**Automatic · Math only · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
\hat{``rv = m[1]``}
```

</details>

<a id="snippet-113"></a>

### 113. H

Trigger: `HH`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\mathbb{H}
```

</details>

<a id="snippet-114"></a>

### 114. D

Trigger: `DD`

**Automatic · Math only · In-word**

<details>
<summary>Show configured snippet template</summary>

```text
\mathbb{D}
```

</details>

<a id="snippet-115"></a>

### 115. Evaluate SymPy expression as LaTeX

Trigger: `\bcas (.+?) cas` (regular expression)

**Automatic · No math-only restriction · Regex suffix match**

<details>
<summary>Show configured snippet template</summary>

```text
``rv = evaluateCAS(m[1], w, m[0]);``
```

</details>

## Updating this catalog

After changing the snippet file, run `tools/generate_snippet_guide.py` with the
toolkit Python (or any Python 3). Defaults are relative to that script's toolkit:

```sh
python3 tools/generate_snippet_guide.py
```

You can also pass `--snippets PATH --output PATH` to generate from chezmoi source.
The generated catalog does not reload the editor; run **HyperSnips: Reload Snippets**.

Source SHA-256: `90c55280405a110a2962eb5e486474800cec701bcd0e9af1cc2b42df9b9e2e2d`.
