export default async function selectOriginDestination (puppeteer) {
  const {
    focus,
    selectWithTab
  } = puppeteer

  await focus('body')
  await selectWithTab(3)
  await selectWithTab(7)
}
