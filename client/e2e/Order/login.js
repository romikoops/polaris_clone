import { DEMO_USER, DEMO_PASSWORD } from '../_modules/constants'

const loginButton = 'layout-fill layout-row layout-align-space-around-center'

const BUTTONS = 'button > div'
const LOGIN_BUTTON = `div[class="${loginButton}"]`
const LOGIN_LINK_HOME = '.pointy a'
const PASSWORD = 'input[name="password"]'
const USER = 'input[name="email"]'
const ACCOUNT_PAGE_LOADED = `i.fa-tachometer`

export default async function login (puppeteer) {
  const {
    click,
    count,
    exists,
    fill,
    page,
    waitForSelectors,
    saveStep,
    url
  } = puppeteer
  await saveStep('login.0')

  /**
   * There are several buttons
   */
  expect(await count(BUTTONS)).toBeGreaterThan(1)

  /**
   * Click on home login link
   */
  expect(await exists(LOGIN_LINK_HOME)).toBeTruthy()
  expect(await click(LOGIN_LINK_HOME)).toBeTruthy()
  await saveStep('login.1')

  /**
   * Fill username and password
   * Click submit form
   */
  expect(await waitForSelectors(USER, PASSWORD)).toBeTruthy()
  await fill(USER, DEMO_USER)
  await fill(PASSWORD, DEMO_PASSWORD)
  await click(LOGIN_BUTTON)
  await saveStep('login.2')

  /**
   *  Wait for navigation change
   */
  await page.waitForSelector(ACCOUNT_PAGE_LOADED)
  expect(await exists(ACCOUNT_PAGE_LOADED)).toBeTruthy()

  const currentURL = await url()
  expect(currentURL.endsWith('/account')).toBeTruthy()
  await saveStep('login.3')
}
