import { DEMO_USER, DEMO_PASSWORD } from '../_modules/constants'

const loginButton = 'layout-fill layout-row layout-align-space-around-center'

const BUTTONS = 'button > div'
const LOGIN_BUTTON = `div[class="${loginButton}"]`
const LOGIN_LINK_HOME = 'div.flex-70 a'
const PASSWORD = 'input[name="password"]'
const USER = 'input[name="email"]'
const ACCOUNT_PAGE_LOADED = `i.fa-tachometer`

export default async function login (puppeteer, expect) {
  const {
    click,
    count,
    exists,
    fill,
    page,
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
