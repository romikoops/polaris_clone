export default async function selectOriginDestination (puppeteer) {
  await puppeteer.focus('body')
  await puppeteer.selectWithTab(3)
  await puppeteer.selectWithTab(7)
}
