import bookingNextStep from './bookingNextStep'

/**
 * Selectors defining end of navigation change
 */
const SHIPMENT_DETAILS_LOADED = 'i.fa-truck'
const FINAL_DETAILS_LOADED = 'h1'
const FINISH_BOOKING_LOADED = 'i.fa-ship'
const CHOOSE_OFFER_LOADED = {
  selector: 'h3.flex-none',
  index: 4,
  text: 'departure'
}
const SENDER_LOADED = 'i.fa-pencil-square-o'
const RECEIVER_LOADED = { selector: SENDER_LOADED, count: 2 }

const EXPORT_IMPORT = 'p.flex-none'
const ITEMS_OR_CONTAINERS = 'div.layout-column'
const DATE_INPUT = 'input[placeholder="DD/MM/YYYY"]'
const CONFIRM = { selector: 'i.fa-check', index: 'last' }
const CHOOSE_SENDER = { selector: 'h3', index: 5 }
const SELECT_RECEIVER_SENDER = { selector: 'div[style="padding: 15px;"] > div', index: 1 }
const CHOOSE_RECEIVER = { selector: 'h3', index: 6 }

export default async function order (puppeteer, expect) {
  const {
    click,
    clickWithPartialText,
    clickWithText,
    inputWithTab,
    focus,
    page,
    selectWithTab,
    selectFirstAvailableDay,
    url,
    waitAndClick,
    waitFor,
    waitForText
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
   * Click on 'Ocean FCL & Rail FCL'
   */
  expect(await clickWithPartialText(ITEMS_OR_CONTAINERS, 'FCL')).toBeTruthy()

  /**
   * Click and wait for next step
   */
  expect(await clickWithText('button', 'Next Step')).toBeTruthy()
  await page.waitForSelector(SHIPMENT_DETAILS_LOADED)

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
   * Click on confirm no dangerous goods
   */
  expect(await click(CONFIRM)).toBeTruthy()

  /**
   * Click and wait for next step
   */
  expect(await clickWithText('p', 'Get Offers')).toBeTruthy()
  expect(await waitForText(CHOOSE_OFFER_LOADED)).toBeTruthy()

  const offersURL = await url()
  expect(offersURL.endsWith('choose_offer')).toBeTruthy()

  /**
   * Select first offer and wait for navigation change
   */
  expect(await clickWithText('p', 'Choose')).toBeTruthy()
  await page.waitForSelector(FINAL_DETAILS_LOADED)

  const finalDetailsURL = await url()
  expect(finalDetailsURL.endsWith('final_details')).toBeTruthy()

  /**
   * Click on 'Choose a sender' and select first sender
   */
  expect(await click(CHOOSE_SENDER)).toBeTruthy()
  expect(await waitAndClick(SELECT_RECEIVER_SENDER)).toBeTruthy()
  expect(await waitFor(SENDER_LOADED)).toBeTruthy()

  /**
   * Click on 'Choose a receiver' and select first receiver
   */
  expect(await click(CHOOSE_RECEIVER)).toBeTruthy()
  expect(await waitAndClick(SELECT_RECEIVER_SENDER)).toBeTruthy()
  expect(await waitFor(RECEIVER_LOADED)).toBeTruthy()

  /**
   * Set price of goods
   */
  await focus('body')
  await selectWithTab(1, 'Up')

  /**
   * Set description of goods
   */
  await inputWithTab(2, 'foo')

  /**
   * Click and wait for next step
   */
  expect(await clickWithText('p', 'Review Booking')).toBeTruthy()
  await page.waitForSelector(FINISH_BOOKING_LOADED)

  const finishBookingURL = await url()
  expect(finishBookingURL.endsWith('finish_booking')).toBeTruthy()
}
