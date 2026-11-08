"""A shared LaTeX mathematical-input layer for CAS and PythonTeX.

This parses a supported mathematical notation subset, never arbitrary TeX.
"""
from pathlib import Path
import json
import re
import sympy as sp
from sympy.core.function import AppliedUndef, FunctionClass

ROOT = Path(__file__).resolve().parent.parent
GREEK = set('alpha beta gamma delta epsilon varepsilon zeta eta theta vartheta iota kappa lambda mu nu xi pi varpi rho varrho sigma varsigma tau upsilon phi varphi chi psi omega Gamma Delta Theta Lambda Xi Pi Sigma Upsilon Phi Psi Omega'.split())
COMMANDS = GREEK | set('int limits frac dfrac tfrac sqrt sin cos tan csc sec cot arcsin arccos arctan arccsc arcsec arccot sinh cosh tanh arsinh arcosh artanh log ln lg exp lim to rightarrow infty sum prod binom dbinom tbinom overline mathit cdot times div left right lfloor rfloor lceil rceil le leq leqq leqslant ge geq geqq geqslant neq partial'.split())
FUNCTION_OPERATORS = set('sin cos tan csc sec cot arcsin arccos arctan sinh cosh tanh log ln exp'.split())
MATRIX_ENVS = ('pmatrix', 'bmatrix', 'matrix', 'smallmatrix')


class MathInputError(ValueError):
    pass


def group(text, start):
    if start >= len(text) or text[start] != '{':
        raise MathInputError('Expected a braced argument in the LaTeX expression.')
    depth = 1
    i = start + 1
    while i < len(text):
        if text[i] == '\\':
            i += 2
            continue
        if text[i] == '{': depth += 1
        if text[i] == '}': depth -= 1
        if depth == 0: return text[start+1:i], i+1
        i += 1
    raise MathInputError('Unbalanced braces in the LaTeX expression.')


def expand_aliases(text):
    aliases = {'dd': {'args': 0, 'body': 'd'}, 'abs': {'args': 1, 'body': r'\left|#1\right|'}}
    file = ROOT / 'config/latex-macros.json'
    if file.exists(): aliases.update(json.loads(file.read_text()))
    for _ in range(8):
        result = []
        i = 0
        changed = False
        while i < len(text):
            match = re.match(r'\\([A-Za-z]+)', text[i:])
            if not match or match[1] not in aliases:
                result.append(text[i]); i += 1; continue
            alias = aliases[match[1]]
            if isinstance(alias, str): alias = {'args': 0, 'body': alias}
            count = alias['args']
            if not isinstance(count, int) or not 0 <= count <= 3:
                raise MathInputError('A registered math macro must take zero to three braced arguments.')
            replacement = alias['body']
            i += len(match[0])
            for number in range(1, count+1):
                while i < len(text) and text[i].isspace(): i += 1
                argument, i = group(text, i)
                replacement = replacement.replace('#'+str(number), argument)
            result.append(replacement); changed = True
        text = ''.join(result)
        if len(text) > 10000: raise MathInputError('Expanded expression is too large.')
        if not changed: return text
    raise MathInputError('Registered macro expansion is recursive or too deeply nested.')


def normalize(source):
    text = source.strip()
    for opening, closing in [('$$','$$'),('$','$'),(r'\[',r'\]'),(r'\(',r'\)')]:
        if text.startswith(opening) and text.endswith(closing):
            text = text[len(opening):-len(closing)].strip(); break
    text = expand_aliases(text)
    text = re.sub(r'\\(?:mathrm|operatorname)\s*\{\s*d\s*\}', 'd', text)
    text = re.sub(r'\\mathrm\s*\{\s*e\s*\}', lambda _:r'\mathit{EulerConstant}', text)
    text = re.sub(r'\\mathrm\s*\{\s*i\s*\}', lambda _:r'\mathit{ImaginaryConstant}', text)
    def operator(match):
        name = match[1]
        if name in FUNCTION_OPERATORS: return '\\'+name
        if name in {'det','trace','rank'}: return '\\'+name
        raise MathInputError(f'No computational meaning is registered for operator {name!r}.')
    text = re.sub(r'\\operatorname\s*\{([A-Za-z]+)\}', operator, text)
    text = re.sub(r'(?<!\\)\\(?:,|;|:|!|\s)|\\(?:quad|qquad|enspace|thinspace)\b', ' ', text)
    text = text.replace('**', '^')  # Backward-compatible scalar power spelling.
    return text.strip()


def split_top(text, delimiter):
    result = []; start = 0; stack = []
    i = 0
    while i < len(text):
        if not stack and text.startswith(delimiter, i):
            result.append(text[start:i]); i += len(delimiter); start = i; continue
        char = text[i]
        if char == '\\': i += 2; continue
        if char in '{[(': stack.append(char)
        elif char in '}])':
            if stack: stack.pop()
        i += 1
    result.append(text[start:])
    return result


def binding(name, scope, protected=()):
    if name in protected or name not in scope: return None
    value = scope[name]
    # Do not mistake SymPy's star-imported constants/functions for document definitions.
    if name in sp.__dict__ and value is sp.__dict__[name]: return None
    if isinstance(value, (sp.Basic, sp.MatrixBase, int, float, complex)) and not isinstance(value, bool):
        return sp.sympify(value)
    return None


