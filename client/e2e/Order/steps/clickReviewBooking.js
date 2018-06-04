const FINISH_BOOKING_LOADED = 'i.fa-ship'

export default async function clickReviewBooking (puppeteer) {
  expect(await puppeteer.clickWithText('p', 'Review Booking')).toBeTruthy()
  await puppeteer.page.waitForSelector(FINISH_BOOKING_LOADED)

  expect(await puppeteer.shouldMatchScreenshot('review.booking', 110)).toBeTruthy()
}
