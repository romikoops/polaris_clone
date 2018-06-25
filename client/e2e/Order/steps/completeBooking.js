import { delay } from '../../_modules/delay'

const CHECK_ICON = 'i.fa-check'
const THANK_YOU_LOADED = {
  text: 'Thank you for your booking request.',
  selector: 'p.flex-100'
}

export default async function completeBooking (puppeteer) {
  await puppeteer.saveStep('completeBooking.0')
  expect(await puppeteer.click(CHECK_ICON, 'last')).toBeTruthy()
  expect(await puppeteer.clickWithText('p', 'Finish Booking Request')).toBeTruthy()

  expect(await puppeteer.waitForText(THANK_YOU_LOADED)).toBeTruthy()
  await puppeteer.saveStep('completeBooking.1')

  /**
   * Previous step confirm that we are landing on `thank_you` page
   * but without delay, we'll see the loading animation
   */
  await delay(10000)
  const thankYouURL = await puppeteer.url()
  expect(thankYouURL.endsWith('thank_you')).toBeTruthy()
  await puppeteer.saveStep('completeBooking.2')
}
