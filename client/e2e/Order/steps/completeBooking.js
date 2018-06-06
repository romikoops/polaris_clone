import { delay } from '../../_modules/delay'

const CHECK_ICON = 'i.fa-check'
const THANK_YOU_LOADED = {
  text: 'Thank you for your booking request.',
  selector: 'p.flex-100'
}

export default async function completeBooking (puppeteer) {
  await delay(3000)
  expect(await puppeteer.click(CHECK_ICON, 'last')).toBeTruthy()
  expect(await puppeteer.clickWithText('p', 'Finish Booking Request')).toBeTruthy()

  /**
   * TODO: it doesn't wait for text, still there is no `false` returned
   */
  expect(await puppeteer.waitForText(THANK_YOU_LOADED)).toBeTruthy()

  await puppeteer.takeScreenshot('thank.you')
  const thankYouURL = await puppeteer.url()
  expect(thankYouURL.endsWith('thank_you')).toBeTruthy()
}
