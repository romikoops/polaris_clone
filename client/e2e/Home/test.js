/* eslint vars-on-top: "off", no-var: "off",
no-ex-assign: "off", block-scoped-var: "off", "no-console": "off" */
import open from 'open'
import init from '../_modules/init'
import { BASE_URL } from '../_modules/constants'

import login from './steps/login'
import order from './steps/order'
import orderCase1 from './steps/orderCase1'

const options = {
  headless: false,
  log: false,
  screenOnError: 'LOCAL',
  url: BASE_URL
}

test.skip('successful login and placing an order - case 1', async () => {
  try {
    var puppeteer = await init(options)

    /**
     * Login as demo user
     */
    await login(puppeteer, expect)

    /**
     * Place an order as a seller
     */
    await orderCase1(puppeteer, expect)
    await puppeteer.browser.close()
  } catch (e) {
    console.log(e)
    console.log(await puppeteer.catchError({}))
    puppeteer.onError()
  }
})

test('successful login and placing an order - case 0', async () => {
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
    await puppeteer.browser.close()
  } catch (e) {
    const { screen } = await puppeteer.catchError({})
    open(screen)

    console.log(e, screen)
    puppeteer.onError()
  }
})
