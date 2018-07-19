import { delay } from '../../_modules/delay'

const LONG_DELAY = 10000
const SELECTOR = '#origin'
const ORIGIN = 'Gothenburg'

/**
 * Two versions are kept as UI often change between the two behaviours
 */

export default async function selectOriginDestination (puppeteer) {
  const {
    focus,
    saveStep,
    selectWithTab,
    shouldMatchHTML,
    shouldMatchScreenshot
  } = puppeteer
  await saveStep('selectOriginDestinationWithClick.0')

  await focus('body')
  await selectWithTab(2)
  await selectWithTab(7)

  await saveStep('selectOriginDestinationWithClick.1')
  await shouldMatchScreenshot('booking.summary')
  await shouldMatchHTML('booking.summary')
}

/**
 * When the user needs to click on origin to select it
 */
export async function selectOriginDestinationWithClick (puppeteer) {
  const {
    $,
    focus,
    page,
    saveStep,
    selectWithTab
  } = puppeteer
  await saveStep('selectOriginDestinationWithClick.0')

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
  await selectWithTab(7)
  await saveStep('selectOriginDestinationWithClick.1')
}
