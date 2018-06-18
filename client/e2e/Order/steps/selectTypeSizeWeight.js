export default async function selectTypeSizeWeight (puppeteer) {
  await puppeteer.selectWithTab(14)
  await puppeteer.selectWithTab(1, 'Up')
  await puppeteer.selectWithTab(1, 'Up')
  await puppeteer.selectWithTab(1, 'Up')
  await puppeteer.selectWithTab(1, 'Up')
  await puppeteer.selectWithTab(1, 'Up')
}
