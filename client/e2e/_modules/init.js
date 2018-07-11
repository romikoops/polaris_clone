import path from 'path'
import { existsSync, unlinkSync } from 'fs'
import { log } from 'log'

import { delay } from './delay'
import { initPuppeteer } from '../_vendor/init-puppeteer'
import { isDocker } from '../_modules/isDocker'

const SCREEN_DIR = path.resolve(__dirname, '../node_modules')
const STEPS_SCREEN_DIR = path.resolve(__dirname, '../_screens')
const STEP_DELAY = Number(process.env.STEP_DELAY || '0')
const DELAY = 250

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

    return counted >= countValue
  }

  const waitForSelectors = async (...selectors) => {
    mark('waitForSelectors', `[${selectors.toString()}]`)

    const promised = selectors.map(singleSelector => waitFor(singleSelector))
    const result = await Promise.all(promised)

    return !result.includes(false)
  }

  /**
   * It waits 20 seconds for selector with specified index contains specified text
   */
  const waitForText = async (input) => {
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

  const takeScreenshot = async (label, screenDirectoryFlag) => {
    const screenDirectory = screenDirectoryFlag
      ? STEPS_SCREEN_DIR
      : SCREEN_DIR

    const screenshotPath = `${screenDirectory}/${label}.png`

    if (existsSync(screenshotPath)) {
      unlinkSync(screenshotPath)
    }
    await page.screenshot({
      fullPage: true,
      path: screenshotPath
    })

    return screenshotPath
  }
  const saveStep = async (label) => {
    if (!isDocker()) {
      return
    }
    await takeScreenshot(label, true)
  }

  const shouldMatchScreenshot = async (label, tolerance) => {
    await delay(2 * DELAY)
    const filePath = `${SCREEN_DIR}/${label}.png`

    if (!existsSync(filePath)) {
      await takeScreenshot(label)
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
    await takeScreenshot(compareLabel)
    log('Second image of visual regression testing is saved', 'info')

    return tolerance === undefined
      ? log(`Run 'node compare ${label}' to complete visual regression testing`, 'success')
      : log(`Run 'node compare ${label} ${tolerance}' to complete visual regression testing`, 'success')
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
