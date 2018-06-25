const SHIPMENT_DETAILS_LOADED = 'i.fa-truck'

export default async function clickNextStep (puppeteer) {
  await puppeteer.saveStep('clickNextStep.0')
  expect(await puppeteer.clickWithText('button', 'Next Step')).toBeTruthy()
  await puppeteer.page.waitForSelector(SHIPMENT_DETAILS_LOADED)

  const currentURL = await puppeteer.url()
  expect(currentURL.endsWith('shipment_details')).toBeTruthy()
  await puppeteer.saveStep('clickNextStep.1')
}
