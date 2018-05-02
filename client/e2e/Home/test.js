/* eslint vars-on-top: "off", no-var: "off",
no-ex-assign: "off", block-scoped-var: "off", "no-console": "off" */
import init from '../_modules/init'
import { BASE_URL } from '../_modules/constants'
import { delay } from '../_modules/delay'

import login from './steps/login'
import order from './steps/order'

const options = {
  headless: false,
  log: true,
  screenOnError: 'LOCAL',
  url: BASE_URL
}

test('successful login', async () => {
  try {
    var puppeteer = await init(options)

    /**
     * Login as demo user
     */
    await login(puppeteer, expect)

    /**
     * Place an order as a seller
     */
    await order(puppeteer, expect)

    await delay(3000)
    await puppeteer.browser.close()
  } catch (e) {
    console.log(e)
    console.log(puppeteer.onError())
    console.log(await puppeteer.catchError({}))
  }
})
