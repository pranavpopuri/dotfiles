Math Source Preview is a local extension for this project's native LaTeX editor.

Inactive equations are displayed as SVG images. Move the caret into an equation
to reveal the original source. All selections touching an equation reveal it;
copying, saving, undo, HyperSnips, and Vim continue to use the original text.
CAS expressions remain visible until they have been evaluated.

Use **Math Source Preview: Toggle In-Source Rendering** to switch it off.
It supports dollar and bracket delimiters and equation, align, alignat, gather,
multline, displaymath, and math environments. Comments and common code/verbatim
environments are skipped. This is a limited math-fragment parser, not a complete
TeX parser. Unsupported formulas remain as source.

The renderer runs in a worker with a three-second timeout. It uses the MathJax
library already shipped with LaTeX Workshop; a future Workshop version changing
that dependency may require updating this local extension. No network services
or document-code execution are used for rendering. Macros are configured in
`mathSourcePreview.macros`; document preambles are not automatically executed.

VS Code decorations cannot reflow document lines. Rendered math is scaled to fit
its existing source rows, so put large equations in multiline display blocks.
Source row spacing remains. Use Workshop's hover or math preview panel for larger
previews and final PDF output for authoritative typesetting.

Package with `python3 tools/package_visual_extension.py` from the project root.
Install the generated `cache/math-source-preview.vsix` using the editor CLI or
**Extensions: Install from VSIX**. The graphical editing behavior must be checked
in the running editor after installation; automated checks cover parsing,
MathJax rendering, selection reveal, and packaging.
