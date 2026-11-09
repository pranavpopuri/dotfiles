'use strict';
// MathJax SVG viewBox coordinates use 1000 units per em.
function layout({font, lineHeight, rows, scale, heightEm, ratio}) {
    const canvasHeight = rows === 1 ? lineHeight*.85 : rows*lineHeight;
    const height = Math.min(font*heightEm*scale, canvasHeight);
    return {height, width:height*ratio, canvasHeight,
        rowHeight:canvasHeight/rows, top:(canvasHeight-height)/2};
}
module.exports = {layout};
