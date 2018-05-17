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
  const holder = []

  const mark = (operation, selector, additional) => {
    if (holder.length === 10) {
      holder.shift()
    }

    const x = additional === undefined
      ? { selector, operation }
      : { selector, operation, additional }

    holder.push(x)
  }

  if (options.log) {
    page.on('console', log)
  }

  const $ = async (...input) => {
    mark('$', input[0])

    const result = await page.$eval(...input)
    await delay(STEP_DELAY)

    return result
  }

  const $$ = async (...input) => {
    mark('$$', input[0])

    const result = await page.$$eval(...input)
    await delay(STEP_DELAY)

    return result
  }

  const waitFor = async (selectorInput, countInput = 1) => {
    const { selector, count } = typeof selectorInput === 'object'
      ? selectorInput
      : { selector: selectorInput, count: countInput }

    mark('waitFor', selector, count)

    let counter = 20
    let found = await page.$$eval(
      selector,
      (els, countValue) => els.length >= countValue,
      count
    )

    while (!found && counter > 0) {
      counter -= 1
      // eslint-disable-next-line
      await delay(DELAY)
      // eslint-disable-next-line
      found = await page.$$eval(
        selector,
        (els, countValue) => els.length >= countValue,
        count
      )
    }

    return found
  }

  const waitForSelectors = async (...selectors) => {
    mark('waitForSelectors', `[${selectors.toString()}]`)

    const promised = selectors.map(singleSelector => waitFor(singleSelector))
    const result = await Promise.all(promised)

    return !result.includes(false)
  }

  /**
   * It waits 2 seconds for selector with specified index contains specified text
   */
  const waitForText = async (input) => {
    mark('waitForText', input.selector)

    let counter = 20
    let found = false

    while (!found && counter > 0) {
      counter -= 1
      // eslint-disable-next-line
      await delay(DELAY)
      // eslint-disable-next-line
      const countResult = await page.$$eval(
        input.selector,
        els => els.length
      )

      if (countResult < input.index + 1) {
        // eslint-disable-next-line
        continue
      }

      // eslint-disable-next-line
      const texts = await page.$$eval(
        input.selector,
        els => els.map(el => el.textContent)
      )

      found = texts[input.index].includes(input.text)
    }

    return found
  }

  const url = () => {
    mark('url')

    return page.evaluate(() => window.location.href)
  }

  const focus = (selector) => {
    mark('focus', selector)

    return $(selector, el => el.focus())
  }

  const count = (selector) => {
    mark('count', selector)

    return page.$$eval(selector, els => els.length)
  }

  const exists = (selector) => {
    mark('exists', selector)

    return page.$$eval(selector, els => els.length > 0)
  }

  const click = async (selectorInput, indexInput) => {
    const { selector, index } = typeof selectorInput === 'object'
      ? selectorInput
      : { selector: selectorInput, index: indexInput }

    mark('click', selector, index)

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
    mark('clickWithText', selector, text)

    if (await exists(selector) === false) {
      return false
    }

    return $$(selector, clickWithTextFn, text)
  }

  const clickWithPartialText = async (selector, text) => {
    mark('clickWithPartialText', selector, text)

    if (await exists(selector) === false) {
      return false
    }

    return $$(selector, clickWithPartialTextFn, text)
  }

  const waitAndClick = async (input) => {
    mark('waitAndClick', input)

    if (await waitFor(input.selector, input.index + 1) === false) {
      return false
    }

    return click(input.selector, input.index)
  }

  const fill = async (selector, text) => {
    mark('fill', selector, text)

    await focus(selector)
    await page.keyboard.type(text, { delay: 50 })
  }

  const setInput = async (selector, newValue) => {
    mark('setInput', selector, newValue)

    if (await exists(selector) === false) {
      return false
    }

    await page.$eval(selector, setInputFn, newValue)

    return true
  }

  const inputWithTab = async (tabCount, text) => {
    mark('inputWithTab', tabCount, text)

    // eslint-disable-next-line
    for (const _ of Array(tabCount).fill('')) {
      // eslint-disable-next-line
      await page.keyboard.press('Tab')
      // eslint-disable-next-line
      await delay(DELAY)
    }

    await page.keyboard.type(text, { delay: 50 })
  }

  const selectWithTab = async (tabCount, arrowToPressInput) => {
    const arrowToPress = arrowToPressInput === undefined
      ? 'ArrowDown'
      : `Arrow${arrowToPressInput}`

    mark('selectWithTab', tabCount, arrowToPress)

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
    mark('selectFirstAvailableDay', selector)

    if (await exists(selector) === false) {
      return false
    }

    await $(selector, el => el.click())
    await delay(DELAY)

    return page.evaluate(selectFirstAvailableDayFn)
  }

  const onError = () => {
    // eslint-disable-next-line
    holder.forEach(x => console.log(x))
  }

  const stop = async () => page.evaluate('.NON_EXISTING_SELECTOR', clickWhichSelector)

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
    stop,
    inputWithTab,
    selectWithTab,
    selectFirstAvailableDay,
    setInput,
    waitFor,
    waitForText,
    waitAndClick,
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
