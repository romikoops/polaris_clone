const FINISH_BOOKING_LOADED = 'i.fa-ship'

export default async function clickReviewBooking (puppeteer) {
  expect(await puppeteer.clickWithText('p', 'Review Booking')).toBeTruthy()
  expect(await puppeteer.page.waitForSelector(FINISH_BOOKING_LOADED)).toBeTruthy()
  // await puppeteer.shouldMatchScreenshot('review.booking', 110)

  // const finishBookingURL = await puppeteer.url()
  // expect(finishBookingURL.endsWith('finish_booking')).toBeTruthy()
}
