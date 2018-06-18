export function isDocker () {
  return process.env.PUPPETEER_HEADLESS === 'true'
}
