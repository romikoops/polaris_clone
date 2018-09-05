import { EXPORT_IMPORT, ITEMS_OR_CONTAINERS } from '../_modules/constants'

import bookingNextStep from './steps/bookingNextStep'
import chooseSenderReceiver from './steps/chooseSenderReceiver'
import clickGetOffers from './steps/clickGetOffers'
import clickNextStep from './steps/clickNextStep'
import clickReviewBooking from './steps/clickReviewBooking'
import confirmDangerousGoods from './steps/confirmDangerousGoods'
import completeBooking from './steps/completeBooking'
import selectDate from './steps/selectDate'
import selectFirstOffer from './steps/selectFirstOffer'
import selectOriginDestination from './steps/selectOriginDestination'
import selectTypeSizeWeight from './steps/selectTypeSizeWeight'
import setPriceDescription from './steps/setPriceDescription'

export default async function orderExportLCL (puppeteer) {
  const { clickWithPartialText } = puppeteer

  /**
   * Click booking's next step
   */
  await bookingNextStep(puppeteer)

  /**
   * Click on 'Export'
   */
  expect(await clickWithPartialText(EXPORT_IMPORT, 'Export')).toBeTruthy()

  /**
   * Click on 'Air, Ocean LCL & Rail LCL'
   */
  expect(await clickWithPartialText(ITEMS_OR_CONTAINERS, 'LCL')).toBeTruthy()

  /**
   * Click next step and wait for navigation change
   */
  await clickNextStep(puppeteer)

  /**
   * Select origin and destination
   */
  await selectOriginDestination(puppeteer)

  /**
   * Select colli type, set size and weight
   */
  await selectTypeSizeWeight(puppeteer)

  /**
  * Select date
  */
  await selectDate(puppeteer, expect)

  /**
   * Click on confirm no dangerous goods
   */
  await confirmDangerousGoods(puppeteer, expect)

  /**
   * Click get offers and wait for navigation change
   */
  await clickGetOffers(puppeteer, expect)

  /**
   * Select first offer and wait for navigation change
   */
  await selectFirstOffer(puppeteer, expect)

  /**
   * Select first sender and first receiver
   */
  await chooseSenderReceiver(puppeteer, expect)

  /**
   * Set price and description of goods
   */
  await setPriceDescription(puppeteer)

  /**
   * Click review booking
   */
  // await clickReviewBooking(puppeteer, expect)

  /**
   * Click review booking and complete the test
   */
  // await completeBooking(puppeteer, expect)
}
