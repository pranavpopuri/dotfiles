"""Evaluate a SymPy expression from stdin and print its LaTeX representation."""
import ast
import sys


def calculate(source):
    import sympy as sp

    names = {name: getattr(sp, name) for name in (
        "sin cos tan asin acos atan sinh cosh tanh exp log sqrt Abs factorial "
        "simplify expand factor cancel together apart trigsimp integrate diff "
        "limit series summation product solve solveset Eq Rational Integer Float "
        "Symbol symbols Function Matrix Integral Derivative Sum Product N "
        "pi E I oo S".split()
    )}
    methods = {"subs", "doit", "evalf", "det", "inv", "transpose"}
    binary = {ast.Add: lambda a, b: a+b, ast.Sub: lambda a, b: a-b,
              ast.Mult: lambda a, b: a*b, ast.Div: lambda a, b: a/b,
              ast.Pow: lambda a, b: a**b}

    def visit(node):
        if isinstance(node, ast.Constant) and isinstance(node.value, (int, float, str)):
            return sp.sympify(node.value) if not isinstance(node.value, str) else node.value
        if isinstance(node, ast.Name) and not node.id.startswith("_"):
            return names.get(node.id, sp.Symbol(node.id))
        if isinstance(node, (ast.Tuple, ast.List)):
            return [visit(item) for item in node.elts]
        if isinstance(node, ast.BinOp) and type(node.op) in binary:
            return binary[type(node.op)](visit(node.left), visit(node.right))
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, (ast.UAdd, ast.USub)):
            value = visit(node.operand)
            return -value if isinstance(node.op, ast.USub) else value
        if isinstance(node, ast.Call):
            if isinstance(node.func, ast.Name) and node.func.id in names:
                function = names[node.func.id]
            elif isinstance(node.func, ast.Attribute) and node.func.attr in methods:
                function = getattr(visit(node.func.value), node.func.attr)
            else:
                raise ValueError("Unsupported function or method")
            if any(item.arg is None for item in node.keywords):
                raise ValueError("Keyword unpacking is not supported")
            return function(*[visit(item) for item in node.args],
                            **{item.arg: visit(item.value) for item in node.keywords})
        raise ValueError("Use SymPy syntax, including ** for powers; raw LaTeX is not supported")

    return sp.latex(visit(ast.parse(source.strip(), mode="eval").body))


if __name__ == "__main__":
    try:
        print(calculate(sys.stdin.read()))
    except Exception as error:
        print(f"CAS: {error}", file=sys.stderr)
        sys.exit(1)
