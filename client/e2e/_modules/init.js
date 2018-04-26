import { initPuppeteer } from 'init-puppeteer'
import { delay } from './delay'

const DELAY = Number(process.env.STEP_DELAY || '0')

export default async function init (options) {
  const { page, browser, catchError } = await initPuppeteer(options)

  const $ = async (...input) => {
    const result = await page.$eval(...input)
    await delay(DELAY)

    return result
  }

  const $$ = async (...input) => {
    const result = await page.$$eval(...input)
    await delay(DELAY)

    return result
  }

  const waitFor = async (selector, count = 1) => {
    let counter = 10
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
    const promised = selectors.map(singleSelector => waitFor(singleSelector))
    const result = await Promise.all(promised)

    return !result.includes(false)
  }

  const click = selector => $(selector, el => el.click())
  const focus = selector => $(selector, el => el.focus())
  const count = selector => page.$$eval(selector, els => els.length)
  const exists = selector => page.$$eval(selector, els => els.length > 0)

  const fill = async (selector, text) => {
    await focus(selector)
    await page.keyboard.type(text, { delay: 50 })
  }

  return {
    $$,
    $,
    browser,
    catchError,
    click,
    count,
    exists,
    fill,
    page,
    waitFor,
    waitForSelectors
  }
}
