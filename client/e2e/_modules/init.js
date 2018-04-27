import { initPuppeteer } from 'init-puppeteer'
import { delay } from './delay'

const DELAY = Number(process.env.STEP_DELAY || '0')

export default async function init (options) {
  const { page, browser, catchError } = await initPuppeteer(options)
  let selectorHolder
  let operationHolder

  const $ = async (...input) => {
    // eslint-disable-next-line
    selectorHolder = input[0]

    const result = await page.$eval(...input)
    await delay(DELAY)

    return result
  }

  const $$ = async (...input) => {
    // eslint-disable-next-line
    selectorHolder = input[0]

    const result = await page.$$eval(...input)
    await delay(DELAY)

    return result
  }

  const waitFor = async (selector, count = 1) => {
    selectorHolder = selector
    operationHolder = 'waitFor'

    let counter = 15
    const countFn = page.$$eval(
      selector,
      (els, countValue) => els.length >= countValue,
      count
    )
    let found = await countFn

    while (!found && counter > 0) {
      counter -= 1
      // eslint-disable-next-line
      await delay(200)
      // eslint-disable-next-line
      found = await countFn
    }

    return found
  }

  const waitForSelectors = async (...selectors) => {
    selectorHolder = `[${selectors.toString()}]`
    operationHolder = 'waitForSelectors'

    const promised = selectors.map(singleSelector => waitFor(singleSelector))
    const result = await Promise.all(promised)

    return !result.includes(false)
  }

  const url = () => {
    operationHolder = 'url'

    return page.evaluate(() => window.location.href)
  }

  const focus = (selector) => {
    operationHolder = 'focus'

    return $(selector, el => el.focus())
  }

  const count = (selector) => {
    selectorHolder = selector
    operationHolder = 'count'

    return page.$$eval(selector, els => els.length)
  }
  const exists = (selector) => {
    selectorHolder = selector
    operationHolder = 'exists'

    return page.$$eval(selector, els => els.length > 0)
  }

  const click = async (selector, index) => {
    operationHolder = 'click'

    if (index === undefined) {
      const ok = await exists(selector)

      if (!ok) {
        return false
      }
      await $(selector, el => el.click())

      return true
    }

    return $$(selector, clickWhichSelector, index)
  }
  const clickWithText = async (selector, text) => {
    const ok = await exists(selector)
    if (!ok) {
      return false
    }

    return $$(selector, clickWithTextFn, text)
  }
  const fill = async (selector, text) => {
    selectorHolder = selector
    operationHolder = 'fill'

    await focus(selector)
    await page.keyboard.type(text, { delay: 50 })
  }

  const selectWithTab = async (tabCount) => {
    // eslint-disable-next-line
    for (const _ of Array(tabCount).fill('')) {
      // eslint-disable-next-line
      await page.keyboard.press('Tab')
      // eslint-disable-next-line
      await delay(200)
    }

    await page.keyboard.press('ArrowDown')
    await delay(200)
    await page.keyboard.press('Enter')
    await delay(200)
  }

  const onError = () =>
    `Latest operation - '${operationHolder}' | Latest selector - '${selectorHolder}'`

  return {
    $$,
    $,
    browser,
    catchError,
    click,
    clickWithText,
    count,
    exists,
    fill,
    focus,
    onError,
    page,
    url,
    selectWithTab,
    waitFor,
    waitForSelectors
  }
}

function clickWhichSelector (els, i) {
  // eslint-disable-next-line
  const convertIndex = (x, length) => (typeof x === 'number'
    ? x
    : x === 'last'
      ? length - 1
      : 0)

  const index = convertIndex(i, els.length)

  if (index >= els.length) {
    return false
  }

  els[index].click()

  return true
}

function clickWithTextFn (els, text) {
  const filtered = els.filter(x => x.textContent.includes(text))

  if (filtered.length === 0) {
    return false
  }
  filtered[0].click()

  return true
}
