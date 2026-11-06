"""Generate a vector PDF plot for inclusion in notes."""
from pathlib import Path
import math
import argparse
import os
from tex_environment import ROOT
os.environ.setdefault("MPLCONFIGDIR", str(ROOT / "cache/matplotlib"))
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--project', type=Path, default=Path.cwd())
args = parser.parse_args()
root = args.project.expanduser().resolve()
(root / 'figures').mkdir(exist_ok=True)
x = [-3 + 6*i/300 for i in range(301)]
y = [math.exp(-value**2/2)/math.sqrt(2*math.pi) for value in x]
fig, ax = plt.subplots(figsize=(6, 3.5), layout='constrained')
ax.plot(x, y, label=r'$\mathcal{N}(0,1)$')
ax.set(xlabel=r'$x$', ylabel='Density')
ax.legend()
ax.grid(alpha=.2)
destination = root / 'figures/normal.pdf'
fig.savefig(destination)
plt.close(fig)
print(destination)
