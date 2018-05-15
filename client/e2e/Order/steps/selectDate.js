export const DATE_INPUT = 'input[placeholder="DD/MM/YYYY"]'

export default async function selectDate (puppeteer, expect) {
  expect(await puppeteer.selectFirstAvailableDay(DATE_INPUT)).toBeTruthy()
}
