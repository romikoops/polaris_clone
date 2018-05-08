import bookingNextStep from './bookingNextStep'

/**
 * Selectors defining end of navigation change
 */
const DETAILS_LOADED = 'i.fa-truck'
const OFFERS_LOADED = 'input[type="range"]'

const EXPORT_IMPORT = 'p.flex-none'
const ITEMS_OR_CONTAINERS = 'div.layout-column'
const DATE_INPUT = 'input[placeholder="DD/MM/YYYY"]'
const CONFIRM = { selector: 'i.fa-check', index: 'last' }

export default async function order (puppeteer, expect) {
  const {
    $,
    click,
    clickWithPartialText,
    clickWithText,
    focus,
    page,
    selectWithTab,
    selectFirstAvailableDay,
    url
  } = puppeteer

  /**
   * Click booking's next step
   */
  await bookingNextStep(puppeteer, expect)

  /**
   * Click on 'Export'
   */
  expect(await clickWithPartialText(EXPORT_IMPORT, 'Export')).toBeTruthy()

  /**
   * Click on 'Air, Ocean LCL & Rail LCL'
   */
  expect(await clickWithPartialText(ITEMS_OR_CONTAINERS, 'LCL')).toBeTruthy()

  /**
   * Click and wait for next step
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
   * Select colli type, set size and weight
   */
  await selectWithTab(14)
  await selectWithTab(1, 'Up')
  await selectWithTab(1, 'Up')
  await selectWithTab(1, 'Up')
  await selectWithTab(1, 'Up')
  await selectWithTab(1, 'Up')

  /**
  * Select date
  */
  expect(await selectFirstAvailableDay(DATE_INPUT)).toBeTruthy()

  /**
   * Click on confirm no dangerous goods
   */
  expect(await click(CONFIRM)).toBeTruthy()

  /**
   * Click and wait for next step
   */
  expect(await clickWithText('p', 'Get Offers')).toBeTruthy()
  await page.waitForSelector(OFFERS_LOADED)

  const offersURL = await url()
  expect(offersURL.endsWith('choose_offer')).toBeTruthy()

  await $('p.gg', el => el.textContent)
}
