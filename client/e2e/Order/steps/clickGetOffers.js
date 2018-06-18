const CHOOSE_OFFER_LOADED = {
  selector: 'h3.flex-none',
  index: 4,
  text: 'departure'
}

export default async function clickGetOffers (puppeteer) {
  expect(await puppeteer.clickWithText('p', 'Get Offers')).toBeTruthy()
  expect(await puppeteer.waitForText(CHOOSE_OFFER_LOADED)).toBeTruthy()

  const offersURL = await puppeteer.url()
  expect(offersURL.endsWith('choose_offer')).toBeTruthy()
}
