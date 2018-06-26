const BOOKING_LOADED = '.flex-85'

/**
 * Click and wait for next step
 */
export default async function bookingNextStep (puppeteer) {
  await puppeteer.saveStep('bookingNextStep.0')
  expect(await puppeteer.click('button', 'last')).toBeTruthy()
  expect(await puppeteer.waitFor(BOOKING_LOADED, 2)).toBeTruthy()
  await puppeteer.saveStep('bookingNextStep.1')
}
