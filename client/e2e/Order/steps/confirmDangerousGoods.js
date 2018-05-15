const CONFIRM_DANGEROUS_GOODS = { selector: 'i.fa-check', index: 'last' }

export default async function confirmDangerousGoods (puppeteer, expect) {
  expect(await puppeteer.click(CONFIRM_DANGEROUS_GOODS)).toBeTruthy()
}
