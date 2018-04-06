import { initPuppeteer } from 'init-puppeteer'
import { BASE_URL } from '../_modules/constants'
import { buttonsSelector } from './selectors'
import { getTextContents } from './evaluations'

test('buttons on home page', async () => {
  try {
    var { browser, page, catchError } = await initPuppeteer({
      headless: false,
      screenOnError:'LOCAL',
      url: BASE_URL,
    })

    const buttons = await page.$$eval(buttonsSelector, getTextContents)
    const expectedButtons = [ 'Book Now', 'Read More', 'Read More', 'Read More', 'Book Now' ]

    expect(buttons).toEqual(expectedButtons)

    await browser.close()
  } catch (e) {
    e = await catchError(e)
    console.log(e)
  }
})

