export default async function setPriceDescription (puppeteer) {
  /**
   * Set price of goods
   */
  await puppeteer.focus('body')
  await puppeteer.selectWithTab(1, 'Up')

  /**
   * Set description of goods
   */
  await puppeteer.inputWithTab(2, 'foo')
}
