/**
 * Selectors defining end of navigation change
 */
const BOOKING_LOADED = '.flex-85'
const DETAILS_LOADED = 'i.fa-truck'
const OFFERS_LOADED = 'input[type="range"]'

const EXPORT_IMPORT = 'p.flex-none'
const ITEMS_OR_CONTAINERS = 'div.layout-column'
const DATE_INPUT = 'input[placeholder="DD/MM/YYYY"]'
const CONFIRM = { selector: 'i.fa-check', index: 'last' }

export default async function order (puppeteer, expect) {
  const {
    click,
    clickWithText,
    focus,
    page,
    selectWithTab,
    selectFirstAvailableDay,
    url,
    waitFor
  } = puppeteer

  /**
   * Click on 'Find Rates' and wait for navagation change
   */
  await click('button', 'last')
  expect(await waitFor(BOOKING_LOADED, 2)).toBeTruthy()

  /**
   * Click on 'Export'
   */
  expect(await clickWithText(EXPORT_IMPORT, 'Export')).toBeTruthy()

  /**
   * Click on 'Ocean FCL & Rail FCL'
   */
  expect(await clickWithText(ITEMS_OR_CONTAINERS, 'FCL')).toBeTruthy()

  /**
   * Click on 'Next Step' and wait for navagation change
   */
  expect(await clickWithText('button', 'Next Step')).toBeTruthy()
  await page.waitForSelector(DETAILS_LOADED)

  const currentURL = await url()
  expect(currentURL.endsWith('shipment_details')).toBeTruthy()

  /**
   * Select origin and destination
   */
  await focus('body')
  await selectWithTab(3)
  await selectWithTab(7)

  /**
   * Select date
   */
  expect(await selectFirstAvailableDay(DATE_INPUT)).toBeTruthy()

  /**
   * Set net weight
   */
  await focus('body')
  await selectWithTab(14, 'Up')

  /**
   * Click on confirm no dangereous goods
   */
  expect(await click(CONFIRM)).toBeTruthy()

  /**
   * Click on 'Get Offers' and wait for navigation change
   */
  expect(await clickWithText('p', 'Get Offers')).toBeTruthy()
  await page.waitForSelector(OFFERS_LOADED)

  const offersURL = await url()
  expect(offersURL.endsWith('choose_offer')).toBeTruthy()
}
