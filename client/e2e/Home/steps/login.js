import {
  BUTTONS,
  LOGIN_LINK_FORM,
  LOGIN_LINK_HOME,
  ACCOUNT_PAGE_LOADED,
  USER, PASSWORD,
  LOGIN_BUTTON
} from '../selectors'
import { DEMO_USER, DEMO_PASSWORD } from '../../_modules/constants'

export default async function login (puppeteer, expect) {
  const {
    click,
    count,
    exists,
    fill,
    page,
    waitFor,
    waitForSelectors,
    url
  } = puppeteer

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
     * Click submit form
     */
  expect(await waitForSelectors(USER, PASSWORD)).toBeTruthy()
  await fill(USER, DEMO_USER)
  await fill(PASSWORD, DEMO_PASSWORD)
  await click(LOGIN_BUTTON)

  /**
   *  Wait for navigation change
   */
  await page.waitForSelector(ACCOUNT_PAGE_LOADED)
  expect(await exists(ACCOUNT_PAGE_LOADED)).toBeTruthy()

  const currentURL = await url()
  expect(currentURL.endsWith('/account')).toBeTruthy()
}
