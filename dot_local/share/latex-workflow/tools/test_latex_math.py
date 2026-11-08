"""Regression tests for the shared LaTeX input boundary."""
import unittest
import sympy as sp
from latex_math import evaluate_latex as ev, MathInputError, normalize, define_function, inline_value
from latex_pythontex import transform, transform_chunk
from cas import calculate

class Translation(unittest.TestCase):
    def test_assignment(self):
        value=transform_chunk('  answer2 = \\int_0^1 x^2\\,dx\n','code')
        self.assertIn('evaluate_latex',value)
        self.assertFalse(value.startswith(' '))
        compile(value,'translated','exec')
        self.assertEqual(transform_chunk(value,'code'),value)

    def test_pasted_display(self):
        source = '  answer = \\[\n    \\left(\\frac{6}{\\sum_{i=1}^{n} x_i^6}\\right)^{\\frac{1}{5}}\n  \\]\n  result = simplify(answer)\n'
        code = transform_chunk(source, 'code')
        self.assertEqual(code.count('\n'), source.count('\n'))
        compile(code, '<pasted display>', 'exec')
        self.assertIn('result = simplify(answer)', code)
        self.assertEqual(transform_chunk(code, 'code'), code)

    def test_legacy(self):
        code="x, y = symbols('x y')\nI = Integral(x*y, (y,0,1-x), (x,0,1))\nresult = I.doit()\n"
        self.assertEqual(transform_chunk(code,'code'),code)
    def test_records(self):
        source='=>PYTHONTEX#sympy#default#default#0#code#####1#\n a = x^2\n=>PYTHONTEX#sympy#default#default#1#i#####3#\n\\frac{1}{3}\n=>PYTHONTEX:SETTINGS#\nfoo=bar\n'
        output=transform(source)
        self.assertEqual(output,transform(output))
        self.assertIn('foo=bar',output)
        self.assertEqual(output.count('evaluate_latex'),2)
    def test_normalization(self):
        self.assertEqual(normalize(r'\[\frac{1}{2}\,\dd x\]'),r'\frac{1}{2} d x')
    def test_native_cas(self):
        self.assertEqual(calculate('integrate(x*y, (y,0,1-x), (x,0,1))'),r'\frac{1}{24}')

class Evaluation(unittest.TestCase):

    def test_original_sample(self):
        source = r'\left( \frac{6}{\sum_{i=1}^{n} x_i^6} \right) ^ {\frac{1}{5}}'
        value = ev(source)
        x = sp.IndexedBase('x')
        i, n = sp.symbols('i n')
        expected = (6/sp.Sum(x[i]**6,(i,1,n)))**sp.Rational(1,5)
        self.assertEqual(sp.simplify(value-expected),0)
        self.assertTrue(value.has(sp.Sum))
        self.assertTrue(value.has(x[i]))

    def test_indexed_sum(self):
        value=ev(r'\sum_{i=1}^{3} x_i^6')
        x=sp.IndexedBase('x')
        self.assertEqual(value,x[1]**6+x[2]**6+x[3]**6)
        self.assertEqual(value.subs({x[1]:1,x[2]:2,x[3]:3}),794)

    def test_bar(self):
        value=ev(r'\bar{x}^6')
        self.assertTrue(value.is_Pow)
        self.assertEqual(value.exp,6)
        self.assertEqual(sp.diff(value,sp.Symbol('x')),0)

    def test_calculator_operations(self):
        self.assertEqual(ev(r'simplify: \sin^2(x)+\cos^2(x)'),1)
        self.assertEqual(ev(r'expand: (x+1)^3'),sp.expand((sp.Symbol('x')+1)**3))
        self.assertEqual(sp.simplify(ev(r'\frac{d}{dx}(x^3+x^2+1)')-(3*sp.Symbol('x')**2+2*sp.Symbol('x'))),0)
        self.assertEqual(ev(r'\sum_{i=1}^{10} i'),55)
        self.assertEqual(ev(r'\int_0^1 x^2\,dx'),sp.Rational(1,3))

    def test_multiline_execution(self):
        source='answer = \\[\n  \\left(\\frac{6}{\\sum_{i=1}^{n} x_i^6}\\right)^{\\frac{1}{5}}\n\\]\nresult = simplify(answer)\n'
        scope={'simplify':sp.simplify}
        exec(transform_chunk(source,'code'),scope)
        self.assertTrue(scope['result'].has(sp.Sum))

    def test_fraction(self): self.assertEqual(ev(r'\frac{1}{3}'),sp.Rational(1,3))
    def test_integral(self): self.assertEqual(ev(r'\int_0^1 x^2\,dx'),sp.Rational(1,3))
    def test_double_integral(self): self.assertEqual(ev(r'\int_0^1\int_0^{1-x}xy\,dy\,dx'),sp.Rational(1,24))
    def test_derivative(self): self.assertEqual(ev(r'\frac{d}{dx} x^3'),3*sp.Symbol('x')**2)
    def test_identity(self): self.assertEqual(ev(r'\sin^2(x)+\cos^2(x)'),1)
    def test_constants(self): self.assertEqual(ev(r'\pi'),sp.pi)
    def test_factor(self): self.assertEqual(ev('factor: x^2-1'),(sp.Symbol('x')-1)*(sp.Symbol('x')+1))
    def test_solve(self): self.assertEqual(ev('solve x: x^2=1'),[-1,1])
    def test_context(self): self.assertEqual(ev(r'\int_0^a x\,dx',{'a':2,'x':5}),2)
    def test_function(self):
        f=define_function('x','x^2',{'x':3})
        self.assertEqual(ev('f(2)',{'f':f}),4)
    def test_matrix(self): self.assertEqual(ev(r'\det{\begin{pmatrix}1&2\\3&4\end{pmatrix}}'),-2)
    def test_inline(self):
        integral=sp.Integral(sp.Symbol('x'),(sp.Symbol('x'),0,1))
        self.assertEqual(inline_value('result',{'result':integral}),integral)
    def test_cas(self): self.assertEqual(calculate(r'\int_0^1 x^2\,dx'),r'\frac{1}{3}')
    def test_errors(self):
        for source in [r'\unknown{x}',r'\frac{1}{']:
            with self.subTest(source=source),self.assertRaises(MathInputError): ev(source)
    def test_execute_block(self):
        scope={}
        exec(transform_chunk('  answer2 = \\int_0^1 x^2\\,dx\n','code'),scope)
        self.assertEqual(scope['answer2'],sp.Rational(1,3))

if __name__=='__main__': unittest.main()
