/* eslint vars-on-top: "off", no-var: "off",
no-ex-assign: "off", block-scoped-var: "off", "no-console": "off" */
import open from 'open'
import init from '../_modules/init'
import { BASE_URL } from '../_modules/constants'

import login from './login'
import orderExportFCL from './orderExportFCL'
import orderExportLCL from './orderExportLCL'

const options = {
  headless: false,
  log: false,
  slowMo: 250,
  screenOnError: 'LOCAL',
  url: BASE_URL
}

test('successful login and placing an export LCL order', async () => {
  try {
    var puppeteer = await init(options)

    /**
     * Login as demo user
     */
    await login(puppeteer, expect)

    /**
     * Place an order as a seller
     */
    await orderExportLCL(puppeteer, expect)
    await puppeteer.browser.close()
  } catch (e) {
    const { screen } = await puppeteer.catchError({})

    console.log(e, screen)
    puppeteer.onError()
    open(screen)
  }
})

test('successful login and placing an export FCL order', async () => {
  try {
    var puppeteer = await init(options)

    /**
     * Login as demo user
     */
    await login(puppeteer, expect)

    /**
     * Place an order as a seller
     */
    await orderExportFCL(puppeteer, expect)
    await puppeteer.browser.close()
  } catch (e) {
    const { screen } = await puppeteer.catchError({})

    console.log(e, screen)
    puppeteer.onError()
    open(screen)
  }
})
