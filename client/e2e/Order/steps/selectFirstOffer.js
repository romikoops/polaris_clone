const FINAL_DETAILS_LOADED = 'h1'

export default async function selectFirstOffer (puppeteer) {
  await puppeteer.saveStep('selectFirstOffer.0')

  expect(await puppeteer.clickWithText('p', 'Choose')).toBeTruthy()
  await puppeteer.page.waitForSelector(FINAL_DETAILS_LOADED)

  const finalDetailsURL = await puppeteer.url()
  expect(finalDetailsURL.endsWith('final_details')).toBeTruthy()
  await puppeteer.saveStep('selectFirstOffer.1')
}
