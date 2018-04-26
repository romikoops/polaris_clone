/* eslint vars-on-top: "off", no-var: "off",
no-ex-assign: "off", block-scoped-var: "off", "no-console": "off" */
import { BASE_URL, DEMO_USER, DEMO_PASSWORD } from '../_modules/constants'
import {
  BUTTONS,
  LOGIN_LINK_FORM,
  LOGIN_LINK_HOME,
  USER, PASSWORD,
  LOGIN_BUTTON
} from './selectors'
import init from '../_modules/init'
import { delay } from '../_modules/delay'

test('buttons on home page', async () => {
  try {
    var {
      browser,
      catchError,
      click,
      count,
      exists,
      fill,
      page,
      waitFor,
      waitForSelectors
    } = await init({
      headless: false,
      logFlag: true,
      screenOnError: 'LOCAL',
      url: BASE_URL
    })

    /**
     * There are several buttons
     */
    expect(await count(BUTTONS)).toBeGreaterThan(4)

    /**
     * Click on home login link
     */
    expect(await exists(LOGIN_LINK_HOME)).toBeTruthy()
    await click(LOGIN_LINK_HOME)

    /**
     * Click on login link within the form
     */
    expect(await waitFor(LOGIN_LINK_FORM, 2)).toBeTruthy()
    const [, loginDiv] = await page.$$(LOGIN_LINK_FORM)
    await loginDiv.click()
    await loginDiv.dispose()

    /**
     * Fill username and password
     */
    expect(await waitForSelectors(USER, PASSWORD)).toBeTruthy()
    await fill(USER, DEMO_USER)
    await fill(PASSWORD, DEMO_PASSWORD)
    await click(LOGIN_BUTTON)

    await delay(1000)

    await browser.close()
  } catch (e) {
    e = await catchError(e)
    console.log(e)
  }
})
