"""Generate the complete user-facing reference from the real HyperSnips file."""
import argparse
import hashlib
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
HEADER = re.compile(r'^snippet\s+(?:`([^`]+)`|(\S+))(?:\s+"([^"]+)")?(?:\s+([AMiwb]*))?\s*$')


def read_snippets(text):
    context = None
    snippets = []
    lines = iter(text.splitlines())
    for line in lines:
        if line.startswith('context '):
            context = line[len('context '):]
            continue
        match = HEADER.match(line)
        if not match:
            continue
        body = []
        for body_line in lines:
            if body_line.startswith('endsnippet'):
                break
            body.append(body_line.rstrip())
        snippets.append({'trigger': match[1] or match[2], 'regex': match[1] is not None,
                         'description': match[3] or '', 'flags': match[4] or '',
                         'context': context, 'body': '\n'.join(body)})
        context = None
    return snippets


def code(value):
    return '`' + value.replace('`', '\u02cb').replace('|', '\\|') + '`'


def reference(text):
    snippets = read_snippets(text)
    out = [
        '# Complete HyperSnips reference', '',
        'Practical instructions: [GUIDE.md](GUIDE.md). Daily summary: [CHEATSHEET.md](CHEATSHEET.md).', '',
        f'This catalog contains **all {len(snippets)} snippets** from `hsnips/latex.hsnips`.',
        'It is generated from the configured file, not a generic list of suggested shortcuts.', '',
        '## How to read this reference', '',
        '- **Automatic** means it expands on the final trigger character, without Tab.',
        '- **Manual** means request/accept its matching completion (Ctrl+Space / Trigger Suggest).',
        '  Tab alone is context-dependent; Tab/Shift+Tab navigate placeholders after expansion.',
        '- **Math** means the snippet requires a recognized math scope. **Any** means it has no',
        '  math-only context restriction; do not nest a snippet that creates its own math environment.',
        '- **Start of line** permits only whitespace before a literal trigger; **word boundary**',
        '  requires a suitable word boundary. **In-word** permits a suffix, such as `xsr`.',
        '- Regex triggers match the current line suffix. Their displayed expression is a matching',
        '  rule, not the text you should type. Concrete examples appear below.',
        '- Templates show the configured body (trailing whitespace omitted). `$1`, `$2`, etc. are editable tab stops,',
        '  `${1:default}` supplies default text, and `$0` is the final cursor position.',
        '- Double-backtick blocks are JavaScript used by HyperSnips, not LaTeX to type yourself.',
        '  Some backslashes are escaped for the native snippet engine. This is a source reference,',
        '  not a claim that every inherited template produces perfect output without adjustment.', '',
        '## Regex and postfix examples', '',
        '| Example input in math | What the rule does |',
        '| --- | --- |',
        '| `x/`, `3x/` | Put a symbol/coefficient in a fraction numerator |',
        '| `(x+1)/` | Put the parenthesized expression in a fraction numerator |',
        '| `x2`, then a second digit | Insert a subscript; group a two-digit subscript |',
        '| `sin`, `cos`, `pi`, `int` | Add a command backslash automatically |',
        '| `xhat`, `xbar` | Accent one preceding letter |',
        '| `hat`, `bar` | Insert an accent wrapper with a placeholder |',
        '| `sts` | Insert a text subscript (with a special preceding-character rule) |',
        '| `cas diff(x**2,x) cas` | Evaluate on the closing marker; this rule has no math-only context |', '',
        'The single-letter postfix rules do not capture an entire arbitrary expression.',
        'Math auto-expansions pause while `cas ` appears in the current line prefix.', '',
        '## Complete index', '',
        '| # | Trigger or regex | Description | Mode | Scope |',
        '| --- | --- | --- | --- | --- |',
    ]
    for number, snippet in enumerate(snippets, 1):
        mode = 'Automatic' if 'A' in snippet['flags'] else 'Manual'
        scope = 'Math' if snippet['context'] else 'Any'
        trigger = ('Regex: ' if snippet['regex'] else '') + code(snippet['trigger'])
        out.append(f'| [{number:03d}](#snippet-{number:03d}) | {trigger} | {snippet["description"].replace("|", " / ")} | {mode} | {scope} |')
    out += ['', '## Configured templates', '']
    for number, snippet in enumerate(snippets, 1):
        flags = snippet['flags']
        boundary = 'Regex suffix match' if snippet['regex'] else 'Start of line' if 'b' in flags else 'In-word' if 'i' in flags else 'Word boundary' if 'w' in flags else 'Whitespace/start before trigger'
        mode = 'Automatic' if 'A' in flags else 'Manual completion'
        scope = 'Math only' if snippet['context'] else 'No math-only restriction'
        out += [f'<a id="snippet-{number:03d}"></a>', '',
                f'### {number:03d}. {snippet["description"]}', '',
                f'Trigger: {code(snippet["trigger"])}' + (' (regular expression)' if snippet['regex'] else ''), '',
                f'**{mode} · {scope} · {boundary}**', '',
                '<details>', '<summary>Show configured snippet template</summary>', '',
                '```text', snippet['body'], '```', '', '</details>', '']
    out += ['## Updating this catalog', '',
            'After changing the snippet file, run `tools/generate_snippet_guide.py` with the',
            'toolkit Python (or any Python 3). Defaults are relative to that script\'s toolkit:', '',
            '```sh', 'python3 tools/generate_snippet_guide.py', '```', '',
            'You can also pass `--snippets PATH --output PATH` to generate from chezmoi source.',
            'The generated catalog does not reload the editor; run **HyperSnips: Reload Snippets**.', '',
            'Source SHA-256: `' + hashlib.sha256(text.encode()).hexdigest() + '`.', '']
    return '\n'.join(out)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snippets', type=Path, default=ROOT / 'hsnips/latex.hsnips')
    parser.add_argument('--output', type=Path, default=ROOT / 'SNIPPETS.md')
    args = parser.parse_args()
    args.output.write_text(reference(args.snippets.read_text()))
    print(args.output)
