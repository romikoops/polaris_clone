import { resolve } from 'path'

const SCREENS_DIR = resolve(
  __dirname,
  '../../node_modules'
)

export async function takeScreenshot (
  page,
  screenOnError
) {
  try {
    if (screenOnError === 'OFF') {
      return 'OFF'
    }

    const screenshotPath = `${SCREENS_DIR}/${Date.now()}.png`
    await page.screenshot({
      fullPage: true,
      path: screenshotPath
    })

    return screenshotPath
  } catch (err) {
    throw err
  }
}
