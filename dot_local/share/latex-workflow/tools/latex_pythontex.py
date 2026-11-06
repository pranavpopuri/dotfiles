"""Translate mathematical LaTeX at the SymPy/PythonTeX input boundary."""
import ast
import json
import re
import textwrap


def mathematical(source):
    try:
        parsed = ast.parse(source, mode='eval')
        if isinstance(parsed.body, ast.Call): return False
    except SyntaxError:
        pass
    if '\\' in source or '^' in source or re.match(r'(evaluate|simplify|expand|factor|hold|solve|numeric)\b.*:', source):
        return True
    try:
        node = ast.parse(source, mode='eval')
    except SyntaxError:
        return True
    allowed = (ast.Expression, ast.BinOp, ast.UnaryOp, ast.Name, ast.Load,
               ast.Constant, ast.Add, ast.Sub, ast.Mult, ast.Div, ast.Pow,
               ast.USub, ast.UAdd)
    return all(isinstance(part, allowed) and not (isinstance(part, ast.Constant) and not isinstance(part.value, (int,float))) for part in ast.walk(node)) and source not in {'True','False','None'}


def invocation(expression):
    return "__import__('latex_math').evaluate_latex("+json.dumps(expression)+", locals())"


def transform_chunk(code, kind):
    if kind == 'i':
        expression=code.strip()
        # Named outputs retain their exact saved form, including held integrals.
        if re.fullmatch(r'[A-Za-z_]\w*', expression):
            return "__import__('latex_math').inline_value("+json.dumps(expression)+", locals())\n"
        return invocation(expression)+'\n' if mathematical(expression) else code
    if kind != 'code': return code
    lines=[]
    for line in textwrap.dedent(code).splitlines(keepends=True):
        match=re.match(r'^(\s*)([A-Za-z_]\w*)(?:\(([A-Za-z ,]+)\))?\s*=\s*(.+?)\s*$', line)
        if match and mathematical(match[4]):
            indent,name,args,expression=match.groups()
            value=("__import__('latex_math').define_function("+json.dumps(args)+", "+json.dumps(expression)+", locals())") if args else invocation(expression)
            line=indent+name+' = '+value+'\n'
        lines.append(line)
    return ''.join(lines)


def transform(source):
    chunks=re.split(r'(?m)^(=>PYTHONTEX#[^\n]*\n)',source)
    for index in range(1,len(chunks),2):
        fields=chunks[index].strip().split('#')
        if len(fields)>5 and fields[1]=='sympy':
            code, marker, settings=chunks[index+1].partition('=>PYTHONTEX:SETTINGS#')
            chunks[index+1]=transform_chunk(code,fields[5])+marker+settings
    return ''.join(chunks)
