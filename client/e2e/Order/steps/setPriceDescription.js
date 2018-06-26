export default async function setPriceDescription (puppeteer) {
  await puppeteer.saveStep('setPriceDescription.0')

  /**
   * Set price of goods
   */
  await puppeteer.focus('body')
  await puppeteer.selectWithTab(1, 'Up')

  /**
   * Set description of goods
   */
  await puppeteer.inputWithTab(2, 'foo')
  await puppeteer.saveStep('setPriceDescription.1')
}
