'use strict';
function escaped(text, offset) {
    let count = 0;
    while (offset > 0 && text[--offset] === '\\') count++;
    return count % 2 === 1;
}
function fragments(source) {
    // Mask code and comments without changing offsets or line numbers.
    let text = source.replace(/\\begin\{(verbatim\*?|Verbatim|lstlisting|minted|pycode|sympycode|pythontexcustomcode)\}[\s\S]*?\\end\{\1\}/g,
        match => match.replace(/[^\n]/g, ' '));
    text = text.replace(/\\verb\*?([^\w\s])[\s\S]*?\1/g, match => match.replace(/[^\n]/g, ' '));
    text = text.replace(/%[^\n]*/g, (match, offset) => escaped(text, offset) ? match : ' '.repeat(match.length));
    const opening = /\$\$|\$|\\\[|\\\(|\\begin\{(equation\*?|align\*?|alignat\*?|gather\*?|multline\*?|displaymath|math)\}/g;
    const result = [];
    let match;
    while ((match = opening.exec(text))) {
        if (escaped(text, match.index)) continue;
        const delimiter = match[0];
        const close = match[1] ? `\\end{${match[1]}}` : ({'$$':'$$', '$':'$', '\\[':'\\]', '\\(':'\\)'})[delimiter];
        let end = text.indexOf(close, opening.lastIndex);
        while (end >= 0 && escaped(text, end)) end = text.indexOf(close, end + close.length);
        if (end < 0) continue;
        const body = source.slice(opening.lastIndex, end);
        if (delimiter === '$' && body.includes('\n')) continue;
        const endOffset = end + close.length;
        const math = match[1] && !['equation', 'equation*', 'math', 'displaymath'].includes(match[1])
            ? source.slice(match.index, endOffset) : body;
        if (math.length <= 5000 && !/\bcas /.test(math)) {
            result.push({start:match.index, end:endOffset, math, display:!['$', '\\(', '\\begin{math}'].includes(delimiter)});
        }
        opening.lastIndex = endOffset;
    }
    return result;
}
module.exports = {fragments};
