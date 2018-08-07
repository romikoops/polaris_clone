import init from '../_modules/init'
import { BASE_URL } from '../_modules/constants'

import login from './login'
import orderExportFCL from './orderExportFCL'
import orderExportLCL from './orderExportLCL'

const options = {
  headless: process.env.PUPPETEER_HEADLESS === 'true',
  log: false,
  slowMo: 250,
  url: BASE_URL
}

test.only('successful login and placing an export LCL order', async () => {
  try {
    const puppeteer = await init(options)

    /**
     * Login as demo user
     */
    await login(puppeteer)

    /**
     * Place an order as a seller
     */
    await orderExportLCL(puppeteer)
    await puppeteer.browser.close()
  } catch (e) {
    console.log(e)
  }
})

test('successful login and placing an export FCL order', async () => {
  try {
    const puppeteer = await init(options)

    /**
     * Login as demo user
     */
    await login(puppeteer)

    /**
     * Place an order as a seller
     */
    await orderExportFCL(puppeteer)
    await puppeteer.browser.close()
  } catch (e) {
    console.log(e)
  }
})
