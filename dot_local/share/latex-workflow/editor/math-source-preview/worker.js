'use strict';
const {parentPort, workerData} = require('worker_threads');
const path = require('path');
const lib = name => require(path.join(workerData.library, 'js', name));
const {mathjax} = lib('mathjax.js');
const {TeX} = lib('input/tex.js');
const {SVG} = lib('output/svg.js');
const {liteAdaptor} = lib('adaptors/liteAdaptor.js');
const {RegisterHTMLHandler} = lib('handlers/html.js');
lib('input/tex/AllPackages.js');
const adaptor = liteAdaptor();
RegisterHTMLHandler(adaptor);
parentPort.on('message', ({id, math, display, macros, color}) => {
    try {
        // A fresh input parser prevents one equation from defining macros for another.
        const document = mathjax.document('', {
            InputJax: new TeX({packages:['base','ams','newcommand','configmacros','boldsymbol','mathtools'], macros,
                maxBuffer:10000, maxMacros:1000,
                formatError: (_jax, error) => {throw new Error(error.message);}}),
            OutputJax: new SVG({fontCache:'none'}),
            renderActions: {
                readableScripts: [140, () => {}, math => {
                    math.root.walkTree(node => {
                        if (!node.attributes) return;
                        node.attributes.set('scriptsizemultiplier', .85);
                        node.attributes.set('scriptminsize', '.75em');
                    });
                }]
            }
        });
        const node = document.convert(math.replace(/\\label\{[^}]*\}/g,''), {display, em:16, ex:8, containerWidth:1000});
        let svg = adaptor.innerHTML(node).replace(/currentColor/g, color);
        if (/data-mml-node="merror"/.test(svg)) throw new Error('Unsupported or incomplete math');
        const view = /viewBox="([^\"]+)"/.exec(svg);
        const bounds = view ? view[1].split(/\s+/).map(Number) : [0,0,1000,1000];
        parentPort.postMessage({id, svg, ratio:bounds[2]/bounds[3], heightEm:bounds[3]/1000});
    } catch (error) { parentPort.postMessage({id, error:error.message}); }
});
