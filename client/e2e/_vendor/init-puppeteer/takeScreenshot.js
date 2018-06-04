export async function takeScreenshot (
  page,
  screenOnError
) {
  try {
    if (screenOnError === 'OFF') {
      return 'OFF'
    }

    const screenshotPath = `${__dirname}/${Date.now()}.png`
    await page.screenshot({
      fullPage: true,
      path: screenshotPath
    })

    return screenshotPath
  } catch (err) {
    throw err
  }
}
