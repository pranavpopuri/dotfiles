"""Merge only LaTeX workflow additions into the normal macOS VSCodium settings."""
from pathlib import Path
from datetime import datetime
import json
import os
import re
from tex_environment import ROOT

USER = Path(os.environ.get('LATEX_WORKFLOW_EDITOR_USER', str(Path.home() / 'Library/Application Support/VSCodium/User')))


def clean_jsonc(text, trailing=True):
    result = list(text)
    i = 0
    while i < len(text):
        if text[i] == '"':
            i += 1
            while i < len(text):
                if text[i] == '\\':
                    i += 2
                elif text[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
        elif text.startswith('//', i) or text.startswith('/*', i):
            end = text.find('\n', i) if text.startswith('//', i) else text.find('*/', i + 2)
            end = len(text) if end < 0 else end if text.startswith('//', i) else end + 2
            for j in range(i, end):
                if text[j] != '\n':
                    result[j] = ' '
            i = end
        else:
            i += 1
    if trailing:
        i = 0
        while i < len(result):
            if result[i] == '"':
                i += 1
                while i < len(result):
                    if result[i] == '\\':
                        i += 2
                    elif result[i] == '"':
                        i += 1
                        break
                    else:
                        i += 1
            else:
                if result[i] == ',':
                    j = i + 1
                    while j < len(result) and result[j].isspace():
                        j += 1
                    if j < len(result) and result[j] in '}]':
                        result[i] = ' '
                i += 1
    return ''.join(result)


def loads(text):
    return json.loads(clean_jsonc(text))


def patch_object(text, changes):
    """Replace known values/add keys, keeping unrelated JSONC text and comments."""
    clean = clean_jsonc(text)
    current = json.loads(clean)
    decoder = json.JSONDecoder()
    spans = {}
    i = clean.index('{') + 1
    while True:
        while clean[i].isspace() or clean[i] == ',':
            i += 1
        if clean[i] == '}':
            closing = i
            break
        key, i = decoder.raw_decode(clean, i)
        while clean[i].isspace():
            i += 1
        assert clean[i] == ':'
        i += 1
        while clean[i].isspace():
            i += 1
        start = i
        _, i = decoder.raw_decode(clean, i)
        spans[key] = (start, i)
    indent_match = re.search(r'\n([ \t]+)"', clean)
    indent = indent_match[1] if indent_match else '    '
    edits = []
    additions = {}
    for key, value in changes.items():
        if key in spans:
            if current[key] != value:
                start, end = spans[key]
                rendered = json.dumps(value, indent=2, ensure_ascii=False).replace('\n', '\n' + indent)
                edits.append((start, end, rendered))
        else:
            additions[key] = value
    if additions:
        if spans:
            last_end = list(spans.values())[-1][1]
            if ',' not in clean_jsonc(text, trailing=False)[last_end:closing]:
                edits.append((last_end, last_end, ','))
        entries = [indent + json.dumps(key) + ': ' + json.dumps(value, indent=2, ensure_ascii=False).replace('\n', '\n' + indent) for key, value in additions.items()]
        edits.append((closing, closing, '\n' + ',\n'.join(entries) + '\n'))
    for _, (start, end, replacement) in sorted(enumerate(edits), key=lambda item:(item[1][0], item[0]), reverse=True):
        text = text[:start] + replacement + text[end:]
    assert loads(text) == {**current, **changes}
    return text


def merge_named(old, additions, key, first=False):
    names = {item[key] for item in additions}
    other = [item for item in old if item.get(key) not in names]
    return additions + other if first else other + additions


def merge_settings(text, defaults):
    current = loads(text)
    changes = dict(defaults)
    for key in ['latex-workshop.latex.tools', 'latex-workshop.latex.recipes']:
        changes[key] = merge_named(current.get(key, []), defaults[key], 'name', first=True)
    changes['cSpell.import'] = list(dict.fromkeys(current.get('cSpell.import', []) + defaults.get('cSpell.import', [])))
    if '[latex]' in defaults:
        changes['[latex]'] = {**defaults['[latex]'], **current.get('[latex]', {})}
    # Preserve intentional user choices for existing feature scalars/macros.
    for key in changes.keys() & current.keys():
        if key not in ['latex-workshop.latex.tools', 'latex-workshop.latex.recipes', 'cSpell.import', '[latex]', 'hsnips.hsnipsPath']:
            changes[key] = current[key]
    return patch_object(text, changes)


def install():
    USER.mkdir(parents=True, exist_ok=True)
    backup = ROOT / 'cache' / ('normal-editor-before-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    feature_settings = json.loads((ROOT / 'config/settings.json').read_text())
    outputs = {}
    settings = USER / 'settings.json'
    outputs[settings] = merge_settings(settings.read_text() if settings.exists() else '{}\n', feature_settings)
    keybindings = USER / 'keybindings.json'
    binding_text = keybindings.read_text() if keybindings.exists() else None
    bindings = loads(binding_text) if binding_text is not None else []
    original_bindings = list(bindings)
    ours = json.loads((ROOT / 'config/keybindings.json').read_text())
    identities = {(item['key'], item['when']) for item in ours}
    bindings = [item for item in bindings if (item.get('key'), item.get('when')) not in identities] + ours
    outputs[keybindings] = binding_text if binding_text is not None and bindings == original_bindings else json.dumps(bindings, indent=2) + '\n'
    tasks = USER / 'tasks.json'
    task_text = tasks.read_text() if tasks.exists() else '{"version":"2.0.0"}\n'
    old_tasks = loads(task_text)
    ours = json.loads((ROOT / 'config/tasks.json').read_text())
    outputs[tasks] = patch_object(task_text, {
        'tasks': merge_named(old_tasks.get('tasks', []), ours['tasks'], 'label'),
        'inputs': merge_named(old_tasks.get('inputs', []), ours['inputs'], 'id')})
    for destination, content in outputs.items():
        if destination.exists() and destination.read_text() == content:
            continue
        backup.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            (backup / destination.name).write_bytes(destination.read_bytes())
        destination.write_text(content)
    print('LaTeX features merged into normal VSCodium: ' + str(USER))


if __name__ == '__main__':
    install()
