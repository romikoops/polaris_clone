export default async function selectTypeSizeWeight (puppeteer) {
  await puppeteer.saveStep('selectTypeSizeWeight.0')

  await puppeteer.selectWithTab(13)
  await puppeteer.selectWithTab(1, 'Up')
  await puppeteer.selectWithTab(1, 'Up')
  await puppeteer.selectWithTab(1, 'Up')
  await puppeteer.selectWithTab(1, 'Up')
  await puppeteer.selectWithTab(1, 'Up')
  await puppeteer.saveStep('selectTypeSizeWeight.1')
}
