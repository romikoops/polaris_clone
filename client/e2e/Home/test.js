/* eslint vars-on-top: "off", no-var: "off",
no-ex-assign: "off", block-scoped-var: "off", "no-console": "off" */
import init from '../_modules/init'
import login from './steps/login'
import { BASE_URL } from '../_modules/constants'
import { delay } from '../_modules/delay'

const options = {
  headless: false,
  logFlag: false,
  screenOnError: 'LOCAL',
  url: BASE_URL
}

test('successful login', async () => {
  try {
    var puppeteer = await init(options)

    await login(puppeteer, expect)
    await delay(1000)

    await puppeteer.browser.close()
  } catch (e) {
    console.log(e)
    console.log(puppeteer.onError())
    console.log(await puppeteer.catchError({}))
  }
})
