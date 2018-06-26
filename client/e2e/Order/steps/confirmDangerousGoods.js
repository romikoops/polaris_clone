const CONFIRM_DANGEROUS_GOODS = { selector: 'i.fa-check', index: 'last' }

export default async function confirmDangerousGoods (puppeteer) {
  await puppeteer.saveStep('confirmDangerousGoods')
  expect(await puppeteer.click(CONFIRM_DANGEROUS_GOODS)).toBeTruthy()
}
