const BOOKING_LOADED = '.flex-85'

/**
 * Click and wait for next step
 */
export default async function bookingNextStep (puppeteer, expect) {
  await puppeteer.click('button', 'last')
  expect(await puppeteer.waitFor(BOOKING_LOADED, 2)).toBeTruthy()
}
