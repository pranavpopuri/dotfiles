'use strict';
const {test} = require('node:test');
const assert = require('node:assert/strict');
const path = require('path');
const {fragments} = require('../editor/math-source-preview/fragments');
const root = path.resolve(__dirname,'..');
const fs = require('fs'), os = require('os');
const extensionRoots = [path.join(root,'extensions'),path.join(os.homedir(),'.vscode-oss/extensions'),path.join(os.homedir(),'.vscode/extensions')];
const workshop = extensionRoots.flatMap(directory => fs.existsSync(directory) ? fs.readdirSync(directory).filter(name=>name.startsWith('james-yu.latex-workshop-')).map(name=>path.join(directory,name)) : []).find(directory=>fs.existsSync(path.join(directory,'node_modules/mathjax-full')));
if (!workshop) throw new Error('Install LaTeX Workshop before running the preview tests.');
const library = path.join(workshop,'node_modules/mathjax-full');

test('extract complete math and skip comments, code, escaped delimiters, and CAS input', () => {
    const input = String.raw`Prose \$5.
% $ignored$
$x^2$ and \(\alpha\).
\[
\frac{1}{24}
\]
\begin{align*}x&=1\\y&=2\end{align*}
\begin{sympycode}
print('$not_math$')
\end{sympycode}
$cas simplify(x) cas$
$incomplete`;
    const result = fragments(input);
    assert.equal(result.length,4);
    assert.deepEqual(result.map(x=>x.display),[false,false,true,true]);
    assert(result[3].math.startsWith('\\begin{align*}'));
    assert.equal(input.slice(result[0].start,result[0].end),'$x^2$');
});

test('real MathJax worker renders fractions, matrices, and course macros', async () => {
    const {Worker} = require('worker_threads');
    const worker = new Worker(path.join(root,'editor/math-source-preview/worker.js'),{workerData:{library}});
    try {
        for (const [index, math] of [String.raw`\frac{1}{24}`,String.raw`\begin{pmatrix}1&2\\3&4\end{pmatrix}`,String.raw`\E[X]+\Var(X)`].entries()) {
            const result = await new Promise((resolve,reject) => {
                const timeout=setTimeout(()=>reject(new Error('worker timeout')),5000);
                worker.once('message', data=>{clearTimeout(timeout);resolve(data);});
                worker.once('error',reject);
                worker.postMessage({id:index,math,display:true,color:'#ffffff',macros:{E:'\\mathbb{E}',Var:'\\operatorname{Var}'}});
            });
            assert(!result.error,result.error);
            assert(result.svg.includes('<svg'));
            assert(result.ratio>0);
            assert(!result.svg.includes('currentColor'));
        }
    } finally {await worker.terminate();}
});

test('extension hides inactive math, reveals source at the caret, and never edits the document',async () => {
    class Position {constructor(line,character){this.line=line;this.character=character;}}
    const offset = p=>p.line*10000+p.character;
    class Range {
        constructor(start,end){this.start=start;this.end=end;}
        intersection(other){return offset(this.end)>=offset(other.start)&&offset(other.end)>=offset(this.start)?this:undefined;}
    }
    let input='\\[\n\\frac{1}{24}\n\\]\nProse';
    const document={languageId:'latex',uri:{},isClosed:false,getText:()=>input,lineAt(line){return {range:new Range(new Position(line,0),new Position(line,input.split('\n')[line].length))};},positionAt(index){
        const parts=input.slice(0,index).split('\n');return new Position(parts.length-1,parts.at(-1).length);
    }};
    const displayed=new Map(), history=[];
    const editor={document,visibleRanges:[new Range(new Position(0,0),new Position(4,0))],
        selections:[new Range(new Position(3,1),new Position(3,1))],setDecorations(type,ranges){displayed.set(type.name,ranges);history.push({type:type.name,ranges});}};
    let selectionChanged, textChanged;
    const disposable=()=>({dispose(){}});
    let type=0;
    const vscode={
        Range,Position,DecorationRangeBehavior:{ClosedClosed:1},ConfigurationTarget:{Workspace:2,Global:1},ColorThemeKind:{Light:1,HighContrastLight:4},
        Uri:{parse:value=>({toString:()=>value})},
        MarkdownString:class {appendMarkdown(){}},
        extensions:{getExtension:()=>({extensionPath:path.resolve(library,'../..')})},
        workspace:{getConfiguration:()=>({get:(key,fallback)=>fallback}),onDidChangeTextDocument:callback=>{textChanged=callback;return disposable();},onDidChangeConfiguration:disposable},
        commands:{registerCommand:disposable},
        window:{visibleTextEditors:[editor],activeColorTheme:{kind:2},createOutputChannel:()=>({appendLine(){},dispose(){}}),
            createTextEditorDecorationType:()=>({name:++type===1?'hidden':'images',dispose(){}}),
            onDidChangeTextEditorSelection:callback=>{selectionChanged=callback;return disposable();},
            onDidChangeTextEditorVisibleRanges:disposable,onDidChangeVisibleTextEditors:disposable,onDidChangeActiveColorTheme:disposable}
    };
    const Module=require('module'),original=Module._load;
    Module._load=function(name,...args){return name==='vscode'?vscode:original.call(this,name,...args);};
    const context={extensionPath:path.join(root,'editor/math-source-preview'),subscriptions:[]};
    try {require('../editor/math-source-preview/extension').activate(context);}
    finally {Module._load=original;}
    async function until(predicate){for(let i=0;i<60;i++){if(predicate())return;await new Promise(resolve=>setTimeout(resolve,50));}assert.fail('Decoration update timed out');}
    try {
        await until(()=>displayed.get('images')?.length===3);
        assert.equal(displayed.get('hidden').length,1);
        history.length=0;
        input += ' edited';
        textChanged();
        await new Promise(resolve=>setTimeout(resolve,100));
        assert(history.filter(item=>item.type==='hidden').every(item=>item.ranges.length===1), 'editing prose must not reveal unchanged math');
        history.length=0;
        input='Before\n'+input;
        editor.selections=[new Range(new Position(4,1),new Position(4,1))];
        textChanged();
        await until(()=>displayed.get('hidden')?.[0]?.start.line===1);
        assert(history.filter(item=>item.type==='hidden').every(item=>item.ranges.length===1), 'moving math must not reveal its source');
        editor.selections=[new Range(new Position(2,5),new Position(2,5))];
        selectionChanged();
        await until(()=>displayed.get('hidden')?.length===0);
        assert.equal(displayed.get('images').length,1);
        assert(displayed.get('images')[0].renderOptions.after);
        assert.equal(displayed.get('images')[0].range.start.line,3);
        assert.equal(document.getText(),input);
    } finally {for(const subscription of context.subscriptions) subscription.dispose();}
});
