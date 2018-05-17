import { delay } from '../../_modules/delay'

const LONG_DELAY = 10000
const SELECTOR = '#origin'
const ORIGIN = 'Gothenburg'

export default async function selectOriginDestination (puppeteer) {
  const {
    $,
    page,
    focus,
    selectWithTab
  } = puppeteer

  await focus('body')
  await selectWithTab(3)

  const coordinates = await $(
    SELECTOR,
    el => JSON.stringify(el.getBoundingClientRect())
  )
  const { x, y } = JSON.parse(coordinates)

  await page.keyboard.type(ORIGIN, { delay: 50 })

  await page.mouse.click(x + 10, y + 40)
  await delay(LONG_DELAY)
  await focus('body')
  await selectWithTab(11)
}
