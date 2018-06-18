export default async function setWeight (puppeteer) {
  await puppeteer.saveStep('setWeight.0')

  await puppeteer.focus('body')
  await puppeteer.selectWithTab(14, 'Up')
  await puppeteer.saveStep('setWeight.1')
}
