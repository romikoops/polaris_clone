import { initPuppeteer } from 'init-puppeteer'
import { delay } from './delay'

const STEP_DELAY = Number(process.env.STEP_DELAY || '0')
const DELAY = 200

function log (input) {
  // eslint-disable-next-line
  if (input._type === 'log' && !input._text.startsWith('%')) {
    // eslint-disable-next-line
    console.log(input._text)
  }
}

export default async function init (options) {
  const { page, browser, catchError } = await initPuppeteer(options)
  let selectorHolder
  let operationHolder

  if (options.log) {
    page.on('console', log)
  }

  const $ = async (...input) => {
    // eslint-disable-next-line
    selectorHolder = input[0]

    const result = await page.$eval(...input)
    await delay(STEP_DELAY)

    return result
  }

  const $$ = async (...input) => {
    // eslint-disable-next-line
    selectorHolder = input[0]

    const result = await page.$$eval(...input)
    await delay(STEP_DELAY)

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
      await delay(DELAY)
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

  const click = async (selectorInput, indexInput) => {
    operationHolder = 'click'
    const { selector, index } = typeof selectorInput === 'object'
      ? selectorInput
      : { selector: selectorInput, index: indexInput }

    if (index === undefined) {
      if (await exists(selector) === false) {
        return false
      }
      await $(selector, el => el.click())

      return true
    }

    return $$(selector, clickWhichSelector, index)
  }

  const clickWithText = async (selector, text) => {
    if (await exists(selector) === false) {
      return false
    }

    return $$(selector, clickWithTextFn, text)
  }

  const clickWithPartialText = async (selector, text) => {
    if (await exists(selector) === false) {
      return false
    }

    return $$(selector, clickWithPartialTextFn, text)
  }

  const fill = async (selector, text) => {
    selectorHolder = selector
    operationHolder = 'fill'

    await focus(selector)
    await page.keyboard.type(text, { delay: 50 })
  }

  const setInput = async (selector, newValue) => {
    selectorHolder = selector
    operationHolder = 'setInput'

    if (await exists(selector) === false) {
      return false
    }

    await page.$eval(selector, setInputFn, newValue)

    return true
  }

  const selectWithTab = async (tabCount, arrowToPressInput) => {
    const arrowToPress = arrowToPressInput === undefined
      ? 'ArrowDown'
      : `Arrow${arrowToPressInput}`

    // eslint-disable-next-line
    for (const _ of Array(tabCount).fill('')) {
      // eslint-disable-next-line
      await page.keyboard.press('Tab')
      // eslint-disable-next-line
      await delay(DELAY)
    }

    await page.keyboard.press(arrowToPress)
    await delay(DELAY)
    await page.keyboard.press('Enter')
    await delay(DELAY)
  }
  const selectFirstAvailableDay = async (selector) => {
    if (await exists(selector) === false) {
      return false
    }

    await $(selector, el => el.click())
    await delay(DELAY)

    return page.evaluate(selectFirstAvailableDayFn)
  }

  const onError = () => {
    const head = `Latest operation - '${operationHolder}'`
    const tail = `Latest selector - '${selectorHolder}'`

    return `${head} | ${tail}`
  }

  return {
    $$,
    $,
    browser,
    catchError,
    click,
    clickWithText,
    clickWithPartialText,
    count,
    exists,
    fill,
    focus,
    onError,
    page,
    url,
    selectWithTab,
    selectFirstAvailableDay,
    setInput,
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
  const filtered = els.filter(x => x.textContent === text)

  if (filtered.length === 0) {
    return false
  }
  filtered[0].click()

  return true
}

function clickWithPartialTextFn (els, text) {
  const filtered = els.filter(x => x.textContent.includes(text))

  if (filtered.length === 0) {
    return false
  }
  filtered[0].click()

  return true
}

function setInputFn (el, newValue) {
  // eslint-disable-next-line
  el.value = newValue
}

function selectFirstAvailableDayFn () {
  const els = Array.from(document.querySelectorAll('.DayPicker-Day'))
  const filtered = els.filter(x => x.classList.length === 1)

  if (filtered.length === 0) {
    return false
  }
  filtered[0].click()

  return true
}
