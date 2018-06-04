export const getSettings = (input) => {
  const args = [
    '--no-first-run',
    '--disable-sync',
    '--disable-gpu',
    '--disable-translate',
    '--disable-background-networking',
    '--single-process',
    '--ignore-certificate-errors',
    `--window-size=${input.resolution.x},${input.resolution.y}`,
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--shm-size=1G'
  ]

  return {
    args,
    handleSIGINT: false,
    headless: input.headless
  }
}
