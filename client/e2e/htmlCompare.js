const [,,label] = process.argv

var fs = require('fs'),
    HtmlDiffer = require('html-differ').HtmlDiffer,
    logger = require('html-differ/lib/logger');
 
var html1 = fs.readFileSync(`${__dirname}/_screens/${label}.html`, 'utf-8')
var html2 = fs.readFileSync(`${__dirname}/_screens/${label}.to.compare.html`, 'utf-8')
 
var options = {
        ignoreAttributes: [],
        compareAttributesAsJSON: [],
        ignoreWhitespaces: true,
        ignoreComments: true,
        ignoreEndTags: false,
        ignoreDuplicateAttributes: false
    };
 
var htmlDiffer = new HtmlDiffer(options);
 
var diff = htmlDiffer.diffHtml(html1, html2),
    isEqual = htmlDiffer.isEqual(html1, html2),
    res = logger.getDiffText(diff, { charsAroundDiff: 40 });
 
logger.logDiffText(diff, { charsAroundDiff: 40 })

console.log(isEqual, 'isEqual')