const FINISH_BOOKING_LOADED = {
  selector: 'p[class="flex-none fade"]',
  text: 'Booking Confirmation'
}

export default async function clickReviewBooking (puppeteer) {
  await puppeteer.saveStep('clickReviewBooking.0')

  expect(await puppeteer.clickWithText('p', 'Review Booking')).toBeTruthy()
  expect(await puppeteer.waitForText(FINISH_BOOKING_LOADED)).toBeTruthy()

  // expect(await puppeteer.shouldMatchScreenshot('review.booking', 110)).toBeTruthy()

  const finishBookingURL = await puppeteer.url()
  expect(finishBookingURL.endsWith('finish_booking')).toBeTruthy()
  await puppeteer.saveStep('clickReviewBooking.1')
}
