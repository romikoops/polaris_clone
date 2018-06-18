export default async function setWeight (puppeteer) {
  await puppeteer.focus('body')
  await puppeteer.selectWithTab(14, 'Up')
}
