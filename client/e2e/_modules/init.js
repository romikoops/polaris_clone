import open from 'open'
import path from 'path'
import { existsSync, unlinkSync } from 'fs'

import looksSame from '../_vendor/looks-same'
import { delay } from './delay'
import { initPuppeteer } from '../_vendor/init-puppeteer'

const SCREEN_DIR = path.resolve(__dirname, '../node_modules')
const STEP_DELAY = Number(process.env.STEP_DELAY || '0')
const DELAY = 250

function log (input) {
  if (input._type === 'log' && !input._text.startsWith('%')) {
    console.log(input._text)
  } else if (input._type === 'error') {
    console.error(input._text)
  }
}

function compareImages (label, compareLabel, toleranceInput) {
  return new Promise((resolve) => {
    const tolerance = toleranceInput === undefined ? 0 : toleranceInput
    const base = `${SCREEN_DIR}/${label}.png`
    const compareTo = `${SCREEN_DIR}/${compareLabel}.png`
    const diff = `${SCREEN_DIR}/${label}.diff.png`

    looksSame(
      base,
      compareTo,
      { tolerance },
      (err, equal) => {
        if (err !== null) {
          throw err
        }

        if (equal) {
          return resolve(true)
        }

        if (existsSync(diff)) {
          unlinkSync(diff)
        }

        return looksSame.createDiff({
          reference: base,
          current: compareTo,
          diff,
          highlightColor: '#ff00ff',
          strict: false
        }, (diffErr) => {
          if (diffErr !== null) {
            throw diffErr
          }
          open(diff)

          resolve(false)
        })
      }
    )
  })
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

  if (options.log !== false) {
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
      await delay(DELAY)
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

    const waitIndex = input.index === undefined ? 0 : input.index
    let counter = 20
    let found = false

    while (!found && counter > 0) {
      counter -= 1
      await delay(DELAY)
      const countResult = await page.$$eval(
        input.selector,
        els => els.length
      )

      if (countResult < waitIndex + 1) {
        continue
      }

      const texts = await page.$$eval(
        input.selector,
        els => els.map(el => el.textContent)
      )

      found = texts[waitIndex].includes(input.text)
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

    for (const _ of Array(tabCount).fill('')) {
      await page.keyboard.press('Tab')
      await delay(DELAY)
    }

    await page.keyboard.type(text, { delay: 50 })
  }

  const pressTabAndType = async (text) => {
    await page.keyboard.press('Tab')
    await page.keyboard.type(text, { delay: 50 })
  }

  const selectWithTab = async (tabCount, arrowToPressInput, bruteForceFlag) => {
    const arrowToPress = arrowToPressInput === undefined
      ? 'ArrowDown'
      : `Arrow${arrowToPressInput}`

    mark('selectWithTab', tabCount, arrowToPress)

    for (const _ of Array(tabCount).fill('')) {
      await page.keyboard.press('Tab')

      if (bruteForceFlag) {
        await page.keyboard.press(arrowToPress)
        await delay(DELAY)
      }
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
  const takeScreenshot = async (label) => {
    const screenshotPath = `${SCREEN_DIR}/${label}.png`

    if (existsSync(screenshotPath)) {
      unlinkSync(screenshotPath)
    }
    await page.screenshot({
      fullPage: true,
      path: screenshotPath
    })

    return screenshotPath
  }
  const shouldMatchScreenshot = async (label, tolerance, resetFlag) => {
    await delay(2 * DELAY)
    const filePath = `${SCREEN_DIR}/${label}.png`

    if (!existsSync(filePath)) {
      await takeScreenshot(label)
      /**
       * As there is no screenshot to compare
       * we save the screen and return true
       */

      return true
    }

    if (resetFlag === true) {
      unlinkSync(filePath)
      await takeScreenshot(label)

      return true
    }
    const compareLabel = `${label}.to.compare`
    const compareFilePath = `${SCREEN_DIR}/${compareLabel}.png`

    if (existsSync(compareFilePath)) {
      unlinkSync(compareFilePath)
    }
    await takeScreenshot(compareLabel)
    const result = await compareImages(label, compareLabel, tolerance)

    if (result === false) {
      console.warning('compareImages', false)
    }

    return result
  }

  const onError = () => {
    holder.forEach(x => console.log(x))
  }

  const stop = async () => page.evaluate('.NON_EXISTING_SELECTOR', clickWhichSelector)

  return {
    $$,
    $,
    browser,
    catchError,
    click,
    clickWithPartialText,
    clickWithText,
    count,
    exists,
    fill,
    focus,
    inputWithTab,
    onError,
    page,
    selectFirstAvailableDay,
    selectWithTab,
    setInput,
    shouldMatchScreenshot,
    stop,
    pressTabAndType,
    takeScreenshot,
    url,
    waitAndClick,
    waitFor,
    waitForSelectors,
    waitForText
  }
}

function clickWhichSelector (els, i) {
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
