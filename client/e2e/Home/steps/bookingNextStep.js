import { BOOKING_LOADED } from '../selectors'

export default async function bookingNextStep (puppeteer, expect) {
  const {
    click,
    waitFor
  } = puppeteer

  /**
   * Click and wait for next step
   */
  await click('button', 'last')
  expect(await waitFor(BOOKING_LOADED, 2)).toBeTruthy()
}
