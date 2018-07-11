const DATE_INPUT = 'input[placeholder="DD/MM/YYYY"]'

export default async function selectDate (puppeteer) {
  await puppeteer.saveStep('selectDate')
  await puppeteer.shouldMatchScreenshot('select.date')

  expect(await puppeteer.selectFirstAvailableDay(DATE_INPUT)).toBeTruthy()
}
