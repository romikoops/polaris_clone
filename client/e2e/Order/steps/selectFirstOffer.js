export const FINAL_DETAILS_LOADED = 'h1'

export default async function selectFirstOffer (puppeteer, expect) {
  expect(await puppeteer.clickWithText('p', 'Choose')).toBeTruthy()
  await puppeteer.page.waitForSelector(FINAL_DETAILS_LOADED)

  const finalDetailsURL = await puppeteer.url()
  expect(finalDetailsURL.endsWith('final_details')).toBeTruthy()
}
