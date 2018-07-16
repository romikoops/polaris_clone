import path from 'path'
import { existsSync, unlinkSync } from 'fs'
import { log } from '../_modules/log'

import { delay } from './delay'
import { initPuppeteer } from '../_vendor/init-puppeteer'
import { isDocker } from '../_modules/isDocker'

const SCREEN_DIR = path.resolve(__dirname, '../node_modules')
const STEPS_SCREEN_DIR = path.resolve(__dirname, '../_screens')
const STEP_DELAY = Number(process.env.STEP_DELAY || '0')
const DELAY = 250

function waitNotificator (selector, operationType) {
  log('______________', 'warning')
  console.log('Selector, Type', selector, operationType)
  log('______________', 'warning')
}

function logFn (input) {
  if (input._type === 'log' && !input._text.startsWith('%')) {
    console.log(input._text)
  } else if (input._type === 'error') {
    console.error(input._text)
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

  if (options.log !== false) {
    page.on('console', logFn)
  }

  const getHandle$ = async (selector) => {
    const handle = page.evaluateHandle(x => document.querySelector(x), selector)

    const ok = page.evaluate(el => el !== null, handle)

    if (!ok) {
      await handle.dispose()

      return false
    }

    return handle
  }

  const getHandle$$ = async (selector) => {
    const handle = page.evaluateHandle(x => document.querySelectorAll(x), selector)

    const ok = page.evaluate(el => el.length > 0, handle)

    if (!ok) {
      await handle.dispose()

      return false
    }

    return handle
  }

  const $ = async (selector, fn, additional) => {
    const handle = await getHandle$(selector)

    if (handle === false) {
      return false
    }
    const result = await page.evaluate(fn, handle, additional)
    await handle.dispose()
    await delay(STEP_DELAY)

    return result
  }
  const $$ = async (selector, fn, additional) => {
    const handle = await getHandle$$(selector)

    if (handle === false) {
      return false
    }
    const result = await page.evaluate(fn, handle, additional)
    await handle.dispose()
    await delay(STEP_DELAY)

    return result
  }

  const count = (selector) => {
    mark('count', selector)

    return $$(selector, els => els.length)
  }

  const waitFor = async (selectorInput, countInput = 1) => {
    waitNotificator(selectorInput, 'waitFor')
    console.time('waitFor')
    const { selector, count: countValue } = typeof selectorInput === 'object'
      ? selectorInput
      : { selector: selectorInput, count: countInput }

    mark('waitFor', selector, countValue)

    let counter = 50
    let counted = await count(selector)

    while (counted < countValue && counter > 0) {
      counter -= 1
      await delay(DELAY)
      counted = await count(selector)
    }
    console.timeEnd('waitFor')
    log('_____DELAY_START________', 'success')
    await delay(1500)
    log('_____DELAY_END________', 'success')

    return counted >= countValue
  }

  const waitForSelectors = async (...selectors) => {
    waitNotificator(selectors, 'waitForSelectors')
    console.time('waitForSelectors')
    mark('waitForSelectors', `[${selectors.toString()}]`)

    const promised = selectors.map(singleSelector => waitFor(singleSelector))
    const result = await Promise.all(promised)

    console.timeEnd('waitForSelectors')
    log('_____DELAY_START________', 'success')
    await delay(1500)
    log('_____DELAY_END________', 'success')

    return !result.includes(false)
  }

  /**
   * It waits 20 seconds for selector with specified index contains specified text
   */
  const waitForText = async (input) => {
    waitNotificator(input, 'waitForText')
    console.time('waitForText')
    mark('waitForText', input.selector)

    const waitIndex = input.index === undefined ? 0 : input.index
    let counter = 50
    let found = false

    while (!found && counter > 0) {
      counter -= 1
      await delay(DELAY)
      const countResult = await count(input.selector)

      if (countResult < waitIndex + 1) {
        continue
      }

      const texts = await $$(
        input.selector,
        els => Array.from(els).map(el => el.textContent)
      )
      found = texts[waitIndex].includes(input.text)
    }
    console.timeEnd('waitForText')
    log('_____DELAY_START________', 'success')
    await delay(1500)
    log('_____DELAY_END________', 'success')

    return found
  }

  const url = () => {
    mark('url')

    return page.evaluate(() => window.location.href)
  }

  const focus = async (selector) => {
    mark('focus', selector)

    const handle = await getHandle$(selector)
    if (handle === false) {
      return false
    }
    await handle.focus()
    await handle.dispose()

    return true
  }

  const exists = (selector) => {
    mark('exists', selector)

    return $$(selector, els => els.length > 0)
  }

  const click = async (selectorInput, indexInput) => {
    const { selector, index } = typeof selectorInput === 'object'
      ? selectorInput
      : { selector: selectorInput, index: indexInput }

    mark('click', selector, index)

    if (index === undefined) {
      const handle = await getHandle$(selector)
      if (handle === false) {
        return false
      }
      await handle.click()
      await handle.dispose()

      return true
    }

    return $$(selector, clickWhichSelector, index)
  }

  const clickWithText = async (selector, text) => {
    mark('clickWithText', selector, text)

    if (await exists(selector) === false) {
      return false
    }
    const texts = await page.evaluate(
      (sel) => {
        const els = document.querySelectorAll(sel)

        return Array.from(els).map(el => el.textContent)
      },
      selector
    )
    const index = texts.indexOf(text)

    if (index === -1) {
      return false
    }
    await page.evaluate(
      (sel, i) => {
        const els = document.querySelectorAll(sel)
        els[i].click()
      },
      selector,
      index
    )

    return true
  }

  const clickWithPartialText = async (selector, text) => {
    mark('clickWithPartialText', selector, text)

    if (await exists(selector) === false) {
      return false
    }
    const texts = await page.evaluate(
      (sel) => {
        const els = document.querySelectorAll(sel)

        return Array.from(els).map(el => el.textContent)
      },
      selector
    )
    const index = texts.findIndex(x => x.includes(text))

    if (index === -1) {
      return false
    }
    await page.evaluate(
      (sel, i) => {
        const els = document.querySelectorAll(sel)
        els[i].click()
      },
      selector,
      index
    )

    return true
  }

  const waitAndClick = async (input) => {
    mark('waitAndClick', input)
    waitNotificator(input, 'waitAndClick')
    console.time('waitAndClick')

    if (await waitFor(input.selector, input.index + 1) === false) {
      log('`waitFor` returns `false`', 'error')

      return false
    }
    console.timeEnd('waitAndClick')
    log('_____DELAY_START________', 'success')
    await delay(1500)
    log('_____DELAY_END________', 'success')

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

  const takeScreenshot = async (label, options = {}) => {
    const screenDirectory = options.screenDirectoryFlag
      ? STEPS_SCREEN_DIR
      : SCREEN_DIR

    const fileExtension = options.fullQuality
      ? 'png'
      : 'jpeg'

    const screenshotPath = `${screenDirectory}/${label}.${fileExtension}`
    const screenshotOptionsBase = {
      fullPage: true,
      type: fileExtension,
      path: screenshotPath
    }
    const screenshotOptions = options.fullQuality
      ? screenshotOptionsBase
      : { ...screenshotOptionsBase, quality: 50 }

    if (existsSync(screenshotPath)) {
      unlinkSync(screenshotPath)
    }
    await page.screenshot(screenshotOptions)

    return screenshotPath
  }

  let saveStepCounter = 0
  let labelHolder
  let labelPairHolder

  const logLabelPair = (labelX, labelY) => {
    labelHolder = labelY
    if (labelX === undefined) {
      labelPairHolder = `${saveStepCounter} | ${labelY}`
      console.time(labelPairHolder)

      return
    }
    console.timeEnd(labelPairHolder)
    labelPairHolder = `${saveStepCounter} | ${labelX} ==> ${labelY}`
    console.time(labelPairHolder)
  }
  const saveStep = async (label) => {
    log(label, 'info')
    logLabelPair(labelHolder, label)
    if (!isDocker()) {
      return
    }
    log('screenshot start', 'info')
    console.time('screenshot')
    await takeScreenshot(
      `${saveStepCounter++}__${label}`,
      { screenDirectoryFlag: true }
    )
    console.timeEnd('screenshot')
  }

  const shouldMatchScreenshot = async (label, tolerance) => {
    await delay(2 * DELAY)
    const filePath = `${SCREEN_DIR}/${label}.png`

    if (!existsSync(filePath)) {
      await takeScreenshot(label, { fullQuality: true })
      /**
       * As there is no screenshot to compare
       * we save the screen and return true
       */
      log('Base image of visual regression testing is saved', 'info')

      return log('You need to run the test once again to generate the second image', 'info')
    }
    const compareLabel = `${label}.to.compare`
    const compareFilePath = `${SCREEN_DIR}/${compareLabel}.png`

    if (existsSync(compareFilePath)) {
      unlinkSync(compareFilePath)
    }
    await takeScreenshot(compareLabel, { fullQuality: true })
    log('Second image of visual regression testing is saved', 'info')

    return tolerance === undefined
      ? log(`Run 'node compare ${label}' to complete visual regression testing`, 'success')
      : log(`Run 'node compare ${label} ${tolerance}' to complete visual regression testing`, 'success')
  }

  const shouldMatchSnapshot = async (label) => {
    const baseFilePath = `${STEPS_SCREEN_DIR}/${label}.html`
    const toCompareFilePath = `${STEPS_SCREEN_DIR}/${label}.to.compare.html`
    const isCompareBranch = xistsSync(toCompareFilePath)
    const html = await page.content()

    if (isCompareBranch) {
      unlinkSync(compareFilePath)
    } else {
      writeFileSync(baseFilePath, html)

      return log(`Base html file with label '${label}' created`, 'success')
    }

    log(`To compare html file with label '${label}' created`, 'success')
    log(`Run command 'node htmlCompare ${label}' to compare files`, 'info')
    writeFileSync(toCompareFilePath, html)
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
    saveStep,
    selectFirstAvailableDay,
    selectWithTab,
    setInput,
    shouldMatchSnapshot,
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
