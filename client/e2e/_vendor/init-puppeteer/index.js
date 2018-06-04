import * as common from './common'

import { takeScreenshot } from './takeScreenshot'
import { init } from './init'

function defaultTo (defaultArgument, inputArgument) {
  return inputArgument === undefined || inputArgument === null || Number.isNaN(inputArgument) === true
    ? defaultArgument
    : inputArgument
}

const defaultURL = 'about:blank'
const webpackURL = 'http://localhost:8080'
const defaultResolution = { x: 1366, y: 768 }

const defaultInput = {
  headless: true,
  logFlag: false,
  resolution: defaultResolution,
  screenOnError: 'OFF',
  url: defaultURL,
  waitCondition: common.waitForNetwork
}

function getWait (
  url,
  waitCondition
) {
  const urlFlag = url === defaultURL
    ? common.waitForTimeout(common.SHORT_TIMEOUT)
    : url === webpackURL
      ? common.waitForTimeout(common.TIMEOUT)
      : false

  if (urlFlag === false && waitCondition === undefined) {
    return common.waitForNetwork
  }

  if (typeof waitCondition === 'string') {
    const conditionMap = {
      DOM: 'domcontentloaded',
      LOAD: 'load',
      NETWORK: 'networkidle0'
    }

    const answer = conditionMap[waitCondition] === undefined

    const condition = answer
      ? 'load'
      : conditionMap[waitCondition]

    return common.getWaitCondition(condition)
  }

  return waitCondition
}

export async function initPuppeteer (inputRaw) {
  try {
    var input = {
      ...defaultInput,
      ...defaultTo({}, inputRaw)
    }

    var { browser, page } = await init(input)

    const wait = getWait(input.url, input.waitCondition)

    await page.goto(input.url, wait)

    if (input.logFlag) {
      page.on('console', log)
    }

    const catchError = async (e) => {
      if (page !== undefined && page.close !== undefined) {
        e.screen = await takeScreenshot(
          page,
          input.screenOnError
        )

        await browser.close()
      }

      return e
    }

    return {
      browser,
      catchError,
      page
    }
  } catch (error) {
    if (page !== undefined && page.close !== undefined) {
      error.screen = await takeScreenshot(page, input.screenOnError)

      await browser.close()
    }

    throw error
  }
}

function log (input) {
  if (input._type === 'log') {
    console.log(input._text)
  }
}
