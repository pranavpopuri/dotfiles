'use strict';
const vscode = require('vscode');
const path = require('path');
const {Worker} = require('worker_threads');
const {fragments} = require('./fragments');
const {layout} = require('./layout');
function activate(context) {
    let worker, requestId = 0, revision = 0, timer;
    const pending = new Map(), cache = new Map(), inFlight = new Map();
    const editorStates = new WeakMap();
    const output = vscode.window.createOutputChannel('Math Source Preview');
    const hidden = vscode.window.createTextEditorDecorationType({
        textDecoration:'none; font-size: 0px;',
        rangeBehavior:vscode.DecorationRangeBehavior.ClosedClosed
    });
    const images = vscode.window.createTextEditorDecorationType({rangeBehavior:vscode.DecorationRangeBehavior.ClosedClosed});
    function stop() {
        if (worker) void worker.terminate();
        worker = undefined;
        for (const task of pending.values()) {clearTimeout(task.timeout); task.reject(new Error('Renderer restarted'));}
        pending.clear();
    }
    function start() {
        if (worker) return;
        const workshop = vscode.extensions.getExtension('james-yu.latex-workshop');
        if (!workshop) throw new Error('LaTeX Workshop is required');
        worker = new Worker(path.join(context.extensionPath,'worker.js'), {
            workerData:{library:path.join(workshop.extensionPath,'node_modules','mathjax-full')}
        });
        worker.on('message', message => {
            const task = pending.get(message.id);
            if (!task) return;
            pending.delete(message.id); clearTimeout(task.timeout);
            message.error ? task.reject(new Error(message.error)) : task.resolve(message);
        });
        worker.on('error', error => {output.appendLine(error.message); stop();});
    }
    function render(math, display, macros, color) {
        // VS Code configuration values may be proxies, which workers cannot clone.
        macros = JSON.parse(JSON.stringify(macros));
        const key = JSON.stringify([math,display,macros,color]);
        if (cache.has(key)) {
            const result = cache.get(key);
            return result.error ? Promise.reject(new Error(result.error)) : Promise.resolve(result);
        }
        if (inFlight.has(key)) return inFlight.get(key);
        start();
        const promise = new Promise((resolve,reject) => {
            const id = ++requestId;
            const timeout = setTimeout(() => stop(), 3000);
            pending.set(id, {timeout,reject:error => {
                if (error.message !== 'Renderer restarted') {
                    if (cache.size >= 200) cache.delete(cache.keys().next().value);
                    cache.set(key, {error:error.message});
                }
                reject(error);
            },resolve:result => {
                if (cache.size >= 200) cache.delete(cache.keys().next().value);
                cache.set(key,result); resolve(result);
            }});
            try {
                worker.postMessage({id,math,display,macros,color});
            } catch (error) {
                clearTimeout(timeout); pending.delete(id); reject(error);
            }
        }).finally(() => inFlight.delete(key));
        inFlight.set(key, promise);
        return promise;
    }
    async function update() {
        const token = ++revision;
        for (const editor of vscode.window.visibleTextEditors) {
            const document = editor.document;
            const config = vscode.workspace.getConfiguration('mathSourcePreview',document.uri);
            if (!['latex','tex'].includes(document.languageId) || !config.get('enabled',true)) {
                editor.setDecorations(hidden, []); editor.setDecorations(images, []);
                editorStates.delete(editor);
                continue;
            }
            const settings = vscode.workspace.getConfiguration('editor',document.uri);
            const font = settings.get('fontSize',14);
            const settingHeight = settings.get('lineHeight',0);
            const lineHeight = settingHeight === 0 ? font*1.5 : settingHeight < 8 ? font*settingHeight : settingHeight;
            const dark = ![vscode.ColorThemeKind.Light,vscode.ColorThemeKind.HighContrastLight].includes(vscode.window.activeColorTheme.kind);
            const color = dark ? '#e0e0e0' : '#202020';
            const text = document.getText();
            const macros = JSON.parse(JSON.stringify(config.get('macros',{})));
            const scale = Math.max(.25, Math.min(2, config.get('scale', 1.2)));
            const appearance = JSON.stringify([font,lineHeight,macros,color,scale]);
            let state = editorStates.get(editor);
            if (!state || state.document !== document || state.text !== text || state.appearance !== appearance) {
                const previous = state;
                state = {document,text,appearance,rendered:new Map(),fragments:fragments(text)};
                if (previous && previous.document === document && previous.appearance === appearance) {
                    // Carry unchanged equations across edits rather than briefly
                    // publishing an empty set while their images are fetched again.
                    let prefix = 0, suffix = 0;
                    while (prefix < previous.text.length && prefix < text.length && previous.text[prefix] === text[prefix]) prefix++;
                    while (suffix < previous.text.length-prefix && suffix < text.length-prefix &&
                        previous.text[previous.text.length-1-suffix] === text[text.length-1-suffix]) suffix++;
                    const delta = text.length-previous.text.length;
                    const current = new Map(state.fragments.map(fragment => [`${fragment.start}:${fragment.end}`,fragment]));
                    for (const old of previous.fragments) {
                        const shift = old.end <= prefix ? 0 : old.start >= previous.text.length-suffix ? delta : undefined;
                        if (shift === undefined) continue;
                        const key = `${old.start+shift}:${old.end+shift}`;
                        const fragment = current.get(key);
                        const entry = previous.rendered.get(`${old.start}:${old.end}`);
                        if (!entry || !fragment || old.math !== fragment.math || old.display !== fragment.display) continue;
                        if (shift === 0) {
                            state.rendered.set(key,entry);
                        } else {
                            const oldLines = previous.text.split('\n');
                            const move = position => document.positionAt(oldLines.slice(0,position.line)
                                .reduce((total,line) => total+line.length+1,0)+position.character+shift);
                            const remap = decoration => ({...decoration,range:new vscode.Range(move(decoration.range.start),move(decoration.range.end))});
                            state.rendered.set(key,{range:new vscode.Range(document.positionAt(fragment.start),document.positionAt(fragment.end)),
                                decorations:entry.decorations.map(remap),activeDecorations:entry.activeDecorations.map(remap)});
                        }
                    }
                    state.ranges = previous.ranges;
                    state.decorations = previous.decorations;
                }
                editorStates.set(editor,state);
            }
            const rangeOf = fragment => new vscode.Range(document.positionAt(fragment.start),document.positionAt(fragment.end));
            const selected = range => editor.selections.some(selection => selection.intersection(range));
            const keyOf = fragment => `${fragment.start}:${fragment.end}`;
            // Keep existing offscreen decorations and pre-render nearby equations.
            // Scrolling must never clear already-rendered math while work is pending.
            const found = state.fragments.filter(fragment => {
                const range = rangeOf(fragment);
                return !state.rendered.has(keyOf(fragment)) &&
                    editor.visibleRanges.some(visible => range.end.line >= visible.start.line-20 && range.start.line <= visible.end.line+20);
            }).sort((a,b) => {
                const visible = fragment => editor.visibleRanges.some(range => range.intersection(rangeOf(fragment)));
                return Number(visible(b))-Number(visible(a));
            }).slice(0,60);
            const publish = () => {
                if (token !== revision || document.isClosed) return;
                const entries = [...state.rendered.values()];
                const ranges = entries.filter(entry => !selected(entry.range)).map(entry => entry.range);
                const decorations = entries.flatMap(entry => selected(entry.range)
                    ? (config.get('activePreview',true) ? entry.activeDecorations : []) : entry.decorations);
                const same = (left,right) => left && left.length === right.length && left.every((item,index) => item === right[index]);
                if (same(state.ranges,ranges) && same(state.decorations,decorations)) return;
                editor.setDecorations(images,decorations);
                editor.setDecorations(hidden,ranges);
                state.ranges = ranges; state.decorations = decorations;
            };
            publish();
            await Promise.all(found.map(async fragment => {
                try {
                    const result = await render(fragment.math,fragment.display,macros,color);
                    if (token !== revision || document.isClosed) return;
                    const begin = document.positionAt(fragment.start), end = document.positionAt(fragment.end);
                    const range = new vscode.Range(begin,end);
                    // An image is constrained to the existing source rows. No source text is edited.
                    const rows = end.line - begin.line + 1;
                    const {height, width, canvasHeight, rowHeight, top} = layout({
                        font, lineHeight, rows, scale, heightEm:result.heightEm, ratio:result.ratio
                    });
                    if (!Number.isFinite(width) || width > 1200) return;
                    const markdown = new vscode.MarkdownString();
                    const uri = vscode.Uri.parse('data:image/svg+xml;base64,'+Buffer.from(result.svg).toString('base64'));
                    markdown.appendMarkdown(`![Equation](${uri.toString()})`);
                    const decorations = [];
                    // Decorations cannot reserve vertical space. Give each source row
                    // a short SVG slice instead of letting one tall image overlap text.
                    const scaled = result.svg.replace(/<svg\b[^>]*>/, tag =>
                        tag.replace(/\s(?:width|height)="[^"]*"/g, '')
                            .replace(/>$/, ` y="${top}" width="${width}" height="${height}">`));
                    for (let row = 0; row < rows; row++) {
                        const slice = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${rowHeight}" viewBox="0 ${row*rowHeight} ${width} ${rowHeight}" overflow="hidden">${scaled}</svg>`;
                        const sliceUri = vscode.Uri.parse('data:image/svg+xml;base64,'+Buffer.from(slice).toString('base64'));
                        const anchor = row === 0 ? begin : new vscode.Position(begin.line+row,0);
                        decorations.push({range:new vscode.Range(anchor,anchor), hoverMessage:markdown,
                            renderOptions:{before:{contentIconPath:sliceUri,width:`${width}px`,height:`${rowHeight}px`,
                                margin:'0 0.15em',textDecoration:'none; opacity: 1; vertical-align: top;'}}});
                    }
                    // Keep the editable equation visible and put its rendering after
                    // the closing delimiter's line. This never changes saved text.
                    const activeHeight = Math.min(lineHeight*.9, font*1.5);
                    const activeWidth = Math.min(500, activeHeight*result.ratio);
                    const activeAnchor = document.lineAt(end.line).range.end;
                    const activeDecorations = [{range:new vscode.Range(activeAnchor,activeAnchor),
                        hoverMessage:markdown, renderOptions:{after:{contentIconPath:uri,
                            width:`${activeWidth}px`,height:`${activeWidth/result.ratio}px`,
                            margin:'0 0 0 1.5em',textDecoration:'none; opacity: 1;'}}}];
                    state.rendered.set(keyOf(fragment),{range,decorations,activeDecorations});
                    publish();
                } catch (error) {output.appendLine(error.message);}
            }));
        }
    }
    function schedule() {revision++; clearTimeout(timer);timer=setTimeout(() => {void update();},25);}
    context.subscriptions.push(hidden,images,output,{dispose:() => {clearTimeout(timer);stop();}},
        vscode.commands.registerCommand('mathSourcePreview.toggle', async () => {
            const config = vscode.workspace.getConfiguration('mathSourcePreview',vscode.window.activeTextEditor?.document.uri);
            await config.update('enabled',!config.get('enabled',true),vscode.ConfigurationTarget.Global);
        }),
        vscode.workspace.onDidChangeTextDocument(schedule),
        vscode.window.onDidChangeTextEditorSelection(schedule),
        vscode.window.onDidChangeTextEditorVisibleRanges(schedule),
        vscode.window.onDidChangeVisibleTextEditors(schedule),
        vscode.window.onDidChangeActiveColorTheme(schedule),
        vscode.workspace.onDidChangeConfiguration(schedule));
    // Load MathJax before the first equation leaves the caret.
    try {start();} catch (error) {output.appendLine(error.message);}
    schedule();
}
module.exports = {activate};
