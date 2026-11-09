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

The renderer starts its worker when the extension activates. Updates use a 25 ms
debounce, reuse cached results and pending requests, and display each equation
as soon as it is ready. Unsupported expressions are cached until their input
or rendering settings change. The worker has a three-second failure timeout;
other cached equations can appear while a slow request is pending. It uses the MathJax
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

Preview size is controlled by `mathSourcePreview.scale` (default `1.2`).
Change it in Settings to resize equations without changing the source text.

Equation glyphs use the editor font size times the preview scale, independent
of source line count. Editor font changes recompute the preview geometry; window
zoom scales text and decorations together. Tall formulas shrink to fit their
existing source rows.

Scrolling retains existing decorations and pre-renders equations within twenty
source lines of the viewport. Unchanged previews are not cleared or resent to
the editor. Moving the caret into an equation still reveals its source.

Active equations keep their editable source and show a small rendering at the end of the closing delimiter line. Hover for a larger preview. Set mathSourcePreview.activePreview to false to disable this companion preview.
