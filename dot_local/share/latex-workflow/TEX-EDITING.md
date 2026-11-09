# TeX-aware editing with Helix

Your normal VS Code uses **Helix for VS Code** (`jasew.vscode-helix-emulation`),
not VSCodeVim. Its appearance and general preferences are retained. TeX-aware commands come
from LaTeX Workshop, while Helix handles movement and selection-first editing.

This is a useful subset of VimTeX-style functionality, not a VimTeX port. None
of the literal Vim sequences `dse`, `cse`, `ds$`, etc. is installed as a Helix
mapping. The differences are listed below.

## Keys

`Ctrl+L e` means hold Control and press L, release, then press E. On macOS this
is **Control**, not Command. These custom chords apply only in `.tex` files
(language ID `latex`) in Helix Normal/visual modes. They do not intercept Insert
mode. The native Helix Space menu is preserved. User keybindings are managed at
`config/keybindings.json` and merged into the normal editor's User keybindings.

| Chord | Action |
| --- | --- |
| Ctrl+L b | Build using the default recipe |
| Ctrl+L v | Open PDF |
| Ctrl+L s | Source-to-PDF SyncTeX |
| Ctrl+L m | Toggle in-source equation rendering |
| Ctrl+L p | Toggle larger math preview panel |
| Ctrl+L f | Create/edit named Inkscape figure |
| Ctrl+L x | Export named Inkscape figure |
| Ctrl+L e | Select current environment **contents** |
| Ctrl+L a | Select current environment **including** begin/end |
| Ctrl+L r | Select both environment names with multicursors |
| Ctrl+L n | Select the current environment name |
| Ctrl+L g | Navigate to the matching begin/end; put the cursor on begin/end first |
| Ctrl+L w | Wrap the selection in an environment |
| Ctrl+L c | Wrap the selection in a LaTeX command |
| Ctrl+L t | Workshop's display-delimiter/named-equation environment toggle |
| Ctrl+L z | Close the current environment |
| Ctrl+L h | Select the current section |
| Ctrl+L o | Go to Symbol: navigate the document's outline |
| Alt+O / Alt+I | Expand/shrink syntax-aware selection (existing Helix bindings) |

`Alt` is the Option key on macOS. Workshop's LaTeX syntax-tree selection provider
is explicitly enabled, so Helix's existing expand/shrink selection keys can use
TeX structure. Snippets still expand in Insert mode and Tab navigates snippet
placeholders. These are editor commands, not LaTeX commands stored in the file.

Use Cmd+Shift+P to run the equivalent command if another binding interferes.
Workshop's names include **Select the current environment content**,
**Select the current environment**, **Add a multicursor to the current environment
name**, **Surround selection with LaTeX command**, and **Navigate to matching
begin/end**. A command that creates editable selections/placeholders still
requires the appropriate Helix insert/change operation before typing replacement
text; check that both environment names are selected when renaming.

## Examples

Inside this environment, Ctrl+L e selects its contents; Ctrl+L a includes its
begin/end tags:

```latex
\begin{equation*}
  x+y=z
\end{equation*}
```

Ctrl+L r selects both `equation*` names. Replace both with `align*` to change
the environment without changing the body. Unlike VimTeX's `cse`, the native
paired-name edit does not supply a promised star-preservation policy: enter the
complete intended name, including `*` if desired.

Select text using your normal Helix selection habits, then Ctrl+L w to wrap it
in an environment or Ctrl+L c to surround it with a command. Use the editor's
suggestions/placeholders for the chosen environment/command.

For nested selections, put the cursor in the argument below and try Alt+O
repeatedly, then Alt+I to shrink:

```latex
\frac{\sqrt{x^2+y^2}}{1+x}
```

The exact selection progression is controlled by Workshop's parser and cursor
position; these are not VimTeX's named `ic`/`id`/`i$` text objects.

## Comparison with the pasted VimTeX examples

| VimTeX operation | This setup |
| --- | --- |
| `ie` / `ae`: select environment content / whole environment | Ctrl+L e / Ctrl+L a provide the corresponding selections |
| `iP` / `aP`: section text objects | Ctrl+L h selects a section; no Vim operator-pending text objects |
| `cse`: change an environment | Ctrl+L r provides paired-name editing; manually supply the complete new name |
| `%`: matching TeX content | Ctrl+L g provides Workshop's matching begin/end navigation at the tags; not a general VimTeX `%` clone |
| Wrap selected text in environment/command | Ctrl+L w / Ctrl+L c |
| Close an environment | Ctrl+L z |
| `cs$` / `ts$`: switch math wrappers | Ctrl+L t is only Workshop's display `\[...\]` / named environment operation; not the full inline-dollar cycle |
| Section motions such as `[[` / `]]` | Use Ctrl+L o for the outline or Ctrl+L h for selection; exact counted motions are not implemented |
| `dse`, `dsc`, `dsd`, `ds$`: remove wrappers while keeping content | No dedicated one-command equivalent installed |
| `csc`, `csd`: command/delimiter replacement | No dedicated context-aware replacement command installed |
| `tsc`, `tss`, `tse`: star and related-environment toggles | Can edit paired names, but no automatic cycle installed |
| `tsd` / `tsD`: delimiter-sizing cycles | Not implemented |
| `tsf`: fraction versus slash toggle | Not implemented; fraction snippets create fractions but do not toggle existing expressions |
| Counted next/previous environment, math-zone, or frame motions | Not implemented |
| VimTeX's full command/delimiter/item/math text objects | Not implemented; syntax-aware expansion and environment/section selections cover some uses |

Changing keymap extensions alone does not add these missing structural edits.
They would need additional carefully parsed commands, especially for nested
braces, comments, verbatim code, optional arguments, delimiter modifiers, and
multiple cursors. The existing snippets, calculations, preview, build, plotting,
and figure tools continue to work alongside the native TeX-aware commands.

## Maintenance and compatibility

- Helix 0.6.2 is the version already installed in your ordinary editor and is
  listed in the toolkit's `extensions.txt`.
- `tools/install_editor.sh` installs Helix first, then removes VSCodeVim **only
  from the normal extension installation**. It merges the TeX keybindings.
- `latex-workflow setup` calls the same installer on this Mac and future Macs.
- Run **Developer: Reload Window** in your normal VS Code window after setup.
  `latex-workflow open` now reuses it; no isolated window is required.
- This VS Code extension emulates Helix; it is not the standalone Helix editor
  and its selection behavior may differ. Check real editing behavior in the GUI.
- Linux configuration is unchanged. Normal VS Code receives the LaTeX
  extensions and recipes, with your existing visual preferences preserved.

References: [Helix for VS Code](https://github.com/jasonwilliams/vscode-helix),
[Workshop environment commands](https://github.com/James-Yu/LaTeX-Workshop/wiki/Environments),
[VimTeX features](https://github.com/lervag/vimtex#features).
