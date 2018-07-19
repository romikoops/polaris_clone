const X_SELECTOR = '_23SkfwkdbICA73cxSvjLQ'
const Y_SELECTOR = 'MLEf6LnvhFJapHszBakJp'

const [,, label] = process.argv
const jsdom = require('jsdom')
const logger = require('html-differ/lib/logger')
const { HtmlDiffer } = require('html-differ')

const { JSDOM } = jsdom
const { readFileSync } = require('fs')

const options = {
  ignoreAttributes: [],
  compareAttributesAsJSON: [],
  ignoreWhitespaces: true,
  ignoreComments: true,
  ignoreEndTags: false,
  ignoreDuplicateAttributes: false
}

const htmlDiffer = new HtmlDiffer(options)

function htmlCompare () {
  const xHTMLFile = readFileSync(`${__dirname}/_screens/${label}.html`).toString()
  const yHTMLFile = readFileSync(`${__dirname}/_screens/${label}.to.compare.html`).toString()

  const xDOM = new JSDOM(xHTMLFile)
  const yDOM = new JSDOM(yHTMLFile)

  const xHTML = xDOM.window.document.querySelector(`.${X_SELECTOR}`).outerHTML
  const yHTML = yDOM.window.document.querySelector(`.${Y_SELECTOR}`).outerHTML

  const diff = htmlDiffer.diffHtml(xHTML, yHTML)
  const isEqual = htmlDiffer.isEqual(xHTML, yHTML)
  if (isEqual) {
    return console.log('EQUAL')
  }

  logger.logDiffText(diff, { charsAroundDiff: 40 })
}

htmlCompare()
