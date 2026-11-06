'use strict';
const vscode = require('vscode');
const path = require('path');
const {Worker} = require('worker_threads');
const {fragments} = require('./fragments');
function activate(context) {
    let worker, requestId = 0, revision = 0, timer;
    const pending = new Map(), cache = new Map();
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
        const key = JSON.stringify([math,display,macros,color]);
        if (cache.has(key)) return Promise.resolve(cache.get(key));
        start();
        return new Promise((resolve,reject) => {
            const id = ++requestId;
            const timeout = setTimeout(() => stop(), 3000);
            pending.set(id, {timeout,reject,resolve:result => {
                if (cache.size >= 200) cache.delete(cache.keys().next().value);
                cache.set(key,result); resolve(result);
            }});
            worker.postMessage({id,math,display,macros,color});
        });
    }
    async function update() {
        const token = ++revision;
        for (const editor of vscode.window.visibleTextEditors) {
            const document = editor.document;
            const config = vscode.workspace.getConfiguration('mathSourcePreview',document.uri);
            editor.setDecorations(hidden, []); editor.setDecorations(images, []);
            if (!['latex','tex'].includes(document.languageId) || !config.get('enabled',true)) continue;
            const settings = vscode.workspace.getConfiguration('editor',document.uri);
            const font = settings.get('fontSize',14);
            const settingHeight = settings.get('lineHeight',0);
            const lineHeight = settingHeight === 0 ? font*1.5 : settingHeight < 8 ? font*settingHeight : settingHeight;
            const dark = ![vscode.ColorThemeKind.Light,vscode.ColorThemeKind.HighContrastLight].includes(vscode.window.activeColorTheme.kind);
            const color = dark ? '#e0e0e0' : '#202020';
            const ranges = [], decorations = [];
            const found = fragments(document.getText()).filter(fragment => {
                const range = new vscode.Range(document.positionAt(fragment.start),document.positionAt(fragment.end));
                return editor.visibleRanges.some(visible => visible.intersection(range)) &&
                    !editor.selections.some(selection => selection.intersection(range));
            }).slice(0,60);
            for (const fragment of found) {
                try {
                    const result = await render(fragment.math,fragment.display,config.get('macros',{}),color);
                    if (token !== revision || document.isClosed) return;
                    const begin = document.positionAt(fragment.start), end = document.positionAt(fragment.end);
                    const range = new vscode.Range(begin,end);
                    // An image is constrained to the existing source rows. No source text is edited.
                    const height = Math.min(font*3.5, (end.line-begin.line+1)*lineHeight*.9);
                    const width = height * result.ratio;
                    if (!Number.isFinite(width) || width > 1200) continue;
                    const anchor = end.line === begin.line ? begin : new vscode.Position(end.line,0);
                    const markdown = new vscode.MarkdownString();
                    const uri = vscode.Uri.parse('data:image/svg+xml;base64,'+Buffer.from(result.svg).toString('base64'));
                    markdown.appendMarkdown(`![Equation](${uri.toString()})`);
                    ranges.push(range);
                    decorations.push({range:new vscode.Range(anchor,anchor), hoverMessage:markdown,
                        renderOptions:{before:{contentIconPath:uri,width:`${width}px`,height:`${height}px`,margin:'0 0.15em',textDecoration:'none; opacity: 1;'}}});
                } catch (error) {output.appendLine(error.message);}
            }
            if (token === revision) {editor.setDecorations(hidden,ranges);editor.setDecorations(images,decorations);}
        }
    }
    function schedule() {revision++; clearTimeout(timer);timer=setTimeout(() => {void update();},120);}
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
    schedule();
}
module.exports = {activate};
