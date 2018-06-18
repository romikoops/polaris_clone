import { launch } from 'puppeteer'
import { getSettings } from './getSettings'

export async function init (input) {
  try {
    const settings = getSettings(input)
    const browser = await launch(settings)
    const page = await browser.newPage()

    await page.setViewport({
      height: input.resolution.y,
      width: input.resolution.x
    })

    return { browser, page }
  } catch (err) {
    throw err
  }
}