def indexed_symbols(expression, parser):
    """Give mathematical subscripts index semantics, rather than opaque names.

    The upstream converter returns Symbol('x_i'); a Sum cannot see i inside
    that name. IndexedBase preserves that dependency for sums and derivatives.
    """
    if not isinstance(expression, sp.Basic):
        if isinstance(expression, sp.MatrixBase):
            return expression.applyfunc(lambda item: indexed_symbols(item, parser))
        return expression
    replacements = {}
    for symbol in expression.atoms(sp.Symbol):
        base, separator, subscript = symbol.name.partition('_')
        if not separator or not subscript:
            continue
        if subscript.startswith('{') and subscript.endswith('}'):
            subscript = subscript[1:-1]
        indices = tuple(parser(part.strip()) for part in split_top(subscript, ','))
        replacements[symbol] = sp.IndexedBase(base)[indices]
    return expression.xreplace(replacements)


def parse_math(source, scope=None, protected=()):
    scope = scope or {}
    if not isinstance(source, str) or not source.strip(): raise MathInputError('Enter a mathematical expression.')
    if len(source) > 5000: raise MathInputError('Use an expression shorter than 5000 characters.')
    text = normalize(source)
    known = binding(text, scope, protected)
    if known is not None: return known
    # Standalone matrices are handled explicitly, since SymPy's scalar grammar lacks them.
    for env in MATRIX_ENVS:
        opening = '\\begin{'+env+'}'; closing = '\\end{'+env+'}'
        if text.startswith(opening) and text.endswith(closing):
            body = text[len(opening):-len(closing)]
            rows = split_top(body, r'\\')
            entries = [[parse_math(value.strip(),scope,protected) for value in split_top(row,'&')] for row in rows if row.strip()]
            if not entries or any(len(row)!=len(entries[0]) for row in entries):
                raise MathInputError('Matrix rows must have equal column counts.')
            return sp.Matrix(entries)
    matrix_operator = re.match(r'^\\(det|trace|rank)\b\s*(.*)$', text, re.S)
    if matrix_operator:
        rest = matrix_operator[2].strip()
        if rest.startswith('(') and rest.endswith(')'): rest=rest[1:-1]
        if rest.startswith('{'):
            argument,end=group(rest,0)
            if end==len(rest): rest=argument
        matrix=parse_math(rest,scope,protected)
        if not isinstance(matrix,sp.MatrixBase):
            raise MathInputError('Define the matrix first, or supply its matrix environment directly.')
        return {'det':matrix.det,'trace':matrix.trace,'rank':matrix.rank}[matrix_operator[1]]()
    if '\\begin' in text or '\\end' in text:
        raise MathInputError('This mathematical environment/embedded matrix operation is not supported by the scalar parser.')
    try:
        from latex2sympy2_extended import latex2sympy
        from latex2sympy2_extended.latex2sympy2 import ConversionConfig
        expression = latex2sympy(text, conversion_config=ConversionConfig(lowercase_symbols=False))
        expression = indexed_symbols(expression, latex2sympy)
    except ImportError as error:
        raise MathInputError('Install latex2sympy2_extended in the workflow Python environment.') from error
    except Exception as error:
        raise MathInputError('Cannot interpret this LaTeX expression: '+str(error)) from error
    constants={sp.Symbol('pi'):sp.pi,sp.Symbol('EulerConstant'):sp.E,sp.Symbol('ImaginaryConstant'):sp.I}
    expression=expression.subs(constants, simultaneous=True)
    # Expand only explicitly defined mathematical functions, never arbitrary Python functions.
    for call in list(expression.atoms(AppliedUndef)):
        name=call.func.__name__
        function=scope.get(name)
        if isinstance(function,sp.Lambda): expression=expression.subs(call,function(*call.args))
    labels = {item.base.label for item in expression.atoms(sp.Indexed)}
    substitutions={symbol:value for symbol in expression.free_symbols
                   if isinstance(symbol, sp.Symbol) and symbol not in labels
                   and (value:=binding(symbol.name,scope,protected)) is not None}
    if substitutions: expression=expression.subs(substitutions, simultaneous=True)
    return expression


def evaluate_latex(source, scope=None, protected=()):
    """Evaluate LaTeX; optional English operation prefixes do not change the math syntax."""
    mode='evaluate'; variable=None; digits=8
    match=re.match(r'^\s*(evaluate|simplify|expand|factor|hold|solve|numeric)(?:\s+([^:]+))?\s*:\s*(.*)$',source,re.S)
    if match:
        mode,option,source=match.groups()
        if mode=='numeric' and option:
            try: digits=int(option)
            except ValueError: raise MathInputError('Numeric precision must be an integer.')
            if not 2<=digits<=100: raise MathInputError('Choose 2 to 100 significant digits.')
        elif mode=='solve':
            if not option or not re.fullmatch(r'[A-Za-z]|\\[A-Za-z]+',option.strip()):
                raise MathInputError('Specify one solve variable, e.g. solve x: x^2=1.')
            variable=sp.Symbol(option.strip().lstrip('\\'))
        elif option: raise MathInputError('This operation takes no option before the colon.')
    expression=parse_math(source,scope,protected)
    if mode=='hold': return expression
    expression=expression.doit()
    if mode=='solve': return sp.solve(expression,variable)
    if mode=='numeric': return sp.N(expression,digits)
    if mode=='expand': return sp.expand(expression)
    if mode=='factor': return sp.factor(expression)
    return sp.simplify(expression)


def define_function(arguments, source, scope=None):
    names=[value.strip().lstrip('\\') for value in arguments.split(',')]
    variables=[sp.Symbol(name) for name in names]
    expression=evaluate_latex(source,scope,protected=names)
    return sp.Lambda(tuple(variables),expression)


def inline_value(source, scope):
    """Keep named stored results as written; evaluate mathematical input otherwise."""
    if source.strip() in scope:
        return scope[source.strip()]
    return evaluate_latex(source, scope)
