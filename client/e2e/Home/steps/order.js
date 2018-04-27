const BOOKING_LOADED = '.flex-85'
const DETAILS_LOADED = 'i.fa-truck'
const EXPORT_IMPORT = 'p.flex-none'
const ITEMS_OR_CONTAINERS = 'div.layout-column'

export default async function order (puppeteer, expect) {
  const {
    click,
    clickWithText,
    focus,
    page,
    selectWithTab,
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
}
